// =============================================================
// FILE: src/modules/reports/admin.routes.ts
// FINAL — Reports admin routes
// Prefix: createApp() içinde /api/admin ile register edilir
// =============================================================

import type { FastifyInstance } from 'fastify';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';

import { adminKpi, adminUsersPerformance, adminLocationsReport } from './admin.controller';

export async function registerReportsAdmin(app: FastifyInstance) {
  const adminGuard = { preHandler: [requireAuth, requireAdmin] as any };
  const BASE = '/reports';

  app.get(
    `${BASE}/kpi`,
    { ...adminGuard, config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    adminKpi,
  );

  app.get(
    `${BASE}/users/performance`,
    { ...adminGuard, config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    adminUsersPerformance,
  );

  app.get(
    `${BASE}/locations`,
    { ...adminGuard, config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    adminLocationsReport,
  );
}
