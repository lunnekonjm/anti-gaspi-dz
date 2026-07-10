import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication } from '@nestjs/common';
import request from 'supertest';

/**
 * Closes S2-01 / A1-11: Verify DevModule routes don't exist in production.
 * 
 * This test sets NODE_ENV=production BEFORE importing AppModule,
 * then confirms /dev/* routes return 404.
 */
describe('DevModule production gate (S2-01 / A1-11)', () => {
  let app: INestApplication;
  const originalEnv = process.env.NODE_ENV;

  beforeAll(async () => {
    // Set production BEFORE module loading
    process.env.NODE_ENV = 'production';
    // Must set JWT_SECRET to avoid fail-fast (Fix 0.3)
    process.env.JWT_SECRET = 'test-secret-for-ci-only';
    
    // Dynamic import to ensure NODE_ENV is set before @Module decorator evaluates
    const { AppModule } = await import('../src/app.module');

    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  afterAll(async () => {
    process.env.NODE_ENV = originalEnv;
    if (app) await app.close();
  });

  it('POST /api/v1/dev/seed should return 404 in production', () => {
    return request(app.getHttpServer())
      .post('/api/v1/dev/seed')
      .expect(404);
  });

  it('DELETE /api/v1/dev/wipe should return 404 in production', () => {
    return request(app.getHttpServer())
      .delete('/api/v1/dev/wipe')
      .expect(404);
  });
});
