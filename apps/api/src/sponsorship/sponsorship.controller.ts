import { Controller, Post, Get, Body, Param, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { SponsorshipService } from './sponsorship.service';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UserRole } from '../common/enums';
import { SponsorCampaign } from '../database/entities';

@ApiTags('Sponsorship / Campagnes')
@Controller('api/v1/sponsorships')
export class SponsorshipController {
  constructor(private readonly sponsorshipService: SponsorshipService) {}

  @Get('active')
  @ApiOperation({ summary: 'Get all active sponsorship campaigns' })
  async getActiveCampaigns() {
    return this.sponsorshipService.findActive();
  }

  @Post()
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Create a new sponsorship campaign (Admin only)' })
  async createCampaign(@Body() dto: Partial<SponsorCampaign>) {
    return this.sponsorshipService.create(dto);
  }
}
