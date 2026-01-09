// =============================================================
// FILE: src/modules/orders/router.ts
// FINAL — Orders public routes
// =============================================================
import type { FastifyInstance } from 'fastify';
import { createOrder, listMyOrders, getOrderDetail, patchMyOrder } from './controller';

export async function registerOrders(app: FastifyInstance) {
  const BASE = '/orders';

  app.post(`${BASE}`, { config: { rateLimit: { max: 60, timeWindow: '1 minute' } } }, createOrder);
  app.get(`${BASE}`, { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } }, listMyOrders);
  app.get(
    `${BASE}/:id`,
    { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    getOrderDetail,
  );

  // only own + submitted (controller enforces)
  app.patch(
    `${BASE}/:id`,
    { config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    patchMyOrder,
  );
}
