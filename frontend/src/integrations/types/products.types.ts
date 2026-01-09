// src/integrations/types/products.types.ts
// Tavvuk – Products Types (Public + Admin)
// Backend: src/modules/products/schema.ts + validation.ts

import type { SortOrder, BoolLike } from '@/integrations/types/common'; // sende varsa
// Eğer projende SortOrder/BoolLike farklı dosyadaysa import'u ona göre ayarla.

export type PoultrySpecies = 'chicken' | 'duck' | 'goose' | 'turkey' | 'quail' | 'other';

export type ProductSort = 'created_at' | 'updated_at' | 'title' | 'price' | 'stock_quantity';

export type ProductListParams = {
  q?: string;

  species?: PoultrySpecies;
  breed?: string;
  tag?: string;

  is_active?: BoolLike;
  is_featured?: BoolLike;

  sort?: ProductSort;
  order?: SortOrder;

  limit?: number;
  offset?: number;
};

/** Admin create */
export type AdminProductCreateBody = {
  title: string;
  slug?: string;

  species?: PoultrySpecies;
  breed?: string | null;
  summary?: string | null;
  description?: string | null;

  price?: number | string;

  image_url?: string | null;
  storage_asset_id?: string | null;
  alt?: string | null;
  images?: string[];
  storage_image_ids?: string[];

  stock_quantity?: number;

  is_active?: BoolLike;
  is_featured?: BoolLike;

  tags?: string[];
};

/** Admin patch */
export type AdminProductUpdateBody = {
  id: string;

  title?: string;
  slug?: string;

  species?: PoultrySpecies;
  breed?: string | null;
  summary?: string | null;
  description?: string | null;

  price?: number | string;

  image_url?: string | null;
  storage_asset_id?: string | null;
  alt?: string | null;
  images?: string[];
  storage_image_ids?: string[];

  stock_quantity?: number;

  is_active?: BoolLike;
  is_featured?: BoolLike;

  tags?: string[];
};

export type AdminProductSetImagesBody = {
  id: string;

  image_url?: string | null;
  storage_asset_id?: string | null;
  alt?: string | null;
  images?: string[];
  storage_image_ids?: string[];
};

export type AdminProductDeleteParams = { id: string };

/** ---------------- RAW (backend) ----------------
 * drizzle row:
 * - price: decimal => genelde string gelir
 * - tinyint => bazen 0/1 gelir
 */
export type ProductRaw = {
  id: string;

  title: string;
  slug: string;

  species: PoultrySpecies;
  breed?: string | null;

  summary?: string | null;
  description?: string | null;

  price?: string | number | null;

  image_url?: string | null;
  storage_asset_id?: string | null;
  alt?: string | null;

  images?: unknown; // json array
  storage_image_ids?: unknown; // json array
  tags?: unknown; // json array

  stock_quantity?: number | string | null;

  is_active?: any; // 0/1/true/false
  is_featured?: any;

  created_at?: string | Date | null;
  updated_at?: string | Date | null;

  [k: string]: unknown;
};

/** ---------------- VIEW (frontend) ---------------- */
export type ProductView = {
  id: string;

  title: string;
  slug: string;

  species: PoultrySpecies;
  breed: string | null;

  summary: string | null;
  description: string | null;

  price: number; // normalize

  image_url: string | null;
  storage_asset_id: string | null;
  alt: string | null;

  images: string[];
  storage_image_ids: string[];
  tags: string[];

  stock_quantity: number;

  is_active: boolean;
  is_featured: boolean;

  created_at: string | null;
  updated_at: string | null;
};

/* ----------------------------- helpers ----------------------------- */

function toIso(v: unknown): string | null {
  if (!v) return null;
  if (v instanceof Date) return v.toISOString();
  const s = String(v).trim();
  return s.length ? s : null;
}

function toNumber(v: unknown, fb = 0): number {
  if (typeof v === 'number' && Number.isFinite(v)) return v;
  const n = Number(String(v ?? '').trim());
  return Number.isFinite(n) ? n : fb;
}

function toBool(v: unknown): boolean {
  // boolLike + drizzle tinyint uyumu
  if (v === true || v === 1 || v === '1' || v === 'true') return true;
  if (v === false || v === 0 || v === '0' || v === 'false') return false;
  // drizzle bazen "1"/"0" veya number gibi
  return Boolean(v);
}

function toStringArray(v: unknown): string[] {
  if (Array.isArray(v)) return v.map((x) => String(x ?? '').trim()).filter(Boolean);
  // bazı durumlarda json string gelebilir
  if (typeof v === 'string') {
    const s = v.trim();
    if (!s) return [];
    try {
      const parsed = JSON.parse(s);
      if (Array.isArray(parsed)) return parsed.map((x) => String(x ?? '').trim()).filter(Boolean);
    } catch {
      // fallback
      return [];
    }
  }
  return [];
}

/* ----------------------------- normalizer ----------------------------- */

export function normalizeProduct(raw: ProductRaw): ProductView {
  return {
    id: String(raw?.id ?? ''),
    title: String(raw?.title ?? ''),
    slug: String(raw?.slug ?? ''),

    species: (raw?.species as PoultrySpecies) ?? 'chicken',
    breed: raw?.breed != null ? String(raw.breed) : null,

    summary: raw?.summary != null ? String(raw.summary) : null,
    description: raw?.description != null ? String(raw.description) : null,

    price: toNumber(raw?.price, 0),

    image_url: raw?.image_url != null ? String(raw.image_url) : null,
    storage_asset_id: raw?.storage_asset_id != null ? String(raw.storage_asset_id) : null,
    alt: raw?.alt != null ? String(raw.alt) : null,

    images: toStringArray(raw?.images),
    storage_image_ids: toStringArray(raw?.storage_image_ids),
    tags: toStringArray(raw?.tags),

    stock_quantity: toNumber(raw?.stock_quantity, 0),

    is_active: toBool(raw?.is_active),
    is_featured: toBool(raw?.is_featured),

    created_at: toIso(raw?.created_at),
    updated_at: toIso(raw?.updated_at),
  };
}
