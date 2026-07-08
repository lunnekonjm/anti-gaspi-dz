import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Donation, Message, Report } from '../database/entities';
import { CreateDonationDto, CreateMessageDto, CreateReportDto } from './dto';
import { stripPhoneNumbers } from '../common/utils/phone-filter.util';
import { COMMUNES } from './communes.data';

@Injectable()
export class DonationsService {
  private readonly logger = new Logger(DonationsService.name);

  constructor(
    @InjectRepository(Donation)
    private readonly donationRepository: Repository<Donation>,
    @InjectRepository(Message)
    private readonly messageRepository: Repository<Message>,
    @InjectRepository(Report)
    private readonly reportRepository: Repository<Report>,
  ) {}

  /**
   * Create donation — neighborhood must be from the closed communes list.
   * No GPS coordinates, no exact address — privacy by design.
   */
  async create(donorId: string, dto: CreateDonationDto): Promise<Donation> {
    // Validate neighborhood against closed list
    if (!COMMUNES.includes(dto.neighborhood)) {
      throw new HttpException(
        {
          message_fr: `Quartier invalide. Veuillez choisir parmi la liste proposée.`,
          message_ar: `الحي غير صالح. يرجى الاختيار من القائمة المقترحة.`,
          error: 'Bad Request',
        },
        HttpStatus.BAD_REQUEST,
      );
    }

    const donation = this.donationRepository.create({
      donor_id: donorId,
      title: dto.title,
      description: stripPhoneNumbers(dto.description),
      photo_url: dto.photo_url,
      neighborhood: dto.neighborhood,
    });

    return this.donationRepository.save(donation);
  }

  async findByNeighborhood(neighborhood?: string): Promise<Donation[]> {
    const where: Record<string, any> = { status: 'available' };
    if (neighborhood) {
      where.neighborhood = neighborhood;
    }
    return this.donationRepository.find({
      where,
      order: { created_at: 'DESC' },
    });
  }

  async findById(id: string): Promise<Donation | null> {
    return this.donationRepository.findOne({ where: { id } });
  }

  /**
   * Send message on a donation — phone numbers are stripped from content.
   * Both backend AND frontend filter, but backend is authoritative.
   */
  async sendMessage(
    donationId: string,
    senderId: string,
    dto: CreateMessageDto,
  ): Promise<Message> {
    const donation = await this.donationRepository.findOne({
      where: { id: donationId },
    });

    if (!donation) {
      throw new HttpException(
        {
          message_fr: 'Don introuvable.',
          message_ar: 'التبرع غير موجود.',
          error: 'Not Found',
        },
        HttpStatus.NOT_FOUND,
      );
    }

    // Strip phone numbers — authoritative server-side filter
    const filteredContent = stripPhoneNumbers(dto.content);

    const message = this.messageRepository.create({
      donation_id: donationId,
      sender_id: senderId,
      content: filteredContent,
    });

    return this.messageRepository.save(message);
  }

  async getMessages(donationId: string): Promise<Message[]> {
    return this.messageRepository.find({
      where: { donation_id: donationId },
      order: { created_at: 'ASC' },
    });
  }

  async report(
    donationId: string,
    reporterId: string,
    dto: CreateReportDto,
  ): Promise<Report> {
    const report = this.reportRepository.create({
      donation_id: donationId,
      reporter_id: reporterId,
      reason: dto.reason,
    });
    return this.reportRepository.save(report);
  }

  /**
   * Get the list of available communes for the dropdown.
   */
  getCommunes(): string[] {
    return COMMUNES;
  }
}
