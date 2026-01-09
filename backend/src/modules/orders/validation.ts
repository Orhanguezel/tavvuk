// =============================================================
// FILE: src/modules/orders/validation.ts
// FINAL — Orders validations (public + driver + admin)
// =============================================================
import { z } from 'zod';
import { ORDER_STATUSES } from './schema';

export const orderStatusEnum = z.enum(ORDER_STATUSES);

export const orderItemInputSchema = z.object({
  product_id: z.string().uuid(),
  qty_ordered: z.coerce.number().int().min(1).max(100000),
});

export const createOrderBodySchema = z.object({
  city_id: z.string().uuid(),
  district_id: z.string().uuid().optional().nullable(),

  customer_name: z.string().trim().min(2).max(255),
  customer_phone: z.string().trim().min(6).max(50),
  address_text: z.string().trim().min(5),

  items: z.array(orderItemInputSchema).min(1).max(200),
});

export const patchOrderBodySchema = z
  .object({
    city_id: z.string().uuid().optional(),
    district_id: z.string().uuid().nullable().optional(),

    customer_name: z.string().trim().min(2).max(255).optional(),
    customer_phone: z.string().trim().min(6).max(50).optional(),
    address_text: z.string().trim().min(5).optional(),

    items: z.array(orderItemInputSchema).min(1).max(200).optional(),
  })
  .strict();

export const listOrdersQuerySchema = z.object({
  status: orderStatusEnum.optional(),
  date_from: z.string().optional(), // ISO
  date_to: z.string().optional(), // ISO

  limit: z.coerce.number().int().min(1).max(200).default(50),
  offset: z.coerce.number().int().min(0).max(1_000_000).default(0),
  order: z.enum(['created_at']).default('created_at'),
  direction: z.enum(['asc', 'desc']).default('desc'),
});

export const adminListOrdersQuerySchema = z.object({
  status: orderStatusEnum.optional(),
  city_id: z.string().uuid().optional(),
  district_id: z.string().uuid().optional(),

  q: z.string().optional(), // name/phone
  date_from: z.string().optional(),
  date_to: z.string().optional(),

  limit: z.coerce.number().int().min(1).max(200).default(50),
  offset: z.coerce.number().int().min(0).max(1_000_000).default(0),
  sort: z.enum(['created_at', 'status']).default('created_at'),
  order: z.enum(['asc', 'desc']).default('desc'),
});

export const adminApproveBodySchema = z.object({}).optional();

export const adminAssignDriverBodySchema = z.object({
  driver_id: z.string().uuid(),
});

export const adminCancelBodySchema = z.object({
  cancel_reason: z.string().trim().min(2).max(255).optional(),
});

export const driverDeliverBodySchema = z.object({
  delivery_note: z.string().trim().max(2000).optional(),
  items: z
    .array(
      z.object({
        order_item_id: z.string().uuid(),
        qty_delivered: z.coerce.number().int().min(0).max(100000),
      }),
    )
    .min(1)
    .max(500),
});

export type CreateOrderBody = z.infer<typeof createOrderBodySchema>;
export type PatchOrderBody = z.infer<typeof patchOrderBodySchema>;
export type ListOrdersQuery = z.infer<typeof listOrdersQuerySchema>;
export type AdminListOrdersQuery = z.infer<typeof adminListOrdersQuerySchema>;
export type AdminAssignDriverBody = z.infer<typeof adminAssignDriverBodySchema>;
export type DriverDeliverBody = z.infer<typeof driverDeliverBodySchema>;
