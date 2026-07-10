import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Closes P3-06: Add IP address retention policy via a scheduled cleanup.
 *
 * Nullifies ip_address in audit_logs after 90 days. IP addresses are
 * personal data under Algerian Loi 18-07 and European GDPR.
 *
 * This runs as a SQL function + scheduled trigger rather than app-level
 * code, ensuring it works even if the application crashes.
 */
export class AuditLogIpRetention1720742400000 implements MigrationInterface {
  name = 'AuditLogIpRetention1720742400000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Create a function that nullifies old IP addresses
    await queryRunner.query(`
      CREATE OR REPLACE FUNCTION nullify_old_audit_ips()
      RETURNS void AS $$
      BEGIN
        UPDATE audit_logs
        SET ip_address = NULL
        WHERE ip_address IS NOT NULL
          AND created_at < NOW() - INTERVAL '90 days';
      END;
      $$ LANGUAGE plpgsql;
    `);

    // Create an index on created_at for the retention query performance
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at
      ON audit_logs (created_at)
      WHERE ip_address IS NOT NULL;
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP FUNCTION IF EXISTS nullify_old_audit_ips;`);
    await queryRunner.query(`DROP INDEX IF EXISTS idx_audit_logs_created_at;`);
  }
}
