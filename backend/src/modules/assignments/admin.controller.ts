// =============================================================
// FILE: src/modules/assignments/admin.controller.ts
// FINAL — Assignments admin controller
// =============================================================

import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';

import {
  adminAssignmentListQuerySchema,
  adminAssignmentCreateBodySchema,
  adminAssignmentPatchBodySchema,
  adminAssignmentCancelBodySchema,
} from './validation';

import {
  adminListAssignmentsTx,
  getAssignmentByIdTx,
  createAssignmentTx,
  patchAssignmentTx,
  cancelAssignmentTx,
} from './service';

function getAdminId(req: any): string {
  return String(req.user?.sub ?? '');
}

export const adminListAssignments: RouteHandler = async (req, reply) => {
  const q = adminAssignmentListQuerySchema.parse(req.query ?? {});
  const rows = await adminListAssignmentsTx(db as any, q);
  return reply.send(rows);
};

export const adminGetAssignment: RouteHandler = async (req, reply) => {
  const assignmentId = String((req.params as any).id);
  const row = await getAssignmentByIdTx(db as any, assignmentId);
  if (!row) return reply.code(404).send({ error: { message: 'not_found' } });
  return reply.send(row);
};

export const adminCreateAssignment: RouteHandler = async (req, reply) => {
  const adminId = getAdminId(req);
  const body = adminAssignmentCreateBodySchema.parse(req.body ?? {});

  const res = await db.transaction(async (tx: any) => {
    return await createAssignmentTx(tx, {
      order_id: body.order_id,
      driver_id: body.driver_id,
      assigned_by: adminId,
      note: body.note ?? null,
    });
  });

  return reply.code(201).send(res);
};

export const adminPatchAssignment: RouteHandler = async (req, reply) => {
  const adminId = getAdminId(req);
  const assignmentId = String((req.params as any).id);
  const body = adminAssignmentPatchBodySchema.parse(req.body ?? {});

  const res = await db.transaction(async (tx: any) => {
    return await patchAssignmentTx(tx, assignmentId, adminId, body);
  });

  if (!res) return reply.code(404).send({ error: { message: 'not_found' } });
  return reply.send(res);
};

export const adminCancelAssignment: RouteHandler = async (req, reply) => {
  const adminId = getAdminId(req);
  const assignmentId = String((req.params as any).id);
  const body = adminAssignmentCancelBodySchema.parse(req.body ?? {});

  await db.transaction(async (tx: any) => {
    await cancelAssignmentTx(tx, assignmentId, adminId, body.cancel_reason ?? null);
  });

  return reply.send({ ok: true });
};
