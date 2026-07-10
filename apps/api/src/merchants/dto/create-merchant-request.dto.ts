import { IsString, IsNotEmpty, IsOptional, IsUrl } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateMerchantRequestDto {
  @ApiProperty({ description: 'Business name' })
  @IsString()
  @IsNotEmpty()
  business_name: string;

  @ApiProperty({ description: 'Business address' })
  @IsString()
  @IsNotEmpty()
  address: string;

  @ApiPropertyOptional({ description: 'Commercial registry or SIRET' })
  @IsString()
  @IsOptional()
  registration_number?: string;

  @ApiPropertyOptional({ description: 'URL to verification document' })
  @IsUrl()
  @IsOptional()
  document_url?: string;
}
