// =============================================================
// FILE: src/modules/userRoles/router.ts
// FINAL — Tavvuk userRoles router (admin-only)
// =============================================================
import type { FastifyInstance } from 'fastify';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';
import { listUserRoles, createUserRole, deleteUserRole } from './controller';

export async function registerUserRoles(app: FastifyInstance) {
  // ✅ Admin-only: rol verisi hassas (enumeration risk)
  app.get('/user_roles', {
    preHandler: [requireAuth, requireAdmin],
    config: { rateLimit: { max: 60, timeWindow: '1 minute' } },
    handler: listUserRoles,
  });

  app.post('/user_roles', {
    preHandler: [requireAuth, requireAdmin],
    config: { rateLimit: { max: 30, timeWindow: '1 minute' } },
    handler: createUserRole,
  });

  app.delete('/user_roles/:id', {
    preHandler: [requireAuth, requireAdmin],
    config: { rateLimit: { max: 30, timeWindow: '1 minute' } },
    handler: deleteUserRole,
  });
}
