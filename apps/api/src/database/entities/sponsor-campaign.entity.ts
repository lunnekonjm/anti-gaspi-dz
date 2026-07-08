import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
} from 'typeorm';

@Entity('sponsor_campaigns')
export class SponsorCampaign {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ type: 'varchar', length: 200 })
  sponsor_name: string;

  /** e.g. "achat de 2 packs de jus X" */
  @Column({ type: 'text' })
  condition_description: string;

  @Column({ type: 'integer' })
  sponsored_offers_count_limit: number;

  @Column({ type: 'integer', default: 0 })
  sponsored_offers_count_used: number;

  @Column({ type: 'decimal', precision: 12, scale: 2 })
  budget_remaining: number;

  @Column({ type: 'boolean', default: true })
  active: boolean;

  @CreateDateColumn({ type: 'timestamp' })
  created_at: Date;
}
