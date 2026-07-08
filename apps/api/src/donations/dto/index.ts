import { IsString, IsOptional, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { DonationStatus } from '../../common/enums';

export class CreateDonationDto {
  @ApiProperty({ description: 'Title / العنوان', example: 'Couscous fait maison' })
  @IsString()
  title: string;

  @ApiProperty({ description: 'Description / الوصف' })
  @IsString()
  description: string;

  @ApiProperty({ required: false, description: 'Photo URL / رابط الصورة' })
  @IsOptional()
  @IsString()
  photo_url?: string;

  @ApiProperty({
    description: 'Neighborhood from closed list / الحي من القائمة المغلقة',
    example: 'Bab El Oued',
  })
  @IsString()
  neighborhood: string;
}

export class CreateMessageDto {
  @ApiProperty({ description: 'Message content (phone numbers will be stripped) / محتوى الرسالة' })
  @IsString()
  content: string;
}

export class CreateReportDto {
  @ApiProperty({ description: 'Report reason / سبب البلاغ' })
  @IsString()
  reason: string;
}
