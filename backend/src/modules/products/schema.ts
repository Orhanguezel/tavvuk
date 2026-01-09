// =============================================================
// FILE: src/modules/products/schema.ts
// FINAL — Tavvuk Products (poultry types)
// - Simple product entity for poultry breeds/species
// - Stock fields exist but no stock logic enforced in v1
// =============================================================
import {
  mysqlTable,
  char,
  varchar,
  text,
  longtext,
  int,
  tinyint,
  decimal,
  datetime,
  json,
  index,
  uniqueIndex,
  mysqlEnum,
} from 'drizzle-orm/mysql-core';
import { sql } from 'drizzle-orm';

export const POULTRY_SPECIES = ['chicken', 'duck', 'goose', 'turkey', 'quail', 'other'] as const;
export type PoultrySpecies = (typeof POULTRY_SPECIES)[number];

export const products = mysqlTable(
  'products',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),

    // ✅ core
    title: varchar('title', { length: 255 }).notNull(),
    slug: varchar('slug', { length: 255 }).notNull(),

    // ✅ poultry classification
    species: mysqlEnum('species', POULTRY_SPECIES).notNull().default('chicken'),
    breed: varchar('breed', { length: 255 }), // e.g. Ataks, Sussex, Tinted...
    summary: varchar('summary', { length: 500 }),
    description: text('description'),

    // ✅ commercial (optional)
    price: decimal('price', { precision: 10, scale: 2 }).notNull().default('0.00'),

    // ✅ images (cover + gallery)
    image_url: longtext('image_url'),
    storage_asset_id: char('storage_asset_id', { length: 36 }),
    alt: varchar('alt', { length: 255 }),
    images: json('images')
      .$type<string[]>()
      .notNull()
      .default(sql`JSON_ARRAY()`),
    storage_image_ids: json('storage_image_ids')
      .$type<string[]>()
      .notNull()
      .default(sql`JSON_ARRAY()`),

    // ✅ stock (v1: informational only)
    stock_quantity: int('stock_quantity').notNull().default(0),

    // ✅ flags
    is_active: tinyint('is_active').notNull().default(1).$type<boolean>(),
    is_featured: tinyint('is_featured').notNull().default(0).$type<boolean>(),

    // ✅ tags for search/filter
    tags: json('tags')
      .$type<string[]>()
      .notNull()
      .default(sql`JSON_ARRAY()`),

    created_at: datetime('created_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`),
    updated_at: datetime('updated_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`)
      .$onUpdateFn(() => new Date()),
  },
  (t) => [
    uniqueIndex('products_slug_uq').on(t.slug),

    index('products_species_idx').on(t.species),
    index('products_breed_idx').on(t.breed),
    index('products_active_idx').on(t.is_active),
    index('products_featured_idx').on(t.is_featured),
    index('products_asset_idx').on(t.storage_asset_id),
    index('products_created_at_idx').on(t.created_at),
  ],
);

export type ProductRow = typeof products.$inferSelect;
export type NewProductRow = typeof products.$inferInsert;
