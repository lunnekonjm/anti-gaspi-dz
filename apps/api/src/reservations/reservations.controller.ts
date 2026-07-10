import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  UseInterceptors,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ReservationsService } from './reservations.service';
import { CreateReservationDto, RedeemReservationDto } from './dto';
import { CurrentUser, Roles } from '../common/decorators';
import { RolesGuard } from '../common/guards';
import { AuditLogInterceptor } from '../common/interceptors';
import { User } from '../database/entities';
import { UserRole } from '../common/enums';

@ApiTags('Reservations / الحجوزات')
@Controller('api/v1/reservations')
export class ReservationsController {
  constructor(private readonly reservationsService: ReservationsService) {}

  @Post()
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(AuditLogInterceptor)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Create reservation / إنشاء حجز',
    description: 'Atomic booking with anti-overbooking protection',
  })
  async create(@CurrentUser() user: User, @Body() dto: CreateReservationDto) {
    return this.reservationsService.create(user.id, dto);
  }

  @Post(':id/redeem')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.MERCHANT)
  @UseInterceptors(AuditLogInterceptor)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary:
      'Redeem reservation via QR scan (merchant) / تأكيد الاستلام عبر مسح QR (التاجر)',
  })
  // Closes S2-07: Merchant-ownership verification on redeem
  async redeem(@CurrentUser() user: User, @Param('id') id: string, @Body() dto: RedeemReservationDto) {
    return this.reservationsService.redeem(id, dto.qr_code_token, user.id);
  }

  @Post(':id/cancel')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(AuditLogInterceptor)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Cancel reservation / إلغاء الحجز',
  })
  async cancel(@CurrentUser() user: User, @Param('id') id: string) {
    return this.reservationsService.cancel(id, user.id);
  }

  @Get('mine')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Get my reservations / حجوزاتي',
  })
  async findMine(@CurrentUser() user: User) {
    return this.reservationsService.findByConsumer(user.id);
  }

  @Get('merchant')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.MERCHANT)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Get merchant reservations (Admin/Merchant only)',
  })
  async findForMerchant(@CurrentUser() user: User) {
    return this.reservationsService.findByMerchant(user.id);
  }
}
