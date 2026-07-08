import { IsUUID, IsString, IsOptional, IsInt, Min } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateReservationDto {
  @ApiProperty({ description: 'Offer ID / معرف العرض' })
  @IsUUID()
  offer_id: string;

  @ApiProperty({
    description: 'Quantity to reserve / الكمية المراد حجزها',
    default: 1,
  })
  @IsOptional()
  @IsInt()
  @Min(1)
  quantity?: number;
}

export class RedeemReservationDto {
  @ApiProperty({
    description: 'QR code token for verification / رمز التحقق من QR',
  })
  @IsString()
  qr_code_token: string;
}
