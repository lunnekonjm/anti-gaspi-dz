import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import { AppModule } from './app.module';
import { BilingualExceptionFilter } from './common/filters';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: { enableImplicitConversion: true },
    }),
  );

  // Bilingual exception filter (FR + AR responses)
  app.useGlobalFilters(new BilingualExceptionFilter());

  // CORS — Closes A1-07 / S2-10: explicit origin allow-list instead of wildcard
  const allowedOrigins = (configService.get<string>('CORS_ORIGINS') || 'http://localhost:3000,http://localhost:8080,https://anti-gaspi-dz.web.app')
    .split(',')
    .map((o: string) => o.trim());
  app.enableCors({
    origin: (origin: string | undefined, callback: (err: Error | null, allow?: boolean) => void) => {
      // Allow requests with no origin (mobile apps, curl, server-to-server)
      if (!origin || allowedOrigins.includes(origin)) {
        callback(null, true);
      } else {
        callback(new Error(`Origin ${origin} not allowed by CORS`));
      }
    },
    credentials: false, // App uses Bearer tokens, not cookies
    allowedHeaders: 'Content-Type, Accept, Authorization',
    methods: 'GET,HEAD,PUT,PATCH,POST,DELETE,OPTIONS',
  });

  // Swagger API documentation
  const swaggerConfig = new DocumentBuilder()
    .setTitle('Anti-Gaspi DZ API / واجهة برمجة تطبيقات مكافحة الهدر')
    .setDescription(
      'Platform API for fighting food waste in Algeria — B2C (Surprise Bags), C2C (Family Tab), B2A (Institutional Donations)\n\n' +
        'منصة مكافحة هدر الطعام في الجزائر',
    )
    .setVersion('1.0')
    .addBearerAuth()
    .addTag('Auth / المصادقة')
    .addTag('Users / المستخدمون')
    .addTag('Offers / العروض')
    .addTag('Reservations / الحجوزات')
    .addTag('Payments / المدفوعات')
    .addTag('Donations C2C / التبرعات العائلية')
    .addTag('Institutional Donations B2A / التبرعات المؤسسية')
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, document);

  const port = configService.get<number>('PORT') || configService.get<number>('APP_PORT', 3000);
  await app.listen(port, '0.0.0.0');

  console.log(`🚀 Anti-Gaspi DZ API running on http://0.0.0.0:${port}`);
  console.log(`📚 Swagger docs: http://0.0.0.0:${port}/api/docs`);
}

bootstrap();
