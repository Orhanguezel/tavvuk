import type { RouteHandler } from 'fastify';
import { db } from '@/db/client';
import { driverDeliverBodySchema, listOrdersQuerySchema } from './validation';
import { getOrderById, getOrderItems, deliverOrderTx, listOrdersForDriver } from './repository';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';

function getUserId(req: any): string {
  return String(req.user?.sub ?? '');
}

export const listDriverOrders: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;

  const q = listOrdersQuerySchema.parse({
    ...(req.query ?? {}),
    limit: 100,
    offset: 0,
    order: 'created_at',
    direction: 'desc',
  });

  const userId = getUserId(req);

  // Driver self list: only assigned
  const rows = await listOrdersForDriver(db as any, userId, q);
  return reply.send(rows);
};

// ✅ NEW: Admin lists a specific driver
export const adminListDriverOrders: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;
  await requireAdmin(req as any, reply as any);
  if (reply.sent) return;

  const q = listOrdersQuerySchema.parse({
    ...(req.query ?? {}),
    limit: 100,
    offset: 0,
    order: 'created_at',
    direction: 'desc',
  });

  const driverId = String((req.params as any).driverId ?? '').trim();
  if (!driverId) return reply.code(400).send({ error: { message: 'driver_id_required' } });

  const rows = await listOrdersForDriver(db as any, driverId, q);
  return reply.send(rows);
};

export const deliverOrder: RouteHandler = async (req, reply) => {
  await requireAuth(req as any, reply as any);
  if (reply.sent) return;

  const id = String((req.params as any).id);
  const userId = getUserId(req);

  const body = driverDeliverBodySchema.parse(req.body ?? {});

  const o = await getOrderById(db as any, id);
  if (!o) return reply.code(404).send({ error: { message: 'not_found' } });

  const canDeliver = o.assigned_driver_id === userId || o.created_by === userId;
  if (!canDeliver) return reply.code(403).send({ error: { message: 'forbidden' } });

  if (o.status === 'cancelled')
    return reply.code(409).send({ error: { message: 'order_cancelled' } });

  await db.transaction(async (tx: any) => {
    await deliverOrderTx(tx, id, userId, body);
  });

  const updated = await getOrderById(db as any, id);
  const items = await getOrderItems(db as any, id);
  return reply.send({ order: updated, items });
};
