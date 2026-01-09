// =============================================================
// FILE: src/modules/products/admin.controller.ts
// FINAL — Tavvuk Products admin controller
// - CRUD + setImages
// - No stock decrement logic in v1
// =============================================================
import type { RouteHandler } from 'fastify';
import { randomUUID } from 'crypto';

import {
  productListQuerySchema,
  productCreateSchema,
  productUpdateSchema,
  productSetImagesSchema,
} from './validation';
import {
  listProducts,
  createProduct,
  updateProduct,
  deleteProduct,
  getProductById,
} from './repository';

export const adminListProducts: RouteHandler = async (req, reply) => {
  const q = productListQuerySchema.parse(req.query ?? {});
  const rows = await listProducts(q);
  return reply.send(rows);
};

export const adminGetProduct: RouteHandler = async (req, reply) => {
  const { id } = req.params as { id: string };
  const row = await getProductById(String(id));
  if (!row) return reply.code(404).send({ error: { message: 'not_found' } });
  return reply.send(row);
};

export const adminCreateProduct: RouteHandler = async (req, reply) => {
  const body = productCreateSchema.parse(req.body ?? {});

  const created = await createProduct({
    title: body.title,
    slug: body.slug ?? body.title,
    species: body.species,
    breed: body.breed ?? null,
    summary: body.summary ?? null,
    description: body.description ?? null,
    price: body.price != null ? String(body.price) : '0.00',

    image_url: body.image_url ?? null,
    storage_asset_id: body.storage_asset_id ?? null,
    alt: body.alt ?? null,
    images: body.images ?? [],
    storage_image_ids: body.storage_image_ids ?? [],

    stock_quantity: body.stock_quantity ?? 0,

    is_active: (body.is_active as any) ?? 1,
    is_featured: (body.is_featured as any) ?? 0,
    tags: body.tags ?? [],
  } as any);

  return reply.code(201).send(created);
};

export const adminUpdateProduct: RouteHandler = async (req, reply) => {
  const { id } = req.params as { id: string };
  const body = productUpdateSchema.parse(req.body ?? {});
  const updated = await updateProduct(String(id), {
    ...body,
    price: body.price != null ? String(body.price) : undefined,
  } as any);

  if (!updated) return reply.code(404).send({ error: { message: 'not_found' } });
  return reply.send(updated);
};

export const adminSetProductImages: RouteHandler = async (req, reply) => {
  const { id } = req.params as { id: string };
  const body = productSetImagesSchema.parse(req.body ?? {});

  const updated = await updateProduct(String(id), {
    image_url: body.image_url ?? null,
    storage_asset_id: body.storage_asset_id ?? null,
    alt: body.alt ?? null,
    images: body.images ?? [],
    storage_image_ids: body.storage_image_ids ?? [],
  } as any);

  if (!updated) return reply.code(404).send({ error: { message: 'not_found' } });
  return reply.send(updated);
};

export const adminDeleteProduct: RouteHandler = async (req, reply) => {
  const { id } = req.params as { id: string };
  const ok = await deleteProduct(String(id));
  if (!ok) return reply.code(404).send({ error: { message: 'not_found' } });
  return reply.code(204).send();
};
