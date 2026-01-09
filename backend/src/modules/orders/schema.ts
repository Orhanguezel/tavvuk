// =============================================================
// FILE: src/modules/orders/schema.ts
// FINAL — Tavvuk Orders schema (orders + order_items + driver_routes)
// - Incentives tabloları BURADA YOK (tek kaynak: src/modules/incentives/schema.ts)
// - Reports için gerekli indexler eklendi
// =============================================================

import {
  mysqlTable,
  char,
  varchar,
  text,
  tinyint,
  int,
  datetime,
  index,
  mysqlEnum,
  foreignKey,
} from 'drizzle-orm/mysql-core';
import { sql } from 'drizzle-orm';

import { users } from '@/modules/auth/schema';
import { products } from '@/modules/products/schema';
import { cities, districts } from '@/modules/locations/schema';

/* ----------------------------- enums ----------------------------- */

export const ORDER_STATUSES = [
  'submitted',
  'approved',
  'assigned',
  'on_delivery',
  'delivered',
  'cancelled',
] as const;

export type OrderStatus = (typeof ORDER_STATUSES)[number];

/* ----------------------------- orders ----------------------------- */

export const orders = mysqlTable(
  'orders',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),

    created_by: char('created_by', { length: 36 }).notNull(),

    assigned_driver_id: char('assigned_driver_id', { length: 36 }),
    status: mysqlEnum('status', ORDER_STATUSES).notNull().default('submitted'),

    city_id: char('city_id', { length: 36 }).notNull(),
    district_id: char('district_id', { length: 36 }),

    customer_name: varchar('customer_name', { length: 255 }).notNull(),
    customer_phone: varchar('customer_phone', { length: 50 }).notNull(),
    address_text: text('address_text').notNull(),

    note_internal: text('note_internal'),

    approved_by: char('approved_by', { length: 36 }),
    approved_at: datetime('approved_at', { fsp: 3 }),

    assigned_by: char('assigned_by', { length: 36 }),
    assigned_at: datetime('assigned_at', { fsp: 3 }),

    delivered_at: datetime('delivered_at', { fsp: 3 }),
    delivery_note: text('delivery_note'),

    delivered_qty_total: int('delivered_qty_total').notNull().default(0),
    is_delivery_counted: tinyint('is_delivery_counted').notNull().default(0),

    cancel_reason: varchar('cancel_reason', { length: 255 }),

    created_at: datetime('created_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`),

    updated_at: datetime('updated_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`)
      .$onUpdateFn(() => new Date()),
  },
  (t) => [
    // mevcut indexler
    index('orders_status_created_at_idx').on(t.status, t.created_at),
    index('orders_city_district_created_at_idx').on(t.city_id, t.district_id, t.created_at),
    index('orders_created_by_created_at_idx').on(t.created_by, t.created_at),
    index('orders_assigned_driver_created_at_idx').on(t.assigned_driver_id, t.created_at),

    index('orders_customer_phone_idx').on(t.customer_phone),
    index('orders_customer_name_idx').on(t.customer_name),

    // -----------------------------
    // Reports ek indexleri (FINAL)
    // -----------------------------
    index('orders_status_delivered_at_idx').on(t.status, t.delivered_at),
    index('orders_created_by_delivered_at_idx').on(t.created_by, t.delivered_at),
    index('orders_assigned_driver_delivered_at_idx').on(t.assigned_driver_id, t.delivered_at),
    index('orders_city_delivered_at_idx').on(t.city_id, t.delivered_at),
    index('orders_district_delivered_at_idx').on(t.district_id, t.delivered_at),

    foreignKey({
      columns: [t.created_by],
      foreignColumns: [users.id],
      name: 'fk_orders_created_by',
    })
      .onDelete('restrict')
      .onUpdate('cascade'),

    foreignKey({
      columns: [t.assigned_driver_id],
      foreignColumns: [users.id],
      name: 'fk_orders_assigned_driver',
    })
      .onDelete('set null')
      .onUpdate('cascade'),

    foreignKey({
      columns: [t.approved_by],
      foreignColumns: [users.id],
      name: 'fk_orders_approved_by',
    })
      .onDelete('set null')
      .onUpdate('cascade'),

    foreignKey({
      columns: [t.assigned_by],
      foreignColumns: [users.id],
      name: 'fk_orders_assigned_by',
    })
      .onDelete('set null')
      .onUpdate('cascade'),

    foreignKey({
      columns: [t.city_id],
      foreignColumns: [cities.id],
      name: 'fk_orders_city',
    })
      .onDelete('restrict')
      .onUpdate('cascade'),

    foreignKey({
      columns: [t.district_id],
      foreignColumns: [districts.id],
      name: 'fk_orders_district',
    })
      .onDelete('set null')
      .onUpdate('cascade'),
  ],
);

/* ----------------------------- order_items ----------------------------- */

export const orderItems = mysqlTable(
  'order_items',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),
    order_id: char('order_id', { length: 36 }).notNull(),
    product_id: char('product_id', { length: 36 }).notNull(),

    qty_ordered: int('qty_ordered').notNull(),
    qty_delivered: int('qty_delivered').notNull().default(0),

    created_at: datetime('created_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`),

    updated_at: datetime('updated_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`)
      .$onUpdateFn(() => new Date()),
  },
  (t) => [
    // mevcut indexler
    index('order_items_order_id_idx').on(t.order_id),
    index('order_items_product_id_idx').on(t.product_id),

    // reports ek indexi (order+product)
    index('order_items_order_product_idx').on(t.order_id, t.product_id),

    foreignKey({
      columns: [t.order_id],
      foreignColumns: [orders.id],
      name: 'fk_order_items_order',
    })
      .onDelete('cascade')
      .onUpdate('cascade'),

    foreignKey({
      columns: [t.product_id],
      foreignColumns: [products.id],
      name: 'fk_order_items_product',
    })
      .onDelete('restrict')
      .onUpdate('cascade'),
  ],
);

/* ----------------------------- driver_routes (optional) ----------------------------- */

export const driverRoutes = mysqlTable(
  'driver_routes',
  {
    id: char('id', { length: 36 }).primaryKey().notNull(),
    driver_id: char('driver_id', { length: 36 }).notNull(),
    city_id: char('city_id', { length: 36 }).notNull(),
    district_id: char('district_id', { length: 36 }),

    created_at: datetime('created_at', { fsp: 3 })
      .notNull()
      .default(sql`CURRENT_TIMESTAMP(3)`),
  },
  (t) => [
    index('driver_routes_driver_idx').on(t.driver_id),
    index('driver_routes_city_district_idx').on(t.city_id, t.district_id),

    foreignKey({
      columns: [t.driver_id],
      foreignColumns: [users.id],
      name: 'fk_driver_routes_driver',
    })
      .onDelete('cascade')
      .onUpdate('cascade'),

    foreignKey({
      columns: [t.city_id],
      foreignColumns: [cities.id],
      name: 'fk_driver_routes_city',
    })
      .onDelete('restrict')
      .onUpdate('cascade'),

    foreignKey({
      columns: [t.district_id],
      foreignColumns: [districts.id],
      name: 'fk_driver_routes_district',
    })
      .onDelete('set null')
      .onUpdate('cascade'),
  ],
);

// Types
export type OrderRow = typeof orders.$inferSelect;
export type NewOrderRow = typeof orders.$inferInsert;

export type OrderItemRow = typeof orderItems.$inferSelect;
export type NewOrderItemRow = typeof orderItems.$inferInsert;

export type DriverRouteRow = typeof driverRoutes.$inferSelect;
