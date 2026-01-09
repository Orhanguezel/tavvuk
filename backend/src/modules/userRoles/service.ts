// =============================================================
// FILE: src/modules/userRoles/service.ts
// FINAL — Tavvuk roles helpers
// =============================================================
import { db } from '@/db/client';
import { userRoles, type UserRoleName } from './schema';
import { eq } from 'drizzle-orm';

export type Role = UserRoleName;

const ROLE_WEIGHT: Record<Role, number> = {
  admin: 3,
  seller: 2,
  driver: 1,
};

export function normalizeRoles(input: (string | null | undefined)[]): Role[] {
  const set = new Set<Role>();
  for (const v of input) {
    const r = String(v ?? '').trim();
    if (r === 'admin' || r === 'seller' || r === 'driver') set.add(r);
  }
  return Array.from(set);
}

/** Kullanıcının tüm rollerini döndürür (uniq). */
export async function getUserRoles(userId: string): Promise<Role[]> {
  const rows = await db
    .select({ role: userRoles.role })
    .from(userRoles)
    .where(eq(userRoles.user_id, userId));

  return normalizeRoles(rows.map((x) => x.role as unknown as string));
}

/** Kullanıcının “primary” rolünü döndürür. Rol yoksa seller fallback. */
export async function getPrimaryRole(userId: string): Promise<Role> {
  const roles = await getUserRoles(userId);
  if (!roles.length) return 'seller';

  let best: Role = 'seller';
  let bestWeight = ROLE_WEIGHT[best];

  for (const r of roles) {
    const w = ROLE_WEIGHT[r] ?? 0;
    if (w > bestWeight) {
      best = r;
      bestWeight = w;
    }
  }
  return best;
}

/** Guard helper: admin mi? */
export async function isAdmin(userId: string): Promise<boolean> {
  const roles = await getUserRoles(userId);
  return roles.includes('admin');
}
