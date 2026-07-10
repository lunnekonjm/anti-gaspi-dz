import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateMerchantRequest1720569600002 implements MigrationInterface {
  name = 'CreateMerchantRequest1720569600002';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TYPE "merchant_requests_status_enum" AS ENUM('pending', 'approved', 'rejected')`
    );
    await queryRunner.query(
      `CREATE TABLE "merchant_requests" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "user_id" uuid NOT NULL,
        "business_name" character varying(150) NOT NULL,
        "address" character varying(255) NOT NULL,
        "registration_number" character varying(50),
        "document_url" character varying(255),
        "status" "merchant_requests_status_enum" NOT NULL DEFAULT 'pending',
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        "updated_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "PK_merchant_requests" PRIMARY KEY ("id")
      )`
    );
    await queryRunner.query(
      `ALTER TABLE "merchant_requests" ADD CONSTRAINT "FK_merchant_requests_user" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "merchant_requests" DROP CONSTRAINT "FK_merchant_requests_user"`);
    await queryRunner.query(`DROP TABLE "merchant_requests"`);
    await queryRunner.query(`DROP TYPE "merchant_requests_status_enum"`);
  }
}
