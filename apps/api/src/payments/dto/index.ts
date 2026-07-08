import { IsUUID, IsEnum, IsOptional, IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { PaymentProvider } from '../../common/enums';

export class InitiatePaymentDto {
  @ApiProperty({ description: 'Reservation ID / معرف الحجز' })
  @IsUUID()
  reservation_id: string;

  @ApiProperty({
    description: 'Payment provider / مزود الدفع',
    enum: PaymentProvider,
    default: PaymentProvider.MOCK,
  })
  @IsOptional()
  @IsEnum(PaymentProvider)
  provider?: PaymentProvider;
}

export class PaymentWebhookDto {
  @ApiProperty({ description: 'Payment reference from PSP' })
  @IsString()
  payment_reference: string;

  @ApiProperty({ description: 'Reservation ID' })
  @IsUUID()
  reservation_id: string;

  @ApiProperty({ description: 'Payment status' })
  @IsString()
  status: string;

  @ApiProperty({
    description: 'Webhook signature for verification',
    required: false,
  })
  @IsOptional()
  @IsString()
  signature?: string;
}
