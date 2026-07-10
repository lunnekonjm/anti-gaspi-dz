# Changelog — Anti-Gaspi DZ

All notable changes to this project will be documented in this file.

## [Unreleased] — Phase 0: Emergency Lockdown

### ⚠️ SECRET ROTATION REQUIRED

The following secrets were previously committed to git history and **must be treated as compromised**. Rotate them immediately in all deployed environments (Render dashboard, docker-compose):

- **JWT_SECRET** — Regenerate via `openssl rand -hex 32`, set in Render env vars
- **DATABASE_PASSWORD** — Change in Render managed Postgres and `docker-compose.yml`
- **DEV_API_KEY** — Regenerate and set in Render env vars

### Security Fixes

- **S2-01 / A1-11**: DevModule (`/dev/seed`, `/dev/wipe`) gated behind `NODE_ENV !== 'production'` — routes don't exist in production (404)
- **S2-02**: Hardcoded OTP `'123456'` removed — OTP is now always cryptographically random via `crypto.randomInt()`
- **S2-04**: `'default-secret'` JWT fallback removed — app fails to start if `JWT_SECRET` is not set
- **S2-05**: Payment webhook signature is now mandatory — unsigned webhook calls are rejected (401)
- **S2-06**: Mock payment endpoint (`GET /payments/mock/pay`) gated behind `NODE_ENV !== 'production'`
- **S2-03**: `apps/mobile/.env` removed from git tracking; root `.gitignore` added with `**/.env` glob
- **A1-07 / S2-10**: Wildcard CORS replaced with explicit origin allow-list via `CORS_ORIGINS` env var; `credentials: false`
- **A1-01**: `synchronize: true` replaced with `synchronize: false` unconditionally; baseline migration + `ormconfig.ts` added
- **A1-10 / S2-12**: Production DB SSL now uses `rejectUnauthorized: true` — verifies server certificate
- **S2-07**: `redeem()` now verifies calling merchant owns the offer — returns 403 if mismatched
- **S2-08**: Transfer deed generation endpoint restricted to `MERCHANT` role via `RolesGuard`
