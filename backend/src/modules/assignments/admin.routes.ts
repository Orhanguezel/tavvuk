// =============================================================
// FILE: src/modules/assignments/admin.routes.ts
// FINAL — Assignments admin routes
// Prefix: createApp() içinde /api/admin ile register edilecek
// =============================================================

import type { FastifyInstance } from 'fastify';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';
import {
  adminListAssignments,
  adminGetAssignment,
  adminCreateAssignment,
  adminPatchAssignment,
  adminCancelAssignment,
} from './admin.controller';

export async function registerAssignmentsAdmin(app: FastifyInstance) {
  const adminGuard = { preHandler: [requireAuth, requireAdmin] as any };
  const BASE = '/assignments';

  app.get(
    `${BASE}`,
    { ...adminGuard, config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    adminListAssignments,
  );

  app.get(
    `${BASE}/:id`,
    { ...adminGuard, config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    adminGetAssignment,
  );

  // create: order approved -> assigned, order.assigned_driver_id set
  app.post(
    `${BASE}`,
    { ...adminGuard, config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    adminCreateAssignment,
  );

  // patch: change driver or note (keeps status=assigned on order)
  app.patch(
    `${BASE}/:id`,
    { ...adminGuard, config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    adminPatchAssignment,
  );

  // cancel assignment: sets assignment cancelled + clears order assignment (optional), status back to approved
  app.post(
    `${BASE}/:id/cancel`,
    { ...adminGuard, config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    adminCancelAssignment,
  );
}
