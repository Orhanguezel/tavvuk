// ===================================================================
// FILE: src/modules/notifications/schema.ts
// FINAL — Notifications (Drizzle / MySQL)
// ===================================================================

import { mysqlTable, char, varchar, text, tinyint, datetime, index } from 'drizzle-orm/mysql-core';
import { sql } from 'drizzle-orm';

export const notifications = mysqlTable(
  'notifications',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),

    // auth user id (users tablosu ile FK kurmak istersen sonradan ekleriz)
    user_id: char('user_id', { length: 36 }).notNull(),

    title: varchar('title', { length: 255 }).notNull(),
    message: text('message').notNull(),

    // serbest string (union type ile DX iyileştirme)
    type: varchar('type', { length: 50 }).notNull(),

    // 0/1 (MySQL’de boolean yerine tinyint daha stabil)
    is_read: tinyint('is_read', { unsigned: true }).notNull().default(0),

    created_at: datetime('created_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`),
  },
  (t) => [
    index('idx_notifications_user_id').on(t.user_id),
    index('idx_notifications_user_read').on(t.user_id, t.is_read),
    index('idx_notifications_created_at').on(t.created_at),
  ],
);

export type NotificationRow = typeof notifications.$inferSelect;
export type NotificationInsert = typeof notifications.$inferInsert;

/**
 * Bildirim türleri için tavsiye edilen union.
 * DB tarafında serbest string.
 */
export type NotificationType =
  | 'order_created'
  | 'order_paid'
  | 'order_failed'
  | 'booking_created'
  | 'booking_status_changed'
  | 'system'
  | 'custom'
  | (string & {});
