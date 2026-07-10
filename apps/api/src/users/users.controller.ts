import {
  Controller,
  Post,
  Put,
  Delete,
  Get,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateConsentDto, UpdateProfileDto } from './dto';
import { CurrentUser } from '../common/decorators';
import { User } from '../database/entities';

@ApiTags('Users / المستخدمون')
@Controller('api/v1/users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get current user profile / الملف الشخصي' })
  async getProfile(@CurrentUser() user: User) {
    return {
      id: user.id,
      phone_number: user.phone_number,
      role: user.role,
      display_name: user.display_name,
      language_preference: user.language_preference,
      consent_payment: user.consent_payment,
      consent_geolocation: user.consent_geolocation,
      consent_notifications: user.consent_notifications,
    };
  }

  @Post('consent')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Update granular consents / تحديث الموافقات',
    description: 'Three separate toggles: payment, geolocation, notifications',
  })
  async updateConsent(
    @CurrentUser() user: User,
    @Body() dto: UpdateConsentDto,
  ) {
    return this.usersService.updateConsent(user.id, dto);
  }

  @Put('me')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update profile / تحديث الملف الشخصي' })
  async updateProfile(
    @CurrentUser() user: User,
    @Body() dto: UpdateProfileDto,
  ) {
    return this.usersService.updateProfile(user.id, dto);
  }

  @Put('me/fcm-token')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: 'Update FCM push token / تحديث رمز FCM' })
  async updateFcmToken(
    @CurrentUser() user: User,
    @Body() dto: import('./dto').UpdateFcmTokenDto,
  ) {
    await this.usersService.updateFcmToken(user.id, dto.fcm_token);
    return { status: 'success' };
  }

  @Delete('me')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({
    summary: 'Delete account (right to erasure) / حذف الحساب (الحق في النسيان)',
  })
  async deleteAccount(@CurrentUser() user: User) {
    await this.usersService.deleteAccount(user.id);
  }
}
