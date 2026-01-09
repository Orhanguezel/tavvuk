// =============================================================
// FILE: src/modules/userRoles/schema.ts
// FINAL — Tavvuk user_roles schema
// =============================================================
import { mysqlTable, char, mysqlEnum, datetime, index, uniqueIndex } from 'drizzle-orm/mysql-core';
import { sql } from 'drizzle-orm';

export const USER_ROLES = ['admin', 'seller', 'driver'] as const;
export type UserRoleName = (typeof USER_ROLES)[number];

export const userRoles = mysqlTable(
  'user_roles',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),
    user_id: char('user_id', { length: 36 }).notNull(),

    role: mysqlEnum('role', USER_ROLES).notNull(),

    created_at: datetime('created_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`),
  },
  (t) => [
    index('user_roles_user_id_idx').on(t.user_id),
    uniqueIndex('user_roles_user_role_unique').on(t.user_id, t.role),
  ],
);

export type UserRoleRow = typeof userRoles.$inferSelect;
export type UserRoleInsert = typeof userRoles.$inferInsert;
