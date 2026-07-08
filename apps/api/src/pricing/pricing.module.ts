import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PricingService } from './pricing.service';
import { PricingConfig } from '../database/entities';

@Module({
  imports: [TypeOrmModule.forFeature([PricingConfig])],
  providers: [PricingService],
  exports: [PricingService],
})
export class PricingModule {}
