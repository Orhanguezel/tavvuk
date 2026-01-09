// =============================================================
// FILE: src/modules/auth/router.ts
// FINAL — Tavvuk auth routes (clean)
// - Only: register/login/refresh + me/status + password reset + logout
// =============================================================
import type { FastifyInstance } from 'fastify';
import { makeAuthController } from './controller';

export async function registerAuth(app: FastifyInstance) {
  const c = makeAuthController(app);
  const BASE = '/auth';

  // Auth
  app.post(
    `${BASE}/register`,
    { config: { rateLimit: { max: 20, timeWindow: '1 minute' } } },
    c.register,
  );

  app.post(
    `${BASE}/login`,
    { config: { rateLimit: { max: 30, timeWindow: '1 minute' } } },
    c.login,
  );

  app.post(
    `${BASE}/refresh`,
    { config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    c.refresh,
  );

  // Password reset
  app.post(
    `${BASE}/password-reset/request`,
    { config: { rateLimit: { max: 10, timeWindow: '1 minute' } } },
    c.passwordResetRequest,
  );

  app.post(
    `${BASE}/password-reset/confirm`,
    { config: { rateLimit: { max: 20, timeWindow: '1 minute' } } },
    c.passwordResetConfirm,
  );

  // Read-only auth state
  app.get(`${BASE}/me`, c.me);
  app.get(`${BASE}/status`, c.status);

  // Account updates
  app.put(`${BASE}/me`, c.update);

  // Logout
  app.post(`${BASE}/logout`, c.logout);
}
