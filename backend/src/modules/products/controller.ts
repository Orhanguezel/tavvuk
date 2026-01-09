// =============================================================
// FILE: src/modules/products/controller.ts
// FINAL — Tavvuk Products public controller
// - List + BySlug
// =============================================================
import type { RouteHandler } from 'fastify';
import { productListQuerySchema } from './validation';
import { listProducts, getProductBySlug } from './repository';
import { toBool01 } from '@/modules/_shared/_shared';

export const listPublicProducts: RouteHandler = async (req, reply) => {
  const q = productListQuerySchema.parse(req.query ?? {});

  // Public default: only active unless explicitly asked
  const isActive = q.is_active != null ? toBool01(q.is_active) : 1;

  const rows = await listProducts({
    ...q,
    is_active: isActive as any,
  });

  return reply.send(rows);
};

export const getPublicProductBySlug: RouteHandler = async (req, reply) => {
  const { slug } = req.params as { slug: string };
  const row = await getProductBySlug(String(slug));
  if (!row || row.is_active !== (true as any) /* drizzle tinyint typed */) {
    // allow if is_active true, otherwise 404
    if (!row) return reply.code(404).send({ error: { message: 'not_found' } });
    if ((row as any).is_active !== 1)
      return reply.code(404).send({ error: { message: 'not_found' } });
  }
  return reply.send(row);
};
