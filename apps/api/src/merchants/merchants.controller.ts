import { Controller, Post, Get, Body, Param, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { MerchantsService } from './merchants.service';
import { CreateMerchantRequestDto } from './dto';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UserRole } from '../common/enums';
import { CurrentUser } from '../common/decorators';
import { User } from '../database/entities';

@ApiTags('Merchants / التجار')
@Controller('api/v1/merchants')
export class MerchantsController {
  constructor(private readonly merchantsService: MerchantsService) {}

  @Post('onboard')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Submit a merchant onboarding request' })
  async createRequest(
    @CurrentUser() user: User,
    @Body() dto: CreateMerchantRequestDto,
  ) {
    return this.merchantsService.createRequest(user.id, dto);
  }

  // NOTE: Admin endpoints are located here for convenience, 
  // but ideally they'd be in an Admin module.
  @Get('requests')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all pending merchant requests (Admin only)' })
  async getPendingRequests() {
    return this.merchantsService.getPendingRequests();
  }

  @Post('requests/:id/approve')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Approve a merchant request (Admin only)' })
  async approveRequest(@Param('id') id: string) {
    return this.merchantsService.approveRequest(id);
  }

  @Post('requests/:id/reject')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Reject a merchant request (Admin only)' })
  async rejectRequest(@Param('id') id: string) {
    return this.merchantsService.rejectRequest(id);
  }
}
