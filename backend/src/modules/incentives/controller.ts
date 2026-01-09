// =============================================================
// FILE: src/modules/incentives/controller.ts
// FINAL — Incentives public controller
// =============================================================

import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';
import { requireAuth } from '@/common/middleware/auth';
import { mySummaryQuerySchema } from './validation';
import { mySummary } from './service';

function getUserId(req: any): string {
  return String(req.user?.sub ?? '');
}

export const getMySummary: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;

  const q = mySummaryQuerySchema.parse(req.query ?? {});
  const userId = getUserId(req);

  const rows = await mySummary(db as any, userId, q);
  return reply.send(rows);
};
