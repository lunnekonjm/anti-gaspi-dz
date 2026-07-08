import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

/**
 * OTP codes for phone verification.
 * Rate limited: max 5 attempts per hour per phone number.
 */
@Entity('otp_codes')
export class OtpCode {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 20 })
  phone_number: string;

  @Column({ type: 'varchar', length: 10 })
  code: string;

  @Column({ type: 'timestamp' })
  expires_at: Date;

  @Column({ type: 'boolean', default: false })
  is_used: boolean;

  @Column({ type: 'integer', default: 0 })
  attempt_count: number;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;
}
