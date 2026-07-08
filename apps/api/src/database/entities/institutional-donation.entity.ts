import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { InstitutionalDonationStatus } from '../../common/enums';
import { User } from './user.entity';
import { TransferDeed } from './transfer-deed.entity';

/**
 * B2A Institutional Donation — from professionals to associations.
 * `liability_transferred_at` is ONLY set after explicit electronic signature
 * by the association — never automatically.
 */
@Entity('institutional_donations')
export class InstitutionalDonation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  professional_id: string;

  @Column({ type: 'uuid' })
  association_id: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ type: 'varchar', length: 200 })
  estimated_quantity: string;

  @Column({
    type: 'enum',
    enum: InstitutionalDonationStatus,
    default: InstitutionalDonationStatus.ANNOUNCED,
  })
  status: InstitutionalDonationStatus;

  @Column({ type: 'varchar', length: 500, nullable: true })
  transfer_deed_url: string;

  /**
   * CRITICAL: Only set after explicit electronic signature by the association.
   * This is the legal moment when sanitary liability transfers.
   * NEVER auto-filled.
   */
  @Column({ type: 'timestamp', nullable: true })
  liability_transferred_at: Date | null;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.institutional_donations_given)
  @JoinColumn({ name: 'professional_id' })
  professional: User;

  @ManyToOne(() => User, (user) => user.institutional_donations_received)
  @JoinColumn({ name: 'association_id' })
  association: User;

  @OneToOne(() => TransferDeed, (deed) => deed.institutional_donation, {
    nullable: true,
  })
  transfer_deed: TransferDeed;
}
