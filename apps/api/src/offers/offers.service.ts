import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Cron, CronExpression } from '@nestjs/schedule';
import { Offer } from '../database/entities';
import { ExpiryType, OfferStatus } from '../common/enums';
import { CreateOfferDto } from './dto';

@Injectable()
export class OffersService {
  private readonly logger = new Logger(OffersService.name);

  constructor(
    @InjectRepository(Offer)
    private readonly offerRepository: Repository<Offer>,
  ) {}

  /**
   * Create a new offer — DLC validation is a hard block.
   * If expiry_type=DLC and expiry_date < pickup_window_end → 422.
   */
  async create(merchantId: string, dto: CreateOfferDto): Promise<Offer> {
    // DLC blocking validation
    if (dto.expiry_type === ExpiryType.DLC) {
      const expiryDate = new Date(dto.expiry_date);
      const pickupEnd = new Date(dto.pickup_window_end);
      if (expiryDate < pickupEnd) {
        throw new HttpException(
          {
            message_fr:
              'La date DLC ne peut pas être antérieure à la fin du créneau de retrait. Cela présente un risque sanitaire.',
            message_ar:
              'لا يمكن أن يكون تاريخ DLC قبل نهاية فترة الاستلام. يشكل ذلك خطراً صحياً.',
            error: 'Unprocessable Entity',
          },
          HttpStatus.UNPROCESSABLE_ENTITY,
        );
      }
    }

    const offer = this.offerRepository.create({
      merchant_id: merchantId,
      title: dto.title,
      initial_value: dto.initial_value,
      sale_price: dto.sale_price,
      quantity_available: dto.quantity_available,
      pickup_window_start: new Date(dto.pickup_window_start),
      pickup_window_end: new Date(dto.pickup_window_end),
      expiry_type: dto.expiry_type,
      expiry_date: dto.expiry_date,
      photo_url: dto.photo_url,
      latitude: dto.latitude,
      longitude: dto.longitude,
      status: OfferStatus.ACTIVE,
    });

    return this.offerRepository.save(offer);
  }

  /**
   * Get active offers, optionally filtered by geolocation.
   * Uses Haversine formula for distance calculation.
   */
  async findActive(
    lat?: number,
    lng?: number,
    radiusKm?: number,
  ): Promise<Offer[]> {
    const queryBuilder = this.offerRepository
      .createQueryBuilder('offer')
      .leftJoinAndSelect('offer.merchant', 'merchant')
      .where('offer.status = :status', { status: OfferStatus.ACTIVE })
      .andWhere('offer.quantity_available > 0')
      .andWhere('offer.pickup_window_end > :now', { now: new Date() });

    if (lat && lng && radiusKm) {
      // Haversine formula for distance filtering
      queryBuilder.andWhere(
        `(6371 * acos(
          cos(radians(:lat)) * cos(radians(offer.latitude)) *
          cos(radians(offer.longitude) - radians(:lng)) +
          sin(radians(:lat)) * sin(radians(offer.latitude))
        )) <= :radius`,
        { lat, lng, radius: radiusKm },
      );
      queryBuilder.orderBy(
        `(6371 * acos(
          cos(radians(${lat})) * cos(radians(offer.latitude)) *
          cos(radians(offer.longitude) - radians(${lng})) +
          sin(radians(${lat})) * sin(radians(offer.latitude))
        ))`,
        'ASC',
      );
    } else {
      queryBuilder.orderBy('offer.created_at', 'DESC');
    }

    return queryBuilder.getMany();
  }

  async findById(id: string): Promise<Offer | null> {
    return this.offerRepository.findOne({
      where: { id },
      relations: { merchant: true },
    });
  }

  async findByMerchant(merchantId: string): Promise<Offer[]> {
    return this.offerRepository.find({
      where: { merchant_id: merchantId },
      order: { created_at: 'DESC' },
    });
  }

  /**
   * Scheduled job: auto-expire offers past their pickup window.
   * Runs every 5 minutes.
   */
  @Cron(CronExpression.EVERY_5_MINUTES)
  async expireOffers() {
    const result = await this.offerRepository
      .createQueryBuilder()
      .update(Offer)
      .set({ status: OfferStatus.EXPIRED })
      .where('status = :status', { status: OfferStatus.ACTIVE })
      .andWhere('pickup_window_end < :now', { now: new Date() })
      .execute();

    if (result.affected && result.affected > 0) {
      this.logger.log(`Auto-expired ${result.affected} offers`);
    }
  }
}
