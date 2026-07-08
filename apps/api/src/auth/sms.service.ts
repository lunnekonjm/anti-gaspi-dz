import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

/**
 * Provider-agnostic SMS service interface.
 * Default: console (free, for development).
 * Production: Twilio, Infobip, or local SMPP provider.
 */
@Injectable()
export class SmsService {
  private readonly logger = new Logger(SmsService.name);
  private readonly provider: string;

  constructor(private readonly configService: ConfigService) {
    this.provider = this.configService.get<string>('SMS_PROVIDER', 'console');
  }

  async sendOtp(phoneNumber: string, code: string): Promise<boolean> {
    const message = `[Anti-Gaspi DZ] Votre code de vérification / رمز التحقق الخاص بك: ${code}`;

    switch (this.provider) {
      case 'console':
        return this.sendViaConsole(phoneNumber, message);
      case 'twilio':
        return this.sendViaTwilio(phoneNumber, message);
      default:
        return this.sendViaConsole(phoneNumber, message);
    }
  }

  private async sendViaConsole(
    phoneNumber: string,
    message: string,
  ): Promise<boolean> {
    this.logger.log(`📱 SMS to ${phoneNumber}: ${message}`);
    return true;
  }

  private async sendViaTwilio(
    phoneNumber: string,
    message: string,
  ): Promise<boolean> {
    // TODO: Implement Twilio integration when credentials are provided
    // const accountSid = this.configService.get('TWILIO_ACCOUNT_SID');
    // const authToken = this.configService.get('TWILIO_AUTH_TOKEN');
    // const fromNumber = this.configService.get('TWILIO_PHONE_NUMBER');
    this.logger.warn(
      'Twilio integration not yet configured, falling back to console',
    );
    return this.sendViaConsole(phoneNumber, message);
  }
}
