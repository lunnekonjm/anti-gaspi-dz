import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { ReservationStatus } from '../../common/enums';
import { User } from './user.entity';
import { Offer } from './offer.entity';

@Entity('reservations')
export class Reservation {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  offer_id: string;

  @Column({ type: 'uuid' })
  consumer_id: string;

  @Column({
    type: 'enum',
    enum: ReservationStatus,
    default: ReservationStatus.PENDING_PAYMENT,
  })
  status: ReservationStatus;

  /** Reference from SATIM/BaridiMob — never contains card data */
  @Column({ type: 'varchar', length: 200, nullable: true })
  payment_reference: string;

  /** JWT-signed single-use token for QR code verification */
  @Column({ type: 'varchar', length: 500, nullable: true })
  qr_code_token: string;

  @CreateDateColumn({ type: 'timestamp' })
  reserved_at: Date;

  @Column({ type: 'timestamp', nullable: true })
  confirmed_at: Date | null;

  @Column({ type: 'timestamp', nullable: true })
  picked_up_at: Date | null;

  // Relations
  @ManyToOne(() => Offer, (offer) => offer.reservations)
  @JoinColumn({ name: 'offer_id' })
  offer: Offer;

  @ManyToOne(() => User, (user) => user.reservations)
  @JoinColumn({ name: 'consumer_id' })
  consumer: User;
}
