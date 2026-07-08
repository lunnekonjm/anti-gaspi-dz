import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { InstitutionalDonationsController } from './institutional-donations.controller';
import { InstitutionalDonationsService } from './institutional-donations.service';
import {
  InstitutionalDonation,
  TransferDeed,
  User,
  AuditLog,
} from '../database/entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([InstitutionalDonation, TransferDeed, User, AuditLog]),
  ],
  controllers: [InstitutionalDonationsController],
  providers: [InstitutionalDonationsService],
  exports: [InstitutionalDonationsService],
})
export class InstitutionalDonationsModule {}
