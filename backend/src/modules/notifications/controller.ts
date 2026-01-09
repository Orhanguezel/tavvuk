// ===================================================================
// FILE: src/modules/notifications/controller.ts
// FINAL — Notifications Controller (user + global)
// - Global notifications support via GLOBAL_USER_ID
// - List/unread-count/mark-all-read include global + user notifications
// - Delete: only user's own notifications (global delete disabled)
// ===================================================================

import type { RouteHandler } from 'fastify';
import { randomUUID } from 'crypto';
import { db } from '@/db/client';
import { and, desc, eq, sql, or } from 'drizzle-orm';

import {
  notifications,
  type NotificationRow,
  type NotificationInsert,
  type NotificationType,
} from './schema';

import {
  notificationCreateSchema,
  notificationUpdateSchema,
  notificationMarkAllReadSchema,
} from './validation';

/**
 * Seed/global notifications bucket.
 * If a notification is inserted with this user_id, every authenticated user can see it.
 */
const GLOBAL_USER_ID = '00000000-0000-0000-0000-000000000000';

/* ---------------------------------------------------------------
 * Auth helper
 * --------------------------------------------------------------- */
function getAuthUserId(req: any): string {
  const sub = req.user?.sub ?? req.user?.id ?? null;
  if (!sub) throw new Error('unauthorized');
  return String(sub);
}

function parseIntSafe(v: unknown, fallback: number): number {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}

function clamp(n: number, min: number, max: number): number {
  return Math.max(min, Math.min(max, n));
}

/* ---------------------------------------------------------------
 * Programatik kullanım: createUserNotification (booking/orders çağırır)
 * --------------------------------------------------------------- */
export async function createUserNotification(input: {
  userId: string;
  title: string;
  message: string;
  type?: NotificationType;
}): Promise<NotificationRow> {
  const insert: NotificationInsert = {
    id: randomUUID(),
    user_id: input.userId,
    title: input.title,
    message: input.message,
    type: input.type ?? 'system',
    is_read: 0,
    created_at: new Date(),
  };

  await db.insert(notifications).values(insert);

  const [row] = await db
    .select()
    .from(notifications)
    .where(eq(notifications.id, insert.id))
    .limit(1);

  return row as NotificationRow;
}

/* ---------------------------------------------------------------
 * HTTP Handlers
 * --------------------------------------------------------------- */

// GET /notifications
export const listNotifications: RouteHandler = async (req, reply) => {
  try {
    const userId = getAuthUserId(req);

    const q = (req.query ?? {}) as {
      is_read?: string | boolean | number;
      type?: string;
      limit?: string | number;
      offset?: string | number;
      include_global?: string | boolean | number; // optional
    };

    const limit = clamp(parseIntSafe(q.limit, 50), 1, 200);
    const offset = clamp(parseIntSafe(q.offset, 0), 0, 100000);

    const includeGlobal =
      typeof q.include_global === 'undefined'
        ? true
        : typeof q.include_global === 'boolean'
        ? q.include_global
        : ['1', 'true', 'yes', 'on'].includes(String(q.include_global).toLowerCase());

    // base scope: user notifications (+ global optional)
    const scope = includeGlobal
      ? or(eq(notifications.user_id, userId), eq(notifications.user_id, GLOBAL_USER_ID))
      : eq(notifications.user_id, userId);

    const whereConds: any[] = [scope];

    if (typeof q.type === 'string' && q.type.trim().length > 0) {
      whereConds.push(eq(notifications.type, q.type.trim()));
    }

    if (typeof q.is_read !== 'undefined') {
      const b =
        typeof q.is_read === 'boolean'
          ? q.is_read
          : ['1', 'true', 'yes', 'on'].includes(String(q.is_read).toLowerCase());
      whereConds.push(eq(notifications.is_read, b ? 1 : 0));
    }

    const rows = await db
      .select()
      .from(notifications)
      .where(and(...whereConds))
      .orderBy(desc(notifications.created_at))
      .limit(limit)
      .offset(offset);

    return reply.send(rows);
  } catch (e: any) {
    if (e?.message === 'unauthorized') {
      return reply.code(401).send({ error: { message: 'unauthorized' } });
    }
    req.log.error(e);
    return reply.code(500).send({ error: { message: 'notifications_list_failed' } });
  }
};

// GET /notifications/unread-count
export const getUnreadCount: RouteHandler = async (req, reply) => {
  try {
    const userId = getAuthUserId(req);

    const q = (req.query ?? {}) as { include_global?: string | boolean | number };

    const includeGlobal =
      typeof q.include_global === 'undefined'
        ? true
        : typeof q.include_global === 'boolean'
        ? q.include_global
        : ['1', 'true', 'yes', 'on'].includes(String(q.include_global).toLowerCase());

    const scope = includeGlobal
      ? or(eq(notifications.user_id, userId), eq(notifications.user_id, GLOBAL_USER_ID))
      : eq(notifications.user_id, userId);

    const [row] = await db
      .select({ count: sql<number>`COUNT(*)` })
      .from(notifications)
      .where(and(scope, eq(notifications.is_read, 0)));

    return reply.send({ count: Number(row?.count ?? 0) });
  } catch (e: any) {
    if (e?.message === 'unauthorized') {
      return reply.code(401).send({ error: { message: 'unauthorized' } });
    }
    req.log.error(e);
    return reply.code(500).send({ error: { message: 'notifications_unread_count_failed' } });
  }
};

// POST /notifications
export const createNotificationHandler: RouteHandler = async (req, reply) => {
  try {
    const authUserId = getAuthUserId(req);

    const body = notificationCreateSchema.parse(req.body ?? {});
    const targetUserId = body.user_id ?? authUserId;

    const row = await createUserNotification({
      userId: targetUserId,
      title: body.title,
      message: body.message,
      type: body.type,
    });

    return reply.code(201).send(row);
  } catch (e: any) {
    if (e?.name === 'ZodError') {
      return reply.code(400).send({ error: { message: 'validation_error', details: e.issues } });
    }
    if (e?.message === 'unauthorized') {
      return reply.code(401).send({ error: { message: 'unauthorized' } });
    }
    req.log.error(e);
    return reply.code(500).send({ error: { message: 'notification_create_failed' } });
  }
};

// PATCH /notifications/:id
export const markNotificationRead: RouteHandler = async (req, reply) => {
  const { id } = req.params as { id: string };

  try {
    const userId = getAuthUserId(req);
    const patch = notificationUpdateSchema.parse(req.body ?? {});

    const isRead = patch.is_read ?? true;

    const [existing] = await db
      .select()
      .from(notifications)
      .where(eq(notifications.id, id))
      .limit(1);

    // allow marking own OR global notification
    const ownerOk =
      existing && (existing.user_id === userId || existing.user_id === GLOBAL_USER_ID);

    if (!ownerOk) {
      return reply.code(404).send({ error: { message: 'not_found' } });
    }

    await db
      .update(notifications)
      .set({ is_read: isRead ? 1 : 0 })
      .where(eq(notifications.id, id));

    const [updated] = await db
      .select()
      .from(notifications)
      .where(eq(notifications.id, id))
      .limit(1);

    return reply.send(updated);
  } catch (e: any) {
    if (e?.name === 'ZodError') {
      return reply.code(400).send({ error: { message: 'validation_error', details: e.issues } });
    }
    if (e?.message === 'unauthorized') {
      return reply.code(401).send({ error: { message: 'unauthorized' } });
    }
    req.log.error(e);
    return reply.code(500).send({ error: { message: 'notification_update_failed' } });
  }
};

// POST /notifications/mark-all-read
export const markAllRead: RouteHandler = async (req, reply) => {
  try {
    const userId = getAuthUserId(req);
    notificationMarkAllReadSchema.parse(req.body ?? {});

    // mark both user + global unread as read
    await db
      .update(notifications)
      .set({ is_read: 1 })
      .where(
        and(
          or(eq(notifications.user_id, userId), eq(notifications.user_id, GLOBAL_USER_ID)),
          eq(notifications.is_read, 0),
        ),
      );

    return reply.send({ ok: true });
  } catch (e: any) {
    if (e?.name === 'ZodError') {
      return reply.code(400).send({ error: { message: 'validation_error', details: e.issues } });
    }
    if (e?.message === 'unauthorized') {
      return reply.code(401).send({ error: { message: 'unauthorized' } });
    }
    req.log.error(e);
    return reply.code(500).send({ error: { message: 'notifications_mark_all_read_failed' } });
  }
};

// DELETE /notifications/:id
export const deleteNotification: RouteHandler = async (req, reply) => {
  const { id } = req.params as { id: string };

  try {
    const userId = getAuthUserId(req);

    const [existing] = await db
      .select()
      .from(notifications)
      .where(eq(notifications.id, id))
      .limit(1);

    // security: only delete own notifications (global delete disabled)
    if (!existing || existing.user_id !== userId) {
      return reply.code(404).send({ error: { message: 'not_found' } });
    }

    await db.delete(notifications).where(eq(notifications.id, id));
    return reply.send({ ok: true });
  } catch (e: any) {
    if (e?.message === 'unauthorized') {
      return reply.code(401).send({ error: { message: 'unauthorized' } });
    }
    req.log.error(e);
    return reply.code(500).send({ error: { message: 'notification_delete_failed' } });
  }
};
