import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, In } from 'typeorm';
import { Offer } from '../database/entities/offer.entity';
import { OfferStatus } from '../common/enums';

/**
 * Closes P3-05: Reduce lat/lng precision for expired/cancelled offers.
 *
 * Runs daily at 4:00 AM. For offers that are expired, cancelled, or sold out
 * AND have high-precision lat/lng (7 decimal places), reduce to 2 decimal
 * places (~1.1km precision) — enough for aggregate analytics but not
 * enough to identify a specific storefront.
 *
 * Active/draft offers retain full precision for the geolocation search.
 */
@Injectable()
export class LocationPrivacyService {
  private readonly logger = new Logger(LocationPrivacyService.name);

  constructor(
    @InjectRepository(Offer)
    private readonly offerRepository: Repository<Offer>,
  ) {}

  @Cron(CronExpression.EVERY_DAY_AT_4AM)
  async reduceExpiredOfferPrecision(): Promise<void> {
    // Find expired/cancelled/sold_out offers with high-precision coordinates
    const result = await this.offerRepository
      .createQueryBuilder()
      .update(Offer)
      .set({
        // Round to 2 decimal places (~1.1km precision)
        latitude: () => 'ROUND(latitude::numeric, 2)',
        longitude: () => 'ROUND(longitude::numeric, 2)',
      })
      .where('status IN (:...statuses)', {
        statuses: [
          OfferStatus.EXPIRED,
          OfferStatus.CANCELLED,
          OfferStatus.SOLD_OUT,
        ],
      })
      .andWhere('latitude IS NOT NULL')
      // Only process offers not already rounded (avoid repeated updates)
      // A 7-decimal coordinate like 36.7538200 → 36.75 after rounding
      // Detect by checking if rounding changes the value
      .andWhere('latitude != ROUND(latitude::numeric, 2)')
      .execute();

    if (result.affected && result.affected > 0) {
      this.logger.log(
        `Location privacy: reduced precision on ${result.affected} expired offer(s).`,
      );
    }
  }
}
