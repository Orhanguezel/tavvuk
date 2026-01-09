import type { Role } from '@/integrations/types';

export type UserRolesListParams = {
  user_id?: string; // uuid
  role?: Role;

  order?: 'created_at';
  direction?: 'asc' | 'desc';

  limit?: number;
  offset?: number;
};

export type UserRoleRowRaw = {
  id: string;
  user_id: string;
  role: Role | string;

  created_at?: string | Date | null;

  [k: string]: unknown;
};

export type UserRoleRowView = {
  id: string;
  user_id: string;
  role: Role;
  created_at: string | null;
};

export type CreateUserRoleBody = {
  user_id: string;
  role: Role;
};

export type DeleteUserRoleBody = { id: string };

function toIso(v: unknown): string | null {
  if (!v) return null;
  if (v instanceof Date) return v.toISOString();
  const s = String(v).trim();
  return s ? s : null;
}

function normalizeRole(v: unknown): Role {
  const s = String(v ?? '').trim();
  if (s === 'admin' || s === 'seller' || s === 'driver') return s;
  return 'seller';
}

export function normalizeUserRoleRow(raw: UserRoleRowRaw): UserRoleRowView {
  return {
    id: String(raw?.id ?? ''),
    user_id: String(raw?.user_id ?? ''),
    role: normalizeRole(raw?.role),
    created_at: toIso(raw?.created_at),
  };
}
