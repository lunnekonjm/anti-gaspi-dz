import { IsString, IsNotEmpty, IsOptional, IsUUID } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateReportDto {
  @ApiPropertyOptional({ description: 'ID of the donation (for C2C)' })
  @IsUUID()
  @IsOptional()
  donation_id?: string;

  @ApiPropertyOptional({ description: 'ID of the reservation (for B2C)' })
  @IsUUID()
  @IsOptional()
  reservation_id?: string;

  @ApiProperty({ description: 'Reason for the report' })
  @IsString()
  @IsNotEmpty()
  reason: string;
}
