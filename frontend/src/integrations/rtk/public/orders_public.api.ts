// src/integrations/rtk/orders_public.api.ts
// =============================================================
// Tavvuk – Orders PUBLIC RTK
// Base prefix: /api (baseApi içinde varsayılır)
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  CreateOrderBody,
  PatchOrderBody,
  ListOrdersQuery,
  OrderView,
  OrderDetailResponse,
} from '@/integrations/types/orders.types';

const ORDERS_BASE = '/orders';

function cleanSp(sp: URLSearchParams): string {
  const s = sp.toString();
  return s;
}

function bool01(v: unknown): '1' | '0' | undefined {
  if (v === true || v === 1 || v === '1' || v === 'true') return '1';
  if (v === false || v === 0 || v === '0' || v === 'false') return '0';
  return undefined;
}

export const ordersPublicApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** POST /orders -> { order, items } */
    createOrder: b.mutation<OrderDetailResponse, CreateOrderBody>({
      query: (body) => ({ url: ORDERS_BASE, method: 'POST', body }),
      transformResponse: (res: any): OrderDetailResponse => ({
        order: (res?.order ?? null) as any,
        items: Array.isArray(res?.items) ? res.items : [],
      }),
      invalidatesTags: (_r) => [{ type: 'Orders' as const, id: 'MY_LIST' }],
    }),

    /** GET /orders -> Order[] (my orders, own OR assigned in repo) */
    listMyOrders: b.query<OrderView[], ListOrdersQuery | void>({
      query: (params) => {
        const p = (params ?? {}) as ListOrdersQuery;
        const sp = new URLSearchParams();

        if (p.status) sp.set('status', p.status);
        if (p.date_from) sp.set('date_from', p.date_from);
        if (p.date_to) sp.set('date_to', p.date_to);

        if (p.limit != null) sp.set('limit', String(p.limit));
        if (p.offset != null) sp.set('offset', String(p.offset));
        if (p.order) sp.set('order', p.order);
        if (p.direction) sp.set('direction', p.direction);

        const qs = cleanSp(sp);
        return { url: qs ? `${ORDERS_BASE}?${qs}` : ORDERS_BASE, method: 'GET' };
      },
      transformResponse: (res: any): OrderView[] => (Array.isArray(res) ? (res as any) : []),
      providesTags: (result) =>
        result?.length
          ? [
              ...result.map((o) => ({ type: 'Orders' as const, id: o.id })),
              { type: 'Orders' as const, id: 'MY_LIST' },
            ]
          : [{ type: 'Orders' as const, id: 'MY_LIST' }],
    }),

    /** GET /orders/:id -> { order, items } */
    getOrderDetail: b.query<OrderDetailResponse, { id: string }>({
      query: ({ id }) => ({ url: `${ORDERS_BASE}/${encodeURIComponent(id)}`, method: 'GET' }),
      transformResponse: (res: any): OrderDetailResponse => ({
        order: (res?.order ?? null) as any,
        items: Array.isArray(res?.items) ? res.items : [],
      }),
      providesTags: (_r, _e, arg) => [{ type: 'Orders' as const, id: arg.id }],
    }),

    /** PATCH /orders/:id -> { order, items } (only own + submitted) */
    patchMyOrder: b.mutation<OrderDetailResponse, { id: string; patch: PatchOrderBody }>({
      query: ({ id, patch }) => ({
        url: `${ORDERS_BASE}/${encodeURIComponent(id)}`,
        method: 'PATCH',
        body: patch,
      }),
      transformResponse: (res: any): OrderDetailResponse => ({
        order: (res?.order ?? null) as any,
        items: Array.isArray(res?.items) ? res.items : [],
      }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'Orders' as const, id: arg.id },
        { type: 'Orders' as const, id: 'MY_LIST' },
      ],
    }),
  }),
  overrideExisting: true,
});

export const {
  useCreateOrderMutation,
  useListMyOrdersQuery,
  useGetOrderDetailQuery,
  usePatchMyOrderMutation,
} = ordersPublicApi;
