import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateReview1720569600003 implements MigrationInterface {
  name = 'CreateReview1720569600003';

  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(
      `CREATE TABLE "reviews" (
        "id" uuid NOT NULL DEFAULT uuid_generate_v4(),
        "reservation_id" uuid NOT NULL,
        "reviewer_id" uuid NOT NULL,
        "merchant_id" uuid NOT NULL,
        "rating" integer NOT NULL,
        "comment" text,
        "created_at" TIMESTAMP NOT NULL DEFAULT now(),
        CONSTRAINT "CHK_c8b746fbdb2b810842271df542" CHECK ("rating" >= 1 AND "rating" <= 5),
        CONSTRAINT "PK_231ae565c273ee700b283f15c1d" PRIMARY KEY ("id")
      )`
    );
    await queryRunner.query(
      `ALTER TABLE "reviews" ADD CONSTRAINT "FK_231ae565c273ee700b283f15c1e" FOREIGN KEY ("reservation_id") REFERENCES "reservations"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`
    );
    await queryRunner.query(
      `ALTER TABLE "reviews" ADD CONSTRAINT "FK_231ae565c273ee700b283f15c1f" FOREIGN KEY ("reviewer_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`
    );
    await queryRunner.query(
      `ALTER TABLE "reviews" ADD CONSTRAINT "FK_231ae565c273ee700b283f15c20" FOREIGN KEY ("merchant_id") REFERENCES "users"("id") ON DELETE NO ACTION ON UPDATE NO ACTION`
    );
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`ALTER TABLE "reviews" DROP CONSTRAINT "FK_231ae565c273ee700b283f15c20"`);
    await queryRunner.query(`ALTER TABLE "reviews" DROP CONSTRAINT "FK_231ae565c273ee700b283f15c1f"`);
    await queryRunner.query(`ALTER TABLE "reviews" DROP CONSTRAINT "FK_231ae565c273ee700b283f15c1e"`);
    await queryRunner.query(`DROP TABLE "reviews"`);
  }
}
