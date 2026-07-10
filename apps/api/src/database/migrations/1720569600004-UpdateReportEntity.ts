import { MigrationInterface, QueryRunner } from 'typeorm';

export class UpdateReportEntity1720569600004 implements MigrationInterface {
  name = 'UpdateReportEntity1720569600004';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TYPE "reports_status_enum" AS ENUM('pending', 'resolved', 'dismissed')`
    );
    await queryRunner.query(
      `ALTER TABLE "reports" ADD "reservation_id" uuid`
    );
    await queryRunner.query(
      `ALTER TABLE "reports" ADD "status" "reports_status_enum" NOT NULL DEFAULT 'pending'`
    );
    await queryRunner.query(
      `ALTER TABLE "reports" ADD "updated_at" TIMESTAMP NOT NULL DEFAULT now()`
    );
    await queryRunner.query(
      `ALTER TABLE "reports" ALTER COLUMN "donation_id" DROP NOT NULL`
    );
    await queryRunner.query(
      `ALTER TABLE "reports" ADD CONSTRAINT "FK_reports_reservation" FOREIGN KEY ("reservation_id") REFERENCES "reservations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "reports" DROP CONSTRAINT "FK_reports_reservation"`);
    await queryRunner.query(`ALTER TABLE "reports" ALTER COLUMN "donation_id" SET NOT NULL`);
    await queryRunner.query(`ALTER TABLE "reports" DROP COLUMN "updated_at"`);
    await queryRunner.query(`ALTER TABLE "reports" DROP COLUMN "status"`);
    await queryRunner.query(`ALTER TABLE "reports" DROP COLUMN "reservation_id"`);
    await queryRunner.query(`DROP TYPE "reports_status_enum"`);
  }
}
