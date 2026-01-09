// =============================================================
// FILE: src/integrations/types/reports.types.ts
// FINAL — Reports Types (admin queries + DTO)
// Backend: src/modules/reports/* ile uyumlu
// =============================================================

import type { BoolLike } from '@/integrations/types/common';

/** ----------------------------- Enums ----------------------------- */

export type ReportRole = 'seller' | 'driver';
export type KpiPeriod = 'day' | 'week' | 'month';

/** ----------------------------- Query Types ----------------------------- */
/**
 * Backend validation:
 * - from/to: optional string (ISO date or datetime); service Date() parse ediyor
 * - from <= to
 */
export type DateRangeQuery = {
  from?: string;
  to?: string;
};

export type AdminKpiQuery = DateRangeQuery;

export type AdminUserPerformanceQuery = DateRangeQuery & {
  role: ReportRole;
};

export type AdminLocationsQuery = DateRangeQuery;

/** ----------------------------- DTOs ----------------------------- */

export interface KpiRow {
  period: KpiPeriod;
  bucket: string; // YYYY-MM-DD | YYYY-Www | YYYY-MM
  orders_total: number;
  delivered_orders: number;
  cancelled_orders: number;
  chickens_delivered: number;
  success_rate: number; // 0..1 (4 decimals)
}

export interface UserPerformanceRow {
  user_id: string;
  role: ReportRole;

  orders_total: number;
  delivered_orders: number;
  cancelled_orders: number;

  chickens_delivered: number;
  success_rate: number;

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
