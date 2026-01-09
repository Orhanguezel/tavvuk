// src/integrations/types/orders.types.ts
// =============================================================
// Tavvuk – Orders Types (shared: public + driver + admin)
// =============================================================

export type OrderStatus =
  | 'submitted'
  | 'approved'
  | 'assigned'
  | 'on_delivery'
  | 'delivered'
  | 'cancelled';

export const ORDER_STATUSES: readonly OrderStatus[] = [
  'submitted',
  'approved',
  'assigned',
  'on_delivery',
  'delivered',
  'cancelled',
] as const;

export type OrderItemInput = {
  product_id: string; // uuid
  qty_ordered: number;
};

export type CreateOrderBody = {
  city_id: string; // uuid
  district_id?: string | null; // uuid

  customer_name: string;
  customer_phone: string;
  address_text: string;

  items: OrderItemInput[];
};

export type PatchOrderBody = Partial<{
  city_id: string;
  district_id: string | null;

  customer_name: string;
  customer_phone: string;
  address_text: string;

  items: OrderItemInput[];
}>;

export type ListOrdersQuery = Partial<{
  status: OrderStatus;
  date_from: string; // ISO
  date_to: string; // ISO

  limit: number;
  offset: number;
  order: 'created_at';
  direction: 'asc' | 'desc';
}>;

export type AdminListOrdersQuery = Partial<{
  status: OrderStatus;
  city_id: string;
  district_id: string;

  q: string; // name/phone
  date_from: string; // ISO
  date_to: string; // ISO

  limit: number;
  offset: number;
  sort: 'created_at' | 'status';
  order: 'asc' | 'desc';
}>;

export type AdminAssignDriverBody = {
  driver_id: string; // uuid
};

export type AdminCancelBody = {
  cancel_reason?: string;
};

export type DriverDeliverBody = {
  delivery_note?: string;
  items: {
    order_item_id: string; // uuid
    qty_delivered: number;
  }[];
};

// ------------------------------------------------------------
// View models (backend rows are returned directly from drizzle)
// ------------------------------------------------------------

export type OrderView = {
  id: string;

  created_by: string;

  assigned_driver_id?: string | null;
  status: OrderStatus;

  city_id: string;
  district_id?: string | null;

  customer_name: string;
  customer_phone: string;
  address_text: string;

  note_internal?: string | null;

  approved_by?: string | null;
  approved_at?: string | null;

  assigned_by?: string | null;
  assigned_at?: string | null;

  delivered_at?: string | null;
  delivery_note?: string | null;

  delivered_qty_total?: number;
  is_delivery_counted?: any;

  cancel_reason?: string | null;

  created_at?: string;
  updated_at?: string;
};

export type OrderItemView = {
  id: string;
  order_id: string;
  product_id: string;

  qty_ordered: number;
  qty_delivered: number;

  created_at?: string;
  updated_at?: string;
};

export type OrderDetailResponse = {
  order: OrderView | null;
  items: OrderItemView[];
};


// admin assign-driver response: { ok: true, assignment: ... } (service shape unknown)
// burada minimumla tipliyoruz
export type AdminAssignDriverResponse = {
  ok: true;
  assignment: any | null;
};


// Driver list query (listOrdersQuerySchema ile uyumlu)
export type DriverOrdersListQuery = ListOrdersQuery & { q?: string }; // q UI filter

