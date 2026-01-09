// =============================================================
// FILE: src/modules/products/admin.routes.ts
// FINAL — Tavvuk Products admin routes
// Prefix: createApp() içinde /api/admin ile register ediliyor
// =============================================================
import type { FastifyInstance } from 'fastify';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';

import {
  adminListProducts,
  adminGetProduct,
  adminCreateProduct,
  adminUpdateProduct,
  adminSetProductImages,
  adminDeleteProduct,
} from './admin.controller';

export async function registerProductsAdmin(app: FastifyInstance) {
  const guard = { preHandler: [requireAuth, requireAdmin] as any };

  app.get(
    '/products',
    { ...guard, config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    adminListProducts,
  );
  app.get(
    '/products/:id',
    { ...guard, config: { rateLimit: { max: 240, timeWindow: '1 minute' } } },
    adminGetProduct,
  );

  app.post(
    '/products',
    { ...guard, config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    adminCreateProduct,
  );
  app.patch(
    '/products/:id',
    { ...guard, config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    adminUpdateProduct,
  );

  app.post(
    '/products/:id/images',
    { ...guard, config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    adminSetProductImages,
  );

  app.delete(
    '/products/:id',
    { ...guard, config: { rateLimit: { max: 30, timeWindow: '1 minute' } } },
    adminDeleteProduct,
  );
}
