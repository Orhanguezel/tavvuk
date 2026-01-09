// =============================================================
// FILE: src/common/middleware/roles.ts
// FINAL — requireAdmin (JWT fast-path + DB truth)
// =============================================================
import type { FastifyRequest, FastifyReply } from 'fastify';
import type { JwtUser } from './auth';
import { isAdmin as isAdminDb } from '@/modules/userRoles/service';

function looksAdminFromJwt(u: JwtUser | undefined): boolean {
  if (!u) return false;
  if (u.is_admin === true) return true;
  if (u.role === 'admin') return true;
  if (Array.isArray(u.roles) && u.roles.includes('admin')) return true;
  return false;
}

/** Yalnızca admin erişimine izin verir (JWT hızlı yol + DB kesin doğrulama). */
export async function requireAdmin(req: FastifyRequest, reply: FastifyReply) {
  const u = (req as unknown as { user?: JwtUser }).user;

  // 1) JWT fast-path
  if (looksAdminFromJwt(u)) return;

  // 2) DB truth (admin role sonradan verildiyse anında etkiler)
  const userId = String(u?.sub ?? '').trim();
  if (!userId) {
    return reply.code(401).send({ error: { message: 'no_token' } });
  }

  const ok = await isAdminDb(userId);
  if (!ok) {
    return reply.code(403).send({ error: { message: 'forbidden' } });
  }
}
