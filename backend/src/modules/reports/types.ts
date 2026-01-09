// =============================================================
// FILE: src/modules/reports/types.ts
// FINAL — Reports shared types (DTO)
// =============================================================

export type ReportRole = 'seller' | 'driver';

export interface KpiRow {
  period: 'day' | 'week' | 'month';
  bucket: string; // YYYY-MM-DD or YYYY-Www or YYYY-MM
  orders_total: number;
  delivered_orders: number;
  cancelled_orders: number;
  chickens_delivered: number; // sum(order_items.qty_delivered) (delivered orders)
  success_rate: number; // delivered_orders / (orders_total - cancelled_orders)
}

export interface UserPerformanceRow {
  user_id: string;
  role: ReportRole;

  orders_total: number; // submitted+approved+assigned+on_delivery+delivered+cancelled (range)
  delivered_orders: number;
  cancelled_orders: number;

  chickens_delivered: number;
  success_rate: number;

  // incentives (ledger) — optional if no ledger in range
  incentive_amount_total: number;
  incentive_deliveries_count: number;
  incentive_chickens_count: number;
}

export interface LocationRow {
  city_id: string | null;
  city_name: string | null;
  district_id: string | null;
  district_name: string | null;

  orders_total: number;
  delivered_orders: number;
  cancelled_orders: number;
  chickens_delivered: number;
  success_rate: number;
}
