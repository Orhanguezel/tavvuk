// =============================================================
// FILE: src/modules/products/router.ts
// FINAL — Tavvuk Products public routes
// Prefix: createApp() içinde /api altında register ediliyor
// =============================================================
import type { FastifyInstance } from 'fastify';
import { listPublicProducts, getPublicProductBySlug } from './controller';

export async function registerProducts(app: FastifyInstance) {
  app.get('/products', {
    config: { rateLimit: { max: 120, timeWindow: '1 minute' } },
    handler: listPublicProducts,
  });

  app.get('/products/by-slug/:slug', {
    config: { rateLimit: { max: 240, timeWindow: '1 minute' } },
    handler: getPublicProductBySlug,
  });
}
