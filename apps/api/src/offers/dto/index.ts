import {
  IsString,
  IsNumber,
  IsEnum,
  IsDateString,
  IsOptional,
  Min,
  IsInt,
} from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { ExpiryType } from '../../common/enums';

export class CreateOfferDto {
  @ApiProperty({ description: 'Offer title / عنوان العرض', example: 'Sac Surprise Boulangerie' })
  @IsString()
  title: string;

  @ApiProperty({ description: 'Original value in DA / القيمة الأصلية بالدينار', example: 500 })
  @IsNumber()
  @Min(0)
  initial_value: number;

  @ApiProperty({ description: 'Sale price in DA / سعر البيع بالدينار', example: 200 })
  @IsNumber()
  @Min(0)
  sale_price: number;

  @ApiProperty({ description: 'Quantity available / الكمية المتوفرة', example: 5 })
  @IsInt()
  @Min(1)
  quantity_available: number;

  @ApiProperty({ description: 'Pickup window start / بداية فترة الاستلام' })
  @IsDateString()
  pickup_window_start: string;

  @ApiProperty({ description: 'Pickup window end / نهاية فترة الاستلام' })
  @IsDateString()
  pickup_window_end: string;

  @ApiProperty({ description: 'Expiry type DLC (hard limit) or DDM (advisory) / نوع الصلاحية', enum: ExpiryType })
  @IsEnum(ExpiryType)
  expiry_type: ExpiryType;

  @ApiProperty({ description: 'Expiry date / تاريخ الصلاحية' })
  @IsDateString()
  expiry_date: string;

  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  photo_url?: string;

  @ApiProperty({ required: false, description: 'Latitude of pickup location' })
  @IsOptional()
  @IsNumber()
  latitude?: number;

  @ApiProperty({ required: false, description: 'Longitude of pickup location' })
  @IsOptional()
  @IsNumber()
  longitude?: number;
}

export class QueryOffersDto {
  @IsOptional()
  @IsNumber()
  lat?: number;

  @IsOptional()
  @IsNumber()
  lng?: number;

  @IsOptional()
  @IsNumber()
  @Min(0.1)
  radius?: number; // in km
}
