import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { DataPurgeService } from './data-purge.service';
import { User } from '../database/entities';

@Module({
  imports: [TypeOrmModule.forFeature([User])],
  controllers: [UsersController],
  providers: [UsersService, DataPurgeService],
  exports: [UsersService],
})
export class UsersModule {}
