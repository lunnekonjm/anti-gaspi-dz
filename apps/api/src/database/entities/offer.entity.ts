import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { OfferStatus, ExpiryType } from '../../common/enums';
import { User } from './user.entity';
import { Reservation } from './reservation.entity';
import { SponsorCampaign } from './sponsor-campaign.entity';

@Entity('offers')
export class Offer {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  merchant_id: string;

  @Column({ type: 'varchar', length: 200 })
  title: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  initial_value: number;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  sale_price: number;

  @Column({ type: 'integer' })
  quantity_available: number;

  @Column({ type: 'timestamp' })
  pickup_window_start: Date;

  @Column({ type: 'timestamp' })
  pickup_window_end: Date;

  @Column({ type: 'enum', enum: ExpiryType })
  expiry_type: ExpiryType;

  @Column({ type: 'date' })
  expiry_date: string;

  @Column({
    type: 'enum',
    enum: OfferStatus,
    default: OfferStatus.DRAFT,
  })
  status: OfferStatus;

  @Column({ type: 'varchar', length: 500, nullable: true })
  photo_url: string;

  @Column({ type: 'uuid', nullable: true })
  sponsor_campaign_id: string | null;

  /** Merchant's latitude for geospatial queries */
  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  latitude: number;

  /** Merchant's longitude for geospatial queries */
  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  longitude: number;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  // Relations
  @ManyToOne(() => User, (user) => user.offers)
  @JoinColumn({ name: 'merchant_id' })
  merchant: User;

  @OneToMany(() => Reservation, (reservation) => reservation.offer)
  reservations: Reservation[];

  @ManyToOne(() => SponsorCampaign, { nullable: true })
  @JoinColumn({ name: 'sponsor_campaign_id' })
  sponsor_campaign: SponsorCampaign;
}
