import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  OneToMany,
  DeleteDateColumn,
} from 'typeorm';
import { UserRole, Language } from '../../common/enums';
import { Offer } from './offer.entity';
import { Reservation } from './reservation.entity';
import { Donation } from './donation.entity';
import { InstitutionalDonation } from './institutional-donation.entity';
import { Message } from './message.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 20, unique: true })
  phone_number: string;

  @Column({ type: 'enum', enum: UserRole, default: UserRole.CONSUMER })
  role: UserRole;

  @Column({ type: 'varchar', length: 100, nullable: true })
  display_name: string;

  @Column({ type: 'enum', enum: Language, default: Language.FR })
  language_preference: Language;

  @Column({ type: 'boolean', default: false })
  consent_payment: boolean;

  @Column({ type: 'boolean', default: false })
  consent_geolocation: boolean;

  @Column({ type: 'boolean', default: false })
  consent_notifications: boolean;

  @Column({ type: 'timestamp', nullable: true })
  consent_timestamp: Date;

  @Column({ type: 'boolean', default: false })
  is_verified: boolean;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  @DeleteDateColumn({ type: 'timestamp', nullable: true })
  deleted_at: Date | null;

  // Relations
  @OneToMany(() => Offer, (offer) => offer.merchant)
  offers: Offer[];

  @OneToMany(() => Reservation, (reservation) => reservation.consumer)
  reservations: Reservation[];

  @OneToMany(() => Donation, (donation) => donation.donor)
  donations: Donation[];

  @OneToMany(() => InstitutionalDonation, (donation) => donation.professional)
  institutional_donations_given: InstitutionalDonation[];

  @OneToMany(() => InstitutionalDonation, (donation) => donation.association)
  institutional_donations_received: InstitutionalDonation[];

  @OneToMany(() => Message, (message) => message.sender)
  messages: Message[];
}
