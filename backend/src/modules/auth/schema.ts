// =============================================================
// FILE: src/modules/auth/schema.ts
// FINAL — Tavvuk users + refresh_tokens (Drizzle)
// =============================================================
import {
  mysqlTable,
  char,
  varchar,
  tinyint,
  datetime,
  index,
  uniqueIndex,
} from 'drizzle-orm/mysql-core';
import { sql } from 'drizzle-orm';
import { longtext } from '@/modules/_shared/longtext';

/** USERS */
export const users = mysqlTable(
  'users',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),
    email: varchar('email', { length: 255 }).notNull(),
    password_hash: varchar('password_hash', { length: 255 }).notNull(),
    full_name: varchar('full_name', { length: 255 }),
    phone: varchar('phone', { length: 50 }),

    // ✅ optional profile image on users
    profile_image: varchar('profile_image', { length: 500 }),
    profile_image_asset_id: char('profile_image_asset_id', { length: 36 }),
    profile_image_alt: varchar('profile_image_alt', { length: 255 }),

    // (projedeki legacy alanlar varsa kalsın)
    featured_image: varchar('featured_image', { length: 500 }),
    featured_image_asset_id: char('featured_image_asset_id', { length: 36 }),
    image_url: longtext('image_url'),
    storage_asset_id: char('storage_asset_id', { length: 36 }),
    alt: varchar('alt', { length: 255 }),

    is_active: tinyint('is_active').notNull().default(1),
    email_verified: tinyint('email_verified').notNull().default(0),

    reset_token: varchar('reset_token', { length: 255 }),
    reset_token_expires: datetime('reset_token_expires', { fsp: 3 }),

    created_at: datetime('created_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`),

    updated_at: datetime('updated_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`)
      .$onUpdateFn(() => new Date()),

    last_sign_in_at: datetime('last_sign_in_at', { fsp: 3 }),
  },
  (t) => [
    uniqueIndex('users_email_unique').on(t.email),
    index('users_is_active_idx').on(t.is_active),
    index('users_created_at_idx').on(t.created_at),
  ],
);

/** REFRESH TOKENS (hash + rotation) */
export const refresh_tokens = mysqlTable(
  'refresh_tokens',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(), // jti
    user_id: char('user_id', { length: 36 }).notNull(),
    token_hash: varchar('token_hash', { length: 255 }).notNull(),

    created_at: datetime('created_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`),

    expires_at: datetime('expires_at', { fsp: 3 }).notNull(),
    revoked_at: datetime('revoked_at', { fsp: 3 }),
    replaced_by: char('replaced_by', { length: 36 }),
  },
  (t) => [
    index('refresh_tokens_user_id_idx').on(t.user_id),
    index('refresh_tokens_expires_at_idx').on(t.expires_at),
  ],
);

export type User = typeof users.$inferSelect;
export type NewUser = typeof users.$inferInsert;
export type RefreshToken = typeof refresh_tokens.$inferSelect;
