import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  InstitutionalDonation,
  TransferDeed,
  User,
} from '../database/entities';
import { InstitutionalDonationStatus, UserRole } from '../common/enums';
import { CreateInstitutionalDonationDto } from './dto';
import PDFDocument from 'pdfkit';
import { stripPhoneNumbers } from '../common/utils/phone-filter.util';
import * as crypto from 'crypto';

@Injectable()
export class InstitutionalDonationsService {
  private readonly logger = new Logger(InstitutionalDonationsService.name);

  constructor(
    @InjectRepository(InstitutionalDonation)
    private readonly donationRepository: Repository<InstitutionalDonation>,
    @InjectRepository(TransferDeed)
    private readonly deedRepository: Repository<TransferDeed>,
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /**
   * Create B2A donation announcement (merchant/professional only).
   */
  async create(
    professionalId: string,
    dto: CreateInstitutionalDonationDto,
  ): Promise<InstitutionalDonation> {
    // Verify association exists and has correct role
    const association = await this.userRepository.findOne({
      where: { id: dto.association_id, role: UserRole.ASSOCIATION },
    });

    if (!association) {
      throw new HttpException(
        {
          message_fr: 'Association introuvable ou non vérifiée.',
          message_ar: 'الجمعية غير موجودة أو غير موثقة.',
          error: 'Not Found',
        },
        HttpStatus.NOT_FOUND,
      );
    }

    const donation = this.donationRepository.create({
      professional_id: professionalId,
      association_id: dto.association_id,
      description: dto.description,
      estimated_quantity: dto.estimated_quantity,
      status: InstitutionalDonationStatus.ANNOUNCED,
    });

    return this.donationRepository.save(donation);
  }

  /**
   * Accept donation (association only).
   */
  async accept(
    donationId: string,
    associationId: string,
  ): Promise<InstitutionalDonation> {
    const donation = await this.donationRepository.findOne({
      where: { id: donationId, association_id: associationId },
    });

    if (!donation) {
      throw new HttpException(
        {
          message_fr: 'Don institutionnel introuvable.',
          message_ar: 'التبرع المؤسسي غير موجود.',
          error: 'Not Found',
        },
        HttpStatus.NOT_FOUND,
      );
    }

    if (donation.status !== InstitutionalDonationStatus.ANNOUNCED) {
      throw new HttpException(
        {
          message_fr: 'Ce don ne peut plus être accepté dans son état actuel.',
          message_ar: 'لا يمكن قبول هذا التبرع في حالته الحالية.',
          error: 'Conflict',
        },
        HttpStatus.CONFLICT,
      );
    }

    donation.status = InstitutionalDonationStatus.ACCEPTED;
    return this.donationRepository.save(donation);
  }

  /**
   * Generate transfer deed (bon de cession) — SERVER-SIDE ONLY.
   * PDF generated with hash for integrity verification.
   * liability_transferred_at is set ONLY after explicit signature.
   */
  async generateTransferDeed(donationId: string): Promise<TransferDeed> {
    const donation = await this.donationRepository.findOne({
      where: { id: donationId },
      relations: { professional: true, association: true },
    });

    if (!donation || donation.status !== InstitutionalDonationStatus.ACCEPTED) {
      throw new HttpException(
        {
          message_fr:
            'Le don doit être accepté avant de générer le bon de cession.',
          message_ar: 'يجب قبول التبرع قبل إنشاء وثيقة التنازل.',
          error: 'Conflict',
        },
        HttpStatus.CONFLICT,
      );
    }

    // Generate PDF server-side
    const pdfBuffer = await this.generatePdf(donation);
    const verificationHash = crypto
      .createHash('sha256')
      .update(pdfBuffer)
      .digest('hex');

    // In production, upload to secure storage. For now, store reference.
    const pdfUrl = `/storage/transfer-deeds/${donationId}.pdf`;

    const deed = this.deedRepository.create({
      institutional_donation_id: donationId,
      pdf_url: pdfUrl,
      verification_hash: verificationHash,
    });

    const savedDeed = await this.deedRepository.save(deed);

    // Update donation status
    donation.status = InstitutionalDonationStatus.TRANSFERRED;
    donation.transfer_deed_url = pdfUrl;
    await this.donationRepository.save(donation);

    return savedDeed;
  }

  /**
   * Sign transfer deed — sets liability_transferred_at.
   * This is the legal moment when sanitary liability transfers.
   * NEVER auto-filled.
   */
  async signTransferDeed(
    donationId: string,
    associationId: string,
  ): Promise<InstitutionalDonation> {
    const donation = await this.donationRepository.findOne({
      where: { id: donationId, association_id: associationId },
    });

    if (
      !donation ||
      donation.status !== InstitutionalDonationStatus.TRANSFERRED
    ) {
      throw new HttpException(
        {
          message_fr: 'Le bon de cession doit être généré avant la signature.',
          message_ar: 'يجب إنشاء وثيقة التنازل قبل التوقيع.',
          error: 'Conflict',
        },
        HttpStatus.CONFLICT,
      );
    }

    const deed = await this.deedRepository.findOne({
      where: { institutional_donation_id: donationId },
    });

    if (deed) {
      deed.signed_at = new Date();
      await this.deedRepository.save(deed);
    }

    donation.liability_transferred_at = new Date();
    donation.status = InstitutionalDonationStatus.COMPLETED;
    return this.donationRepository.save(donation);
  }

  async findByProfessional(
    professionalId: string,
  ): Promise<InstitutionalDonation[]> {
    return this.donationRepository.find({
      where: { professional_id: professionalId },
      relations: { association: true },
      order: { created_at: 'DESC' },
    });
  }

  async findByAssociation(
    associationId: string,
  ): Promise<InstitutionalDonation[]> {
    return this.donationRepository.find({
      where: { association_id: associationId },
      relations: { professional: true },
      order: { created_at: 'DESC' },
    });
  }

  async getAssociations(): Promise<User[]> {
    return this.userRepository.find({
      where: { role: UserRole.ASSOCIATION },
      select: { id: true, display_name: true, phone_number: true },
    });
  }

  private async generatePdf(donation: InstitutionalDonation): Promise<Buffer> {
    return new Promise((resolve, reject) => {
      const doc = new PDFDocument({ size: 'A4', margin: 50 });
      const chunks: Buffer[] = [];

      doc.on('data', (chunk: Buffer) => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      doc.on('error', reject);

      // Header
      doc
        .fontSize(20)
        .text('Bon de Cession / وثيقة التنازل', { align: 'center' });
      doc.moveDown();
      doc.fontSize(12).text(`Date: ${new Date().toLocaleDateString('fr-DZ')}`);
      doc.moveDown();

      // Donor info
      doc.fontSize(14).text('Donateur / المتبرع:');
      doc
        .fontSize(12)
        .text(`Nom: ${donation.professional?.display_name || 'N/A'}`);
      doc.moveDown();

      // Association info
      doc.fontSize(14).text('Association bénéficiaire / الجمعية المستفيدة:');
      doc
        .fontSize(12)
        .text(`Nom: ${donation.association?.display_name || 'N/A'}`);
      doc.moveDown();

      // Donation details
      doc.fontSize(14).text('Détails du don / تفاصيل التبرع:');
      doc.fontSize(12).text(`Description: ${donation.description}`);
      doc.text(`Quantité estimée: ${donation.estimated_quantity}`);
      doc.moveDown(2);

      // Legal notice
      doc
        .fontSize(10)
        .text(
          "La responsabilité sanitaire est transférée à l'association au moment de la signature de ce document.",
          { align: 'center' },
        );
      doc.text(
        'تنتقل المسؤولية الصحية إلى الجمعية عند التوقيع على هذه الوثيقة.',
        { align: 'center' },
      );
      doc.moveDown(2);

      // Signature lines
      doc.text(
        'Signature du donateur / توقيع المتبرع: _______________________',
      );
      doc.moveDown();
      doc.text(
        "Signature de l'association / توقيع الجمعية: _______________________",
      );

      // ID and timestamp
      doc.moveDown(2);
      doc.fontSize(8).text(`ID: ${donation.id}`, { align: 'right' });
      doc.text(`Généré le: ${new Date().toISOString()}`, { align: 'right' });

      doc.end();
    });
  }
}
