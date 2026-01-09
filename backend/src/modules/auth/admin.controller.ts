// =============================================================
// FILE: src/modules/auth/admin.controller.ts
// FINAL — Tavvuk Admin Users Controller (roles[])
// - DB-level role filter (no JS filter)
// - No N+1 roles lookup: roles are fetched in one query
// - tx-safe last admin guards
// =============================================================
import type { FastifyInstance, FastifyReply, FastifyRequest } from 'fastify';
import { randomUUID } from 'crypto';

import { db } from '@/db/client';
import { users, refresh_tokens } from '@/modules/auth/schema';
import { userRoles } from '@/modules/userRoles/schema';
import { profiles } from '@/modules/profiles/schema';

import { and, asc, desc, eq, like, sql, inArray } from 'drizzle-orm';
import { hash as argonHash } from 'argon2';

import { notifications, type NotificationInsert } from '@/modules/notifications/schema';
import { sendPasswordChangedMail } from '@/modules/mail/service';

import {
  adminUsersListQuery,
  adminUserUpdateBody,
  adminUserSetActiveBody,
  adminUserSetRolesBody,
  adminUserSetPasswordBody,
} from '@/modules/auth/validation';

import { pickUserDto, toBool01 } from '@/modules/_shared/_shared';

type Role = 'admin' | 'seller' | 'driver';
type UserRow = typeof users.$inferSelect;

/* -------------------------------- role helpers -------------------------------- */

function isRole(v: unknown): v is Role {
  return v === 'admin' || v === 'seller' || v === 'driver';
}

function normalizeRoles(
  input: readonly (Role | string | null | undefined)[] | undefined | null,
): Role[] {
  const set = new Set<Role>();
  for (const v of input ?? []) {
    if (isRole(v)) {
      set.add(v);
      continue;
    }
    const s = String(v ?? '').trim();
    if (isRole(s)) set.add(s);
  }
  return Array.from(set);
}

/** Tx-safe roles fetch (db or transaction). */
async function getUserRolesTx(executor: any, userId: string): Promise<Role[]> {
  const rows = await executor
    .select({ role: userRoles.role })
    .from(userRoles)
    .where(eq(userRoles.user_id, userId));

  return normalizeRoles(rows.map((x: any) => x.role));
}

/** Count admins using db-like executor (db or tx) */
async function countAdmins(executor: any): Promise<number> {
  const rows = await executor
    .select({ c: sql<number>`count(*)`.as('c') })
    .from(userRoles)
    .where(eq(userRoles.role, 'admin'));
  return Number(rows?.[0]?.c ?? 0);
}

async function attachRolesToUsers(baseUsers: any[]) {
  const ids = baseUsers.map((u) => u.id);
  if (ids.length === 0) return [];

  const roleRows = await db
    .select({ user_id: userRoles.user_id, role: userRoles.role })
    .from(userRoles)
    .where(inArray(userRoles.user_id, ids));

  const rolesMap = new Map<string, Role[]>();
  for (const r of roleRows as any[]) {
    const arr = rolesMap.get(r.user_id) ?? [];
    const rr = normalizeRoles([r.role]);
    if (rr[0]) arr.push(rr[0]);
    rolesMap.set(r.user_id, normalizeRoles(arr));
  }

  return baseUsers.map((u) => ({
    ...u,
    roles: rolesMap.get(u.id) ?? [],
  }));
}

export function makeAdminController(_app: FastifyInstance) {
  return {
    /** GET /admin/users */
    list: async (req: FastifyRequest, reply: FastifyReply) => {
      const q = adminUsersListQuery.parse(req.query ?? {});

      const conds: any[] = [];

      // q search: email + full_name + phone
      if (q.q) {
        const term = `%${String(q.q).trim()}%`;
        conds.push(
          sql`(${users.email} LIKE ${term} OR ${users.full_name} LIKE ${term} OR ${users.phone} LIKE ${term})`,
        );
      }

      if (typeof q.is_active === 'boolean') {
        conds.push(eq(users.is_active, q.is_active ? 1 : 0));
      }

      // ✅ DB-level role filter
      const roleFilter: Role | null = isRole(q.role) ? q.role : null;
      if (roleFilter) {
        conds.push(
          sql`EXISTS (
            SELECT 1
            FROM ${userRoles}
            WHERE ${userRoles.user_id} = ${users.id}
              AND ${userRoles.role} = ${roleFilter}
          )`,
        );
      }

      const where = conds.length === 0 ? undefined : conds.length === 1 ? conds[0] : and(...conds);

      const sortCol =
        q.sort === 'email'
          ? users.email
          : q.sort === 'last_login_at'
          ? users.last_sign_in_at
          : users.created_at;

      const orderFn = q.order === 'asc' ? asc : desc;

      const base = await db
        .select()
        .from(users)
        .where(where)
        .orderBy(orderFn(sortCol))
        .limit(q.limit)
        .offset(q.offset);

      const withRoles = await attachRolesToUsers(base);
      return reply.send(withRoles.map((u) => pickUserDto(u as any, (u as any).roles)));
    },

    /** GET /admin/users/:id */
    get: async (req: FastifyRequest, reply: FastifyReply) => {
      const id = String((req.params as Record<string, string>).id);

      const u = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0];
      if (!u) return reply.status(404).send({ error: { message: 'not_found' } });

      const withRoles = (await attachRolesToUsers([u]))[0] ?? { ...u, roles: [] as Role[] };
      return reply.send(pickUserDto(withRoles as any, (withRoles as any).roles));
    },

    /** PATCH /admin/users/:id */
    update: async (req: FastifyRequest, reply: FastifyReply) => {
      const id = String((req.params as Record<string, string>).id);
      const body = adminUserUpdateBody.parse(req.body ?? {});

      const existing = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0];
      if (!existing) return reply.status(404).send({ error: { message: 'not_found' } });

      const patch: Partial<UserRow> = {
        ...(body.full_name !== undefined ? { full_name: body.full_name } : {}),
        ...(body.phone !== undefined ? { phone: body.phone } : {}),
        ...(body.email !== undefined ? { email: body.email } : {}),
        ...(body.is_active != null ? { is_active: toBool01(body.is_active) ? 1 : 0 } : {}),

        ...('profile_image' in body ? { profile_image: body.profile_image ?? null } : {}),
        ...('profile_image_asset_id' in body
          ? { profile_image_asset_id: body.profile_image_asset_id ?? null }
          : {}),
        ...('profile_image_alt' in body
          ? { profile_image_alt: body.profile_image_alt ?? null }
          : {}),

        updated_at: new Date(),
      } as any;

      await db
        .update(users)
        .set(patch as any)
        .where(eq(users.id, id));

      const updated = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0];
      if (!updated) return reply.status(404).send({ error: { message: 'not_found' } });

      const withRoles = (await attachRolesToUsers([updated]))[0] ?? { ...updated, roles: [] };
      return reply.send(pickUserDto(withRoles as any, (withRoles as any).roles));
    },

    /** POST /admin/users/:id/active */
    setActive: async (req: FastifyRequest, reply: FastifyReply) => {
      const id = String((req.params as Record<string, string>).id);
      const { is_active } = adminUserSetActiveBody.parse(req.body ?? {});

      const u = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0];
      if (!u) return reply.status(404).send({ error: { message: 'not_found' } });

      const active = toBool01(is_active);

      await db
        .update(users)
        .set({
          is_active: active ? 1 : 0,
          ...(active ? { email_verified: 1 } : {}),
          updated_at: new Date(),
        })
        .where(eq(users.id, id));

      return reply.send({ ok: true });
    },

    /** POST /admin/users/:id/roles (tam set) */
    setRoles: async (req: FastifyRequest, reply: FastifyReply) => {
      const id = String((req.params as Record<string, string>).id);
      const { roles } = adminUserSetRolesBody.parse(req.body ?? {});

      const u = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0];
      if (!u) return reply.status(404).send({ error: { message: 'not_found' } });

      const nextRoles = normalizeRoles(roles);

      try {
        await db.transaction(async (tx: any) => {
          const currentRoles = await getUserRolesTx(tx, id);

          // last-admin protection (admin'i kaldırma)
          const removingAdmin = currentRoles.includes('admin') && !nextRoles.includes('admin');
          if (removingAdmin) {
            const admins = await countAdmins(tx);
            if (admins <= 1) {
              throw Object.assign(new Error('cannot_remove_last_admin'), { code: 'LAST_ADMIN' });
            }
          }

          await tx.delete(userRoles).where(eq(userRoles.user_id, id));

          if (nextRoles.length > 0) {
            await tx.insert(userRoles).values(
              nextRoles.map((r) => ({
                id: randomUUID(),
                user_id: id,
                role: r,
              })),
            );
          }
        });
      } catch (err: any) {
        if (err?.code === 'LAST_ADMIN') {
          return reply.status(409).send({ error: { message: 'cannot_remove_last_admin' } });
        }
        throw err;
      }

      return reply.send({ ok: true });
    },

    /** POST /admin/users/:id/password */
    setPassword: async (req: FastifyRequest, reply: FastifyReply) => {
      const id = String((req.params as Record<string, string>).id);
      const { password } = adminUserSetPasswordBody.parse(req.body ?? {});

      const u = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0];
      if (!u) return reply.status(404).send({ error: { message: 'not_found' } });

      const password_hash = await argonHash(password);

      await db
        .update(users)
        .set({
          password_hash,
          is_active: 1,
          email_verified: 1,
          updated_at: new Date(),
        })
        .where(eq(users.id, id));

      // revoke refresh tokens
      await db
        .update(refresh_tokens)
        .set({ revoked_at: new Date() })
        .where(eq(refresh_tokens.user_id, id));

      // notification best effort
      try {
        const notif: NotificationInsert = {
          id: randomUUID(),
          user_id: id,
          title: 'Şifreniz güncellendi',
          message:
            'Hesap şifreniz yönetici tarafından güncellendi. Bu işlemi siz yapmadıysanız lütfen en kısa sürede bizimle iletişime geçin.',
          type: 'password_changed',
          is_read: 0,
          created_at: new Date(),
        };
        await db.insert(notifications).values(notif);
      } catch (err: unknown) {
        req.log?.error?.(err, 'admin_password_change_notification_failed');
      }

      const targetEmail = u.email;
      if (targetEmail) {
        const userName =
          (u.full_name && u.full_name.length > 0 ? u.full_name : targetEmail.split('@')[0]) ||
          'Kullanıcı';

        void sendPasswordChangedMail({
          to: targetEmail,
          user_name: userName,
          site_name: 'Tavvuk',
        }).catch((err: unknown) => req.log?.error?.(err, 'admin_password_change_mail_failed'));
      }

      return reply.send({ ok: true });
    },

    /** DELETE /admin/users/:id */
    remove: async (req: FastifyRequest, reply: FastifyReply) => {
      const id = String((req.params as Record<string, string>).id);

      const u = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0];
      if (!u) return reply.status(404).send({ error: { message: 'not_found' } });

      try {
        await db.transaction(async (tx: any) => {
          const roles = await getUserRolesTx(tx, id);

          // last-admin protection (admin user'ı silme)
          if (roles.includes('admin')) {
            const admins = await countAdmins(tx);
            if (admins <= 1) {
              throw Object.assign(new Error('cannot_delete_last_admin'), { code: 'LAST_ADMIN' });
            }
          }

          await tx.delete(refresh_tokens).where(eq(refresh_tokens.user_id, id));
          await tx.delete(userRoles).where(eq(userRoles.user_id, id));
          await tx.delete(profiles).where(eq(profiles.id, id));
          await tx.delete(users).where(eq(users.id, id));
        });
      } catch (err: any) {
        if (err?.code === 'LAST_ADMIN') {
          return reply.status(409).send({ error: { message: 'cannot_delete_last_admin' } });
        }
        throw err;
      }

      return reply.send({ ok: true });
    },
  };
}
