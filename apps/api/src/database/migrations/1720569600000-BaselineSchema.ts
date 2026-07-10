import { MigrationInterface, QueryRunner } from 'typeorm';

/**
 * Baseline migration — captures the schema as it existed when
 * synchronize:true was disabled (Closes A1-01).
 *
 * This migration is intentionally a no-op for existing databases
 * that already have the schema from synchronize:true. For fresh
 * databases, run the full schema DDL below.
 *
 * To generate future migrations against actual DB state, use:
 *   npx typeorm migration:generate -d ormconfig.ts src/database/migrations/MigrationName
 */
export class BaselineSchema1720569600000 implements MigrationInterface {
  name = 'BaselineSchema1720569600000';

  public async up(queryRunner: QueryRunner): Promise<void> {
    // Check if tables already exist (from synchronize:true era)
    const tableExists = await queryRunner.query(
      `SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users')`,
    );

    if (tableExists[0]?.exists) {
      // Schema already exists — this is an existing database
      console.log('Baseline migration: schema already exists, skipping DDL.');
      return;
    }

    // Fresh database — create all tables
    await queryRunner.query(`
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

      CREATE TYPE user_role AS ENUM ('consumer', 'merchant', 'association', 'admin');
      CREATE TYPE language AS ENUM ('ar', 'fr');
      CREATE TYPE offer_status AS ENUM ('draft', 'active', 'sold_out', 'expired', 'cancelled');
      CREATE TYPE expiry_type AS ENUM ('DLC', 'DDM');
      CREATE TYPE reservation_status AS ENUM ('pending_payment', 'confirmed', 'picked_up', 'cancelled', 'no_show');
      CREATE TYPE donation_status AS ENUM ('available', 'reserved', 'completed', 'reported');
      CREATE TYPE institutional_donation_status AS ENUM ('announced', 'accepted', 'transferred', 'completed');
      CREATE TYPE commission_type AS ENUM ('percentage', 'fixed');
      CREATE TYPE payment_provider AS ENUM ('mock', 'satim', 'baridimob');

      CREATE TABLE users (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        phone_number VARCHAR(20) UNIQUE NOT NULL,
        display_name VARCHAR(100),
        role user_role DEFAULT 'consumer',
        language_preference language DEFAULT 'fr',
        is_verified BOOLEAN DEFAULT FALSE,
        consent_payment BOOLEAN DEFAULT FALSE,
        consent_geolocation BOOLEAN DEFAULT FALSE,
        consent_notifications BOOLEAN DEFAULT FALSE,
        consent_timestamp TIMESTAMP,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW(),
        deleted_at TIMESTAMP
      );

      CREATE TABLE otp_codes (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        phone_number VARCHAR(20) NOT NULL,
        code VARCHAR(10) NOT NULL,
        is_used BOOLEAN DEFAULT FALSE,
        expires_at TIMESTAMP NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE sponsor_campaigns (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        sponsor_name VARCHAR(200) NOT NULL,
        condition_description TEXT NOT NULL,
        sponsored_offers_count_limit INTEGER NOT NULL,
        sponsored_offers_count_used INTEGER DEFAULT 0,
        budget_remaining DECIMAL(12, 2) NOT NULL,
        active BOOLEAN DEFAULT TRUE,
        created_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE offers (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        merchant_id UUID NOT NULL REFERENCES users(id),
        sponsor_campaign_id UUID REFERENCES sponsor_campaigns(id),
        title VARCHAR(200) NOT NULL,
        initial_value DECIMAL(10, 2) NOT NULL,
        sale_price DECIMAL(10, 2) NOT NULL,
        quantity_available INTEGER NOT NULL,
        pickup_window_start TIMESTAMP NOT NULL,
        pickup_window_end TIMESTAMP NOT NULL,
        expiry_type expiry_type DEFAULT 'DDM',
        expiry_date DATE,
        photo_url VARCHAR(500),
        latitude DECIMAL(9, 7),
        longitude DECIMAL(10, 7),
        status offer_status DEFAULT 'draft',
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE reservations (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        offer_id UUID NOT NULL REFERENCES offers(id),
        consumer_id UUID NOT NULL REFERENCES users(id),
        status reservation_status DEFAULT 'pending_payment',
        payment_reference VARCHAR(100),
        qr_code_token TEXT,
        reserved_at TIMESTAMP DEFAULT NOW(),
        confirmed_at TIMESTAMP,
        picked_up_at TIMESTAMP
      );

      CREATE TABLE donations (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        donor_id UUID NOT NULL REFERENCES users(id),
        title VARCHAR(200) NOT NULL,
        description TEXT,
        photo_url VARCHAR(500),
        neighborhood VARCHAR(100) NOT NULL,
        status donation_status DEFAULT 'available',
        created_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE messages (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        donation_id UUID NOT NULL REFERENCES donations(id),
        sender_id UUID NOT NULL REFERENCES users(id),
        content TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE reports (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        donation_id UUID NOT NULL REFERENCES donations(id),
        reporter_id UUID NOT NULL REFERENCES users(id),
        reason TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE institutional_donations (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        professional_id UUID NOT NULL REFERENCES users(id),
        association_id UUID NOT NULL REFERENCES users(id),
        description TEXT NOT NULL,
        estimated_quantity VARCHAR(200),
        status institutional_donation_status DEFAULT 'announced',
        transfer_deed_url VARCHAR(500),
        liability_transferred_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE transfer_deeds (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        institutional_donation_id UUID NOT NULL UNIQUE REFERENCES institutional_donations(id),
        pdf_url VARCHAR(500) NOT NULL,
        verification_hash VARCHAR(64) NOT NULL,
        generated_at TIMESTAMP DEFAULT NOW(),
        signed_at TIMESTAMP
      );

      CREATE TABLE pricing_configs (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        segment VARCHAR(50) NOT NULL,
        commission_type commission_type DEFAULT 'percentage',
        commission_value DECIMAL(10, 4) NOT NULL,
        is_active BOOLEAN DEFAULT TRUE,
        effective_from TIMESTAMP DEFAULT NOW(),
        created_at TIMESTAMP DEFAULT NOW()
      );

      CREATE TABLE audit_logs (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        user_id UUID,
        action VARCHAR(200) NOT NULL,
        entity_type VARCHAR(100),
        entity_id VARCHAR(100),
        metadata JSONB,
        ip_address VARCHAR(50),
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.query(`
      DROP TABLE IF EXISTS audit_logs CASCADE;
      DROP TABLE IF EXISTS pricing_configs CASCADE;
      DROP TABLE IF EXISTS transfer_deeds CASCADE;
      DROP TABLE IF EXISTS institutional_donations CASCADE;
      DROP TABLE IF EXISTS reports CASCADE;
      DROP TABLE IF EXISTS messages CASCADE;
      DROP TABLE IF EXISTS donations CASCADE;
      DROP TABLE IF EXISTS reservations CASCADE;
      DROP TABLE IF EXISTS offers CASCADE;
      DROP TABLE IF EXISTS sponsor_campaigns CASCADE;
      DROP TABLE IF EXISTS otp_codes CASCADE;
      DROP TABLE IF EXISTS users CASCADE;
      DROP TYPE IF EXISTS payment_provider;
      DROP TYPE IF EXISTS commission_type;
      DROP TYPE IF EXISTS institutional_donation_status;
      DROP TYPE IF EXISTS donation_status;
      DROP TYPE IF EXISTS reservation_status;
      DROP TYPE IF EXISTS expiry_type;
      DROP TYPE IF EXISTS offer_status;
      DROP TYPE IF EXISTS language;
      DROP TYPE IF EXISTS user_role;
    `);
  }
}
