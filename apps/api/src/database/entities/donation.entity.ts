import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { DonationStatus } from '../../common/enums';
import { User } from './user.entity';
import { Message } from './message.entity';
import { Report } from './report.entity';

/**
 * C2C Donation — "Onglet Famille"
 * Privacy by design: NO GPS coordinates, NO exact address.
 * Only `neighborhood` from a closed list of Algerian communes.
 */
@Entity('donations')
export class Donation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  donor_id: string;

  @Column({ type: 'varchar', length: 200 })
  title: string;

  @Column({ type: 'text' })
  description: string;

  @Column({ type: 'varchar', length: 500, nullable: true })
  photo_url: string;

  /**
   * From a closed list of Algerian communes — NEVER a free-text address.
   * Schema-level enforcement: this maps to a validated enum/lookup table.
   */
  @Column({ type: 'varchar', length: 100 })
  neighborhood: string;

  @Column({
    type: 'enum',
    enum: DonationStatus,
    default: DonationStatus.AVAILABLE,
  })
  status: DonationStatus;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.donations)
  @JoinColumn({ name: 'donor_id' })
  donor: User;

  @OneToMany(() => Message, (message) => message.donation)
  messages: Message[];

  @OneToMany(() => Report, (report) => report.donation)
  reports: Report[];
}
