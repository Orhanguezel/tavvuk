import type { BoolLike, Role } from '@/integrations/types';

export type AdminUsersListParams = {
  q?: string;
  role?: Role;
  is_active?: boolean;
  limit?: number;
  offset?: number;
  sort?: 'created_at' | 'email' | 'last_login_at';
  order?: 'asc' | 'desc';
};

export type AdminUserRaw = {
  id: string;
  email?: string | null;
  full_name?: string | null;
  phone?: string | null;

  is_active?: number | boolean | null;
  email_verified?: number | boolean | null;

  profile_image?: string | null;
  profile_image_asset_id?: string | null;
  profile_image_alt?: string | null;

  created_at?: string | Date | null;
  updated_at?: string | Date | null;
  last_sign_in_at?: string | Date | null;

  roles?: Role[] | null;

  [k: string]: unknown;
};

export type AdminUserView = {
  id: string;
  email: string;
  full_name: string | null;
  phone: string | null;

  is_active: boolean;
  email_verified: boolean;

  profile_image: string | null;
  profile_image_asset_id: string | null;
  profile_image_alt: string | null;

  created_at: string | null;
  updated_at: string | null;
  last_sign_in_at: string | null;

  roles: Role[];
  is_admin: boolean;
};

function toBool(v: unknown, fb = false): boolean {
  if (typeof v === 'boolean') return v;
  if (typeof v === 'number') return v === 1;
  const s = String(v ?? '')
    .trim()
    .toLowerCase();
  if (s === '1' || s === 'true') return true;
  if (s === '0' || s === 'false') return false;
  return fb;
}

function toIso(v: unknown): string | null {
  if (!v) return null;
  if (v instanceof Date) return v.toISOString();
  const s = String(v).trim();
  return s ? s : null;
}

export function normalizeAdminUser(raw: AdminUserRaw): AdminUserView {
  const roles = Array.isArray(raw?.roles) ? (raw.roles.filter(Boolean) as Role[]) : [];

  return {
    id: String(raw.id),
    email: String(raw.email ?? '').trim(),
    full_name: raw.full_name != null ? String(raw.full_name) : null,
    phone: raw.phone != null ? String(raw.phone) : null,

    is_active: toBool(raw.is_active, true),
    email_verified: toBool(raw.email_verified, false),

    profile_image: raw.profile_image != null ? String(raw.profile_image) : null,
    profile_image_asset_id:
      raw.profile_image_asset_id != null ? String(raw.profile_image_asset_id) : null,
    profile_image_alt: raw.profile_image_alt != null ? String(raw.profile_image_alt) : null,

    created_at: toIso(raw.created_at),
    updated_at: toIso(raw.updated_at),
    last_sign_in_at: toIso(raw.last_sign_in_at),

    roles,
    is_admin: roles.includes('admin'),
  };
}

export type AdminUpdateUserBody = {
  id: string;
  full_name?: string;
  phone?: string;
  email?: string;
  is_active?: BoolLike;
  profile_image?: string;
  profile_image_asset_id?: string;
  profile_image_alt?: string;
};

export type AdminSetActiveBody = { id: string; is_active: BoolLike };
export type AdminSetRolesBody = { id: string; roles: Role[] };
export type AdminSetPasswordBody = { id: string; password: string };
export type AdminRemoveUserBody = { id: string };
