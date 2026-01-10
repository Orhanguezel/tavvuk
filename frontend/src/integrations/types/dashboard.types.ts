// =============================================================
// FILE: src/integrations/types/dashboard.types.ts
// FINAL — Dashboard Analytics Types (admin)
// =============================================================

export type DashboardRangeKey = '7d' | '30d' | '90d';
export type DashboardTrendBucket = 'day' | 'week';

export type AdminDashboardAnalyticsQuery = {
  range?: DashboardRangeKey;
};

export interface DashboardAnalyticsDto {
  range: DashboardRangeKey;
  from: string; // ISO
  to: string; // ISO
  meta: {
    bucket: DashboardTrendBucket;
  };

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
}
