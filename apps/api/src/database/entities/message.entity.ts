import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Donation } from './donation.entity';

/**
 * Internal messaging for C2C donations.
 * Phone numbers are stripped from content via regex before storage.
 */
@Entity('messages')
export class Message {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  donation_id: string;

  @Column({ type: 'uuid' })
  sender_id: string;

  /** Content with phone numbers stripped by PhoneNumberFilter */
  @Column({ type: 'text' })
  content: string;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  // Relations
  @ManyToOne(() => Donation, (donation) => donation.messages)
  @JoinColumn({ name: 'donation_id' })
  donation: Donation;

  @ManyToOne(() => User, (user) => user.messages)
  @JoinColumn({ name: 'sender_id' })
  sender: User;
}
