import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ThrottlerModule } from '@nestjs/throttler';
import { ScheduleModule } from '@nestjs/schedule';
import { CacheModule } from '@nestjs/cache-manager';
import { redisStore } from 'cache-manager-redis-yet';

// Feature modules
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { OffersModule } from './offers/offers.module';
import { ReservationsModule } from './reservations/reservations.module';
import { PaymentsModule } from './payments/payments.module';
import { PricingModule } from './pricing/pricing.module';
import { DonationsModule } from './donations/donations.module';
import { InstitutionalDonationsModule } from './institutional-donations/institutional-donations.module';
import { SponsorshipModule } from './sponsorship/sponsorship.module';
import { DevModule } from './dev/dev.module';

// Entities
import {
  User,
  Offer,
  Reservation,
  Donation,
  Message,
  Report,
  InstitutionalDonation,
  TransferDeed,
  SponsorCampaign,
  PricingConfig,
  AuditLog,
  OtpCode,
} from './database/entities';

@Module({
  imports: [
    // Environment configuration
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),

    // PostgreSQL via TypeORM
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      useFactory: (configService: ConfigService) => {
        const url = configService.get('DATABASE_URL');
        const isProd = configService.get('NODE_ENV') === 'production';
        return {
          type: 'postgres',
          ...(url
            ? {
                url,
                ssl: isProd ? { rejectUnauthorized: false } : false,
              }
            : {
                host: configService.get<string>('DATABASE_HOST', 'localhost'),
                port: configService.get<number>('DATABASE_PORT', 5432),
                username: configService.get<string>('DATABASE_USER', 'antigaspi'),
                password: configService.get<string>(
                  'DATABASE_PASSWORD',
                  'antigaspi_dev_2024',
                ),
                database: configService.get<string>('DATABASE_NAME', 'antigaspi'),
              }),
          entities: [
            User,
            Offer,
            Reservation,
            Donation,
            Message,
            Report,
            InstitutionalDonation,
            TransferDeed,
            SponsorCampaign,
            PricingConfig,
            AuditLog,
            OtpCode,
          ],
          synchronize: true, // Dev only — use migrations in production
          logging: configService.get('NODE_ENV') === 'development',
        };
      },
      inject: [ConfigService],
    }),

    // Redis cache
    CacheModule.registerAsync({
      isGlobal: true,
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const url = configService.get('REDIS_URL');
        const host = configService.get('REDIS_HOST', 'localhost');
        const port = configService.get<number>('REDIS_PORT', 6379);
        try {
          const store = await redisStore(
            url ? { url } : { socket: { host, port } },
          );
          return { store };
        } catch {
          // Fallback to in-memory cache if Redis unavailable
          return { ttl: 60 };
        }
      },
      inject: [ConfigService],
    }),

    // Rate limiting
    ThrottlerModule.forRoot([
      {
        name: 'short',
        ttl: 1000,
        limit: 10,
      },
      {
        name: 'long',
        ttl: 60000,
        limit: 100,
      },
    ]),

    // Scheduled tasks (offer expiry, no-show detection)
    ScheduleModule.forRoot(),

    // Feature modules — all three segments loaded from startup
    AuthModule,
    UsersModule,
    OffersModule,
    ReservationsModule,
    PaymentsModule,
    PricingModule,
    DonationsModule,
    InstitutionalDonationsModule,
    SponsorshipModule,
  ],
})
export class AppModule {}
