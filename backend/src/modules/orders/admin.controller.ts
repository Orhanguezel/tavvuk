// =============================================================
// FILE: src/modules/orders/admin.controller.ts
// FINAL — Admin Orders controller (approve/assign/cancel + list filters)
// - assign-driver artık Assignments üzerinden (tek merkez)
// =============================================================
import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';

import {
  adminListOrdersQuerySchema,
  adminAssignDriverBodySchema,
  adminCancelBodySchema,
} from './validation';

import {
  adminListOrders,
  getOrderById,
  getOrderItems,
  approveOrderTx,
  cancelOrderTx,
  adminCountOrders,
} from './repository';

// ✅ Single source of truth for assignments
import { createAssignmentTx } from '@/modules/assignments/service';

function getAdminId(req: any): string {
  return String(req.user?.sub ?? '');
}

export const adminList: RouteHandler = async (req, reply) => {
  

  const q = adminListOrdersQuerySchema.parse(req.query ?? {});

  const [rows, total] = await Promise.all([
    adminListOrders(db as any, q),
    adminCountOrders(db as any, q),
  ]);

  // react-admin / data-grid uyumu
  reply.header('x-total-count', String(total));
  const start = Number(q.offset ?? 0);
  const end = start + rows.length - 1;
  reply.header('content-range', `orders ${start}-${Math.max(end, start)}/${total}`);

  return reply.send(rows);
};

export const adminGet: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;
  await requireAdmin(req as any, reply as any);
  if (reply.sent) return;

  const id = String((req.params as any).id);
  const o = await getOrderById(db as any, id);
  if (!o) return reply.code(404).send({ error: { message: 'not_found' } });

  const items = await getOrderItems(db as any, id);
  return reply.send({ order: o, items });
};

export const adminApprove: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;
  await requireAdmin(req as any, reply as any);
  if (reply.sent) return;

  const id = String((req.params as any).id);
  const adminId = getAdminId(req);

  const o = await getOrderById(db as any, id);
  if (!o) return reply.code(404).send({ error: { message: 'not_found' } });

  if (o.status !== 'submitted') {
    return reply.code(409).send({ error: { message: 'only_submitted_can_be_approved' } });
  }

  await db.transaction(async (tx: any) => {
    await approveOrderTx(tx, id, adminId);
  });

  return reply.send({ ok: true });
};

export const adminAssignDriver: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;
  await requireAdmin(req as any, reply as any);
  if (reply.sent) return;

  const orderId = String((req.params as any).id);
  const adminId = getAdminId(req);
  const body = adminAssignDriverBodySchema.parse(req.body ?? {});

  // Optional early check for clearer 404 (service already checks too)
  const o = await getOrderById(db as any, orderId);
  if (!o) return reply.code(404).send({ error: { message: 'not_found' } });

  try {
    const result = await db.transaction(async (tx: any) => {
      // ✅ canonical: creates assignments row + updates orders (approved → assigned)
      return await createAssignmentTx(tx, {
        order_id: orderId,
        driver_id: body.driver_id,
        assigned_by: adminId,
        note: null,
      });
    });

    // result = { ok: true, assignment: ... }
    return reply.send({ ok: true, assignment: result.assignment ?? null });
  } catch (err: any) {
    // service throws with statusCode in some cases
    const code = Number(err?.statusCode ?? 500);

    if (code === 404) return reply.code(404).send({ error: { message: 'not_found' } });

    if (code === 409) {
      // usually: must_be_approved_before_assign OR unique active assignment violation
      const msg =
        String(err?.message ?? '') === 'must_be_approved_before_assign'
          ? 'must_be_approved_before_assign'
          : String(err?.message ?? 'conflict');

      return reply.code(409).send({ error: { message: msg } });
    }

    // Unique constraint: uq_assignments_order_active
    if (err?.code === 'ER_DUP_ENTRY') {
      return reply.code(409).send({ error: { message: 'order_already_assigned_active' } });
    }

    throw err;
  }
};

export const adminCancel: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;
  await requireAdmin(req as any, reply as any);
  if (reply.sent) return;

  const id = String((req.params as any).id);
  const adminId = getAdminId(req);

  const body = adminCancelBodySchema.parse(req.body ?? {});
  const o = await getOrderById(db as any, id);
  if (!o) return reply.code(404).send({ error: { message: 'not_found' } });

  if (o.status === 'delivered') {
    return reply.code(409).send({ error: { message: 'delivered_cannot_be_cancelled_mvp' } });
  }

  await db.transaction(async (tx: any) => {
    await cancelOrderTx(tx, id, adminId, body.cancel_reason);
  });

  return reply.send({ ok: true });
};
