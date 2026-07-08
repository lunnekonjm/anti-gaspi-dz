import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  Param,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiQuery,
} from '@nestjs/swagger';
import { OffersService } from './offers.service';
import { CreateOfferDto } from './dto';
import { CurrentUser, Roles } from '../common/decorators';
import { RolesGuard } from '../common/guards';
import { AuditLogInterceptor } from '../common/interceptors';
import { User } from '../database/entities';
import { UserRole } from '../common/enums';

@ApiTags('Offers / العروض')
@Controller('api/v1/offers')
export class OffersController {
  constructor(private readonly offersService: OffersService) {}

  @Get()
  @ApiOperation({
    summary: 'List active offers (with optional geolocation filter) / قائمة العروض النشطة',
  })
  @ApiQuery({ name: 'lat', required: false, type: Number })
  @ApiQuery({ name: 'lng', required: false, type: Number })
  @ApiQuery({ name: 'radius', required: false, type: Number, description: 'Radius in km' })
  async findActive(
    @Query('lat') lat?: string,
    @Query('lng') lng?: string,
    @Query('radius') radius?: string,
  ) {
    return this.offersService.findActive(
      lat ? parseFloat(lat) : undefined,
      lng ? parseFloat(lng) : undefined,
      radius ? parseFloat(radius) : undefined,
    );
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get offer by ID / الحصول على عرض بالمعرف' })
  async findById(@Param('id') id: string) {
    return this.offersService.findById(id);
  }

  @Post()
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.MERCHANT)
  @UseInterceptors(AuditLogInterceptor)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Create offer (merchant only) / إنشاء عرض (التجار فقط)',
  })
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateOfferDto,
  ) {
    return this.offersService.create(user.id, dto);
  }

  @Get('merchant/mine')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.MERCHANT)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Get my offers (merchant) / عروضي (التاجر)',
  })
  async findMyOffers(@CurrentUser() user: User) {
    return this.offersService.findByMerchant(user.id);
  }
}
