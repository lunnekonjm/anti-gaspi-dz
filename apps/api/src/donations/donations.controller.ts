import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { DonationsService } from './donations.service';
import { CreateDonationDto, CreateMessageDto, CreateReportDto } from './dto';
import { CurrentUser } from '../common/decorators';
import { User } from '../database/entities';

@ApiTags('Donations C2C / التبرعات العائلية')
@Controller('api/v1/donations')
export class DonationsController {
  constructor(private readonly donationsService: DonationsService) {}

  @Post()
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Create donation (family tab) / إنشاء تبرع (تبويب العائلة)',
    description: 'Neighborhood from closed list only — no exact address',
  })
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateDonationDto,
  ) {
    return this.donationsService.create(user.id, dto);
  }

  @Get()
  @ApiOperation({
    summary: 'List available donations by neighborhood / قائمة التبرعات حسب الحي',
  })
  async findAll(@Query('neighborhood') neighborhood?: string) {
    return this.donationsService.findByNeighborhood(neighborhood);
  }

  @Get('communes')
  @ApiOperation({
    summary: 'Get list of valid communes for dropdown / قائمة البلديات الصالحة',
  })
  getCommunes() {
    return this.donationsService.getCommunes();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get donation by ID / الحصول على تبرع بالمعرف' })
  async findById(@Param('id') id: string) {
    return this.donationsService.findById(id);
  }

  @Post(':id/messages')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Send message (phone numbers stripped) / إرسال رسالة (أرقام الهاتف مخفية)',
  })
  async sendMessage(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: CreateMessageDto,
  ) {
    return this.donationsService.sendMessage(id, user.id, dto);
  }

  @Get(':id/messages')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get donation messages / رسائل التبرع' })
  async getMessages(@Param('id') id: string) {
    return this.donationsService.getMessages(id);
  }

  @Post(':id/report')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Report donation / الإبلاغ عن تبرع' })
  async report(
    @CurrentUser() user: User,
    @Param('id') id: string,
    @Body() dto: CreateReportDto,
  ) {
    return this.donationsService.report(id, user.id, dto);
  }
}
