import {
  Controller,
  Post,
  Get,
  Body,
  Query,
  UseGuards,
  UseInterceptors,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { PaymentsService } from './payments.service';
import { InitiatePaymentDto, PaymentWebhookDto } from './dto';
import { AuditLogInterceptor } from '../common/interceptors';
import { ConsentGuard, RequireConsent } from '../common/guards';

@ApiTags('Payments / المدفوعات')
@Controller('api/v1/payments')
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post('initiate')
  // Closes P3-03: Require payment consent before initiating payment
  @UseGuards(AuthGuard('jwt'), ConsentGuard)
  @RequireConsent('consent_payment')
  @UseInterceptors(AuditLogInterceptor)
  @ApiBearerAuth()
  @ApiOperation({
    summary: 'Initiate payment via SATIM/BaridiMob / بدء الدفع',
    description: 'No card data stored on platform — full PSP delegation',
  })
  async initiatePayment(@Body() dto: InitiatePaymentDto) {
    return this.paymentsService.initiatePayment(dto);
  }

  @Post('webhook')
  @UseInterceptors(AuditLogInterceptor)
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: 'PSP webhook callback / استدعاء webhook من مزود الدفع',
  })
  async handleWebhook(@Body() dto: PaymentWebhookDto) {
    return this.paymentsService.handleWebhook(dto);
  }

  /**
   * Mock payment completion endpoint (development only).
   * Simulates user completing payment on PSP side.
   */
  @Get('mock/pay')
  @ApiOperation({
    summary: '[DEV ONLY] Simulate mock payment completion',
  })
  async mockPayment(
    @Query('ref') ref: string,
    @Query('reservation') reservationId: string,
  ) {
    if (process.env.NODE_ENV === 'production') {
      const { ForbiddenException } = require('@nestjs/common');
      throw new ForbiddenException('Mock payments are disabled in production');
    }
    return this.paymentsService.simulateMockPayment(ref, reservationId);
  }
}
