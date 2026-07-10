import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SponsorshipService } from './sponsorship.service';
import { SponsorCampaign } from '../database/entities';
import { SponsorshipController } from './sponsorship.controller';

@Module({
  imports: [TypeOrmModule.forFeature([SponsorCampaign])],
  providers: [SponsorshipService],
  exports: [SponsorshipService],
  controllers: [SponsorshipController],
})
export class SponsorshipModule {}
