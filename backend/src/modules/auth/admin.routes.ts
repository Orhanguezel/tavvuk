// =============================================================
// FILE: src/modules/auth/admin.routes.ts
// FINAL — Tavvuk admin users endpoints
// Prefix: createApp() içinde /api/admin ile register ediliyor
// =============================================================
import type { FastifyInstance } from 'fastify';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';
import { makeAdminController } from './admin.controller';

export async function registerUserAdmin(app: FastifyInstance) {
  const c = makeAdminController(app);

  // Admin guard tek yerde
  const adminGuard = { preHandler: [requireAuth, requireAdmin] as any };

  app.get(
    '/users',
    { ...adminGuard, config: { rateLimit: { max: 60, timeWindow: '10 minute' } } },
    c.list,
  );
  app.get(
    '/users/:id',
    { ...adminGuard, config: { rateLimit: { max: 120, timeWindow: '10 minute' } } },
    c.get,
  );

  app.patch(
    '/users/:id',
    { ...adminGuard, config: { rateLimit: { max: 60, timeWindow: '10 minute' } } },
    c.update,
  );
  app.post(
    '/users/:id/active',
    { ...adminGuard, config: { rateLimit: { max: 60, timeWindow: '10 minute' } } },
    c.setActive,
  );

  // roles tam set
  app.post(
    '/users/:id/roles',
    { ...adminGuard, config: { rateLimit: { max: 60, timeWindow: '10 minute' } } },
    c.setRoles,
  );

  app.post(
    '/users/:id/password',
    { ...adminGuard, config: { rateLimit: { max: 30, timeWindow: '10 minute' } } },
    c.setPassword,
  );
  app.delete(
    '/users/:id',
    { ...adminGuard, config: { rateLimit: { max: 30, timeWindow: '10 minute' } } },
    c.remove,
  );
}
