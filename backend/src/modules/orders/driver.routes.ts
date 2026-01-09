import type { FastifyInstance } from 'fastify';
import { listDriverOrders, deliverOrder, adminListDriverOrders } from './driver.controller';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';

export async function registerDriverOrders(app: FastifyInstance) {
  // Driver self (token driver)
  app.get(
    '/driver/orders',
    { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    listDriverOrders,
  );

  app.post(
    '/driver/orders/:id/deliver',
    { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    deliverOrder,
  );

  // Admin: pick driver
  app.get(
    '/driver/:driverId/orders',
    {
      config: { rateLimit: { max: 120, timeWindow: '1 minute' } },
      preHandler: [requireAuth as any, requireAdmin as any],
    },
    adminListDriverOrders,
  );
}
