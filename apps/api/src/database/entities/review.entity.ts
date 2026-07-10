import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Check,
} from 'typeorm';
import { User } from './user.entity';
import { Reservation } from './reservation.entity';

@Entity('reviews')
@Check(`"rating" >= 1 AND "rating" <= 5`)
export class Review {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'uuid' })
  reservation_id: string;

  @Column({ type: 'uuid' })
  reviewer_id: string; // The consumer

  @Column({ type: 'uuid' })
  merchant_id: string; // The merchant being reviewed

  @Column({ type: 'int' })
  rating: number; // 1 to 5

  @Column({ type: 'text', nullable: true })
  comment: string;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;

  // Relations
  @ManyToOne(() => Reservation)
  @JoinColumn({ name: 'reservation_id' })
  reservation: Reservation;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'reviewer_id' })
  reviewer: User;

  @ManyToOne(() => User)
  @JoinColumn({ name: 'merchant_id' })
  merchant: User;
}
