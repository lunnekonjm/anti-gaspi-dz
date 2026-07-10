import { DataSource } from 'typeorm';
import { config } from 'dotenv';

config(); // Load .env for local development

/**
 * TypeORM CLI datasource configuration for migration generation/running.
 * 
 * Usage:
 *   npx typeorm migration:generate -d ormconfig.ts src/database/migrations/MigrationName
 *   npx typeorm migration:run -d ormconfig.ts
 *   npx typeorm migration:revert -d ormconfig.ts
 */
export default new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  host: process.env.DATABASE_HOST || 'localhost',
  port: parseInt(process.env.DATABASE_PORT || '5432', 10),
  username: process.env.DATABASE_USER || 'antigaspi',
  password: process.env.DATABASE_PASSWORD,
  database: process.env.DATABASE_NAME || 'antigaspi',
  ssl: process.env.NODE_ENV === 'production'
    ? { rejectUnauthorized: true }
    : false,
  entities: ['src/database/entities/**/*.entity.ts'],
  migrations: ['src/database/migrations/*.ts'],
  synchronize: false,
});
