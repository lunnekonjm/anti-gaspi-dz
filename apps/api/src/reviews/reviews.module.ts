import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ReviewsService } from './reviews.service';
import { ReviewsController } from './reviews.controller';
import { Review, Reservation } from '../database/entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([Review, Reservation]),
  ],
  providers: [ReviewsService],
  controllers: [ReviewsController]
})
export class ReviewsModule {}
