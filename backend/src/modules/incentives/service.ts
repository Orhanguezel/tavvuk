// =============================================================
// FILE: src/modules/incentives/service.ts
// FINAL — Incentives service (plans + rules + ledger + summary + engine)
// =============================================================

import { randomUUID } from 'crypto';
import { and, asc, desc, eq, like, lte, gte, sql } from 'drizzle-orm';

import { incentivePlans, incentiveRules, incentiveLedger } from './schema';
import { orders, orderItems } from '@/modules/orders/schema';
import type { IncentiveRoleContext } from './types';

type Executor = any;

function toInt(v: any, fb: number) {
  const n = Number(v);
  return Number.isFinite(n) ? n : fb;
}

function parseDate(v?: string): Date | null {
  if (!v) return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

function money(n: number) {
  // keep 2 decimals
  return Math.round(n * 100) / 100;
}

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

async function calcDeliveredTotalTx(ex: Executor, orderId: string): Promise<number> {
  const sumRow = await ex
    .select({ s: sql<number>`COALESCE(SUM(${orderItems.qty_delivered}),0)`.as('s') })
    .from(orderItems)
    .where(eq(orderItems.order_id, orderId));
  return Number(sumRow?.[0]?.s ?? 0);
}

/**
 * MVP calculation:
 * - per_delivery: sum(amount) where rule_type=per_delivery and product_id is null
 * - per_chicken:
 *   - if product_id is null => amount * delivered_total
 *   - if product_id specified => amount * delivered_qty_for_that_product
 */
async function calcAmountTx(
  ex: Executor,
  planId: string,
  role: IncentiveRoleContext,
  orderId: string,
  deliveredTotal: number,
): Promise<number> {
  const rules = await getRulesTx(ex, planId, role);

  const perDelivery = rules
    .filter((r: any) => r.rule_type === 'per_delivery' && !r.product_id)
    .reduce((a: number, r: any) => a + Number(r.amount ?? 0), 0);

  // generic per_chicken (no product)
  const perChickenGeneric = rules
    .filter((r: any) => r.rule_type === 'per_chicken' && !r.product_id)
    .reduce((a: number, r: any) => a + Number(r.amount ?? 0), 0);

  // product-specific per_chicken
  const productRules = rules.filter((r: any) => r.rule_type === 'per_chicken' && r.product_id);

      let productSpecific = 0;

      if (productRules.length) {
        const rows: Array<{ product_id: unknown; s: number | string | null }> = await ex
          .select({
            product_id: orderItems.product_id,
            s: sql<number>`COALESCE(SUM(${orderItems.qty_delivered}),0)`.as('s'),
          })
          .from(orderItems)
          .where(eq(orderItems.order_id, orderId))
          .groupBy(orderItems.product_id);

        const qtyByProduct = new Map<string, number>(
          rows.map((x) => [String(x.product_id ?? ''), Number(x.s ?? 0)]),
        );

        for (const r of productRules as any[]) {
          const pid = String(r.product_id ?? '');
          const qty: number = qtyByProduct.get(pid) ?? 0; 
          productSpecific += Number(r.amount ?? 0) * qty;
        }
      }



  return money(perDelivery + perChickenGeneric * deliveredTotal + productSpecific);
}

/* ============================================================================
   Ledger Engine — called when order becomes delivered
   ============================================================================ */

export async function generateLedgerForOrderTx(ex: Executor, orderId: string) {
  const o = (await ex.select().from(orders).where(eq(orders.id, orderId)).limit(1))[0];
  if (!o) return;

  // no ledger for cancelled or not-delivered
  if (o.status !== 'delivered') return;
  if (!o.delivered_at) return;
  if (o.status === 'cancelled') return;

  const deliveredAt = new Date(o.delivered_at as any);
  const plan = await pickActivePlanTx(ex, deliveredAt);
  if (!plan) return;

  // delivered_qty_total should be consistent, but we compute from items for correctness
  const deliveredTotal = await calcDeliveredTotalTx(ex, orderId);
  const calculatedAt = new Date();

  // creator row
  const creatorAmount = await calcAmountTx(ex, plan.id, 'creator', orderId, deliveredTotal);
  try {
    await ex.insert(incentiveLedger).values({
      id: randomUUID(),
      order_id: orderId,
      user_id: o.created_by,
      role_context: 'creator',
      deliveries_count: 1,
      chickens_count: String(deliveredTotal),
      amount_total: String(creatorAmount),
      plan_id: plan.id,
      calculated_at: calculatedAt,
    });
  } catch (err: any) {
    // idempotent unique(order_id,user_id,role_context)
    if (err?.code !== 'ER_DUP_ENTRY') throw err;
  }

  // driver row (if assigned)
  if (o.assigned_driver_id) {
    const driverAmount = await calcAmountTx(ex, plan.id, 'driver', orderId, deliveredTotal);
    try {
      await ex.insert(incentiveLedger).values({
        id: randomUUID(),
        order_id: orderId,
        user_id: o.assigned_driver_id,
        role_context: 'driver',
        deliveries_count: 1,
        chickens_count: String(deliveredTotal),
        amount_total: String(driverAmount),
        plan_id: plan.id,
        calculated_at: calculatedAt,
      });
    } catch (err: any) {
      if (err?.code !== 'ER_DUP_ENTRY') throw err;
    }
  }
}

/* ============================================================================
   Admin — Plans CRUD
   ============================================================================ */

export async function adminListPlans(ex: Executor, q: any) {
  const conds: any[] = [];
  if (q.q) conds.push(like(incentivePlans.name, `%${String(q.q).trim()}%`));
  if (q.is_active !== undefined) conds.push(eq(incentivePlans.is_active, q.is_active ? 1 : 0));

  const where = conds.length ? (conds.length === 1 ? conds[0] : and(...conds)) : undefined;

  const limit = toInt(q.limit, 50);
  const offset = toInt(q.offset, 0);

  const sortCol =
    q.sort === 'name'
      ? incentivePlans.name
      : q.sort === 'effective_from'
      ? incentivePlans.effective_from
      : incentivePlans.created_at;

  const dir = q.order === 'asc' ? asc : desc;

  return await ex
    .select()
    .from(incentivePlans)
    .where(where)
    .orderBy(dir(sortCol))
    .limit(limit)
    .offset(offset);
}

export async function adminCreatePlanTx(
  ex: Executor,
  input: { name: string; is_active: boolean; effective_from: string; created_by: string },
) {
  const id = randomUUID();
  const now = new Date();

  await ex.insert(incentivePlans).values({
    id,
    name: input.name,
    is_active: input.is_active ? 1 : 0,
    effective_from: new Date(input.effective_from) as any,
    created_by: input.created_by,
    created_at: now,
    updated_at: now,
  });

  const row = (await ex.select().from(incentivePlans).where(eq(incentivePlans.id, id)).limit(1))[0];
  return row ?? null;
}

export async function adminPatchPlanTx(
  ex: Executor,
  planId: string,
  patch: Partial<{ name: string; is_active: boolean; effective_from: string }>,
) {
  const now = new Date();
  await ex
    .update(incentivePlans)
    .set({
      ...(patch.name !== undefined ? { name: patch.name } : {}),
      ...(patch.is_active !== undefined ? { is_active: patch.is_active ? 1 : 0 } : {}),
      ...(patch.effective_from !== undefined
        ? { effective_from: new Date(patch.effective_from) as any }
        : {}),
      updated_at: now,
    } as any)
    .where(eq(incentivePlans.id, planId));

  const row = (
    await ex.select().from(incentivePlans).where(eq(incentivePlans.id, planId)).limit(1)
  )[0];
  return row ?? null;
}

/* ============================================================================
   Admin — Rules (GET + PUT replace)
   ============================================================================ */

export async function adminGetRules(ex: Executor, planId: string) {
  return await ex
    .select()
    .from(incentiveRules)
    .where(eq(incentiveRules.plan_id, planId))
    .orderBy(desc(incentiveRules.created_at));
}

export async function adminReplaceRulesTx(
  ex: Executor,
  planId: string,
  input: {
    rules: {
      role_context: 'creator' | 'driver';
      rule_type: 'per_delivery' | 'per_chicken';
      amount: number;
      product_id?: string | null;
      is_active?: boolean;
    }[];
  },
) {
  const now = new Date();

  // hard replace
  await ex.delete(incentiveRules).where(eq(incentiveRules.plan_id, planId));

  if (input.rules.length) {
    await ex.insert(incentiveRules).values(
      input.rules.map((r) => ({
        id: randomUUID(),
        plan_id: planId,
        role_context: r.role_context,
        rule_type: r.rule_type,
        amount: String(money(Number(r.amount))),
        product_id: r.product_id ?? null,
        is_active: r.is_active === undefined ? 1 : r.is_active ? 1 : 0,
        created_at: now,
        updated_at: now,
      })),
    );
  }

  return { ok: true };
}

/* ============================================================================
   Admin — Ledger list + Summary
   ============================================================================ */

export async function adminListLedger(ex: Executor, q: any) {
  const conds: any[] = [];
  if (q.order_id) conds.push(eq(incentiveLedger.order_id, q.order_id));
  if (q.user_id) conds.push(eq(incentiveLedger.user_id, q.user_id));
  if (q.role_context) conds.push(eq(incentiveLedger.role_context, q.role_context));

  const df = parseDate(q.from);
  const dt = parseDate(q.to);
  if (df) conds.push(gte(incentiveLedger.calculated_at, df));
  if (dt) conds.push(lte(incentiveLedger.calculated_at, dt));

  const where = conds.length ? (conds.length === 1 ? conds[0] : and(...conds)) : undefined;

  const limit = toInt(q.limit, 200);
  const offset = toInt(q.offset, 0);

  return await ex
    .select()
    .from(incentiveLedger)
    .where(where)
    .orderBy(desc(incentiveLedger.calculated_at))
    .limit(limit)
    .offset(offset);
}

export async function adminSummary(ex: Executor, q: any) {
  const conds: any[] = [];

  if (q.user_id) conds.push(eq(incentiveLedger.user_id, q.user_id));
  if (q.role_context) conds.push(eq(incentiveLedger.role_context, q.role_context));

  const df = parseDate(q.from);
  const dt = parseDate(q.to);
  if (df) conds.push(gte(incentiveLedger.calculated_at, df));
  if (dt) conds.push(lte(incentiveLedger.calculated_at, dt));

  const where = conds.length ? (conds.length === 1 ? conds[0] : and(...conds)) : undefined;

  const rows = await ex
    .select({
      user_id: incentiveLedger.user_id,
      role_context: incentiveLedger.role_context,
      deliveries_count: sql<number>`COALESCE(SUM(${incentiveLedger.deliveries_count}),0)`.as(
        'deliveries_count',
      ),
      chickens_count: sql<number>`COALESCE(SUM(${incentiveLedger.chickens_count}),0)`.as(
        'chickens_count',
      ),
      amount_total: sql<number>`COALESCE(SUM(${incentiveLedger.amount_total}),0)`.as(
        'amount_total',
      ),
    })
    .from(incentiveLedger)
    .where(where)
    .groupBy(incentiveLedger.user_id, incentiveLedger.role_context)
    .orderBy(desc(sql`amount_total`));

  return rows.map((r: any) => ({
    user_id: String(r.user_id),
    role_context: String(r.role_context),
    deliveries_count: Number(r.deliveries_count ?? 0),
    chickens_count: Number(r.chickens_count ?? 0),
    amount_total: Number(r.amount_total ?? 0),
  }));
}

export async function mySummary(ex: Executor, userId: string, q: any) {
  return await adminSummary(ex, { ...q, user_id: userId });
}
