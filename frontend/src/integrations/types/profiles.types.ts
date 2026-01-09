/**
 * Backend: src/modules/profiles/schema.ts + controller.ts
 * - GET /profiles/:id -> ProfileRow
 * - GET /profiles/me  -> ProfileRow | null
 * - PUT /profiles/me  -> { profile: ProfileUpsertInput } -> ProfileRow | null
 */

export type ProfileRow = {
  id: string;

  full_name?: string | null;
  phone?: string | null;
  avatar_url?: string | null;

  address_line1?: string | null;
  address_line2?: string | null;
  city?: string | null;
  country?: string | null;
  postal_code?: string | null;

  website_url?: string | null;
  instagram_url?: string | null;
  facebook_url?: string | null;
  x_url?: string | null;
  linkedin_url?: string | null;
  youtube_url?: string | null;
  tiktok_url?: string | null;

  created_at?: string | Date | null;
  updated_at?: string | Date | null;

  // backend DTO'da ekstra alanlar gelse bile kırılmasın
  [k: string]: unknown;
};

export type ProfileUpsertInput = {
  full_name?: string;
  phone?: string;
  avatar_url?: string;

  address_line1?: string;
  address_line2?: string;
  city?: string;
  country?: string;
  postal_code?: string;

  website_url?: string;
  instagram_url?: string;
  facebook_url?: string;
  x_url?: string;
  linkedin_url?: string;
  youtube_url?: string;
  tiktok_url?: string;
};

export type ProfileUpsertRequest = { profile: ProfileUpsertInput };
export type ProfilePublicGetParams = { id: string };

/* ----------------------------- normalizers ----------------------------- */

function toIso(v: unknown): string | null {
  if (!v) return null;
  if (v instanceof Date) return v.toISOString();
  const s = String(v).trim();
  return s.length ? s : null;
}

function toStrOrNull(v: unknown): string | null {
  if (v == null) return null;
  const s = String(v).trim();
  return s.length ? s : null;
}

export function normalizeProfileRow(raw: ProfileRow): ProfileRow {
  return {
    ...raw,
    id: String(raw?.id ?? ''),

    full_name: toStrOrNull(raw?.full_name),
    phone: toStrOrNull(raw?.phone),
    avatar_url: toStrOrNull(raw?.avatar_url),

    address_line1: toStrOrNull(raw?.address_line1),
    address_line2: toStrOrNull(raw?.address_line2),
    city: toStrOrNull(raw?.city),
    country: toStrOrNull(raw?.country),
    postal_code: toStrOrNull(raw?.postal_code),

    website_url: toStrOrNull(raw?.website_url),
    instagram_url: toStrOrNull(raw?.instagram_url),
    facebook_url: toStrOrNull(raw?.facebook_url),
    x_url: toStrOrNull(raw?.x_url),
    linkedin_url: toStrOrNull(raw?.linkedin_url),
    youtube_url: toStrOrNull(raw?.youtube_url),
    tiktok_url: toStrOrNull(raw?.tiktok_url),

    created_at: toIso(raw?.created_at),
    updated_at: toIso(raw?.updated_at),
  };
}
