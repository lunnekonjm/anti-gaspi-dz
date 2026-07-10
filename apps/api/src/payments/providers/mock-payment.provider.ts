import { Injectable, Logger } from '@nestjs/common';
import * as crypto from 'crypto';

/**
 * Mock payment provider for development and testing.
 * Simulates SATIM/BaridiMob payment flow.
 * Zero card data stored — only payment references.
 */
@Injectable()
export class MockPaymentProvider {
  private readonly logger = new Logger(MockPaymentProvider.name);

  async createPaymentSession(params: {
    amount: number;
    currency: string;
    reservationId: string;
    callbackUrl: string;
  }): Promise<{
    payment_url: string;
    payment_reference: string;
    qr_data: string;
  }> {
    const paymentReference = `MOCK_${crypto.randomUUID().slice(0, 8).toUpperCase()}`;

    this.logger.log(
      `💳 Mock payment session created: ${paymentReference} for ${params.amount} ${params.currency}`,
    );

    return {
      payment_url: `http://localhost:3000/api/v1/payments/mock/pay?ref=${paymentReference}&reservation=${params.reservationId}`,
      payment_reference: paymentReference,
      qr_data: JSON.stringify({
        provider: 'mock',
        reference: paymentReference,
        amount: params.amount,
        currency: params.currency,
      }),
    };
  }

  /**
   * Simulate payment completion — auto-succeeds in mock mode.
   */
  async simulatePaymentCompletion(paymentReference: string): Promise<{
    status: string;
    payment_reference: string;
  }> {
    this.logger.log(`✅ Mock payment completed: ${paymentReference}`);
    return {
      status: 'success',
      payment_reference: paymentReference,
    };
  }

  verifyWebhookSignature(
    _payload: Record<string, any>,
    signature: string,
  ): boolean {
    if (process.env.NODE_ENV === 'production') {
      return false; // Mock webhooks disabled in production
    }
    return signature === 'mock-signature-123';
  }
}
