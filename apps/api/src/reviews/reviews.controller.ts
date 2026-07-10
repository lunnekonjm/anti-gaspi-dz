import { Controller, Post, Get, Body, Param, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto';
import { CurrentUser } from '../common/decorators';
import { User } from '../database/entities';

@ApiTags('Reviews / Avis')
@Controller('api/v1')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Post('reviews')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a review for a reservation' })
  async createReview(
    @CurrentUser() user: User,
    @Body() dto: CreateReviewDto,
  ) {
    return this.reviewsService.createReview(user.id, dto);
  }

  @Get('merchants/:merchantId/reviews')
  @ApiOperation({ summary: 'Get all reviews for a merchant' })
  async getMerchantReviews(@Param('merchantId') merchantId: string) {
    return this.reviewsService.getMerchantReviews(merchantId);
  }

  @Get('merchants/:merchantId/rating')
  @ApiOperation({ summary: 'Get average rating for a merchant' })
  async getMerchantAverageRating(@Param('merchantId') merchantId: string) {
    return this.reviewsService.getMerchantAverageRating(merchantId);
  }
}
