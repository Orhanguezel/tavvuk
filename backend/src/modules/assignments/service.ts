// =============================================================
// FILE: src/modules/assignments/service.ts
// FINAL — Assignments service (db/tx ready)
// - Audit trail in assignments table
// - Canonical order state in orders.*
// - One active assignment per order is enforced here (tx)
// =============================================================

import { randomUUID } from 'crypto';
import { and, asc, desc, eq, like, sql } from 'drizzle-orm';

import { assignments } from './schema';
import { orders } from '@/modules/orders/schema';

type Executor = any;

function toInt(v: any, fb: number) {
  const n = Number(v);
  return Number.isFinite(n) ? n : fb;
}

export async function getAssignmentByIdTx(ex: Executor, assignmentId: string) {
  const rows = await ex.select().from(assignments).where(eq(assignments.id, assignmentId)).limit(1);
  return rows[0] ?? null;
}

async function getActiveAssignmentForOrderTx(ex: Executor, orderId: string) {
  const rows = await ex
    .select()
    .from(assignments)
    .where(and(eq(assignments.order_id, orderId), eq(assignments.status, 'active')))
    .orderBy(desc(assignments.created_at))
    .limit(1);
  return rows[0] ?? null;
}

export async function adminListAssignmentsTx(ex: Executor, q: any) {
  const conds: any[] = [];

  const includeCancelled = q.include_cancelled == null ? true : !!q.include_cancelled;
  if (!includeCancelled) conds.push(eq(assignments.status, 'active'));
  if (q.status) conds.push(eq(assignments.status, q.status));
  if (q.order_id) conds.push(eq(assignments.order_id, q.order_id));
  if (q.driver_id) conds.push(eq(assignments.driver_id, q.driver_id));
  if (q.assigned_by) conds.push(eq(assignments.assigned_by, q.assigned_by));

  if (q.q) {
    const term = `%${String(q.q).trim()}%`;
    conds.push(
      sql`(${assignments.note} LIKE ${term} OR ${assignments.cancel_reason} LIKE ${term})`,
    );
  }

  const where = conds.length === 0 ? undefined : conds.length === 1 ? conds[0] : and(...conds);

  const limit = toInt(q.limit, 50);
  const offset = toInt(q.offset, 0);

  const sortCol = q.sort === 'updated_at' ? assignments.updated_at : assignments.created_at;
  const dir = q.order === 'asc' ? asc : desc;

  return await ex
    .select({
      id: assignments.id,
      order_id: assignments.order_id,
      driver_id: assignments.driver_id,
      assigned_by: assignments.assigned_by,
      status: assignments.status,
      note: assignments.note,
      cancelled_by: assignments.cancelled_by,
      cancelled_at: assignments.cancelled_at,
      cancel_reason: assignments.cancel_reason,
      created_at: assignments.created_at,
      updated_at: assignments.updated_at,

      order_status: orders.status,
      customer_name: orders.customer_name,
      customer_phone: orders.customer_phone,
    })
    .from(assignments)
    .leftJoin(orders, eq(orders.id, assignments.order_id))
    .where(where)
    .orderBy(dir(sortCol))
    .limit(limit)
    .offset(offset);
}

export async function listAssignmentsForDriver(ex: Executor, driverId: string, q: any) {
  const conds: any[] = [eq(assignments.driver_id, driverId)];

  const status = q.status ?? 'active';
  if (status) conds.push(eq(assignments.status, status));

  const where = conds.length === 1 ? conds[0] : and(...conds);

  const limit = toInt(q.limit, 50);
  const offset = toInt(q.offset, 0);

  return await ex
    .select({
      id: assignments.id,
      order_id: assignments.order_id,
      driver_id: assignments.driver_id,
      assigned_by: assignments.assigned_by,
      status: assignments.status,
      note: assignments.note,
      created_at: assignments.created_at,
      updated_at: assignments.updated_at,

      order_status: orders.status,
      customer_name: orders.customer_name,
      customer_phone: orders.customer_phone,
    })
    .from(assignments)
    .leftJoin(orders, eq(orders.id, assignments.order_id))
    .where(where)
    .orderBy(desc(assignments.created_at))
    .limit(limit)
    .offset(offset);
}

export async function createAssignmentTx(
  ex: Executor,
  input: { order_id: string; driver_id: string; assigned_by: string; note?: string | null },
) {
  // 1) order must exist & must be approved
  const o = (await ex.select().from(orders).where(eq(orders.id, input.order_id)).limit(1))[0];
  if (!o) throw Object.assign(new Error('order_not_found'), { statusCode: 404 });

  if (o.status !== 'approved') {
    throw Object.assign(new Error('must_be_approved_before_assign'), { statusCode: 409 });
  }

  // 2) ensure no active assignment exists (service-level constraint)
  const existingActive = await getActiveAssignmentForOrderTx(ex, input.order_id);
  if (existingActive) {
    throw Object.assign(new Error('order_already_has_active_assignment'), { statusCode: 409 });
  }

  // 3) create assignment row
  const assignmentId = randomUUID();
  const now = new Date();

  await ex.insert(assignments).values({
    id: assignmentId,
    order_id: input.order_id,
    driver_id: input.driver_id,
    assigned_by: input.assigned_by,
    status: 'active',
    note: input.note ?? null,
    created_at: now,
    updated_at: now,
  });

  // 4) sync order state (canonical)
  await ex
    .update(orders)
    .set({
      status: 'assigned',
      assigned_driver_id: input.driver_id,
      assigned_by: input.assigned_by,
      assigned_at: now,
      updated_at: now,
    })
    .where(eq(orders.id, input.order_id));

  const row = await getAssignmentByIdTx(ex, assignmentId);
  return { ok: true, assignment: row };
}

export async function patchAssignmentTx(
  ex: Executor,
  assignmentId: string,
  adminId: string,
  patch: { driver_id?: string; note?: string },
) {
  const a = await getAssignmentByIdTx(ex, assignmentId);
  if (!a) return null;

  if (a.status !== 'active') {
    throw Object.assign(new Error('only_active_can_be_patched'), { statusCode: 409 });
  }

  const now = new Date();

  await ex
    .update(assignments)
    .set({
      ...(patch.driver_id ? { driver_id: patch.driver_id } : {}),
      ...(patch.note !== undefined ? { note: patch.note } : {}),
      updated_at: now,
    } as any)
    .where(eq(assignments.id, assignmentId));

  if (patch.driver_id) {
    await ex
      .update(orders)
      .set({
        assigned_driver_id: patch.driver_id,
        assigned_by: adminId,
        assigned_at: now,
        updated_at: now,
      })
      .where(eq(orders.id, a.order_id));
  }

  const updated = await getAssignmentByIdTx(ex, assignmentId);
  return { ok: true, assignment: updated };
}

export async function cancelAssignmentTx(
  ex: Executor,
  assignmentId: string,
  adminId: string,
  reason: string | null,
) {
  const a = await getAssignmentByIdTx(ex, assignmentId);
  if (!a) return null;

  if (a.status !== 'active') return { ok: true };

  // if order already delivered, do not allow cancelling assignment
  const o = (await ex.select().from(orders).where(eq(orders.id, a.order_id)).limit(1))[0];
  if (o?.status === 'delivered') {
    throw Object.assign(new Error('delivered_cannot_cancel_assignment'), { statusCode: 409 });
  }

  const now = new Date();

  await ex
    .update(assignments)
    .set({
      status: 'cancelled',
      cancelled_by: adminId,
      cancelled_at: now,
      cancel_reason: reason ?? null,
      updated_at: now,
    } as any)
    .where(eq(assignments.id, assignmentId));

  // revert order back to approved (so it can be assigned again)
  await ex
    .update(orders)
    .set({
      status: 'approved',
      assigned_driver_id: null,
      assigned_by: null,
      assigned_at: null,
      updated_at: now,
    } as any)
    .where(eq(orders.id, a.order_id));

  return { ok: true };
}
