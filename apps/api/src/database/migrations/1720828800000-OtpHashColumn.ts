import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Closes S2-14: Widen otp_codes.code column to fit SHA-256 hex digests.
 * Old plaintext codes (10 chars) → SHA-256 hashes (64 chars).
 */
export class OtpHashColumn1720828800000 implements MigrationInterface {
  name = 'OtpHashColumn1720828800000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      ALTER TABLE otp_codes ALTER COLUMN code TYPE varchar(64);
    `);
    // Invalidate any existing plaintext OTPs (they can't be verified after this change)
    await queryRunner.query(`
      UPDATE otp_codes SET is_used = true WHERE LENGTH(code) < 64;
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Cannot safely revert — hashed codes are longer than 10 chars
    // Just mark all as used to prevent issues
    await queryRunner.query(`
      UPDATE otp_codes SET is_used = true;
    `);
    await queryRunner.query(`
      ALTER TABLE otp_codes ALTER COLUMN code TYPE varchar(10);
    `);
  }
}
