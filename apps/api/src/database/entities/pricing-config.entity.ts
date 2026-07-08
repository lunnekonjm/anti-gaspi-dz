import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';
import { CommissionType } from '../../common/enums';

/**
 * Runtime-configurable pricing — commission is NEVER hardcoded.
 * Adjustable from database without redeployment.
 */
@Entity('pricing_config')
export class PricingConfig {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /** Which segment this config applies to: b2c, b2a, sponsoring */
  @Column({ type: 'varchar', length: 50 })
  segment: string;

  @Column({ type: 'enum', enum: CommissionType })
  commission_type: CommissionType;

  /** Percentage (0-100) or fixed amount in DA */
  @Column({ type: 'decimal', precision: 10, scale: 2 })
  commission_value: number;

  @Column({ type: 'boolean', default: true })
  is_active: boolean;

  @Column({ type: 'timestamp' })
  effective_from: Date;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;
}
