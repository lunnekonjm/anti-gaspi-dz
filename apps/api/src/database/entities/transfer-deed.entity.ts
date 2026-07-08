import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { InstitutionalDonation } from './institutional-donation.entity';

/**
 * Transfer deed (bon de cession) for B2A donations.
 * Generated server-side (never client-side) for legal integrity.
 * Includes a verification hash.
 */
@Entity('transfer_deeds')
export class TransferDeed {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  institutional_donation_id: string;

  /** URL to the server-generated PDF */
  @Column({ type: 'varchar', length: 500 })
  pdf_url: string;

  /** SHA-256 hash for PDF integrity verification */
  @Column({ type: 'varchar', length: 64 })
  verification_hash: string;

  @CreateDateColumn({ type: 'timestamp' })
  generated_at: Date;

  /** Set only when the association signs the deed */
  @Column({ type: 'timestamp', nullable: true })
  signed_at: Date | null;

  // Relations
  @OneToOne(() => InstitutionalDonation, (donation) => donation.transfer_deed)
  @JoinColumn({ name: 'institutional_donation_id' })
  institutional_donation: InstitutionalDonation;
}
