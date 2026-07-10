import {
  Injectable,
  HttpException,
  HttpStatus,
  Logger,
  Inject,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, DataSource } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { Cron, CronExpression } from '@nestjs/schedule';
import { CACHE_MANAGER } from '@nestjs/cache-manager';
import type { Cache } from 'cache-manager';
import { Reservation, Offer } from '../database/entities';
import { ReservationStatus, OfferStatus } from '../common/enums';
import { CreateReservationDto } from './dto';
import { NotificationsService } from '../notifications/notifications.service';
import * as crypto from 'crypto';

@Injectable()
export class ReservationsService {
  private readonly logger = new Logger(ReservationsService.name);

  constructor(
    @InjectRepository(Reservation)
    private readonly reservationRepository: Repository<Reservation>,
    @InjectRepository(Offer)
    private readonly offerRepository: Repository<Offer>,
    private readonly dataSource: DataSource,
    private readonly jwtService: JwtService,
    @Inject(CACHE_MANAGER) private readonly cacheManager: Cache,
    private readonly notificationsService: NotificationsService,
  ) {}

  /**
   * Create reservation with anti-overbooking double-layer protection:
   * 1. Redis distributed lock (SET NX) prevents concurrent attempts
   * 2. PostgreSQL SELECT FOR UPDATE ensures atomic stock decrement
   */
  async create(
    consumerId: string,
    dto: CreateReservationDto,
  ): Promise<Reservation> {
    const quantity = dto.quantity || 1;
    const lockKey = `lock:offer:${dto.offer_id}`;

    // Layer 1: Redis distributed lock
    const lockValue = crypto.randomUUID();
    const lockAcquired = await this.acquireLock(lockKey, lockValue, 10);

    if (!lockAcquired) {
      throw new HttpException(
        {
          message_fr: 'Trop de demandes simultanées. Veuillez réessayer.',
          message_ar: 'طلبات متزامنة كثيرة. يرجى المحاولة مرة أخرى.',
          error: 'Conflict',
        },
        HttpStatus.CONFLICT,
      );
    }

    try {
      // Layer 2: PostgreSQL transaction with SELECT FOR UPDATE
      return await this.dataSource.transaction(async (manager) => {
        const offer = await manager
          .getRepository(Offer)
          .createQueryBuilder('offer')
          .setLock('pessimistic_write')
          .where('offer.id = :id', { id: dto.offer_id })
          .getOne();

        if (!offer) {
          throw new HttpException(
            {
              message_fr: 'Offre introuvable.',
              message_ar: 'العرض غير موجود.',
              error: 'Not Found',
            },
            HttpStatus.NOT_FOUND,
          );
        }

        if (offer.status !== OfferStatus.ACTIVE) {
          throw new HttpException(
            {
              message_fr: "Cette offre n'est plus disponible.",
              message_ar: 'هذا العرض لم يعد متاحاً.',
              error: 'Conflict',
            },
            HttpStatus.CONFLICT,
          );
        }

        if (offer.quantity_available < quantity) {
          throw new HttpException(
            {
              message_fr: `Stock insuffisant. Disponible : ${offer.quantity_available}`,
              message_ar: `المخزون غير كافٍ. المتوفر: ${offer.quantity_available}`,
              error: 'Conflict',
            },
            HttpStatus.CONFLICT,
          );
        }

        // Atomic decrement
        offer.quantity_available -= quantity;
        if (offer.quantity_available === 0) {
          offer.status = OfferStatus.SOLD_OUT;
        }
        await manager.save(offer);

        // Create reservation
        const reservation = manager.getRepository(Reservation).create({
          offer_id: dto.offer_id,
          consumer_id: consumerId,
          status: ReservationStatus.PENDING_PAYMENT,
        });

        return manager.save(reservation);
      });
    } finally {
      // Always release lock
      await this.releaseLock(lockKey, lockValue);
    }
  }

  /**
   * Confirm reservation after payment — generates signed QR token.
   * Called by PaymentsModule webhook handler.
   */
  async confirmPayment(
    reservationId: string,
    paymentReference: string,
  ): Promise<Reservation> {
    const reservation = await this.reservationRepository.findOne({
      where: { id: reservationId },
      relations: { consumer: true, offer: { merchant: true } },
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

    // Generate signed single-use QR token
    const qrToken = this.jwtService.sign(
      {
        reservation_id: reservationId,
        type: 'qr_redeem',
        nonce: crypto.randomUUID(),
      },
      { expiresIn: '24h' },
    );

    reservation.status = ReservationStatus.CONFIRMED;
    reservation.payment_reference = paymentReference;
    reservation.qr_code_token = qrToken;
    reservation.confirmed_at = new Date();

    const savedReservation = await this.reservationRepository.save(reservation);

    // Notify consumer (if they consented and have a token)
    if (reservation.consumer?.fcm_token && reservation.consumer?.consent_notifications) {
      await this.notificationsService.sendPushNotification(
        reservation.consumer.fcm_token,
        'Réservation Confirmée',
        `Votre réservation pour "${reservation.offer?.title}" est confirmée.`,
        { reservationId: savedReservation.id }
      );
    }

    // Notify merchant (if they consented and have a token)
    if (reservation.offer?.merchant?.fcm_token && reservation.offer?.merchant?.consent_notifications) {
      await this.notificationsService.sendPushNotification(
        reservation.offer.merchant.fcm_token,
        'Nouvelle Réservation',
        `Une nouvelle réservation a été effectuée pour "${reservation.offer?.title}".`,
        { reservationId: savedReservation.id, offerId: reservation.offer.id }
      );
    }

    return savedReservation;
  }

  /**
   * Redeem reservation — merchant scans QR code.
   * Closes S2-07: Verifies merchant owns the offer being redeemed.
   * Token verified server-side, single use only.
   */
  async redeem(reservationId: string, qrToken: string, merchantId: string): Promise<Reservation> {
    const reservation = await this.reservationRepository.findOne({
      where: { id: reservationId },
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

    // Verify the calling merchant owns this offer
    if (reservation.offer.merchant_id !== merchantId) {
      throw new HttpException(
        {
          message_fr: 'Vous ne pouvez valider que les réservations de vos propres offres.',
          message_ar: 'يمكنك فقط التحقق من حجوزات عروضك الخاصة.',
          error: 'Forbidden',
        },
        HttpStatus.FORBIDDEN,
      );
    }

    if (reservation.status !== ReservationStatus.CONFIRMED) {
      throw new HttpException(
        {
          message_fr:
            'Cette réservation ne peut pas être validée dans son état actuel.',
          message_ar: 'لا يمكن التحقق من هذا الحجز في حالته الحالية.',
          error: 'Conflict',
        },
        HttpStatus.CONFLICT,
      );
    }

    // Verify QR token server-side
    try {
      const decoded = this.jwtService.verify(qrToken);
      if (
        decoded.reservation_id !== reservationId ||
        decoded.type !== 'qr_redeem'
      ) {
        throw new Error('Token mismatch');
      }
    } catch {
      throw new HttpException(
        {
          message_fr: 'QR code invalide ou expiré.',
          message_ar: 'رمز QR غير صالح أو منتهي الصلاحية.',
          error: 'Unauthorized',
        },
        HttpStatus.UNAUTHORIZED,
      );
    }

    // Invalidate token (single use) by clearing it
    reservation.status = ReservationStatus.PICKED_UP;
    reservation.picked_up_at = new Date();
    reservation.qr_code_token = '' as any; // Cleared to invalidate single-use token

    return this.reservationRepository.save(reservation);
  }

  /**
   * Cancel reservation — restores stock.
   */
  async cancel(
    reservationId: string,
    consumerId: string,
  ): Promise<Reservation> {
    return this.dataSource.transaction(async (manager) => {
      const reservation = await manager
        .getRepository(Reservation)
        .findOne({ where: { id: reservationId, consumer_id: consumerId } });

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

      if (
        reservation.status !== ReservationStatus.PENDING_PAYMENT &&
        reservation.status !== ReservationStatus.CONFIRMED
      ) {
        throw new HttpException(
          {
            message_fr: 'Cette réservation ne peut plus être annulée.',
            message_ar: 'لا يمكن إلغاء هذا الحجز بعد الآن.',
            error: 'Conflict',
          },
          HttpStatus.CONFLICT,
        );
      }

      // Restore stock
      await manager
        .getRepository(Offer)
        .createQueryBuilder()
        .update()
        .set({
          quantity_available: () => 'quantity_available + 1',
          status: OfferStatus.ACTIVE,
        })
        .where('id = :id', { id: reservation.offer_id })
        .execute();

      reservation.status = ReservationStatus.CANCELLED;
      return manager.save(reservation);
    });
  }

  async findByConsumer(consumerId: string): Promise<Reservation[]> {
    return this.reservationRepository.find({
      where: { consumer_id: consumerId },
      relations: { offer: { merchant: true } },
      order: { reserved_at: 'DESC' },
    });
  }

  async findByMerchant(merchantId: string): Promise<Reservation[]> {
    return this.reservationRepository.find({
      where: { offer: { merchant_id: merchantId } },
      relations: { offer: true, consumer: true },
      order: { reserved_at: 'DESC' },
    });
  }

  /**
   * No-show detection — auto-marks confirmed reservations as no_show
   * if pickup window has expired. Runs every 10 minutes.
   */
  @Cron(CronExpression.EVERY_10_MINUTES)
  async detectNoShows() {
    const result = await this.reservationRepository
      .createQueryBuilder('reservation')
      .innerJoin('reservation.offer', 'offer')
      .update(Reservation)
      .set({ status: ReservationStatus.NO_SHOW })
      .where('reservation.status = :status', {
        status: ReservationStatus.CONFIRMED,
      })
      .andWhere('offer.pickup_window_end < :now', { now: new Date() })
      .execute();

    if (result.affected && result.affected > 0) {
      this.logger.warn(`Detected ${result.affected} no-shows`);
    }
  }

  // --- Redis lock helpers (Closes A1-04: atomic SET NX PX) ---

  /**
   * Acquire lock atomically using Redis SET NX PX.
   * Falls back gracefully to PostgreSQL FOR UPDATE if Redis is unavailable.
   */
  private async acquireLock(
    key: string,
    value: string,
    ttlSeconds: number,
  ): Promise<boolean> {
    try {
      const store = (this.cacheManager as any).store;
      // cache-manager-redis-yet exposes the underlying redis client
      const client = store?.client;
      if (client && typeof client.set === 'function') {
        // Atomic SET NX PX — only sets if key doesn't exist
        const result = await client.set(key, value, {
          NX: true,
          PX: ttlSeconds * 1000,
        });
        return result === 'OK';
      }
      // Fallback for non-Redis cache (in-memory): use cache-manager API
      // This is inherently non-atomic but acceptable for in-memory single-process
      const existing = await this.cacheManager.get(key);
      if (existing) return false;
      await this.cacheManager.set(key, value, ttlSeconds * 1000);
      return true;
    } catch (error) {
      this.logger.warn(
        `Lock acquisition failed for ${key}, proceeding without lock`,
      );
      return true; // Fallback: rely on PostgreSQL FOR UPDATE
    }
  }

  /**
   * Release lock atomically — only deletes if the value matches (owner check).
   * Uses a Lua script for atomicity, or falls back to GET+DEL for non-Redis stores.
   */
  private async releaseLock(key: string, value: string): Promise<void> {
    try {
      const store = (this.cacheManager as any).store;
      const client = store?.client;
      if (client && typeof client.eval === 'function') {
        // Atomic Lua script: check value then delete in one round-trip
        const luaScript = `
          if redis.call("get", KEYS[1]) == ARGV[1] then
            return redis.call("del", KEYS[1])
          else
            return 0
          end
        `;
        await client.eval(luaScript, { keys: [key], arguments: [value] });
        return;
      }
      // Fallback for non-Redis cache
      const existing = await this.cacheManager.get(key);
      if (existing === value) {
        await this.cacheManager.del(key);
      }
    } catch (error) {
      this.logger.warn(`Lock release failed for ${key}`);
    }
  }
}
