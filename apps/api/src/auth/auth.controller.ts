import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { RequestOtpDto, VerifyOtpDto } from './dto';

@ApiTags('Auth / المصادقة')
@Controller('api/v1/auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('otp/request')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Request OTP via SMS / طلب رمز التحقق عبر الرسائل القصيرة',
  })
  @ApiResponse({
    status: 200,
    description: 'OTP sent successfully / تم إرسال رمز التحقق بنجاح',
  })
  @ApiResponse({
    status: 429,
    description: 'Rate limit exceeded (5/hour) / تم تجاوز حد المحاولات',
  })
  async requestOtp(@Body() dto: RequestOtpDto) {
    return this.authService.requestOtp(dto.phone_number);
  }

  @Post('otp/verify')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Verify OTP and get JWT / التحقق من الرمز والحصول على رمز الدخول',
  })
  @ApiResponse({
    status: 200,
    description: 'Authentication successful / المصادقة ناجحة',
  })
  @ApiResponse({
    status: 401,
    description: 'Invalid or expired OTP / رمز غير صالح أو منتهي الصلاحية',
  })
  async verifyOtp(@Body() dto: VerifyOtpDto) {
    return this.authService.verifyOtp(dto.phone_number, dto.code);
  }
}
