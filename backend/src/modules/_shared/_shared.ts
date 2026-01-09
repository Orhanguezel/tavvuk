// =============================================================
// FILE: src/modules/auth/_shared.ts
// FINAL — Shared helpers for auth module
// =============================================================
import type { users } from '@/modules/auth/schema';

type UserRow = typeof users.$inferSelect;

export const toBool01 = (v: unknown): boolean => (typeof v === 'boolean' ? v : Number(v) === 1);


// =============================================================
export function pickUserDto(u: any, roles: string[] = []) {
  return {
    id: u.id,
    email: u.email ?? null,
    full_name: u.full_name ?? null,
    phone: u.phone ?? null,
    email_verified: u.email_verified ?? 0,
    is_active: u.is_active ?? 1,
    last_sign_in_at: u.last_sign_in_at ?? null,
    roles,
    is_admin: roles.includes('admin'),
    // profil alanları gerekiyorsa ekleyebilirsin
    profile_image: u.profile_image ?? null,
    profile_image_asset_id: u.profile_image_asset_id ?? null,
    profile_image_alt: u.profile_image_alt ?? null,
  };
}

