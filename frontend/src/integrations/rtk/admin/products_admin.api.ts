// src/integrations/rtk/products_admin.api.ts
// Tavvuk – Admin Products API (RTK Query)

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  ProductRaw,
  ProductView,
  ProductListParams,
  AdminProductCreateBody,
  AdminProductUpdateBody,
  AdminProductSetImagesBody,
  AdminProductDeleteParams,
} from '@/integrations/types';
import { normalizeProduct } from '@/integrations/types';

const ADMIN_PRODUCTS_BASE = '/admin/products';

export const productsAdminApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** GET /admin/products */
    adminProductsList: b.query<ProductView[], ProductListParams | void>({
      query: (params) => {
        const p = (params ?? {}) as ProductListParams;
        const sp = new URLSearchParams();

        if (p.q) sp.set('q', p.q);
        if (p.species) sp.set('species', p.species);
        if (p.breed) sp.set('breed', p.breed);
        if (p.tag) sp.set('tag', p.tag);

        if (p.is_active != null) sp.set('is_active', String(p.is_active));
        if (p.is_featured != null) sp.set('is_featured', String(p.is_featured));

        if (p.sort) sp.set('sort', p.sort);
        if (p.order) sp.set('order', p.order);

        if (p.limit != null) sp.set('limit', String(p.limit));
        if (p.offset != null) sp.set('offset', String(p.offset));

        const qs = sp.toString();
        return { url: qs ? `${ADMIN_PRODUCTS_BASE}?${qs}` : ADMIN_PRODUCTS_BASE, method: 'GET' };
      },
      transformResponse: (res: unknown): ProductView[] => {
        if (!Array.isArray(res)) return [];
        return (res as ProductRaw[]).map(normalizeProduct);
      },
      providesTags: (result) =>
        result && result.length
          ? [
              ...result.map((p) => ({ type: 'AdminProducts' as const, id: p.id })),
              { type: 'AdminProducts' as const, id: 'LIST' },
            ]
          : [{ type: 'AdminProducts' as const, id: 'LIST' }],
    }),

    /** GET /admin/products/:id */
    adminProductGet: b.query<ProductView, { id: string }>({
      query: ({ id }) => ({
        url: `${ADMIN_PRODUCTS_BASE}/${encodeURIComponent(id)}`,
        method: 'GET',
      }),
      transformResponse: (res: unknown): ProductView => normalizeProduct(res as ProductRaw),
      providesTags: (_r, _e, arg) => [{ type: 'AdminProducts' as const, id: arg.id }],
    }),

    /** POST /admin/products */
    adminProductCreate: b.mutation<ProductView, AdminProductCreateBody>({
      query: (body) => ({
        url: ADMIN_PRODUCTS_BASE,
        method: 'POST',
        body,
      }),
      transformResponse: (res: unknown): ProductView => normalizeProduct(res as ProductRaw),
      invalidatesTags: () => [{ type: 'AdminProducts' as const, id: 'LIST' }],
    }),

    /** PATCH /admin/products/:id */
    adminProductUpdate: b.mutation<ProductView, AdminProductUpdateBody>({
      query: ({ id, ...patch }) => ({
        url: `${ADMIN_PRODUCTS_BASE}/${encodeURIComponent(id)}`,
        method: 'PATCH',
        body: patch,
      }),
      transformResponse: (res: unknown): ProductView => normalizeProduct(res as ProductRaw),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminProducts' as const, id: arg.id },
        { type: 'AdminProducts' as const, id: 'LIST' },
        // public list de etkilenebilir
        { type: 'Products' as const, id: 'LIST' },
      ],
    }),

    /** POST /admin/products/:id/images */
    adminProductSetImages: b.mutation<ProductView, AdminProductSetImagesBody>({
      query: ({ id, ...body }) => ({
        url: `${ADMIN_PRODUCTS_BASE}/${encodeURIComponent(id)}/images`,
        method: 'POST',
        body,
      }),
      transformResponse: (res: unknown): ProductView => normalizeProduct(res as ProductRaw),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminProducts' as const, id: arg.id },
        { type: 'AdminProducts' as const, id: 'LIST' },
        { type: 'Products' as const, id: 'LIST' },
      ],
    }),

    /** DELETE /admin/products/:id (204) */
    adminProductDelete: b.mutation<{ ok: true }, AdminProductDeleteParams>({
      query: ({ id }) => ({
        url: `${ADMIN_PRODUCTS_BASE}/${encodeURIComponent(id)}`,
        method: 'DELETE',
      }),
      transformResponse: () => ({ ok: true as const }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminProducts' as const, id: arg.id },
        { type: 'AdminProducts' as const, id: 'LIST' },
        { type: 'Products' as const, id: 'LIST' },
      ],
    }),
  }),
  overrideExisting: true,
});

export const {
  useAdminProductsListQuery,
  useAdminProductGetQuery,
  useAdminProductCreateMutation,
  useAdminProductUpdateMutation,
  useAdminProductSetImagesMutation,
  useAdminProductDeleteMutation,
} = productsAdminApi;
