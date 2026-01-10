// =============================================================
// FILE: src/modules/orders/admin.controller.ts
// FINAL — Admin Orders controller (create/list/get/approve/assign/cancel)
// - Guards: requireAuth + requireAdmin (consistent)
// - List: x-total-count + content-range (react-admin compatible)
// - Assign-driver: single source of truth via Assignments service
// - Create: manual order create for admin (submitted)
// =============================================================

import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';

import {
  adminListOrdersQuerySchema,
  adminAssignDriverBodySchema,
  adminCancelBodySchema,
  createOrderBodySchema,
} from './validation';

import {
  adminListOrders,
  adminCountOrders,
  getOrderById,
  getOrderItems,
  createOrderTx,
  approveOrderTx,
  cancelOrderTx,
} from './repository';

// ✅ Single source of truth for assignments
import { createAssignmentTx } from '@/modules/assignments/service';

function getAdminId(req: any): string {
  return String(req.user?.sub ?? '');
}

function setRangeHeaders(
  reply: any,
  resource: string,
  offset: number,
  rowsLen: number,
  total: number,
) {
  reply.header('x-total-count', String(total));
  const start = Number(offset ?? 0);
  const end = start + rowsLen - 1;
  reply.header('content-range', `${resource} ${start}-${Math.max(end, start)}/${total}`);
}

/** POST /admin/orders — manual create */
export const adminCreate: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;
  await requireAdmin(req as any, reply as any);
  if (reply.sent) return;

  const adminId = getAdminId(req);
  if (!adminId) return reply.code(401).send({ error: { message: 'unauthorized' } });

  const body = createOrderBodySchema.parse(req.body ?? {});

  try {
    const created = await db.transaction(async (tx: any) => {
      const orderId = await createOrderTx(tx, {
        created_by: adminId,
        city_id: body.city_id,
        district_id: body.district_id ?? null,
        customer_name: body.customer_name,
        customer_phone: body.customer_phone,
        address_text: body.address_text,
        items: body.items.map((it) => ({
          product_id: it.product_id,
          qty_ordered: it.qty_ordered,
        })),
      });

      const order = await getOrderById(tx, orderId);
      const items = await getOrderItems(tx, orderId);

      return { order, items };
    });

    return reply.code(201).send(created);
  } catch (err: any) {
    // FK errors -> 400 (invalid city/district/product ids)
    if (err?.code === 'ER_NO_REFERENCED_ROW_2' || err?.errno === 1452) {
      return reply.code(400).send({ error: { message: 'invalid_fk' } });
    }
    // Duplicate entry -> 409
    if (err?.code === 'ER_DUP_ENTRY') {
      return reply.code(409).send({ error: { message: 'conflict' } });
    }
    throw err;
  }
};

/** GET /admin/orders — list (filters + count) */
export const adminList: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;
  await requireAdmin(req as any, reply as any);
  if (reply.sent) return;

  const q = adminListOrdersQuerySchema.parse(req.query ?? {});

  const [rows, total] = await Promise.all([
    adminListOrders(db as any, q),
    adminCountOrders(db as any, q),
  ]);

  setRangeHeaders(reply as any, 'orders', Number(q.offset ?? 0), rows.length, total);
  return reply.send(rows);
};

/** GET /admin/orders/:id — detail */
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

/** POST /admin/orders/:id/approve */
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

/** POST /admin/orders/:id/assign-driver */
export const adminAssignDriver: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;
  await requireAdmin(req as any, reply as any);
  if (reply.sent) return;

  const orderId = String((req.params as any).id);
  const adminId = getAdminId(req);
  const body = adminAssignDriverBodySchema.parse(req.body ?? {});

  // early check for clearer 404
  const o = await getOrderById(db as any, orderId);
  if (!o) return reply.code(404).send({ error: { message: 'not_found' } });

  try {
    const result = await db.transaction(async (tx: any) => {
      return await createAssignmentTx(tx, {
        order_id: orderId,
        driver_id: body.driver_id,
        assigned_by: adminId,
        note: null,
      });
    });

    return reply.send({ ok: true, assignment: (result as any)?.assignment ?? null });
  } catch (err: any) {
    const code = Number(err?.statusCode ?? 500);

    if (code === 404) return reply.code(404).send({ error: { message: 'not_found' } });

    if (code === 409) {
      const msg =
        String(err?.message ?? '') === 'must_be_approved_before_assign'
          ? 'must_be_approved_before_assign'
          : String(err?.message ?? 'conflict');

      return reply.code(409).send({ error: { message: msg } });
    }

    // MariaDB duplicate entry (unique active assignment)
    if (err?.code === 'ER_DUP_ENTRY') {
      return reply.code(409).send({ error: { message: 'order_already_assigned_active' } });
    }

    throw err;
  }
};

/** POST /admin/orders/:id/cancel */
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
