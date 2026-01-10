// src/integrations/rtk/orders_admin.api.ts
// =============================================================
// Tavvuk – Orders ADMIN RTK
// Base prefix: /api/admin
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  AdminListOrdersQuery,
  OrderView,
  OrderDetailResponse,
  CreateOrderBody,
  AdminAssignDriverBody,
  AdminAssignDriverResponse,
  AdminCancelBody,
  OkResponse,
} from '@/integrations/types';

const ADMIN_ORDERS_BASE = '/admin/orders';

export const ordersAdminApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** GET /admin/orders -> Order[] */
    adminListOrders: b.query<OrderView[], AdminListOrdersQuery | void>({
      query: (params) => {
        const p = (params ?? {}) as AdminListOrdersQuery;
        const sp = new URLSearchParams();

        if (p.status) sp.set('status', p.status);
        if (p.city_id) sp.set('city_id', p.city_id);
        if (p.district_id) sp.set('district_id', p.district_id);

        if (p.q) sp.set('q', p.q);
        if (p.date_from) sp.set('date_from', p.date_from);
        if (p.date_to) sp.set('date_to', p.date_to);

        if (p.limit != null) sp.set('limit', String(p.limit));
        if (p.offset != null) sp.set('offset', String(p.offset));
        if (p.sort) sp.set('sort', p.sort);
        if (p.order) sp.set('order', p.order);

        const qs = sp.toString();
        return { url: qs ? `${ADMIN_ORDERS_BASE}?${qs}` : ADMIN_ORDERS_BASE, method: 'GET' };
      },
      transformResponse: (res: any): OrderView[] => (Array.isArray(res) ? (res as any) : []),
      providesTags: (result) =>
        result?.length
          ? [
              ...result.map((o) => ({ type: 'AdminOrders' as const, id: o.id })),
              { type: 'AdminOrders' as const, id: 'LIST' },
            ]
          : [{ type: 'AdminOrders' as const, id: 'LIST' }],
    }),

    /** GET /admin/orders/:id -> { order, items } */
    adminGetOrder: b.query<OrderDetailResponse, { id: string }>({
      query: ({ id }) => ({ url: `${ADMIN_ORDERS_BASE}/${encodeURIComponent(id)}`, method: 'GET' }),
      transformResponse: (res: any): OrderDetailResponse => ({
        order: (res?.order ?? null) as any,
        items: Array.isArray(res?.items) ? res.items : [],
      }),
      providesTags: (_r, _e, arg) => [{ type: 'AdminOrders' as const, id: arg.id }],
    }),

    /** POST /admin/orders/:id/approve -> { ok: true } */
    adminApproveOrder: b.mutation<OkResponse, { id: string }>({
      query: ({ id }) => ({
        url: `${ADMIN_ORDERS_BASE}/${encodeURIComponent(id)}/approve`,
        method: 'POST',
        body: {},
      }),
      transformResponse: (res: any): OkResponse => ({ ok: true as const }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminOrders' as const, id: arg.id },
        { type: 'AdminOrders' as const, id: 'LIST' },
        { type: 'Orders' as const, id: arg.id },
        { type: 'Orders' as const, id: 'MY_LIST' },
      ],
    }),

    /** POST /admin/orders/:id/assign-driver -> { ok:true, assignment } */
    adminAssignDriver: b.mutation<
      AdminAssignDriverResponse,
      { id: string; body: AdminAssignDriverBody }
    >({
      query: ({ id, body }) => ({
        url: `${ADMIN_ORDERS_BASE}/${encodeURIComponent(id)}/assign-driver`,
        method: 'POST',
        body,
      }),
      transformResponse: (res: any): AdminAssignDriverResponse => ({
        ok: true as const,
        assignment: res?.assignment ?? null,
      }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminOrders' as const, id: arg.id },
        { type: 'AdminOrders' as const, id: 'LIST' },
        { type: 'DriverOrders' as const, id: 'LIST' },
        { type: 'Orders' as const, id: arg.id },
        { type: 'Orders' as const, id: 'MY_LIST' },
      ],
    }),

    /** POST /admin/orders -> { order, items } */
    adminCreateOrder: b.mutation<OrderDetailResponse, CreateOrderBody>({
      query: (body) => ({
        url: `${ADMIN_ORDERS_BASE}`,
        method: 'POST',
        body,
      }),
      transformResponse: (res: any): OrderDetailResponse => ({
        order: (res?.order ?? res?.data?.order ?? null) as any,
        items: Array.isArray(res?.items) ? res.items : [],
      }),
      invalidatesTags: () => [
        { type: 'AdminOrders' as const, id: 'LIST' },
        { type: 'Orders' as const, id: 'MY_LIST' },
      ],
    }),

    /** POST /admin/orders/:id/cancel -> { ok: true } */
    adminCancelOrder: b.mutation<OkResponse, { id: string; body: AdminCancelBody }>({
      query: ({ id, body }) => ({
        url: `${ADMIN_ORDERS_BASE}/${encodeURIComponent(id)}/cancel`,
        method: 'POST',
        body,
      }),
      transformResponse: (_res: any): OkResponse => ({ ok: true as const }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminOrders' as const, id: arg.id },
        { type: 'AdminOrders' as const, id: 'LIST' },
        { type: 'DriverOrders' as const, id: 'LIST' },
        { type: 'Orders' as const, id: arg.id },
        { type: 'Orders' as const, id: 'MY_LIST' },
      ],
    }),
  }),
  overrideExisting: true,
});

export const {
  useAdminListOrdersQuery,
  useAdminGetOrderQuery,
  useAdminApproveOrderMutation,
  useAdminCreateOrderMutation,
  useAdminAssignDriverMutation,
  useAdminCancelOrderMutation,
} = ordersAdminApi;
