// =============================================================
// FILE: src/modules/incentives/validation.ts
// FINAL — Incentives validation schemas
// =============================================================

import { z } from 'zod';

const boolLike = z.union([z.boolean(), z.number(), z.string()]).transform((v) => {
  if (typeof v === 'boolean') return v;
  const s = String(v).trim().toLowerCase();
  return s === '1' || s === 'true' || s === 'yes' || s === 'on';
});

export const roleContextSchema = z.enum(['creator', 'driver']);
export const ruleTypeSchema = z.enum(['per_delivery', 'per_chicken']);

export const adminPlanListQuerySchema = z.object({
  q: z.string().optional(),
  is_active: boolLike.optional(),
  limit: z.union([z.string(), z.number()]).optional(),
  offset: z.union([z.string(), z.number()]).optional(),
  sort: z.enum(['created_at', 'effective_from', 'name']).optional(),
  order: z.enum(['asc', 'desc']).optional(),
});

export const adminPlanCreateBodySchema = z.object({
  name: z.string().min(2).max(120),
  is_active: boolLike.optional(),
  effective_from: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
});

export const adminPlanPatchBodySchema = z.object({
  name: z.string().min(2).max(120).optional(),
  is_active: boolLike.optional(),
  effective_from: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/)
    .optional(),
});

export const adminRulesReplaceBodySchema = z.object({
  rules: z
    .array(
      z.object({
        role_context: roleContextSchema,
        rule_type: ruleTypeSchema,
        amount: z.number().nonnegative(),
        product_id: z.string().uuid().nullable().optional(),
        is_active: boolLike.optional(),
      }),
    )
    .max(200),
});

export const adminLedgerListQuerySchema = z.object({
  order_id: z.string().uuid().optional(),
  user_id: z.string().uuid().optional(),
  role_context: roleContextSchema.optional(),
  from: z.string().optional(),
  to: z.string().optional(),
  limit: z.union([z.string(), z.number()]).optional(),
  offset: z.union([z.string(), z.number()]).optional(),
});

export const adminSummaryQuerySchema = z.object({
  from: z.string().optional(),
  to: z.string().optional(),
  role_context: roleContextSchema.optional(),
  user_id: z.string().uuid().optional(),
});

export const mySummaryQuerySchema = z.object({
  from: z.string().optional(),
  to: z.string().optional(),
});
