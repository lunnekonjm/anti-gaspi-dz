import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OffersController } from './offers.controller';
import { OffersService } from './offers.service';
import { LocationPrivacyService } from './location-privacy.service';
import { AuditRetentionService } from '../common/services/audit-retention.service';
import { Offer, AuditLog } from '../database/entities';

import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [TypeOrmModule.forFeature([Offer, AuditLog]), NotificationsModule],
  controllers: [OffersController],
  providers: [OffersService, LocationPrivacyService, AuditRetentionService],
  exports: [OffersService],
})
export class OffersModule {}
