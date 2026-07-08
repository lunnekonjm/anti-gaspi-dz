import { IsString, IsNotEmpty, Length, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class VerifyOtpDto {
  @ApiProperty({
    description: 'Phone number in E.164 format / رقم الهاتف',
    example: '+213551234567',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+213[567]\d{8}$/)
  phone_number: string;

  @ApiProperty({
    description: 'OTP code received via SMS / رمز التحقق',
    example: '123456',
  })
  @IsString()
  @IsNotEmpty()
  @Length(6, 6)
  code: string;
}
