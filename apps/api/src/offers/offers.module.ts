import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { OffersController } from './offers.controller';
import { OffersService } from './offers.service';
import { LocationPrivacyService } from './location-privacy.service';
import { Offer, AuditLog } from '../database/entities';

@Module({
  imports: [TypeOrmModule.forFeature([Offer, AuditLog])],
  controllers: [OffersController],
  providers: [OffersService, LocationPrivacyService],
  exports: [OffersService],
})
export class OffersModule {}
