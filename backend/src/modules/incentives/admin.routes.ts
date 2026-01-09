// =============================================================
// FILE: src/modules/incentives/admin.routes.ts
// FINAL — Incentives admin routes
// Prefix: createApp() içinde /api/admin ile register edilir
// =============================================================

import type { FastifyInstance } from 'fastify';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';

import {
  adminListPlans,
  adminCreatePlan,
  adminPatchPlan,
  adminGetPlanRules,
  adminReplacePlanRules,
  adminListLedger,
  adminGetSummary,
} from './admin.controller';

export async function registerIncentivesAdmin(app: FastifyInstance) {
  const adminGuard = { preHandler: [requireAuth, requireAdmin] as any };

  // plans
  app.get('/incentives/plans', { ...adminGuard }, adminListPlans);
  app.post('/incentives/plans', { ...adminGuard }, adminCreatePlan);
  app.patch('/incentives/plans/:id', { ...adminGuard }, adminPatchPlan);

  // rules
  app.get('/incentives/plans/:id/rules', { ...adminGuard }, adminGetPlanRules);
  app.put('/incentives/plans/:id/rules', { ...adminGuard }, adminReplacePlanRules);

  // ledger
  app.get('/incentives/ledger', { ...adminGuard }, adminListLedger);

  // summary
  app.get('/incentives/summary', { ...adminGuard }, adminGetSummary);
}
