import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DevController } from './dev.controller';
import { Offer } from '../database/entities/offer.entity';
import { User } from '../database/entities/user.entity';
import { Donation } from '../database/entities/donation.entity';
import { InstitutionalDonation } from '../database/entities/institutional-donation.entity';
import { Reservation } from '../database/entities/reservation.entity';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      Offer,
      User,
      Donation,
      InstitutionalDonation,
      Reservation,
    ]),
  ],
  controllers: [DevController],
})
export class DevModule {}
