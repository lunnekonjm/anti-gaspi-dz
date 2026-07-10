import { MigrationInterface, QueryRunner } from 'typeorm';

export class AddFcmToken1720569600001 implements MigrationInterface {
  name = 'AddFcmToken1720569600001';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `ALTER TABLE "users" ADD "fcm_token" character varying(255)`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "users" DROP COLUMN "fcm_token"`);
  }
}
