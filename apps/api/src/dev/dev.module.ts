import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { DevController } from './dev.controller';
import { Offer } from '../database/entities/offer.entity';
import { User } from '../database/entities/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Offer, User])],
  controllers: [DevController],
})
export class DevModule {}
