import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SponsorshipService } from './sponsorship.service';
import { SponsorCampaign } from '../database/entities';

@Module({
  imports: [TypeOrmModule.forFeature([SponsorCampaign])],
  providers: [SponsorshipService],
  exports: [SponsorshipService],
})
export class SponsorshipModule {}
