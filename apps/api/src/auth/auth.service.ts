import { Injectable, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, MoreThan } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { User, OtpCode } from '../database/entities';
import { SmsService } from './sms.service';

@Injectable()
export class AuthService {
  private readonly logger = new Logger(AuthService.name);
  private readonly otpLength: number;
  private readonly otpExpiryMinutes: number;
  private readonly otpMaxAttemptsPerHour: number;

  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    @InjectRepository(OtpCode)
    private readonly otpRepository: Repository<OtpCode>,
    private readonly jwtService: JwtService,
    private readonly smsService: SmsService,
    private readonly configService: ConfigService,
  ) {
    this.otpLength = this.configService.get<number>('OTP_LENGTH', 6);
    this.otpExpiryMinutes = this.configService.get<number>(
      'OTP_EXPIRY_MINUTES',
      5,
    );
    this.otpMaxAttemptsPerHour = this.configService.get<number>(
      'OTP_MAX_ATTEMPTS_PER_HOUR',
      5,
    );
  }

  /**
   * Request OTP — sends a code via SMS.
   * Rate limited: max 5 requests per hour per phone number.
   */
  async requestOtp(
    phoneNumber: string,
  ): Promise<{ message_fr: string; message_ar: string }> {
    // Rate limiting: count OTPs sent in last hour
    const oneHourAgo = new Date(Date.now() - 60 * 60 * 1000);
    const recentCount = await this.otpRepository.count({
      where: {
        phone_number: phoneNumber,
        created_at: MoreThan(oneHourAgo),
      },
    });

    if (recentCount >= this.otpMaxAttemptsPerHour) {
      throw new HttpException(
        {
          message_fr: `Trop de tentatives. Veuillez réessayer dans 1 heure. (${this.otpMaxAttemptsPerHour} max/heure)`,
          message_ar: `محاولات كثيرة جداً. يرجى المحاولة بعد ساعة. (${this.otpMaxAttemptsPerHour} كحد أقصى/ساعة)`,
          error: 'Too Many Requests',
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    // Generate OTP code
    const code = this.generateOtpCode();
    const expiresAt = new Date(Date.now() + this.otpExpiryMinutes * 60 * 1000);

    // Save OTP
    const otp = this.otpRepository.create({
      phone_number: phoneNumber,
      code,
      expires_at: expiresAt,
    });
    await this.otpRepository.save(otp);

    // Send via SMS
    await this.smsService.sendOtp(phoneNumber, code);

    return {
      message_fr: 'Code de vérification envoyé par SMS',
      message_ar: 'تم إرسال رمز التحقق عبر الرسائل القصيرة',
    };
  }

  /**
   * Verify OTP + issue JWT.
   * Creates user account if first login.
   */
  async verifyOtp(
    phoneNumber: string,
    code: string,
  ): Promise<{
    access_token: string;
    user: Partial<User>;
    is_new_user: boolean;
  }> {
    // Find valid OTP
    const otp = await this.otpRepository.findOne({
      where: {
        phone_number: phoneNumber,
        code,
        is_used: false,
        expires_at: MoreThan(new Date()),
      },
      order: { created_at: 'DESC' },
    });

    if (!otp) {
      throw new HttpException(
        {
          message_fr: 'Code invalide ou expiré. Veuillez réessayer.',
          message_ar: 'رمز غير صالح أو منتهي الصلاحية. يرجى المحاولة مرة أخرى.',
          error: 'Unauthorized',
        },
        HttpStatus.UNAUTHORIZED,
      );
    }

    // Mark OTP as used
    otp.is_used = true;
    await this.otpRepository.save(otp);

    // Find or create user
    let user = await this.userRepository.findOne({
      where: { phone_number: phoneNumber },
    });
    let isNewUser = false;

    if (!user) {
      user = this.userRepository.create({
        phone_number: phoneNumber,
        is_verified: true,
      });
      await this.userRepository.save(user);
      isNewUser = true;
    } else {
      if (!user.is_verified) {
        user.is_verified = true;
        await this.userRepository.save(user);
      }
    }

    // Generate JWT
    const payload = {
      sub: user.id,
      phone: user.phone_number,
      role: user.role,
    };
    const accessToken = this.jwtService.sign(payload);

    return {
      access_token: accessToken,
      user: {
        id: user.id,
        phone_number: user.phone_number,
        role: user.role,
        display_name: user.display_name,
        language_preference: user.language_preference,
        consent_payment: user.consent_payment,
        consent_geolocation: user.consent_geolocation,
        consent_notifications: user.consent_notifications,
      },
      is_new_user: isNewUser,
    };
  }

  private generateOtpCode(): string {
    // In development (mocked SMS), always use 123456 to make testing easy
    if (process.env.SMS_PROVIDER === 'console' || !process.env.SMS_PROVIDER) {
      return '123456';
    }

    const digits = '0123456789';
    let code = '';
    for (let i = 0; i < this.otpLength; i++) {
      code += digits.charAt(Math.floor(Math.random() * digits.length));
    }
    return code;
  }
}
