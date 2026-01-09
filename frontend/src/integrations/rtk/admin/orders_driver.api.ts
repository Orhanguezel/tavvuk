// src/integrations/rtk/admin/orders_driver.api.ts
// =============================================================
// Tavvuk – Orders DRIVER RTK
// Base prefix: /api
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  ListOrdersQuery,
  OrderView,
  DriverDeliverBody,
  OrderDetailResponse,
} from '@/integrations/types/orders.types';

// ✅ Driver self endpoints 
const DRIVER_ORDERS_BASE = '/admin/driver/orders';

export const ordersDriverApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** GET /driver/orders -> Order[] (self assigned) */
    listDriverOrders: b.query<OrderView[], ListOrdersQuery | void>({
      query: (params) => ({
        url: DRIVER_ORDERS_BASE,
        method: 'GET',
        params: params ?? undefined,
      }),
      transformResponse: (res: any): OrderView[] => (Array.isArray(res) ? (res as any) : []),
      providesTags: (result) =>
        result?.length
          ? [
              ...result.map((o) => ({ type: 'DriverOrders' as const, id: o.id })),
              { type: 'DriverOrders' as const, id: 'LIST' },
            ]
          : [{ type: 'DriverOrders' as const, id: 'LIST' }],
    }),

    /** POST /driver/orders/:id/deliver -> { order, items } */
    deliverOrder: b.mutation<OrderDetailResponse, { id: string; body: DriverDeliverBody }>({
      query: ({ id, body }) => ({
        url: `${DRIVER_ORDERS_BASE}/${encodeURIComponent(id)}/deliver`,
        method: 'POST',
        body,
      }),
      transformResponse: (res: any): OrderDetailResponse => ({
        order: (res?.order ?? null) as any,
        items: Array.isArray(res?.items) ? res.items : [],
      }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'DriverOrders' as const, id: arg.id },
        { type: 'DriverOrders' as const, id: 'LIST' },

        // cross module caches (varsa kalsın)
        { type: 'Orders' as const, id: arg.id },
        { type: 'Orders' as const, id: 'MY_LIST' },
        { type: 'AdminOrders' as const, id: 'LIST' },
      ],
    }),

    /** GET /admin/driver/:driverId/orders (admin) -> Order[] */
    adminListOrdersForDriver: b.query<OrderView[], { driverId: string; params?: ListOrdersQuery }>({
      query: ({ driverId, params }) => ({
        url: `/admin/driver/${encodeURIComponent(driverId)}/orders`,
        method: 'GET',
        params: params ?? undefined,
      }),
      transformResponse: (res: any): OrderView[] => (Array.isArray(res) ? (res as any) : []),
      providesTags: (result, _e, arg) =>
        result?.length
          ? [
              ...result.map((o) => ({ type: 'DriverOrders' as const, id: o.id })),
              { type: 'DriverOrders' as const, id: `DRIVER:${arg.driverId}` },
            ]
          : [{ type: 'DriverOrders' as const, id: `DRIVER:${arg.driverId}` }],
    }),
  }),
  overrideExisting: true,
});

export const {
  useListDriverOrdersQuery,
  useDeliverOrderMutation,
  useAdminListOrdersForDriverQuery,
} = ordersDriverApi;
