import { Controller, Post, Get, Body, Param, UseGuards, Put } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { ReportsService } from './reports.service';
import { CreateReportDto } from './dto';
import { CurrentUser } from '../common/decorators';
import { User, ReportStatus } from '../database/entities';
import { RolesGuard } from '../common/guards/roles.guard';
import { Roles } from '../common/decorators/roles.decorator';
import { UserRole } from '../common/enums';

@ApiTags('Reports / Signalements')
@Controller('api/v1/reports')
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Post()
  @UseGuards(AuthGuard('jwt'))
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Submit a new report' })
  async createReport(
    @CurrentUser() user: User,
    @Body() dto: CreateReportDto,
  ) {
    return this.reportsService.createReport(user.id, dto);
  }

  @Get()
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Get all reports (Admin only)' })
  async getAllReports() {
    return this.reportsService.getAllReports();
  }

  @Put(':id/status')
  @UseGuards(AuthGuard('jwt'), RolesGuard)
  @Roles(UserRole.ADMIN)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Update report status (Admin only)' })
  async updateReportStatus(
    @Param('id') id: string,
    @Body('status') status: ReportStatus,
  ) {
    return this.reportsService.updateReportStatus(id, status);
  }
}
