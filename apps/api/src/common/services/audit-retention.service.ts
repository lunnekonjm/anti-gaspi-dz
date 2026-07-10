import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuditLog } from '../../database/entities';

/**
 * Closes P3-06: IP address retention policy for audit logs.
 *
 * Runs daily at 5:00 AM. Nullifies ip_address for audit log entries
 * older than 90 days. IP addresses are personal data under
 * Algerian Loi 18-07 and European GDPR.
 */
@Injectable()
export class AuditRetentionService {
  private readonly logger = new Logger(AuditRetentionService.name);
  private static readonly RETENTION_DAYS = 90;

  constructor(
    @InjectRepository(AuditLog)
    private readonly auditLogRepository: Repository<AuditLog>,
  ) {}

  @Cron(CronExpression.EVERY_DAY_AT_5AM)
  async nullifyExpiredIps(): Promise<void> {
    try {
      // Call the DB function created by the migration
      await this.auditLogRepository.query(
        `SELECT nullify_old_audit_ips()`,
      );
      this.logger.log('Audit retention: expired IP addresses nullified.');
    } catch (error) {
      // Fallback: direct UPDATE if the function doesn't exist yet
      const cutoff = new Date();
      cutoff.setDate(cutoff.getDate() - AuditRetentionService.RETENTION_DAYS);

      const result = await this.auditLogRepository
        .createQueryBuilder()
        .update(AuditLog)
        .set({ ip_address: null as any })
        .where('ip_address IS NOT NULL')
        .andWhere('created_at < :cutoff', { cutoff })
        .execute();

      this.logger.log(
        `Audit retention: nullified ${result.affected} IP address(es) via fallback.`,
      );
    }
  }
}
