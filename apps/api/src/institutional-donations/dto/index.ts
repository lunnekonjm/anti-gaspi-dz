import { IsString, IsUUID, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateInstitutionalDonationDto {
  @ApiProperty({ description: 'Association ID / معرف الجمعية' })
  @IsUUID()
  association_id: string;

  @ApiProperty({
    description: 'Description of donated items / وصف المواد المتبرع بها',
  })
  @IsString()
  description: string;

  @ApiProperty({
    description: 'Estimated quantity / الكمية المقدرة',
    example: '50 kg de pain',
  })
  @IsString()
  estimated_quantity: string;
}
