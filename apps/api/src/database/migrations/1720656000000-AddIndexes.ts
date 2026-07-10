import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Closes A1-02: Add database indexes for critical query paths.
 *
 * - Compound index on offers(status, pickup_window_end) for findActive()
 * - Compound index on offers(status, quantity_available) for active offer filtering
 * - Index on offers(latitude, longitude) for Haversine distance queries
 * - Compound index on otp_codes(phone_number, created_at) for rate limiting
 * - Index on donations(status, neighborhood) for findByNeighborhood()
 * - Index on reservations(consumer_id) for findByConsumer()
 * - Index on reservations(offer_id) for offer-based lookups
 */
export class AddIndexes1720656000000 implements MigrationInterface {
  name = 'AddIndexes1720656000000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Offers: findActive() filters on status + pickup_window_end + quantity_available
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_offers_status_pickup_end
      ON offers (status, pickup_window_end)
      WHERE status = 'active' AND quantity_available > 0;
    `);

    // Offers: geospatial queries use lat/lng
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_offers_location
      ON offers (latitude, longitude)
      WHERE latitude IS NOT NULL AND longitude IS NOT NULL;
    `);

    // OTP rate limiting: count by phone_number in last hour
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_otp_codes_phone_created
      ON otp_codes (phone_number, created_at);
    `);

    // Donations: findByNeighborhood() filters on status + neighborhood
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_donations_status_neighborhood
      ON donations (status, neighborhood);
    `);

    // Reservations: findByConsumer() and cancel() filter on consumer_id
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_reservations_consumer_id
      ON reservations (consumer_id);
    `);

    // Reservations: redeem() and stock operations join on offer_id
    await queryRunner.query(`
      CREATE INDEX IF NOT EXISTS idx_reservations_offer_id
      ON reservations (offer_id);
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`DROP INDEX IF EXISTS idx_offers_status_pickup_end;`);
    await queryRunner.query(`DROP INDEX IF EXISTS idx_offers_location;`);
    await queryRunner.query(`DROP INDEX IF EXISTS idx_otp_codes_phone_created;`);
    await queryRunner.query(`DROP INDEX IF EXISTS idx_donations_status_neighborhood;`);
    await queryRunner.query(`DROP INDEX IF EXISTS idx_reservations_consumer_id;`);
    await queryRunner.query(`DROP INDEX IF EXISTS idx_reservations_offer_id;`);
  }
}
