// =============================================================
// FILE: src/modules/orders/admin.routes.ts
// FINAL — Admin Orders routes (explicit /admin prefix)
// =============================================================
import type { FastifyInstance } from 'fastify';
import {
  adminList,
  adminGet,
  adminApprove,
  adminAssignDriver,
  adminCancel,
} from './admin.controller';

import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';

export async function registerAdminOrders(app: FastifyInstance) {
  const BASE = '/orders';

  const guard = { preHandler: [requireAuth as any, requireAdmin as any] };

  app.get(
    `${BASE}`,
    { ...guard, config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    adminList,
  );

  app.get(
    `${BASE}/:id`,
    { ...guard, config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    adminGet,
  );

  app.post(
    `${BASE}/:id/approve`,
    { ...guard, config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    adminApprove,
  );

  app.post(
    `${BASE}/:id/assign-driver`,
    { ...guard, config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    adminAssignDriver,
  );

  app.post(
    `${BASE}/:id/cancel`,
    { ...guard, config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    adminCancel,
  );
}
