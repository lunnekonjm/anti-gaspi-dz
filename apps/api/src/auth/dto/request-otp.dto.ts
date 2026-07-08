import { IsString, IsNotEmpty, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RequestOtpDto {
  @ApiProperty({
    description: 'Phone number in E.164 format / رقم الهاتف',
    example: '+213551234567',
  })
  @IsString()
  @IsNotEmpty()
  @Matches(/^\+213[567]\d{8}$/, {
    message:
      'Phone number must be a valid Algerian mobile number (E.164) / يجب أن يكون رقم هاتف جزائري صالح',
  })
  phone_number: string;
}
