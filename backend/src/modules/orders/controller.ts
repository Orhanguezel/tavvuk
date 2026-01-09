// =============================================================
// FILE: src/modules/orders/controller.ts
// FINAL — Orders public controller
// =============================================================
import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';
import { orders } from './schema';
import { createOrderBodySchema, listOrdersQuerySchema, patchOrderBodySchema } from './validation';
import {
  createOrderTx,
  getOrderById,
  getOrderItems,
  listOrdersForUser,
  patchOrderSubmittedTx,
} from './repository';
import { requireAuth } from '@/common/middleware/auth';
import { eq } from 'drizzle-orm';

function getUserId(req: any): string {
  return String(req.user?.sub ?? '');
}

export const createOrder: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;

  const body = createOrderBodySchema.parse(req.body ?? {});
  const userId = getUserId(req);

  const orderId = await db.transaction(async (tx: any) => {
    return await createOrderTx(tx, {
      created_by: userId,
      city_id: body.city_id,
      district_id: body.district_id ?? null,
      customer_name: body.customer_name,
      customer_phone: body.customer_phone,
      address_text: body.address_text,
      items: body.items,
    });
  });

  const o = await getOrderById(db as any, orderId);
  const items = await getOrderItems(db as any, orderId);
  return reply.code(201).send({ order: o, items });
};

export const listMyOrders: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;

  const q = listOrdersQuerySchema.parse(req.query ?? {});
  const userId = getUserId(req);

  const rows = await listOrdersForUser(db as any, userId, q);
  return reply.send(rows);
};

export const getOrderDetail: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;

  const id = String((req.params as any).id);
  const userId = getUserId(req);

  const o = await getOrderById(db as any, id);
  if (!o) return reply.code(404).send({ error: { message: 'not_found' } });

  // visibility: own OR assigned OR admin (admin check is handled in middleware elsewhere; MVP: allow if own/assigned)
  const canSee = o.created_by === userId || o.assigned_driver_id === userId;
  if (!canSee) return reply.code(403).send({ error: { message: 'forbidden' } });

  const items = await getOrderItems(db as any, id);
  return reply.send({ order: o, items });
};

export const patchMyOrder: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;

  const id = String((req.params as any).id);
  const userId = getUserId(req);

  const body = patchOrderBodySchema.parse(req.body ?? {});

  const o = await getOrderById(db as any, id);
  if (!o) return reply.code(404).send({ error: { message: 'not_found' } });

  if (o.created_by !== userId) return reply.code(403).send({ error: { message: 'forbidden' } });
  if (o.status !== 'submitted')
    return reply.code(409).send({ error: { message: 'only_submitted_editable' } });

  await db.transaction(async (tx: any) => {
    await patchOrderSubmittedTx(tx, id, {
      ...(body.city_id ? { city_id: body.city_id } : {}),
      ...(body.district_id !== undefined ? { district_id: body.district_id ?? null } : {}),
      ...(body.customer_name ? { customer_name: body.customer_name } : {}),
      ...(body.customer_phone ? { customer_phone: body.customer_phone } : {}),
      ...(body.address_text ? { address_text: body.address_text } : {}),
      ...(body.items ? { items: body.items } : {}),
    });
  });

  const updated = await getOrderById(db as any, id);
  const items = await getOrderItems(db as any, id);
  return reply.send({ order: updated, items });
};
