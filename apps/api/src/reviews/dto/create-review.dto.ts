import { IsString, IsNotEmpty, IsNumber, Min, Max, IsOptional } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateReviewDto {
  @ApiProperty({ description: 'ID of the reservation being reviewed' })
  @IsString()
  @IsNotEmpty()
  reservation_id: string;

  @ApiProperty({ description: 'Rating from 1 to 5' })
  @IsNumber()
  @Min(1)
  @Max(5)
  rating: number;

  @ApiPropertyOptional({ description: 'Optional comment' })
  @IsString()
  @IsOptional()
  comment?: string;
}
