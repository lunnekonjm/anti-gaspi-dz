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
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get('DATABASE_HOST', 'localhost'),
        port: configService.get<number>('DATABASE_PORT', 5432),
        username: configService.get('DATABASE_USER', 'antigaspi'),
        password: configService.get('DATABASE_PASSWORD', 'antigaspi_dev_2024'),
        database: configService.get('DATABASE_NAME', 'antigaspi'),
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
      }),
      inject: [ConfigService],
    }),

    // Redis cache
    CacheModule.registerAsync({
      isGlobal: true,
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => {
        const host = configService.get('REDIS_HOST', 'localhost');
        const port = configService.get<number>('REDIS_PORT', 6379);
        try {
          const store = await redisStore({
            socket: { host, port },
          });
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
