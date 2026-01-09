// =============================================================
// FILE: src/integrations/types/incentives.types.ts
// FINAL — Incentives RTK Types (admin + public)
// =============================================================

export type IncentiveRoleContext = 'creator' | 'driver';
export type IncentiveRuleType = 'per_delivery' | 'per_chicken';

/* ----------------------------- Plans ----------------------------- */

export interface IncentivePlanDto {
  id: string;
  name: string;
  is_active: 0 | 1;
  effective_from: string; // YYYY-MM-DD
  created_by: string;
  created_at: string;
  updated_at: string;
}

export type AdminPlanListQuery = {
  q?: string;
  is_active?: boolean | 0 | 1;
  limit?: number;
  offset?: number;
  sort?: 'created_at' | 'effective_from' | 'name';
  order?: 'asc' | 'desc';
};

export type AdminPlanCreateBody = {
  name: string;
  is_active?: boolean;
  effective_from: string; // YYYY-MM-DD
};

export type AdminPlanPatchBody = {
  id: string;
  name?: string;
  is_active?: boolean;
  effective_from?: string;
};

/* ----------------------------- Rules ----------------------------- */

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

export type AdminReplaceRulesBody = {
  rules: {
    role_context: IncentiveRoleContext;
    rule_type: IncentiveRuleType;
    amount: number;
    product_id?: string | null;
    is_active?: boolean;
  }[];
};

/* ----------------------------- Ledger ----------------------------- */

export interface IncentiveLedgerDto {
  id: string;
  order_id: string;
  user_id: string;
  role_context: IncentiveRoleContext;
  deliveries_count: 0 | 1;
  chickens_count: string; // decimal
  amount_total: string; // decimal
  plan_id: string;
  calculated_at: string;
}

export type AdminLedgerListQuery = {
  order_id?: string;
  user_id?: string;
  role_context?: IncentiveRoleContext;
  from?: string;
  to?: string;
  limit?: number;
  offset?: number;
};

/* ----------------------------- Summary ----------------------------- */

export interface IncentiveSummaryRow {
  user_id: string;
  role_context: IncentiveRoleContext;
  deliveries_count: number;
  chickens_count: number;
  amount_total: number;
}

export type AdminSummaryQuery = {
  from?: string;
  to?: string;
  role_context?: IncentiveRoleContext;
  user_id?: string;
};

export type MySummaryQuery = {
  from?: string;
  to?: string;
};
