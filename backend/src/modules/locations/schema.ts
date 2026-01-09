// =============================================================
// FILE: src/modules/locations/schema.ts
// FINAL — Tavvuk Locations schema (cities + districts)
// =============================================================
import {
  mysqlTable,
  char,
  varchar,
  int,
  tinyint,
  datetime,
  uniqueIndex,
  index,
  foreignKey,
} from 'drizzle-orm/mysql-core';
import { sql } from 'drizzle-orm';

/**
 * cities
 * - code: TR plate code (1..81) OR generic code (optional)
 * - name: city name
 */
export const cities = mysqlTable(
  'cities',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),

    /** TR plate code (1..81) */
    code: int('code').notNull(),

    name: varchar('name', { length: 128 }).notNull(),

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
    uniqueIndex('cities_code_uq').on(t.code),
    uniqueIndex('cities_name_uq').on(t.name),
    index('cities_active_idx').on(t.is_active),
  ],
);

/**
 * districts
 * - city_id FK
 * - code: within-city sequential code (optional, but useful)
 * - name: district name
 */
export const districts = mysqlTable(
  'districts',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),

    city_id: char('city_id', { length: 36 }).notNull(),
    code: int('code').notNull().default(0),

    name: varchar('name', { length: 128 }).notNull(),
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
    index('districts_city_id_idx').on(t.city_id),
    index('districts_active_idx').on(t.is_active),
    uniqueIndex('districts_city_name_uq').on(t.city_id, t.name),

    foreignKey({
      columns: [t.city_id],
      foreignColumns: [cities.id],
      name: 'fk_districts_city',
    })
      .onDelete('cascade')
      .onUpdate('cascade'),
  ],
);

export type CityRow = typeof cities.$inferSelect;
export type NewCityRow = typeof cities.$inferInsert;

export type DistrictRow = typeof districts.$inferSelect;
export type NewDistrictRow = typeof districts.$inferInsert;
