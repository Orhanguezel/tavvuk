// =============================================================
// FILE: src/modules/orders/repository.ts
// FINAL — Orders repository (create/list/detail + workflow helpers + ledger)
// =============================================================
import { randomUUID } from 'crypto';
import { db } from '@/db/client';
import {
  orders,
  orderItems,
} from './schema';
import {
  incentivePlans,
  incentiveRules,
  incentiveLedger,
} from '@/modules/incentives/schema';
import { and, asc, desc, eq, gte, lte, like, sql, inArray } from 'drizzle-orm';
import { generateLedgerForOrderTx } from '@/modules/incentives/service';
import type { IncentiveRoleContext } from '@/modules/incentives/types';


type Executor = any; // db or tx

function parseDate(v?: string): Date | null {
  if (!v) return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

export async function getOrderById(ex: Executor, id: string) {
  return (await ex.select().from(orders).where(eq(orders.id, id)).limit(1))[0] ?? null;
}

export async function getOrderItems(ex: Executor, orderId: string) {
  return await ex.select().from(orderItems).where(eq(orderItems.order_id, orderId));
}

export async function createOrderTx(
  ex: Executor,
  input: {
    created_by: string;
    city_id: string;
    district_id?: string | null;
    customer_name: string;
    customer_phone: string;
    address_text: string;
    items: { product_id: string; qty_ordered: number }[];
  },
) {
  const orderId = randomUUID();

  await ex.insert(orders).values({
    id: orderId,
    created_by: input.created_by,
    status: 'submitted',
    city_id: input.city_id,
    district_id: input.district_id ?? null,
    customer_name: input.customer_name,
    customer_phone: input.customer_phone,
    address_text: input.address_text,
    delivered_qty_total: 0,
    is_delivery_counted: 0,
  });

  await ex.insert(orderItems).values(
    input.items.map((it) => ({
      id: randomUUID(),
      order_id: orderId,
      product_id: it.product_id,
      qty_ordered: it.qty_ordered,
      qty_delivered: 0,
    })),
  );

  return orderId;
}

export async function patchOrderSubmittedTx(
  ex: Executor,
  orderId: string,
  patch: Partial<{
    city_id: string;
    district_id: string | null;
    customer_name: string;
    customer_phone: string;
    address_text: string;
    items: { product_id: string; qty_ordered: number }[];
  }>,
) {
  await ex
    .update(orders)
    .set({
      ...(patch.city_id ? { city_id: patch.city_id } : {}),
      ...(patch.district_id !== undefined ? { district_id: patch.district_id } : {}),
      ...(patch.customer_name ? { customer_name: patch.customer_name } : {}),
      ...(patch.customer_phone ? { customer_phone: patch.customer_phone } : {}),
      ...(patch.address_text ? { address_text: patch.address_text } : {}),
      updated_at: new Date(),
    } as any)
    .where(eq(orders.id, orderId));

  if (patch.items) {
    // replace items (simple MVP)
    await ex.delete(orderItems).where(eq(orderItems.order_id, orderId));
    await ex.insert(orderItems).values(
      patch.items.map((it) => ({
        id: randomUUID(),
        order_id: orderId,
        product_id: it.product_id,
        qty_ordered: it.qty_ordered,
        qty_delivered: 0,
      })),
    );
  }
}

export async function listOrdersForUser(ex: Executor, userId: string, q: any) {
  const conds: any[] = [];
  // seller/driver: own OR assigned
  conds.push(sql`(${orders.created_by} = ${userId} OR ${orders.assigned_driver_id} = ${userId})`);

  if (q.status) conds.push(eq(orders.status, q.status));
  const df = parseDate(q.date_from);
  const dt = parseDate(q.date_to);
  if (df) conds.push(gte(orders.created_at, df));
  if (dt) conds.push(lte(orders.created_at, dt));

  const where = conds.length === 1 ? conds[0] : and(...conds);
  const dir = q.direction === 'asc' ? asc : desc;

  return await ex
    .select()
    .from(orders)
    .where(where)
    .orderBy(dir(orders.created_at))
    .limit(q.limit)
    .offset(q.offset);
}

export async function adminListOrders(ex: Executor, q: any) {
  const conds: any[] = [];

  if (q.status) conds.push(eq(orders.status, q.status));
  if (q.city_id) conds.push(eq(orders.city_id, q.city_id));
  if (q.district_id) conds.push(eq(orders.district_id, q.district_id));

  if (q.q) {
    const term = `%${String(q.q).trim()}%`;
    conds.push(
      sql`(${orders.customer_name} LIKE ${term} OR ${orders.customer_phone} LIKE ${term})`,
    );
  }

  const df = parseDate(q.date_from);
  const dt = parseDate(q.date_to);
  if (df) conds.push(gte(orders.created_at, df));
  if (dt) conds.push(lte(orders.created_at, dt));

  const where = conds.length ? (conds.length === 1 ? conds[0] : and(...conds)) : undefined;
  const dir = q.order === 'asc' ? asc : desc;
  const sortCol = q.sort === 'status' ? orders.status : orders.created_at;

  return await ex
    .select()
    .from(orders)
    .where(where)
    .orderBy(dir(sortCol))
    .limit(q.limit)
    .offset(q.offset);
}

/* ----------------------------- workflow helpers ----------------------------- */

export async function approveOrderTx(ex: Executor, orderId: string, adminId: string) {
  await ex
    .update(orders)
    .set({
      status: 'approved',
      approved_by: adminId,
      approved_at: new Date(),
      updated_at: new Date(),
    })
    .where(eq(orders.id, orderId));
}



export async function cancelOrderTx(
  ex: Executor,
  orderId: string,
  adminId: string,
  reason?: string,
) {
  await ex
    .update(orders)
    .set({
      status: 'cancelled',
      cancel_reason: reason ?? null,
      updated_at: new Date(),
    })
    .where(eq(orders.id, orderId));

  // ledger varsa iptal senaryosu MVP’de “yazma” üzerinden gittiği için burada silmek opsiyonel:
  // await ex.delete(incentiveLedger).where(eq(incentiveLedger.order_id, orderId));
}

export async function deliverOrderTx(
  ex: Executor,
  orderId: string,
  actorUserId: string,
  payload: { delivery_note?: string; items: { order_item_id: string; qty_delivered: number }[] },
) {
  // update items
  const itemIds = payload.items.map((x) => x.order_item_id);
  const existing = await ex
    .select()
    .from(orderItems)
    .where(and(eq(orderItems.order_id, orderId), inArray(orderItems.id, itemIds)));

  const map = new Map(payload.items.map((x) => [x.order_item_id, x.qty_delivered]));
  for (const it of existing) {
    const q = map.get(it.id);
    if (q == null) continue;
    await ex
      .update(orderItems)
      .set({ qty_delivered: q, updated_at: new Date() })
      .where(eq(orderItems.id, it.id));
  }

  // recalc total
  const sumRow = await ex
    .select({ s: sql<number>`COALESCE(SUM(${orderItems.qty_delivered}),0)`.as('s') })
    .from(orderItems)
    .where(eq(orderItems.order_id, orderId));
  const deliveredTotal = Number(sumRow?.[0]?.s ?? 0);

  await ex
    .update(orders)
    .set({
      status: 'delivered',
      delivered_at: new Date(),
      delivery_note: payload.delivery_note ?? null,
      delivered_qty_total: deliveredTotal,
      is_delivery_counted: 1,
      updated_at: new Date(),
    })
    .where(eq(orders.id, orderId));

  // ledger generate (single source of truth)
  await generateLedgerForOrderTx(ex, orderId);
}

/* ----------------------------- incentive engine (MVP) ----------------------------- */

async function pickActivePlanTx(ex: Executor, deliveredAt: Date) {
  // latest active plan where effective_from <= deliveredAt
  const rows = await ex
    .select()
    .from(incentivePlans)
    .where(and(eq(incentivePlans.is_active, 1), lte(incentivePlans.effective_from, deliveredAt)))
    .orderBy(desc(incentivePlans.effective_from))
    .limit(1);

  return rows[0] ?? null;
}

async function getRulesTx(ex: Executor, planId: string, role: IncentiveRoleContext) {
  return await ex
    .select()
    .from(incentiveRules)
    .where(
      and(
        eq(incentiveRules.plan_id, planId),
        eq(incentiveRules.role_context, role),
        eq(incentiveRules.is_active, 1),
      ),
    );
}

function money(n: number) {
  return Math.round(n * 100) / 100;
}

async function calcAmountTx(
  ex: Executor,
  planId: string,
  role: IncentiveRoleContext,
  deliveredQtyTotal: number,
) {
  const rules = await getRulesTx(ex, planId, role);

  const perDelivery = rules
    .filter((r: any) => r.rule_type === 'per_delivery' && !r.product_id)
    .reduce((a: number, r: any) => a + Number(r.amount ?? 0), 0);

  // MVP: product bazlı hesaplamaya girmeden “toplam qty” ile genelle
  const perChicken = rules
    .filter((r: any) => r.rule_type === 'per_chicken' && !r.product_id)
    .reduce((a: number, r: any) => a + Number(r.amount ?? 0), 0);

  return money(perDelivery + perChicken * deliveredQtyTotal);
}

export async function generateLedgerTx(ex: Executor, orderId: string) {
  const o = await getOrderById(ex, orderId);
  if (!o) return;
  if (o.status !== 'delivered') return;
  if (!o.delivered_at) return;
  if (o.status === 'cancelled') return;

  const plan = await pickActivePlanTx(ex, new Date(o.delivered_at as any));
  if (!plan) return;

  const deliveredQtyTotal = Number(o.delivered_qty_total ?? 0);
  const calculatedAt = new Date();

  // Creator row
  const creatorAmount = await calcAmountTx(ex, plan.id, 'creator', deliveredQtyTotal);
  try {
    await ex.insert(incentiveLedger).values({
      id: randomUUID(),
      order_id: orderId,
      user_id: o.created_by,
      role_context: 'creator',
      deliveries_count: 1,
      chickens_count: deliveredQtyTotal,
      amount_total: String(creatorAmount),
      plan_id: plan.id,
      calculated_at: calculatedAt,
    });
  } catch (err: any) {
    // idempotent: unique(order_id,user_id,role_context)
    if (err?.code !== 'ER_DUP_ENTRY') throw err;
  }

  // Driver row (if assigned)
  if (o.assigned_driver_id) {
    const driverAmount = await calcAmountTx(ex, plan.id, 'driver', deliveredQtyTotal);
    try {
      await ex.insert(incentiveLedger).values({
        id: randomUUID(),
        order_id: orderId,
        user_id: o.assigned_driver_id,
        role_context: 'driver',
        deliveries_count: 1,
        chickens_count: deliveredQtyTotal,
        amount_total: String(driverAmount),
        plan_id: plan.id,
        calculated_at: calculatedAt,
      });
    } catch (err: any) {
      if (err?.code !== 'ER_DUP_ENTRY') throw err;
    }
  }
}

// repository.ts içine ekle

export async function listOrdersForDriver(ex: Executor, driverId: string, q: any) {
  const conds: any[] = [];
  // Driver için: sadece assigned olanlar
  conds.push(eq(orders.assigned_driver_id, driverId));

  if (q.status) conds.push(eq(orders.status, q.status));

  const df = parseDate(q.date_from);
  const dt = parseDate(q.date_to);
  if (df) conds.push(gte(orders.created_at, df));
  if (dt) conds.push(lte(orders.created_at, dt));

  const where = conds.length === 1 ? conds[0] : and(...conds);
  const dir = q.direction === 'asc' ? asc : desc;

  return await ex
    .select()
    .from(orders)
    .where(where)
    .orderBy(dir(orders.created_at))
    .limit(q.limit)
    .offset(q.offset);
}



export async function adminCountOrders(ex: Executor, q: any) {
  const conds: any[] = [];

  if (q.status) conds.push(eq(orders.status, q.status));
  if (q.city_id) conds.push(eq(orders.city_id, q.city_id));
  if (q.district_id) conds.push(eq(orders.district_id, q.district_id));

  if (q.q) {
    const term = `%${String(q.q).trim()}%`;
    conds.push(
      sql`(${orders.customer_name} LIKE ${term} OR ${orders.customer_phone} LIKE ${term})`,
    );
  }

  const df = parseDate(q.date_from);
  const dt = parseDate(q.date_to);
  if (df) conds.push(gte(orders.created_at, df));
  if (dt) conds.push(lte(orders.created_at, dt));

  const where = conds.length ? (conds.length === 1 ? conds[0] : and(...conds)) : undefined;

  const row = await ex
    .select({ c: sql<number>`COUNT(*)`.as('c') })
    .from(orders)
    .where(where);

  return Number(row?.[0]?.c ?? 0);
}



