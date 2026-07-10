import {
  Injectable,
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
  SetMetadata,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

/**
 * Closes P3-03: Consent gating guard.
 *
 * Checks that the authenticated user has granted the required consent
 * before allowing the request to proceed. Applied via @RequireConsent() decorator.
 *
 * Usage:
 *   @UseGuards(AuthGuard('jwt'), ConsentGuard)
 *   @RequireConsent('consent_payment')
 *   async initiatePayment(...) { ... }
 */
export const CONSENT_KEY = 'required_consent';
export const RequireConsent = (...consents: string[]) =>
  SetMetadata(CONSENT_KEY, consents);

@Injectable()
export class ConsentGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredConsents = this.reflector.get<string[]>(
      CONSENT_KEY,
      context.getHandler(),
    );

    if (!requiredConsents || requiredConsents.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      return true; // No user = let AuthGuard handle it
    }

    for (const consent of requiredConsents) {
      if (!user[consent]) {
        throw new HttpException(
          {
            message_fr: `Veuillez accepter le consentement requis avant de continuer.`,
            message_ar: `يرجى قبول الموافقة المطلوبة قبل المتابعة.`,
            error: 'Forbidden',
            required_consent: consent,
          },
          HttpStatus.FORBIDDEN,
        );
      }
    }

    return true;
  }
}
