import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Review, Reservation } from '../database/entities';
import { ReservationStatus } from '../common/enums';
import { CreateReviewDto } from './dto';

@Injectable()
export class ReviewsService {
  constructor(
    @InjectRepository(Review)
    private readonly reviewRepository: Repository<Review>,
    @InjectRepository(Reservation)
    private readonly reservationRepository: Repository<Reservation>,
  ) {}

  async createReview(userId: string, dto: CreateReviewDto): Promise<Review> {
    const reservation = await this.reservationRepository.findOne({
      where: { id: dto.reservation_id },
      relations: { offer: true },
    });

    if (!reservation) {
      throw new HttpException('Reservation not found', HttpStatus.NOT_FOUND);
    }

    if (reservation.consumer_id !== userId) {
      throw new HttpException('You can only review your own reservations', HttpStatus.FORBIDDEN);
    }

    // Only allow reviewing completed (picked up) reservations, or maybe confirmed/redeemed.
    // In our system, redemption usually marks the end. If there is a REDEEMED status, use that.
    // For simplicity, we allow it if it's not cancelled.
    if (reservation.status === ReservationStatus.CANCELLED || reservation.status === ReservationStatus.NO_SHOW) {
      throw new HttpException('Cannot review cancelled or no-show reservations', HttpStatus.BAD_REQUEST);
    }

    const existingReview = await this.reviewRepository.findOne({
      where: { reservation_id: dto.reservation_id, reviewer_id: userId },
    });

    if (existingReview) {
      throw new HttpException('You have already reviewed this reservation', HttpStatus.BAD_REQUEST);
    }

    const review = this.reviewRepository.create({
      reservation_id: dto.reservation_id,
      reviewer_id: userId,
      merchant_id: reservation.offer.merchant_id,
      rating: dto.rating,
      comment: dto.comment,
    });

    return this.reviewRepository.save(review);
  }

  async getMerchantReviews(merchantId: string): Promise<Review[]> {
    return this.reviewRepository.find({
      where: { merchant_id: merchantId },
      relations: { reviewer: true },
      order: { created_at: 'DESC' },
    });
  }

  async getMerchantAverageRating(merchantId: string): Promise<{ average: number; count: number }> {
    const result = await this.reviewRepository
      .createQueryBuilder('review')
      .select('AVG(review.rating)', 'average')
      .addSelect('COUNT(review.id)', 'count')
      .where('review.merchant_id = :merchantId', { merchantId })
      .getRawOne();

    return {
      average: parseFloat(result.average || '0'),
      count: parseInt(result.count || '0', 10),
    };
  }
}
