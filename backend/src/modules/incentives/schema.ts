// =============================================================
// FILE: src/modules/incentives/schema.ts
// FINAL — Incentives schema (plans + rules + ledger) [Drizzle MySQL]
// - Reports için ek indexler eklendi
// =============================================================

import {
  mysqlTable,
  char,
  varchar,
  tinyint,
  datetime,
  decimal,
  date,
  index,
  uniqueIndex,
  foreignKey,
} from 'drizzle-orm/mysql-core';

import { users } from '@/modules/auth/schema';
import { orders } from '@/modules/orders/schema';
import { products } from '@/modules/products/schema';

export const incentivePlans = mysqlTable(
  'incentive_plans',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),

    name: varchar('name', { length: 120 }).notNull(),
    is_active: tinyint('is_active').notNull(), // 0/1

    effective_from: date('effective_from', { mode: 'date' }).notNull(),

    created_by: char('created_by', { length: 36 }).notNull(),

    created_at: datetime('created_at', { mode: 'date', fsp: 3 }).notNull(),
    updated_at: datetime('updated_at', { mode: 'date', fsp: 3 }).notNull(),
  },
  (t) => ({
    idxActiveFrom: index('idx_incentive_plans_active_from').on(t.is_active, t.effective_from),
    idxCreatedAt: index('idx_incentive_plans_created_at').on(t.created_at),

    fkCreatedBy: foreignKey({
      columns: [t.created_by],
      foreignColumns: [users.id],
      name: 'fk_incentive_plans_created_by',
    })
      .onDelete('restrict')
      .onUpdate('cascade'),
  }),
);

export const incentiveRules = mysqlTable(
  'incentive_rules',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),

    plan_id: char('plan_id', { length: 36 }).notNull(),

    // creator | driver
    role_context: varchar('role_context', { length: 20 }).notNull(),

    // per_delivery | per_chicken
    rule_type: varchar('rule_type', { length: 20 }).notNull(),

    amount: decimal('amount', { precision: 12, scale: 2 }).notNull(),

    // optional product targeting
    product_id: char('product_id', { length: 36 }),

    is_active: tinyint('is_active').notNull(), // 0/1

    created_at: datetime('created_at', { mode: 'date', fsp: 3 }).notNull(),
    updated_at: datetime('updated_at', { mode: 'date', fsp: 3 }).notNull(),
  },
  (t) => ({
    idxPlan: index('idx_incentive_rules_plan').on(t.plan_id),
    idxPlanRole: index('idx_incentive_rules_plan_role').on(t.plan_id, t.role_context),
    idxPlanActive: index('idx_incentive_rules_plan_active').on(t.plan_id, t.is_active),

    fkPlan: foreignKey({
      columns: [t.plan_id],
      foreignColumns: [incentivePlans.id],
      name: 'fk_incentive_rules_plan',
    })
      .onDelete('cascade')
      .onUpdate('cascade'),

    fkProduct: foreignKey({
      columns: [t.product_id],
      foreignColumns: [products.id],
      name: 'fk_incentive_rules_product',
    })
      .onDelete('set null')
      .onUpdate('cascade'),
  }),
);

export const incentiveLedger = mysqlTable(
  'incentive_ledger',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),

    order_id: char('order_id', { length: 36 }).notNull(),
    user_id: char('user_id', { length: 36 }).notNull(),

    role_context: varchar('role_context', { length: 20 }).notNull(),

    deliveries_count: tinyint('deliveries_count').notNull(), // 0/1
    chickens_count: decimal('chickens_count', { precision: 12, scale: 2 }).notNull(),

    amount_total: decimal('amount_total', { precision: 12, scale: 2 }).notNull(),

    plan_id: char('plan_id', { length: 36 }).notNull(),

    calculated_at: datetime('calculated_at', { mode: 'date', fsp: 3 }).notNull(),
  },
  (t) => ({
    uqOrderUserRole: uniqueIndex('uq_incentive_ledger_order_user_role').on(
      t.order_id,
      t.user_id,
      t.role_context,
    ),

    idxUser: index('idx_incentive_ledger_user').on(t.user_id),
    idxOrder: index('idx_incentive_ledger_order').on(t.order_id),
    idxPlan: index('idx_incentive_ledger_plan').on(t.plan_id),
    idxCalc: index('idx_incentive_ledger_calculated_at').on(t.calculated_at),
    idxRole: index('idx_incentive_ledger_role').on(t.role_context),

    // -----------------------------
    // Reports ek indexleri (FINAL)
    // -----------------------------
    idxRoleCalc: index('idx_incentive_ledger_role_calc').on(t.role_context, t.calculated_at),
    idxUserRoleCalc: index('idx_incentive_ledger_user_role_calc').on(
      t.user_id,
      t.role_context,
      t.calculated_at,
    ),

    fkOrder: foreignKey({
      columns: [t.order_id],
      foreignColumns: [orders.id],
      name: 'fk_incentive_ledger_order',
    })
      .onDelete('cascade')
      .onUpdate('cascade'),

    fkUser: foreignKey({
      columns: [t.user_id],
      foreignColumns: [users.id],
      name: 'fk_incentive_ledger_user',
    })
      .onDelete('cascade')
      .onUpdate('cascade'),

    fkPlan: foreignKey({
      columns: [t.plan_id],
      foreignColumns: [incentivePlans.id],
      name: 'fk_incentive_ledger_plan',
    })
      .onDelete('restrict')
      .onUpdate('cascade'),
  }),
);

export type IncentivePlanRow = typeof incentivePlans.$inferSelect;
export type IncentiveRuleRow = typeof incentiveRules.$inferSelect;
export type IncentiveLedgerRow = typeof incentiveLedger.$inferSelect;

export type IncentivePlanInsert = typeof incentivePlans.$inferInsert;
export type IncentiveRuleInsert = typeof incentiveRules.$inferInsert;
export type IncentiveLedgerInsert = typeof incentiveLedger.$inferInsert;
