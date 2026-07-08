import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

/**
 * All API errors return bilingual messages (FR + AR).
 * This is a non-negotiable requirement per Loi 09-03, art. 18.
 */
interface BilingualError {
  statusCode: number;
  message_fr: string;
  message_ar: string;
  error: string;
  timestamp: string;
  path: string;
}

/** Common error translations */
const ERROR_TRANSLATIONS: Record<string, { fr: string; ar: string }> = {
  Unauthorized: {
    fr: 'Non autorisé',
    ar: 'غير مصرح',
  },
  Forbidden: {
    fr: 'Accès interdit',
    ar: 'الوصول محظور',
  },
  'Not Found': {
    fr: 'Ressource introuvable',
    ar: 'المورد غير موجود',
  },
  'Too Many Requests': {
    fr: 'Trop de requêtes. Veuillez réessayer plus tard.',
    ar: 'طلبات كثيرة جداً. يرجى المحاولة لاحقاً.',
  },
  'Internal Server Error': {
    fr: 'Erreur interne du serveur',
    ar: 'خطأ داخلي في الخادم',
  },
  'Bad Request': {
    fr: 'Requête invalide',
    ar: 'طلب غير صالح',
  },
  'Unprocessable Entity': {
    fr: 'Entité non traitable',
    ar: 'كيان غير قابل للمعالجة',
  },
  Conflict: {
    fr: 'Conflit',
    ar: 'تعارض',
  },
};

@Catch()
export class BilingualExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(BilingualExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let messageFr = 'Erreur interne du serveur';
    let messageAr = 'خطأ داخلي في الخادم';
    let error = 'Internal Server Error';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exResponse = exception.getResponse();
      error = exception.name
        .replace(/Exception$/, '')
        .replace(/([A-Z])/g, ' $1')
        .trim();

      if (typeof exResponse === 'object' && exResponse !== null) {
        const resp = exResponse as Record<string, any>;
        // Check if the module already provided bilingual messages
        if (resp.message_fr && resp.message_ar) {
          messageFr = resp.message_fr;
          messageAr = resp.message_ar;
        } else {
          const msg = resp.message || exception.message;
          const translation = ERROR_TRANSLATIONS[msg] ||
            ERROR_TRANSLATIONS[resp.error] || {
              fr: typeof msg === 'string' ? msg : JSON.stringify(msg),
              ar: typeof msg === 'string' ? msg : JSON.stringify(msg),
            };
          messageFr = translation.fr;
          messageAr = translation.ar;
        }
        if (resp.error) {
          error = resp.error;
        }
      }
    } else if (exception instanceof Error) {
      this.logger.error(
        `Unhandled error: ${exception.message}`,
        exception.stack,
      );
    }

    const errorResponse: BilingualError = {
      statusCode: status,
      message_fr: messageFr,
      message_ar: messageAr,
      error,
      timestamp: new Date().toISOString(),
      path: request.url,
    };

    response.status(status).json(errorResponse);
  }
}
