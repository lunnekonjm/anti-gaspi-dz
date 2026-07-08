import { Injectable, Logger } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThanOrEqual } from 'typeorm';
import { PricingConfig } from '../database/entities';
import { CommissionType } from '../common/enums';

/**
 * Runtime-configurable pricing — commission NEVER hardcoded.
 * Default: 18% for B2C segment.
 */
@Injectable()
export class PricingService {
  private readonly logger = new Logger(PricingService.name);

  constructor(
    @InjectRepository(PricingConfig)
    private readonly pricingRepository: Repository<PricingConfig>,
  ) {}

  /**
   * Get active commission config for a segment.
   */
  async getActiveConfig(segment: string): Promise<PricingConfig | null> {
    return this.pricingRepository.findOne({
      where: {
        segment,
        is_active: true,
        effective_from: LessThanOrEqual(new Date()),
      },
      order: { effective_from: 'DESC' },
    });
  }

  /**
   * Calculate commission for a given amount and segment.
   */
  async calculateCommission(
    amount: number,
    segment: string = 'b2c',
  ): Promise<{ commission: number; net_amount: number }> {
    const config = await this.getActiveConfig(segment);

    if (!config) {
      // Fallback to 18% if no config found
      const commission = amount * 0.18;
      return {
        commission: Math.round(commission * 100) / 100,
        net_amount: Math.round((amount - commission) * 100) / 100,
      };
    }

    let commission: number;
    if (config.commission_type === CommissionType.PERCENTAGE) {
      commission = amount * (Number(config.commission_value) / 100);
    } else {
      commission = Number(config.commission_value);
    }

    return {
      commission: Math.round(commission * 100) / 100,
      net_amount: Math.round((amount - commission) * 100) / 100,
    };
  }

  /**
   * Update pricing config (admin only).
   */
  async updateConfig(
    segment: string,
    commissionType: CommissionType,
    commissionValue: number,
  ): Promise<PricingConfig> {
    // Deactivate existing configs for this segment
    await this.pricingRepository.update(
      { segment, is_active: true },
      { is_active: false },
    );

    // Create new config
    const config = this.pricingRepository.create({
      segment,
      commission_type: commissionType,
      commission_value: commissionValue,
      is_active: true,
      effective_from: new Date(),
    });

    return this.pricingRepository.save(config);
  }
}
