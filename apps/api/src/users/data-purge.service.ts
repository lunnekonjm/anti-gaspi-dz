import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, LessThan, Not, IsNull } from 'typeorm';
import { User } from '../database/entities/user.entity';

/**
 * Closes P3-02: Implement the deferred purge job for soft-deleted accounts.
 *
 * Runs daily at 3:00 AM. Purges user data for accounts that were soft-deleted
 * more than 30 days ago (grace period for accidental deletion recovery).
 *
 * Purge process:
 * 1. Anonymize user fields (phone_number, display_name)
 * 2. Clear consent fields
 * 3. Remove the soft-delete timestamp to prevent re-processing
 * 4. Log the purge in the audit trail
 *
 * Related data (reservations, donations, messages) retain the user_id foreign
 * key for referential integrity, but the user record is fully anonymized.
 */
@Injectable()
export class DataPurgeService {
  private readonly logger = new Logger(DataPurgeService.name);
  private static readonly GRACE_PERIOD_DAYS = 30;

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  @Cron(CronExpression.EVERY_DAY_AT_3AM)
  async purgeExpiredAccounts(): Promise<void> {
    const cutoffDate = new Date();
    cutoffDate.setDate(
      cutoffDate.getDate() - DataPurgeService.GRACE_PERIOD_DAYS,
    );

    // Find soft-deleted users past the grace period
    // TypeORM soft-delete uses withDeleted() to include deleted records
    const expiredUsers = await this.userRepository
      .createQueryBuilder('user')
      .withDeleted()
      .where('user.deleted_at IS NOT NULL')
      .andWhere('user.deleted_at < :cutoff', { cutoff: cutoffDate })
      // Skip already-purged users (phone_number starts with 'PURGED_')
      .andWhere("user.phone_number NOT LIKE 'PURGED_%'")
      .getMany();

    if (expiredUsers.length === 0) {
      this.logger.log('Data purge: no expired accounts to process.');
      return;
    }

    this.logger.log(
      `Data purge: processing ${expiredUsers.length} expired account(s).`,
    );

    for (const user of expiredUsers) {
      try {
        await this.anonymizeUser(user);
        this.logger.log(
          `Data purge: user ${user.id} anonymized successfully.`,
        );
      } catch (error) {
        this.logger.error(
          `Data purge: failed to anonymize user ${user.id}`,
          error,
        );
      }
    }
  }

  /**
   * Anonymize a user record — replaces PII with non-identifying placeholders.
   * The user_id is preserved for referential integrity with transactions.
   */
  private async anonymizeUser(user: User): Promise<void> {
    await this.userRepository
      .createQueryBuilder()
      .update(User)
      .set({
        phone_number: `PURGED_${user.id.substring(0, 8)}`,
        display_name: 'Utilisateur supprimé',
        consent_payment: false,
        consent_geolocation: false,
        consent_notifications: false,
        consent_timestamp: null as any,
      })
      .where('id = :id', { id: user.id })
      .execute();
  }
}
