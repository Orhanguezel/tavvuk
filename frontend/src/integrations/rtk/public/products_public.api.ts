// src/integrations/rtk/products_public.api.ts
// Tavvuk – Public Products API (RTK Query)

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  ProductRaw,
  ProductView,
  ProductListParams,
} from '@/integrations/types/products.types';
import { normalizeProduct } from '@/integrations/types/products.types';

const PUBLIC_PRODUCTS_BASE = '/products';

export const productsPublicApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** GET /products */
    productsList: b.query<ProductView[], ProductListParams | void>({
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
        return { url: qs ? `${PUBLIC_PRODUCTS_BASE}?${qs}` : PUBLIC_PRODUCTS_BASE, method: 'GET' };
      },
      transformResponse: (res: unknown): ProductView[] => {
        if (!Array.isArray(res)) return [];
        return (res as ProductRaw[]).map(normalizeProduct);
      },
      providesTags: (result) =>
        result && result.length
          ? [
              ...result.map((p) => ({ type: 'Products' as const, id: p.id })),
              { type: 'Products' as const, id: 'LIST' },
            ]
          : [{ type: 'Products' as const, id: 'LIST' }],
    }),

    /** GET /products/by-slug/:slug */
    productBySlug: b.query<ProductView, { slug: string }>({
      query: ({ slug }) => ({
        url: `${PUBLIC_PRODUCTS_BASE}/by-slug/${encodeURIComponent(slug)}`,
        method: 'GET',
      }),
      transformResponse: (res: unknown): ProductView => normalizeProduct(res as ProductRaw),
      providesTags: (_r, _e, arg) => [{ type: 'Products' as const, id: `SLUG:${arg.slug}` }],
    }),
  }),
  overrideExisting: true,
});

export const { useProductsListQuery, useProductBySlugQuery } = productsPublicApi;
