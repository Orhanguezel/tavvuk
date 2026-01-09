// =============================================================
// FILE: src/modules/incentives/types.ts
// FINAL — Incentives shared types
// =============================================================

export type IncentiveRoleContext = 'creator' | 'driver';
export type IncentiveRuleType = 'per_delivery' | 'per_chicken';

export interface IncentivePlanDto {
  id: string;
  name: string;
  is_active: 0 | 1;
  effective_from: string; // YYYY-MM-DD
  created_by: string;
  created_at: string;
  updated_at: string;
}

export interface IncentiveRuleDto {
  id: string;
  plan_id: string;
  role_context: IncentiveRoleContext;
  rule_type: IncentiveRuleType;
  amount: string; // decimal string
  product_id: string | null;
  is_active: 0 | 1;
  created_at: string;
  updated_at: string;
}

export interface IncentiveLedgerDto {
  id: string;
  order_id: string;
  user_id: string;
  role_context: IncentiveRoleContext;
  deliveries_count: 0 | 1;
  chickens_count: string; // decimal string
  amount_total: string; // decimal string
  plan_id: string;
  calculated_at: string;
}

export interface IncentiveSummaryRow {
  user_id: string;
  role_context: IncentiveRoleContext;
  deliveries_count: number;
  chickens_count: number;
  amount_total: number;
}
