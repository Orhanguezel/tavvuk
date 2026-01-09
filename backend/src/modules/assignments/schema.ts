// =============================================================
// FILE: src/modules/assignments/schema.ts
// FINAL — Assignments schema (Drizzle MySQL)
// - Audit trail for order ↔ driver assignments
// - "Only one active assignment per order" is enforced in service (tx)
// =============================================================

import { mysqlTable, char, varchar, datetime, index } from 'drizzle-orm/mysql-core';

export const assignments = mysqlTable(
  'assignments',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),

    order_id: char('order_id', { length: 36 }).notNull(),
    driver_id: char('driver_id', { length: 36 }).notNull(),
    assigned_by: char('assigned_by', { length: 36 }).notNull(),

    // active | cancelled
    status: varchar('status', { length: 20 }).notNull(),

    note: varchar('note', { length: 1000 }),

    cancelled_by: char('cancelled_by', { length: 36 }),
    cancelled_at: datetime('cancelled_at', { mode: 'date', fsp: 3 }),
    cancel_reason: varchar('cancel_reason', { length: 255 }),

    created_at: datetime('created_at', { mode: 'date', fsp: 3 }).notNull(),
    updated_at: datetime('updated_at', { mode: 'date', fsp: 3 }).notNull(),
  },
  (t) => ({
    idxDriver: index('idx_assignments_driver').on(t.driver_id),
    idxOrder: index('idx_assignments_order').on(t.order_id),
    idxOrderStatus: index('idx_assignments_order_status').on(t.order_id, t.status),
    idxStatus: index('idx_assignments_status').on(t.status),
    idxCreatedAt: index('idx_assignments_created_at').on(t.created_at),
  }),
);

export type AssignmentRow = typeof assignments.$inferSelect;
export type AssignmentInsert = typeof assignments.$inferInsert;
