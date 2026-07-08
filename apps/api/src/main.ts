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

  // CORS
  app.enableCors({
    origin: configService.get('FRONTEND_URL', 'https://app.antigaspi.dz'),
    credentials: true,
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

  const port = configService.get<number>('APP_PORT', 3000);
  await app.listen(port);

  console.log(`🚀 Anti-Gaspi DZ API running on http://localhost:${port}`);
  console.log(`📚 Swagger docs: http://localhost:${port}/api/docs`);
}

bootstrap();
