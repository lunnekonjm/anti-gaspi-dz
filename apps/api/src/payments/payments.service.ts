import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { Reservation, Offer } from '../database/entities';
import { ReservationsService } from '../reservations/reservations.service';
import { PricingService } from '../pricing/pricing.service';
import { MockPaymentProvider } from './providers/mock-payment.provider';
import { InitiatePaymentDto, PaymentWebhookDto } from './dto';
import { ReservationStatus } from '../common/enums';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    @InjectRepository(Reservation)
    private readonly reservationRepository: Repository<Reservation>,
    @InjectRepository(Offer)
    private readonly offerRepository: Repository<Offer>,
    private readonly reservationsService: ReservationsService,
    private readonly pricingService: PricingService,
    private readonly mockPaymentProvider: MockPaymentProvider,
    private readonly configService: ConfigService,
  ) {}

  /**
   * Initiate payment — delegates to PSP (mock by default).
   * ZERO card data stored or transmitted by the platform.
   */
  async initiatePayment(dto: InitiatePaymentDto) {
    const reservation = await this.reservationRepository.findOne({
      where: { id: dto.reservation_id },
      relations: { offer: true },
    });

    if (!reservation) {
      throw new HttpException(
        {
          message_fr: 'Réservation introuvable.',
          message_ar: 'الحجز غير موجود.',
          error: 'Not Found',
        },
        HttpStatus.NOT_FOUND,
      );
    }

    if (reservation.status !== ReservationStatus.PENDING_PAYMENT) {
      throw new HttpException(
        {
          message_fr: 'Cette réservation a déjà été traitée.',
          message_ar: 'تم معالجة هذا الحجز بالفعل.',
          error: 'Conflict',
        },
        HttpStatus.CONFLICT,
      );
    }

    const callbackUrl = `${this.configService.get('APP_URL')}/api/v1/payments/webhook`;

    // Use mock provider (will be swapped for SATIM/BaridiMob)
    const paymentSession = await this.mockPaymentProvider.createPaymentSession({
      amount: Number(reservation.offer.sale_price),
      currency: 'DZD',
      reservationId: reservation.id,
      callbackUrl,
    });

    return paymentSession;
  }

  /**
   * Handle PSP webhook callback.
   * Closes S2-05: Webhook signature is now MANDATORY — no bypass.
   */
  async handleWebhook(dto: PaymentWebhookDto) {
    // Signature is mandatory — reject unsigned webhook calls
    if (!dto.signature) {
      throw new HttpException(
        {
          message_fr: 'Signature webhook manquante.',
          message_ar: 'توقيع webhook مفقود.',
          error: 'Unauthorized',
        },
        HttpStatus.UNAUTHORIZED,
      );
    }

    const isValid = this.mockPaymentProvider.verifyWebhookSignature(
      dto as any,
      dto.signature,
    );
    if (!isValid) {
      throw new HttpException(
        {
          message_fr: 'Signature webhook invalide.',
          message_ar: 'توقيع webhook غير صالح.',
          error: 'Unauthorized',
        },
        HttpStatus.UNAUTHORIZED,
      );
    }

    if (dto.status === 'success') {
      return this.reservationsService.confirmPayment(
        dto.reservation_id,
        dto.payment_reference,
      );
    }

    // Payment failed — cancel reservation and restore stock
    return this.reservationsService.cancel(
      dto.reservation_id,
      '', // System-triggered cancellation
    );
  }

  /**
   * Mock endpoint: simulate payment completion.
   * Closes S2-06: Blocked in production — only available in development.
   */
  async simulateMockPayment(paymentReference: string, reservationId: string) {
    if (process.env.NODE_ENV === 'production') {
      throw new HttpException(
        {
          message_fr: 'Endpoint non disponible en production.',
          message_ar: 'نقطة النهاية غير متاحة في الإنتاج.',
          error: 'Not Found',
        },
        HttpStatus.NOT_FOUND,
      );
    }

    const result =
      await this.mockPaymentProvider.simulatePaymentCompletion(
        paymentReference,
      );

    // In dev, bypass signature check by providing a mock signature
    return this.handleWebhook({
      payment_reference: result.payment_reference,
      reservation_id: reservationId,
      status: result.status,
      signature: 'mock-dev-signature',
    });
  }
}
