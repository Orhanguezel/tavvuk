// =============================================================
// FILE: src/modules/reports/admin.controller.ts
// FINAL — Reports admin controller
// =============================================================

import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';

import {
  adminKpiQuerySchema,
  adminUserPerformanceQuerySchema,
  adminLocationsQuerySchema,
} from './validation';

import { adminGetKpi, adminUserPerformance, adminLocations } from './service';

export const adminKpi: RouteHandler = async (req, reply) => {
  const q = adminKpiQuerySchema.parse(req.query ?? {});
  const rows = await adminGetKpi(db as any, q);
  return reply.send(rows);
};

export const adminUsersPerformance: RouteHandler = async (req, reply) => {
  const q = adminUserPerformanceQuerySchema.parse(req.query ?? {});
  const rows = await adminUserPerformance(db as any, q);
  return reply.send(rows);
};

export const adminLocationsReport: RouteHandler = async (req, reply) => {
  const q = adminLocationsQuerySchema.parse(req.query ?? {});
  const rows = await adminLocations(db as any, q);
  return reply.send(rows);
};
