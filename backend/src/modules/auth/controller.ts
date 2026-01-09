// =============================================================
// FILE: src/modules/auth/controller.ts
// FINAL — Tavvuk Auth Controller (clean)
// - Public endpoints: /auth/register /auth/login /auth/refresh
// - No legacy endpoints
// =============================================================
import type { FastifyInstance, FastifyRequest, FastifyReply } from 'fastify';
import '@fastify/cookie';
import '@fastify/jwt';

import { randomUUID, createHash } from 'crypto';
import { db } from '@/db/client';
import { users, refresh_tokens } from './schema';
import { userRoles } from '@/modules/userRoles/schema';
import { eq } from 'drizzle-orm';
import { hash as argonHash, verify as argonVerify } from 'argon2';
import bcrypt from 'bcryptjs';

import {
  registerBody,
  loginBody,
  updateBody,
  passwordResetRequestBody,
  passwordResetConfirmBody,
} from './validation';

import { env } from '@/core/env';
import { profiles } from '@/modules/profiles/schema';
import { sendWelcomeMail, sendPasswordChangedMail } from '@/modules/mail/service';
import { notifications, type NotificationInsert } from '@/modules/notifications/schema';

type Role = 'admin' | 'seller' | 'driver';

interface JWTPayload {
  sub: string;
  email?: string;
  roles?: Role[];
  purpose?: 'password_reset';
  iat?: number;
  exp?: number;
}

export interface JWTLike {
  sign: (p: JWTPayload, opts?: { expiresIn?: string | number }) => string;
  verify: (token: string) => JWTPayload;
}

type UserRow = typeof users.$inferSelect;

/* -------------------- helpers -------------------- */

export function getJWT(app: FastifyInstance): JWTLike {
  return (app as unknown as { jwt: JWTLike }).jwt;
}

export function bearerFrom(req: FastifyRequest): string | null {
  const auth = (req.headers.authorization ?? '') as string;
  if (auth.startsWith('Bearer ')) return auth.slice(7);
  const cookies = (req.cookies ?? {}) as Record<string, string | undefined>;
  const token = cookies.access_token ?? cookies.accessToken;
  return token && token.length > 10 ? token : null;
}

function allowSignup(): boolean {
  return String((env as any).AUTH_ALLOW_SIGNUP ?? '1') === '1';
}

function isRole(v: unknown): v is Role {
  return v === 'admin' || v === 'seller' || v === 'driver';
}

function normalizeRoles(input: readonly unknown[] | undefined | null): Role[] {
  const set = new Set<Role>();
  for (const v of input ?? []) {
    if (isRole(v)) set.add(v);
    else {
      const s = String(v ?? '').trim();
      if (isRole(s)) set.add(s);
    }
  }
  return Array.from(set);
}

/* -------------------- roles DB source of truth -------------------- */

async function getUserRolesDb(userId: string): Promise<Role[]> {
  const rows = await db
    .select({ role: userRoles.role })
    .from(userRoles)
    .where(eq(userRoles.user_id, userId));
  return normalizeRoles(rows.map((x) => x.role));
}

/* -------------------- Profiles -------------------- */

export async function ensureProfileRow(
  userId: string,
  defaults?: { full_name?: string | null; phone?: string | null },
): Promise<void> {
  const existing = await db
    .select({ id: profiles.id })
    .from(profiles)
    .where(eq(profiles.id, userId))
    .limit(1);

  if (existing.length === 0) {
    await db.insert(profiles).values({
      id: userId,
      full_name: defaults?.full_name ?? null,
      phone: defaults?.phone ?? null,
    });
    return;
  }

  if (defaults && (defaults.full_name || defaults.phone)) {
    await db
      .update(profiles)
      .set({
        ...(defaults.full_name ? { full_name: defaults.full_name } : {}),
        ...(defaults.phone ? { phone: defaults.phone } : {}),
        updated_at: new Date(),
      })
      .where(eq(profiles.id, userId));
  }
}

/* -------------------- JWT & Cookies -------------------- */

const ACCESS_MAX_AGE = 60 * 15; // 15 minutes
const REFRESH_MAX_AGE = 60 * 60 * 24 * 7; // 7 days

function cookieBase() {
  return {
    httpOnly: true,
    sameSite: 'lax' as const,
    secure: process.env.NODE_ENV === 'production',
    path: '/',
  };
}

export function setAccessCookie(reply: FastifyReply, token: string) {
  const base = { ...cookieBase(), maxAge: ACCESS_MAX_AGE };
  reply.setCookie('access_token', token, base);
  reply.setCookie('accessToken', token, base); // FE uyumu için iki isim (istersen kaldırırız)
}

export function setRefreshCookie(reply: FastifyReply, token: string) {
  const base = { ...cookieBase(), maxAge: REFRESH_MAX_AGE };
  reply.setCookie('refresh_token', token, base);
}

function clearAuthCookies(reply: FastifyReply) {
  const base = { path: '/' };
  reply.clearCookie('access_token', base);
  reply.clearCookie('accessToken', base);
  reply.clearCookie('refresh_token', base);
}

const sha256 = (s: string) => createHash('sha256').update(s).digest('hex');

/* -------------------- Password verify -------------------- */

async function verifyPasswordSmart(storedHash: string, plain: string): Promise<boolean> {
  const allowTemp = String((env as any).ALLOW_TEMP_LOGIN ?? '') === '1';
  if (allowTemp && storedHash.includes('temporary.hash.needs.reset')) {
    const expected = (env as any).TEMP_PASSWORD || 'admin123';
    return plain === expected;
  }

  if (
    storedHash.startsWith('$2a$') ||
    storedHash.startsWith('$2b$') ||
    storedHash.startsWith('$2y$')
  ) {
    return bcrypt.compare(plain, storedHash);
  }

  return argonVerify(storedHash, plain);
}

/* -------------------- access + refresh issue/rotate -------------------- */

export async function issueTokens(app: FastifyInstance, u: UserRow, roles: Role[]) {
  const jwt = getJWT(app);

  const access = jwt.sign(
    { sub: u.id, email: u.email ?? undefined, roles },
    { expiresIn: `${ACCESS_MAX_AGE}s` },
  );

  const jti = randomUUID();
  const refreshRaw = `${jti}.${randomUUID()}`;

  await db.insert(refresh_tokens).values({
    id: jti,
    user_id: u.id,
    token_hash: sha256(refreshRaw),
    expires_at: new Date(Date.now() + REFRESH_MAX_AGE * 1000),
  });

  return { access, refresh: refreshRaw };
}

async function rotateRefresh(oldRaw: string, userId: string) {
  const oldJti = oldRaw.split('.', 1)[0] ?? '';

  await db
    .update(refresh_tokens)
    .set({ revoked_at: new Date() })
    .where(eq(refresh_tokens.id, oldJti));

  const newJti = randomUUID();
  const newRaw = `${newJti}.${randomUUID()}`;

  await db.insert(refresh_tokens).values({
    id: newJti,
    user_id: userId,
    token_hash: sha256(newRaw),
    expires_at: new Date(Date.now() + REFRESH_MAX_AGE * 1000),
  });

  await db.update(refresh_tokens).set({ replaced_by: newJti }).where(eq(refresh_tokens.id, oldJti));
  return newRaw;
}

/* ================================= CONTROLLER ================================ */

export function makeAuthController(app: FastifyInstance) {
  const jwt = getJWT(app);

  return {
    /* ------------------------------ REGISTER ------------------------------ */
    // POST /auth/register
    register: async (req: FastifyRequest, reply: FastifyReply) => {
      if (!allowSignup()) {
        return reply.status(403).send({ error: { message: 'signup_disabled' } });
      }

      const parsed = registerBody.safeParse(req.body);
      if (!parsed.success) return reply.status(400).send({ error: { message: 'invalid_body' } });

      const email = parsed.data.email.toLowerCase();
      const { password } = parsed.data;

      const topFull = parsed.data.full_name;
      const topPhone = parsed.data.phone;
      const meta = (parsed.data.options?.data ?? {}) as Record<string, unknown>;

      const full_name =
        (topFull ??
          (typeof meta['full_name'] === 'string' ? (meta['full_name'] as string) : undefined)) ||
        undefined;

      const phone =
        (topPhone ?? (typeof meta['phone'] === 'string' ? (meta['phone'] as string) : undefined)) ||
        undefined;

      const exists = await db.select({ id: users.id }).from(users).where(eq(users.email, email));
      if (exists.length > 0) return reply.status(409).send({ error: { message: 'user_exists' } });

      const id = randomUUID();
      const password_hash = await argonHash(password);

      await db.insert(users).values({
        id,
        email,
        password_hash,
        full_name,
        phone,

        profile_image: parsed.data.profile_image ?? null,
        profile_image_asset_id: parsed.data.profile_image_asset_id ?? null,
        profile_image_alt: parsed.data.profile_image_alt ?? null,

        is_active: 1,
        email_verified: 0,
      } as any);

      // default role seller
      await db.insert(userRoles).values({
        id: randomUUID(),
        user_id: id,
        role: 'seller',
      });

      await ensureProfileRow(id, { full_name: full_name ?? null, phone: phone ?? null });

      // Welcome mail (best effort)
      const userNameForMail = full_name || email.split('@')[0];
      void sendWelcomeMail({
        to: email,
        user_name: userNameForMail,
        user_email: email,
        site_name: 'Tavvuk',
      }).catch((err: unknown) => {
        req.log?.error?.(err, 'welcome_mail_failed');
      });

      const u = (await db.select().from(users).where(eq(users.id, id)).limit(1))[0]!;
      const roles = await getUserRolesDb(id);
      const { access, refresh } = await issueTokens(app, u, roles);

      setAccessCookie(reply, access);
      setRefreshCookie(reply, refresh);

      return reply.send({
        access_token: access,
        token_type: 'bearer',
        user: {
          id,
          email,
          full_name: full_name ?? null,
          phone: phone ?? null,
          email_verified: 0,
          is_active: 1,
          roles,
          is_admin: roles.includes('admin'),
        },
      });
    },

    /* ------------------------------ LOGIN ------------------------------ */
    // POST /auth/login
    login: async (req: FastifyRequest, reply: FastifyReply) => {
      const parsed = loginBody.safeParse(req.body);
      if (!parsed.success) return reply.status(400).send({ error: { message: 'invalid_body' } });

      const email = parsed.data.email.toLowerCase();
      const { password } = parsed.data;

      const found = await db.select().from(users).where(eq(users.email, email)).limit(1);
      const u = found[0];

      if (!u || !(await verifyPasswordSmart(u.password_hash, password))) {
        return reply.status(401).send({ error: { message: 'invalid_credentials' } });
      }
      if (u.is_active !== 1) {
        return reply.status(403).send({ error: { message: 'user_inactive' } });
      }

      await db
        .update(users)
        .set({ last_sign_in_at: new Date(), updated_at: new Date() })
        .where(eq(users.id, u.id));

      await ensureProfileRow(u.id);

      const roles = await getUserRolesDb(u.id);
      const { access, refresh } = await issueTokens(app, u, roles);

      setAccessCookie(reply, access);
      setRefreshCookie(reply, refresh);

      return reply.send({
        access_token: access,
        token_type: 'bearer',
        user: {
          id: u.id,
          email: u.email,
          full_name: u.full_name ?? null,
          phone: u.phone ?? null,
          email_verified: u.email_verified,
          is_active: u.is_active,
          roles,
          is_admin: roles.includes('admin'),
        },
      });
    },

    /* ------------------------------ REFRESH ------------------------------ */
    // POST /auth/refresh
    refresh: async (req: FastifyRequest, reply: FastifyReply) => {
      const raw = (
        (req.cookies as Record<string, string | undefined> | undefined)?.refresh_token ?? ''
      ).trim();
      if (!raw.includes('.')) return reply.status(401).send({ error: { message: 'no_refresh' } });

      const jti = raw.split('.', 1)[0] ?? '';
      const row = (
        await db.select().from(refresh_tokens).where(eq(refresh_tokens.id, jti)).limit(1)
      )[0];

      if (!row) return reply.status(401).send({ error: { message: 'invalid_refresh' } });
      if (row.revoked_at) return reply.status(401).send({ error: { message: 'refresh_revoked' } });
      if (new Date(row.expires_at).getTime() < Date.now())
        return reply.status(401).send({ error: { message: 'refresh_expired' } });
      if (row.token_hash !== sha256(raw))
        return reply.status(401).send({ error: { message: 'invalid_refresh' } });

      const u = (await db.select().from(users).where(eq(users.id, row.user_id)).limit(1))[0];
      if (!u) return reply.status(401).send({ error: { message: 'invalid_user' } });
      if (u.is_active !== 1) return reply.status(403).send({ error: { message: 'user_inactive' } });

      const roles = await getUserRolesDb(u.id);

      const access = jwt.sign(
        { sub: u.id, email: u.email ?? undefined, roles },
        { expiresIn: `${ACCESS_MAX_AGE}s` },
      );

      const newRaw = await rotateRefresh(raw, u.id);

      setAccessCookie(reply, access);
      setRefreshCookie(reply, newRaw);

      return reply.send({ access_token: access, token_type: 'bearer' });
    },

    /* ------------------------------ PASSWORD RESET ------------------------------ */

    passwordResetRequest: async (req: FastifyRequest, reply: FastifyReply) => {
      const parsed = passwordResetRequestBody.safeParse(req.body);
      if (!parsed.success) return reply.status(400).send({ success: false, error: 'invalid_body' });

      const email = parsed.data.email.toLowerCase();
      const u = (await db.select().from(users).where(eq(users.email, email)).limit(1))[0] ?? null;

      if (!u) {
        return reply.send({
          success: true,
          message: 'Eğer bu e-posta ile bir hesap varsa, şifre sıfırlama bağlantısı gönderildi.',
        });
      }

      const resetToken = jwt.sign(
        { sub: u.id, email: u.email ?? undefined, purpose: 'password_reset' as const },
        { expiresIn: '1h' },
      );

      return reply.send({ success: true, token: resetToken });
    },

    passwordResetConfirm: async (req: FastifyRequest, reply: FastifyReply) => {
      const parsed = passwordResetConfirmBody.safeParse(req.body);
      if (!parsed.success) return reply.status(400).send({ success: false, error: 'invalid_body' });

      const { token, password } = parsed.data;

      let payload: JWTPayload;
      try {
        payload = jwt.verify(token);
      } catch {
        return reply.status(400).send({ success: false, error: 'invalid_or_expired_token' });
      }

      if (payload.purpose !== 'password_reset' || !payload.sub) {
        return reply.status(400).send({ success: false, error: 'invalid_token_payload' });
      }

      const u =
        (await db.select().from(users).where(eq(users.id, payload.sub)).limit(1))[0] ?? null;
      if (!u) return reply.status(404).send({ success: false, error: 'user_not_found' });

      const password_hash = await argonHash(password);

      await db
        .update(refresh_tokens)
        .set({ revoked_at: new Date() })
        .where(eq(refresh_tokens.user_id, u.id));
      await db
        .update(users)
        .set({ password_hash, updated_at: new Date() })
        .where(eq(users.id, u.id));

      try {
        const notif: NotificationInsert = {
          id: randomUUID(),
          user_id: u.id,
          title: 'Şifreniz güncellendi',
          message:
            'Hesap şifreniz başarıyla değiştirildi. Bu işlemi siz yapmadıysanız lütfen en kısa sürede bizimle iletişime geçin.',
          type: 'password_changed',
          is_read: 0,
          created_at: new Date(),
        };
        await db.insert(notifications).values(notif);
      } catch (err: unknown) {
        req.log?.error?.(err, 'password_change_notification_failed');
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
        }).catch((err: unknown) => req.log?.error?.(err, 'password_change_mail_failed'));
      }

      return reply.send({ success: true, message: 'Parolanız başarıyla güncellendi.' });
    },

    /* ------------------------------ ME / STATUS / UPDATE / LOGOUT ------------------------------ */

    me: async (req: FastifyRequest, reply: FastifyReply) => {
      const token = bearerFrom(req);
      if (!token) return reply.status(401).send({ error: { message: 'no_token' } });

      try {
        const p = jwt.verify(token);
        const roles = await getUserRolesDb(p.sub);
        return reply.send({
          user: {
            id: p.sub,
            email: p.email ?? null,
            roles,
            is_admin: roles.includes('admin'),
          },
        });
      } catch {
        return reply.status(401).send({ error: { message: 'invalid_token' } });
      }
    },

    status: async (req: FastifyRequest, reply: FastifyReply) => {
      const token = bearerFrom(req);
      if (!token) return reply.send({ authenticated: false, is_admin: false });

      try {
        const p = jwt.verify(token);
        const roles = await getUserRolesDb(p.sub);
        return reply.send({
          authenticated: true,
          is_admin: roles.includes('admin'),
          user: { id: p.sub, email: p.email ?? null, roles },
        });
      } catch {
        return reply.send({ authenticated: false, is_admin: false });
      }
    },

    update: async (req: FastifyRequest, reply: FastifyReply) => {
      const token = bearerFrom(req);
      if (!token) return reply.status(401).send({ error: { message: 'no_token' } });

      let p: JWTPayload;
      try {
        p = jwt.verify(token);
      } catch {
        return reply.status(401).send({ error: { message: 'invalid_token' } });
      }

      const parsed = updateBody.safeParse(req.body);
      if (!parsed.success) return reply.status(400).send({ error: { message: 'invalid_body' } });

      const email = parsed.data.email?.toLowerCase();
      const password = parsed.data.password;

      let passwordChanged = false;
      let newEmail = p.email;

      if (email) {
        await db.update(users).set({ email, updated_at: new Date() }).where(eq(users.id, p.sub));
        newEmail = email;
      }

      if (password) {
        const password_hash = await argonHash(password);
        await db
          .update(users)
          .set({ password_hash, updated_at: new Date() })
          .where(eq(users.id, p.sub));
        passwordChanged = true;

        await db
          .update(refresh_tokens)
          .set({ revoked_at: new Date() })
          .where(eq(refresh_tokens.user_id, p.sub));
      }

      if (passwordChanged) {
        try {
          const notif: NotificationInsert = {
            id: randomUUID(),
            user_id: p.sub,
            title: 'Şifreniz güncellendi',
            message:
              'Hesap şifreniz başarıyla değiştirildi. Bu işlemi siz yapmadıysanız lütfen en kısa sürede bizimle iletişime geçin.',
            type: 'password_changed',
            is_read: 0,
            created_at: new Date(),
          };
          await db.insert(notifications).values(notif);
        } catch (err: unknown) {
          req.log?.error?.(err, 'password_change_notification_failed');
        }

        const targetEmail = newEmail;
        if (targetEmail) {
          const userName = targetEmail.split('@')[0] || 'Kullanıcı';
          void sendPasswordChangedMail({
            to: targetEmail,
            user_name: userName,
            site_name: 'Tavvuk',
          }).catch((err: unknown) => req.log?.error?.(err, 'password_change_mail_failed'));
        }
      }

      const roles = await getUserRolesDb(p.sub);
      return reply.send({
        user: {
          id: p.sub,
          email: newEmail ?? null,
          roles,
          is_admin: roles.includes('admin'),
        },
      });
    },

    logout: async (req: FastifyRequest, reply: FastifyReply) => {
      const raw = (
        (req.cookies as Record<string, string | undefined> | undefined)?.refresh_token ?? ''
      ).trim();

      if (raw.includes('.')) {
        const jti = raw.split('.', 1)[0] ?? '';
        await db
          .update(refresh_tokens)
          .set({ revoked_at: new Date() })
          .where(eq(refresh_tokens.id, jti));
      }

      clearAuthCookies(reply);
      return reply.status(204).send();
    },
  };
}
