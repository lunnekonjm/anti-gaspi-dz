import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AuditLog } from '../../database/entities';

/**
 * Appends immutable audit log entries for financial transactions
 * and B2A transfer deeds. Append-only — never updates or deletes.
 */
@Injectable()
export class AuditLogInterceptor implements NestInterceptor {
  private readonly logger = new Logger(AuditLogInterceptor.name);

  constructor(
    @InjectRepository(AuditLog)
    private readonly auditLogRepository: Repository<AuditLog>,
  ) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const method = request.method;
    const url = request.url;
    const user = request.user;

    return next.handle().pipe(
      tap(async (responseData) => {
        // Only log mutations on auditable endpoints
        if (['POST', 'PUT', 'PATCH', 'DELETE'].includes(method)) {
          try {
            const auditEntry = this.auditLogRepository.create({
              user_id: user?.id || null,
              action: `${method} ${url}`,
              entity_type: this.extractEntityType(url),
              entity_id: responseData?.id || null,
              metadata: {
                request_body: this.sanitizeBody(request.body),
                response_id: responseData?.id,
              },
              ip_address:
                request.headers['x-forwarded-for'] ||
                request.connection?.remoteAddress ||
                null,
            });
            await this.auditLogRepository.save(auditEntry);
          } catch (error) {
            // Audit failure should never break the request
            this.logger.error('Failed to write audit log', error);
          }
        }
      }),
    );
  }

  private extractEntityType(url: string): string {
    const parts = url.split('/').filter(Boolean);
    // Extract the resource name from the URL (e.g., /api/v1/reservations -> reservations)
    const apiIndex = parts.indexOf('v1');
    return apiIndex >= 0 && parts[apiIndex + 1]
      ? parts[apiIndex + 1]
      : parts[parts.length - 1] || 'unknown';
  }

  private sanitizeBody(body: Record<string, any>): Record<string, any> {
    if (!body) return {};
    const sanitized = { ...body };
    // Never log sensitive fields
    const sensitiveFields = [
      'password',
      'otp',
      'code',
      'token',
      'card_number',
      'cvv',
      'pin',
    ];
    for (const field of sensitiveFields) {
      if (sanitized[field]) {
        sanitized[field] = '[REDACTED]';
      }
    }
    return sanitized;
  }
}
