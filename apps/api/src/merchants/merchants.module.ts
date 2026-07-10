import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { MerchantsService } from './merchants.service';
import { MerchantsController } from './merchants.controller';
import { MerchantRequest, User } from '../database/entities';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([MerchantRequest, User]),
    NotificationsModule,
  ],
  providers: [MerchantsService],
  controllers: [MerchantsController]
})
export class MerchantsModule {}
