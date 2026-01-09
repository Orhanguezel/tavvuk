// =============================================================
// FILE: src/modules/email-templates/schema.ts
// FINAL — Email Templates (Single Language)
// - No i18n table
// - name, subject, content live in parent table
// =============================================================

import {
  mysqlTable,
  char,
  varchar,
  text,
  datetime,
  tinyint,
  uniqueIndex,
  index,
} from 'drizzle-orm/mysql-core';
import { sql } from 'drizzle-orm';

export const emailTemplates = mysqlTable(
  'email_templates',
  {
    id: char('id', { length: 36 }).notNull().primaryKey(),

    template_key: varchar('template_key', { length: 100 }).notNull(),

    // Single-language fields
    template_name: varchar('template_name', { length: 150 }).notNull(),
    subject: varchar('subject', { length: 255 }).notNull(),
    content: text('content').notNull(), // HTML

    // JSON-string (string[]) | null
    variables: text('variables'),

    // 0/1
    is_active: tinyint('is_active').notNull().default(1),

    created_at: datetime('created_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`),

    updated_at: datetime('updated_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`)
      .$onUpdateFn(() => new Date()),
  },
  (t) => [
    uniqueIndex('ux_email_tpl_key').on(t.template_key),
    index('ix_email_tpl_active').on(t.is_active),
    index('ix_email_tpl_updated_at').on(t.updated_at),
    index('ix_email_tpl_name').on(t.template_name),
  ],
);

export type EmailTemplateRow = typeof emailTemplates.$inferSelect;
export type NewEmailTemplateRow = typeof emailTemplates.$inferInsert;
