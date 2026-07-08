import { IsBoolean, IsOptional, IsString, IsEnum } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';
import { Language, UserRole } from '../../common/enums';

export class UpdateConsentDto {
  @ApiProperty({ description: 'Consent for payment / الموافقة على الدفع' })
  @IsBoolean()
  consent_payment: boolean;

  @ApiProperty({ description: 'Consent for geolocation / الموافقة على تحديد الموقع' })
  @IsBoolean()
  consent_geolocation: boolean;

  @ApiProperty({ description: 'Consent for notifications / الموافقة على الإشعارات' })
  @IsBoolean()
  consent_notifications: boolean;
}

export class UpdateProfileDto {
  @ApiProperty({ required: false })
  @IsOptional()
  @IsString()
  display_name?: string;

  @ApiProperty({ required: false, enum: Language })
  @IsOptional()
  @IsEnum(Language)
  language_preference?: Language;

  @ApiProperty({ required: false, enum: UserRole })
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;
}
