// ===================================================================
// FILE: src/modules/dashboard/admin.controller.ts
// FINAL — Tavvuk Admin Dashboard Analytics (Delivered + Hak Edilen Prim)
// - Orders: delivered_at zaman ekseni
// - Units: order_items.qty_delivered (teslim edilen adet)
// - Incentives: incentive_ledger.amount_total (hak edilen toplam)
// - Mix: product/species bazlı teslim edilen adet (pie)
// - Trend: range'a göre day/week bucket (line)
// ===================================================================

import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';
import { sql, and, eq, inArray } from 'drizzle-orm';

import { orders, orderItems } from '@/modules/orders/schema';
import { products } from '@/modules/products/schema';
import { incentiveLedger } from '@/modules/incentives/schema';
import { users } from '@/modules/auth/schema';

type RangeKey = '7d' | '30d' | '90d';
type TrendBucket = 'day' | 'week';

type DashboardAnalyticsDto = {
  range: RangeKey;
  from: string; // ISO
  to: string; // ISO
  meta: { bucket: TrendBucket };

  totals: {
    delivered_orders: number;
    total_units_delivered: number;
    total_incentives: number;
  };

  drivers: Array<{
    driver_id: string;
    driver_name: string;
    delivered_orders: number;
    units_delivered: number;
    incentives: number;
  }>;

  sellers: Array<{
    seller_id: string;
    seller_name: string;
    delivered_orders: number;
    units_delivered: number;
    incentives: number;
  }>;

  product_mix: Array<{
    product_id: string;
    product_title: string;
    units_delivered: number;
  }>;

  species_mix: Array<{
    species: string;
    units_delivered: number;
  }>;

  trend: Array<{
    bucket: string; // YYYY-MM-DD | YYYY-Wxx
    delivered_orders: number;
    units_delivered: number;
    incentives: number;
  }>;
};

/* ----------------------------- helpers ----------------------------- */

function safeText(v: unknown, fb = ''): string {
  const s = String(v ?? '').trim();
  return s ? s : fb;
}

function toNum(v: unknown, fb = 0): number {
  const n = Number(v);
  return Number.isFinite(n) ? n : fb;
}

function parseRange(raw: unknown): RangeKey {
  const r = String(raw ?? '').trim();
  if (r === '7d' || r === '30d' || r === '90d') return r;
  return '30d';
}

function addDaysUtc(d: Date, days: number) {
  const x = new Date(d.getTime());
  x.setUTCDate(x.getUTCDate() + days);
  return x;
}

function computeWindow(range: RangeKey) {
  const to = new Date();
  const days = range === '7d' ? 7 : range === '30d' ? 30 : 90;
  const from = addDaysUtc(to, -days);
  const bucket: TrendBucket = range === '90d' ? 'week' : 'day';
  return { from, to, bucket };
}

/**
 * MySQL bucket expressions:
 * day  -> DATE(delivered_at) => 'YYYY-MM-DD'
 * week -> CONCAT(YEAR(delivered_at), '-W', LPAD(WEEK(delivered_at, 3), 2, '0'))
 */
function bucketExpr(bucket: TrendBucket) {
  if (bucket === 'day') {
    return sql<string>`DATE(${orders.delivered_at})`;
  }
  return sql<string>`CONCAT(YEAR(${orders.delivered_at}), '-W', LPAD(WEEK(${orders.delivered_at}, 3), 2, '0'))`;
}

function topNPlusOther<T>(
  rows: T[],
  n: number,
  getValue: (x: T) => number,
  makeOther: (sum: number) => T,
): T[] {
  if (rows.length <= n) return rows;
  const top = rows.slice(0, n);
  const rest = rows.slice(n);
  const restSum = rest.reduce((acc, x) => acc + getValue(x), 0);
  return [...top, makeOther(restSum)];
}

/* ----------------------------- handler ----------------------------- */

export const getDashboardAnalyticsAdmin: RouteHandler = async (req, reply) => {
  const range = parseRange((req.query as any)?.range);
  const { from, to, bucket } = computeWindow(range);

  try {
    // -------------------------------------------
    // BASE FILTER: delivered + delivered_at window
    // -------------------------------------------
    const deliveredWhere = and(
      eq(orders.status, 'delivered' as any),
      sql`${orders.delivered_at} IS NOT NULL`,
      sql`${orders.delivered_at} >= ${from} AND ${orders.delivered_at} < ${to}`,
    );

    // ------------------------------------------------------------
    // 1) Totals
    // ------------------------------------------------------------

    const deliveredCountRows = await db
      .select({ c: sql<number>`COUNT(*)` })
      .from(orders)
      .where(deliveredWhere)
      .limit(1);

    const delivered_orders = toNum(deliveredCountRows[0]?.c, 0);

    const unitsRows = await db
      .select({ u: sql<number>`COALESCE(SUM(${orderItems.qty_delivered}), 0)` })
      .from(orderItems)
      .innerJoin(orders, eq(orderItems.order_id, orders.id))
      .where(deliveredWhere)
      .limit(1);

    const total_units_delivered = toNum(unitsRows[0]?.u, 0);

    const incRows = await db
      .select({ s: sql<number>`COALESCE(SUM(${incentiveLedger.amount_total}), 0)` })
      .from(incentiveLedger)
      .innerJoin(orders, eq(incentiveLedger.order_id, orders.id))
      .where(deliveredWhere)
      .limit(1);

    const total_incentives = toNum(incRows[0]?.s, 0);

    // ------------------------------------------------------------
    // 2) Drivers breakdown (orders.assigned_driver_id)
    // ------------------------------------------------------------

    const driversOU = await db
      .select({
        driver_id: sql<string>`COALESCE(${orders.assigned_driver_id}, '')`,
        delivered_orders: sql<number>`COUNT(DISTINCT ${orders.id})`,
        units_delivered: sql<number>`COALESCE(SUM(${orderItems.qty_delivered}), 0)`,
      })
      .from(orders)
      .leftJoin(orderItems, eq(orderItems.order_id, orders.id))
      .where(deliveredWhere)
      .groupBy(orders.assigned_driver_id);

    const driversInc = await db
      .select({
        driver_id: incentiveLedger.user_id,
        incentives: sql<number>`COALESCE(SUM(${incentiveLedger.amount_total}), 0)`,
      })
      .from(incentiveLedger)
      .innerJoin(orders, eq(incentiveLedger.order_id, orders.id))
      .where(and(deliveredWhere, eq(incentiveLedger.role_context, 'driver')))
      .groupBy(incentiveLedger.user_id);

    const driverIncMap = new Map<string, number>(
      driversInc.map((r) => [String(r.driver_id), toNum(r.incentives, 0)]),
    );

    const driverIds = Array.from(
      new Set(driversOU.map((r) => String(r.driver_id || '').trim()).filter(Boolean)),
    );

    // ⚠️ users.full_name yoksa burayı users schema'nıza göre düzeltin.
    const driverUsers = driverIds.length
      ? await db
          .select({
            id: users.id,
            name: sql<string>`COALESCE(${(users as any).full_name}, ${users.email}, '')`,
          })
          .from(users)
          .where(inArray(users.id, driverIds))
      : [];

    const driverNameMap = new Map(driverUsers.map((u) => [String(u.id), safeText(u.name, '—')]));

    const drivers = driversOU
      .filter((r) => String(r.driver_id || '').trim())
      .map((r) => {
        const id = String(r.driver_id);
        return {
          driver_id: id,
          driver_name: driverNameMap.get(id) ?? '—',
          delivered_orders: toNum(r.delivered_orders, 0),
          units_delivered: toNum(r.units_delivered, 0),
          incentives: driverIncMap.get(id) ?? 0,
        };
      })
      .sort((a, b) => b.incentives - a.incentives);

    // ------------------------------------------------------------
    // 3) Sellers breakdown (orders.created_by)
    // ------------------------------------------------------------

    const sellersOU = await db
      .select({
        seller_id: sql<string>`COALESCE(${orders.created_by}, '')`,
        delivered_orders: sql<number>`COUNT(DISTINCT ${orders.id})`,
        units_delivered: sql<number>`COALESCE(SUM(${orderItems.qty_delivered}), 0)`,
      })
      .from(orders)
      .leftJoin(orderItems, eq(orderItems.order_id, orders.id))
      .where(deliveredWhere)
      .groupBy(orders.created_by);

    const sellersInc = await db
      .select({
        seller_id: incentiveLedger.user_id,
        incentives: sql<number>`COALESCE(SUM(${incentiveLedger.amount_total}), 0)`,
      })
      .from(incentiveLedger)
      .innerJoin(orders, eq(incentiveLedger.order_id, orders.id))
      .where(and(deliveredWhere, eq(incentiveLedger.role_context, 'creator')))
      .groupBy(incentiveLedger.user_id);

    const sellerIncMap = new Map<string, number>(
      sellersInc.map((r) => [String(r.seller_id), toNum(r.incentives, 0)]),
    );

    const sellerIds = Array.from(
      new Set(sellersOU.map((r) => String(r.seller_id || '').trim()).filter(Boolean)),
    );

    // ⚠️ users.full_name yoksa burayı users schema'nıza göre düzeltin.
    const sellerUsers = sellerIds.length
      ? await db
          .select({
            id: users.id,
            name: sql<string>`COALESCE(${(users as any).full_name}, ${users.email}, '')`,
          })
          .from(users)
          .where(inArray(users.id, sellerIds))
      : [];

    const sellerNameMap = new Map(sellerUsers.map((u) => [String(u.id), safeText(u.name, '—')]));

    const sellers = sellersOU
      .filter((r) => String(r.seller_id || '').trim())
      .map((r) => {
        const id = String(r.seller_id);
        return {
          seller_id: id,
          seller_name: sellerNameMap.get(id) ?? '—',
          delivered_orders: toNum(r.delivered_orders, 0),
          units_delivered: toNum(r.units_delivered, 0),
          incentives: sellerIncMap.get(id) ?? 0,
        };
      })
      .sort((a, b) => b.units_delivered - a.units_delivered);

    // ------------------------------------------------------------
    // 4) Product mix (pie)
    // ------------------------------------------------------------

    const productAgg = await db
      .select({
        product_id: orderItems.product_id,
        units_delivered: sql<number>`COALESCE(SUM(${orderItems.qty_delivered}), 0)`,
      })
      .from(orderItems)
      .innerJoin(orders, eq(orderItems.order_id, orders.id))
      .where(deliveredWhere)
      .groupBy(orderItems.product_id);

    const productIds = productAgg.map((r) => String(r.product_id)).filter(Boolean);

    const productRows = productIds.length
      ? await db
          .select({ id: products.id, title: products.title })
          .from(products)
          .where(inArray(products.id, productIds))
      : [];

    const productTitleMap = new Map(productRows.map((p) => [String(p.id), safeText(p.title, '—')]));

    const productMixRaw = productAgg
      .map((r) => ({
        product_id: String(r.product_id),
        product_title: productTitleMap.get(String(r.product_id)) ?? '—',
        units_delivered: toNum(r.units_delivered, 0),
      }))
      .sort((a, b) => b.units_delivered - a.units_delivered);

    const product_mix = topNPlusOther(
      productMixRaw,
      10,
      (x) => x.units_delivered,
      (sum) => ({ product_id: '__other__', product_title: 'Diğer', units_delivered: sum }),
    );

    // ------------------------------------------------------------
    // 5) Species mix (pie)
    // ------------------------------------------------------------

    const speciesAgg = await db
      .select({
        species: products.species,
        units_delivered: sql<number>`COALESCE(SUM(${orderItems.qty_delivered}), 0)`,
      })
      .from(orderItems)
      .innerJoin(orders, eq(orderItems.order_id, orders.id))
      .innerJoin(products, eq(orderItems.product_id, products.id))
      .where(deliveredWhere)
      .groupBy(products.species);

    const species_mix = speciesAgg
      .map((r) => ({
        species: String(r.species),
        units_delivered: toNum(r.units_delivered, 0),
      }))
      .sort((a, b) => b.units_delivered - a.units_delivered);

    // ------------------------------------------------------------
    // 6) Trend (line)
    // ------------------------------------------------------------

    const bExpr = bucketExpr(bucket);

    const trendOU = await db
      .select({
        bucket: bExpr,
        delivered_orders: sql<number>`COUNT(DISTINCT ${orders.id})`,
        units_delivered: sql<number>`COALESCE(SUM(${orderItems.qty_delivered}), 0)`,
      })
      .from(orders)
      .leftJoin(orderItems, eq(orderItems.order_id, orders.id))
      .where(deliveredWhere)
      .groupBy(bExpr)
      .orderBy(bExpr);

    const trendInc = await db
      .select({
        bucket: bExpr,
        incentives: sql<number>`COALESCE(SUM(${incentiveLedger.amount_total}), 0)`,
      })
      .from(incentiveLedger)
      .innerJoin(orders, eq(incentiveLedger.order_id, orders.id))
      .where(deliveredWhere)
      .groupBy(bExpr)
      .orderBy(bExpr);

    const incByBucket = new Map<string, number>(
      trendInc.map((r) => [String((r as any).bucket), toNum((r as any).incentives, 0)]),
    );

    const trend = trendOU.map((r) => {
      const key = String((r as any).bucket);
      return {
        bucket: key,
        delivered_orders: toNum((r as any).delivered_orders, 0),
        units_delivered: toNum((r as any).units_delivered, 0),
        incentives: incByBucket.get(key) ?? 0,
      };
    });

    const payload: DashboardAnalyticsDto = {
      range,
      from: from.toISOString(),
      to: to.toISOString(),
      meta: { bucket },
      totals: {
        delivered_orders,
        total_units_delivered,
        total_incentives,
      },
      drivers,
      sellers,
      product_mix,
      species_mix,
      trend,
    };

    return reply.send(payload);
  } catch (err) {
    req.log.error({ err }, 'dashboard_analytics_failed');
    return reply.code(500).send({ error: { message: 'dashboard_analytics_failed' } });
  }
};
