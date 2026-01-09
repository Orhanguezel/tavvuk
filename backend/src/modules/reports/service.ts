// =============================================================
// FILE: src/modules/reports/service.ts
// FINAL — Reports service (admin aggregates)
// - Source tables: orders, order_items, cities, districts, incentive_ledger
// =============================================================

import { and, eq, gte, lte, sql } from 'drizzle-orm';

import { orders, orderItems } from '@/modules/orders/schema';
import { incentiveLedger } from '@/modules/incentives/schema';
import { cities, districts } from '@/modules/locations/schema'; // Eğer path farklıysa düzelt: modules/locations
import type { KpiRow, LocationRow, ReportRole, UserPerformanceRow } from './types';

type Executor = any;

function parseDate(v?: string): Date | null {
  if (!v) return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

function defaultFromTo(q: any): { from: Date; to: Date } {
  const df = parseDate(q?.from);
  const dt = parseDate(q?.to);

  const to = dt ?? new Date();
  const from = df ?? new Date(Date.now() - 30 * 24 * 3600 * 1000);

  return { from, to };
}

function safeRate(num: number, den: number): number {
  if (!den || den <= 0) return 0;
  return Math.round((num / den) * 10000) / 10000; // 4 decimals
}

function isoWeekLabelFromYearWeek(yearWeekNum: number): string {
  // MariaDB YEARWEEK(date, 3) returns e.g. 202601
  const s = String(yearWeekNum);
  if (s.length !== 6) return s;
  const y = s.slice(0, 4);
  const w = s.slice(4);
  return `${y}-W${w}`;
}

/* ============================================================================
   KPI: daily/weekly/monthly aggregates
   ============================================================================ */

export async function adminGetKpi(ex: Executor, q: any): Promise<KpiRow[]> {
  const { from, to } = defaultFromTo(q);

  // day
  const dayRows = await ex
    .select({
      bucket: sql<string>`DATE_FORMAT(${orders.created_at}, '%Y-%m-%d')`.as('bucket'),
      orders_total: sql<number>`COUNT(*)`.as('orders_total'),
      delivered_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='delivered' THEN 1 ELSE 0 END)`.as(
          'delivered_orders',
        ),
      cancelled_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='cancelled' THEN 1 ELSE 0 END)`.as(
          'cancelled_orders',
        ),
      chickens_delivered: sql<number>`
        COALESCE(SUM(
          CASE WHEN ${orders.status}='delivered'
          THEN (SELECT COALESCE(SUM(oi.qty_delivered),0) FROM order_items oi WHERE oi.order_id = ${orders.id})
          ELSE 0 END
        ),0)
      `.as('chickens_delivered'),
    })
    .from(orders)
    .where(and(gte(orders.created_at, from), lte(orders.created_at, to)))
    .groupBy(sql`DATE_FORMAT(${orders.created_at}, '%Y-%m-%d')`)
    .orderBy(sql`bucket ASC`);

  // week (ISO)
  const weekRows = await ex
    .select({
      bucketYW: sql<number>`YEARWEEK(${orders.created_at}, 3)`.as('bucketYW'),
      orders_total: sql<number>`COUNT(*)`.as('orders_total'),
      delivered_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='delivered' THEN 1 ELSE 0 END)`.as(
          'delivered_orders',
        ),
      cancelled_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='cancelled' THEN 1 ELSE 0 END)`.as(
          'cancelled_orders',
        ),
      chickens_delivered: sql<number>`
        COALESCE(SUM(
          CASE WHEN ${orders.status}='delivered'
          THEN (SELECT COALESCE(SUM(oi.qty_delivered),0) FROM order_items oi WHERE oi.order_id = ${orders.id})
          ELSE 0 END
        ),0)
      `.as('chickens_delivered'),
    })
    .from(orders)
    .where(and(gte(orders.created_at, from), lte(orders.created_at, to)))
    .groupBy(sql`YEARWEEK(${orders.created_at}, 3)`)
    .orderBy(sql`bucketYW ASC`);

  // month
  const monthRows = await ex
    .select({
      bucket: sql<string>`DATE_FORMAT(${orders.created_at}, '%Y-%m')`.as('bucket'),
      orders_total: sql<number>`COUNT(*)`.as('orders_total'),
      delivered_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='delivered' THEN 1 ELSE 0 END)`.as(
          'delivered_orders',
        ),
      cancelled_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='cancelled' THEN 1 ELSE 0 END)`.as(
          'cancelled_orders',
        ),
      chickens_delivered: sql<number>`
        COALESCE(SUM(
          CASE WHEN ${orders.status}='delivered'
          THEN (SELECT COALESCE(SUM(oi.qty_delivered),0) FROM order_items oi WHERE oi.order_id = ${orders.id})
          ELSE 0 END
        ),0)
      `.as('chickens_delivered'),
    })
    .from(orders)
    .where(and(gte(orders.created_at, from), lte(orders.created_at, to)))
    .groupBy(sql`DATE_FORMAT(${orders.created_at}, '%Y-%m')`)
    .orderBy(sql`bucket ASC`);

  const out: KpiRow[] = [];

  for (const r of dayRows as any[]) {
    const total = Number(r.orders_total ?? 0);
    const delivered = Number(r.delivered_orders ?? 0);
    const cancelled = Number(r.cancelled_orders ?? 0);
    const denom = total - cancelled;
    out.push({
      period: 'day',
      bucket: String(r.bucket),
      orders_total: total,
      delivered_orders: delivered,
      cancelled_orders: cancelled,
      chickens_delivered: Number(r.chickens_delivered ?? 0),
      success_rate: safeRate(delivered, denom),
    });
  }

  for (const r of weekRows as any[]) {
    const total = Number(r.orders_total ?? 0);
    const delivered = Number(r.delivered_orders ?? 0);
    const cancelled = Number(r.cancelled_orders ?? 0);
    const denom = total - cancelled;
    out.push({
      period: 'week',
      bucket: isoWeekLabelFromYearWeek(Number(r.bucketYW ?? 0)),
      orders_total: total,
      delivered_orders: delivered,
      cancelled_orders: cancelled,
      chickens_delivered: Number(r.chickens_delivered ?? 0),
      success_rate: safeRate(delivered, denom),
    });
  }

  for (const r of monthRows as any[]) {
    const total = Number(r.orders_total ?? 0);
    const delivered = Number(r.delivered_orders ?? 0);
    const cancelled = Number(r.cancelled_orders ?? 0);
    const denom = total - cancelled;
    out.push({
      period: 'month',
      bucket: String(r.bucket),
      orders_total: total,
      delivered_orders: delivered,
      cancelled_orders: cancelled,
      chickens_delivered: Number(r.chickens_delivered ?? 0),
      success_rate: safeRate(delivered, denom),
    });
  }

  return out;
}

/* ============================================================================
   Users Performance: per seller/driver
   - role=seller => orders.created_by
   - role=driver => orders.assigned_driver_id
   - incentives from incentive_ledger (role_context mapped)
   ============================================================================ */

export async function adminUserPerformance(ex: Executor, q: any): Promise<UserPerformanceRow[]> {
  const { from, to } = defaultFromTo(q);
  const role: ReportRole = q.role;

  const userIdExpr =
    role === 'seller'
      ? sql<string>`${orders.created_by}`
      : sql<string>`${orders.assigned_driver_id}`;

  const roleContext = role === 'seller' ? 'creator' : 'driver';

  // base aggregates from orders + items
  const baseRows = await ex
    .select({
      user_id: userIdExpr.as('user_id'),
      orders_total: sql<number>`COUNT(*)`.as('orders_total'),
      delivered_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='delivered' THEN 1 ELSE 0 END)`.as(
          'delivered_orders',
        ),
      cancelled_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='cancelled' THEN 1 ELSE 0 END)`.as(
          'cancelled_orders',
        ),
      chickens_delivered: sql<number>`
        COALESCE(SUM(
          CASE WHEN ${orders.status}='delivered'
          THEN (SELECT COALESCE(SUM(oi.qty_delivered),0) FROM order_items oi WHERE oi.order_id = ${orders.id})
          ELSE 0 END
        ),0)
      `.as('chickens_delivered'),
    })
    .from(orders)
    .where(
      and(
        gte(orders.created_at, from),
        lte(orders.created_at, to),
        role === 'driver' ? sql`${orders.assigned_driver_id} IS NOT NULL` : sql`1=1`,
      ),
    )
    .groupBy(userIdExpr)
    .orderBy(sql`orders_total DESC`);

  // incentives aggregates from ledger
  const ledgerRows = await ex
    .select({
      user_id: incentiveLedger.user_id,
      amount_total: sql<number>`COALESCE(SUM(${incentiveLedger.amount_total}),0)`.as(
        'amount_total',
      ),
      deliveries_count: sql<number>`COALESCE(SUM(${incentiveLedger.deliveries_count}),0)`.as(
        'deliveries_count',
      ),
      chickens_count: sql<number>`COALESCE(SUM(${incentiveLedger.chickens_count}),0)`.as(
        'chickens_count',
      ),
    })
    .from(incentiveLedger)
    .where(
      and(
        eq(incentiveLedger.role_context, roleContext),
        gte(incentiveLedger.calculated_at, from),
        lte(incentiveLedger.calculated_at, to),
      ),
    )
    .groupBy(incentiveLedger.user_id);

  const ledgerMap = new Map<string, any>((ledgerRows as any[]).map((x) => [String(x.user_id), x]));

  return (baseRows as any[])
    .filter((r) => String(r.user_id ?? '').trim())
    .map((r) => {
      const uid = String(r.user_id);
      const total = Number(r.orders_total ?? 0);
      const delivered = Number(r.delivered_orders ?? 0);
      const cancelled = Number(r.cancelled_orders ?? 0);
      const denom = total - cancelled;

      const led = ledgerMap.get(uid);
      return {
        user_id: uid,
        role,
        orders_total: total,
        delivered_orders: delivered,
        cancelled_orders: cancelled,
        chickens_delivered: Number(r.chickens_delivered ?? 0),
        success_rate: safeRate(delivered, denom),

        incentive_amount_total: Number(led?.amount_total ?? 0),
        incentive_deliveries_count: Number(led?.deliveries_count ?? 0),
        incentive_chickens_count: Number(led?.chickens_count ?? 0),
      };
    });
}

/* ============================================================================
   Locations: city/district breakdown
   ============================================================================ */

export async function adminLocations(ex: Executor, q: any): Promise<LocationRow[]> {
  const { from, to } = defaultFromTo(q);

  const rows = await ex
    .select({
      city_id: orders.city_id,
      district_id: orders.district_id,

      city_name: cities.name,
      district_name: districts.name,

      orders_total: sql<number>`COUNT(*)`.as('orders_total'),
      delivered_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='delivered' THEN 1 ELSE 0 END)`.as(
          'delivered_orders',
        ),
      cancelled_orders:
        sql<number>`SUM(CASE WHEN ${orders.status}='cancelled' THEN 1 ELSE 0 END)`.as(
          'cancelled_orders',
        ),
      chickens_delivered: sql<number>`
        COALESCE(SUM(
          CASE WHEN ${orders.status}='delivered'
          THEN (SELECT COALESCE(SUM(oi.qty_delivered),0) FROM order_items oi WHERE oi.order_id = ${orders.id})
          ELSE 0 END
        ),0)
      `.as('chickens_delivered'),
    })
    .from(orders)
    .leftJoin(cities, eq(cities.id, orders.city_id))
    .leftJoin(districts, eq(districts.id, orders.district_id))
    .where(and(gte(orders.created_at, from), lte(orders.created_at, to)))
    .groupBy(orders.city_id, orders.district_id, cities.name, districts.name)
    .orderBy(sql`orders_total DESC`);

  return (rows as any[]).map((r) => {
    const total = Number(r.orders_total ?? 0);
    const delivered = Number(r.delivered_orders ?? 0);
    const cancelled = Number(r.cancelled_orders ?? 0);
    const denom = total - cancelled;

    return {
      city_id: r.city_id ? String(r.city_id) : null,
      city_name: r.city_name ? String(r.city_name) : null,
      district_id: r.district_id ? String(r.district_id) : null,
      district_name: r.district_name ? String(r.district_name) : null,

      orders_total: total,
      delivered_orders: delivered,
      cancelled_orders: cancelled,
      chickens_delivered: Number(r.chickens_delivered ?? 0),
      success_rate: safeRate(delivered, denom),
    };
  });
}
