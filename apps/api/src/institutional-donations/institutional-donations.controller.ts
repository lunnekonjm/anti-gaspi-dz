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
import { InstitutionalDonationsService } from './institutional-donations.service';
import { CreateInstitutionalDonationDto } from './dto';
import { CurrentUser, Roles } from '../common/decorators';
import { RolesGuard } from '../common/guards';
import { AuditLogInterceptor } from '../common/interceptors';
import { User } from '../database/entities';
import { UserRole } from '../common/enums';

@ApiTags('Institutional Donations B2A / التبرعات المؤسسية')
@Controller('api/v1/institutional-donations')
export class InstitutionalDonationsController {
  constructor(
    private readonly service: InstitutionalDonationsService,
  ) {}

  @Post()
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.MERCHANT)
  @UseInterceptors(AuditLogInterceptor)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Announce surplus donation (professional) / الإعلان عن فائض (المهني)',
  })
  async create(
    @CurrentUser() user: User,
    @Body() dto: CreateInstitutionalDonationDto,
  ) {
    return this.service.create(user.id, dto);
  }

  @Post(':id/accept')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.ASSOCIATION)
  @UseInterceptors(AuditLogInterceptor)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Accept donation (association) / قبول التبرع (الجمعية)',
  })
  async accept(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ) {
    return this.service.accept(id, user.id);
  }

  @Post(':id/transfer')
  @UseGuards(AuthGuard('jwt'))
  @UseInterceptors(AuditLogInterceptor)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Generate transfer deed PDF / إنشاء وثيقة التنازل PDF',
    description: 'Server-side PDF generation with SHA-256 hash verification',
  })
  async generateTransferDeed(@Param('id') id: string) {
    return this.service.generateTransferDeed(id);
  }

  @Post(':id/sign')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.ASSOCIATION)
  @UseInterceptors(AuditLogInterceptor)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'Sign transfer deed (association) / توقيع وثيقة التنازل (الجمعية)',
    description: 'Sets liability_transferred_at — legal liability transfer moment',
  })
  async signTransferDeed(
    @CurrentUser() user: User,
    @Param('id') id: string,
  ) {
    return this.service.signTransferDeed(id, user.id);
  }

  @Get('associations')
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'List registered associations / قائمة الجمعيات المسجلة',
  })
  async getAssociations() {
    return this.service.getAssociations();
  }

  @Get('professional/mine')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.MERCHANT)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'My donations as professional / تبرعاتي كمهني',
  })
  async findMyDonations(@CurrentUser() user: User) {
    return this.service.findByProfessional(user.id);
  }

  @Get('association/mine')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.ASSOCIATION)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Donations received as association / التبرعات المستلمة كجمعية',
  })
  async findReceivedDonations(@CurrentUser() user: User) {
    return this.service.findByAssociation(user.id);
  }
}
