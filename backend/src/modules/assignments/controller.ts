// =============================================================
// FILE: src/modules/assignments/controller.ts
// FINAL — Driver assignment list
// =============================================================

import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';
import { requireAuth } from '@/common/middleware/auth';
import { driverAssignmentListQuerySchema } from './validation';
import { listAssignmentsForDriver } from './service';

function getUserId(req: any): string {
  return String(req.user?.sub ?? '');
}

export const listMyAssignments: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;

  const q = driverAssignmentListQuerySchema.parse({
    ...(req.query ?? {}),
    limit: 50,
    offset: 0,
  });

  const userId = getUserId(req);

  const rows = await listAssignmentsForDriver(db as any, userId, q);
  return reply.send(rows);
};
