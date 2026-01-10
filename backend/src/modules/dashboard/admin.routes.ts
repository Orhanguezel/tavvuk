// ===================================================================
// FILE: src/modules/dashboard/admin.routes.ts
// FINAL — Tavvuk Admin Dashboard Analytics Routes
// - GET /api/admin/dashboard/analytics?range=7d|30d|90d
// ===================================================================

import type { FastifyInstance } from 'fastify';
import { requireAuth } from '@/common/middleware/auth';
import { getDashboardAnalyticsAdmin } from './admin.controller';

const BASE = '/dashboard';

export async function registerDashboardAdmin(app: FastifyInstance) {
  app.get(`${BASE}/analytics`, { preHandler: [requireAuth] }, getDashboardAnalyticsAdmin);
}
