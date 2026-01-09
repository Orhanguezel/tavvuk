// =============================================================
// FILE: src/modules/products/validation.ts
// FINAL — Tavvuk Products validation (single source)
// =============================================================
import { z } from 'zod';
import { boolLike } from '@/modules/_shared/common';
import { POULTRY_SPECIES } from './schema';

export const speciesEnum = z.enum(POULTRY_SPECIES);

export const productSortable = z.enum([
  'created_at',
  'updated_at',
  'title',
  'price',
  'stock_quantity',
]);

export const productListQuerySchema = z.object({
  q: z.string().trim().optional(),
  species: speciesEnum.optional(),
  breed: z.string().trim().min(1).max(255).optional(),
  tag: z.string().trim().min(1).max(64).optional(),
  is_active: boolLike.optional(),
  is_featured: boolLike.optional(),

  sort: productSortable.optional(),
  order: z.enum(['asc', 'desc']).optional(),

  limit: z.coerce.number().int().min(1).max(200).optional(),
  offset: z.coerce.number().int().min(0).max(1_000_000).optional(),
});

export type ProductListQuery = z.infer<typeof productListQuerySchema>;

export const productCreateSchema = z
  .object({
    title: z.string().trim().min(2).max(255),
    slug: z.string().trim().min(2).max(255).optional(), // optional -> generate from title if missing

    species: speciesEnum.default('chicken'),
    breed: z.string().trim().min(1).max(255).optional().nullable(),
    summary: z.string().trim().min(1).max(500).optional().nullable(),
    description: z.string().trim().min(1).optional().nullable(),

    price: z.coerce.number().min(0).optional(),

    // images
    image_url: z.string().trim().url().optional().nullable(),
    storage_asset_id: z.string().uuid().optional().nullable(),
    alt: z.string().trim().min(1).max(255).optional().nullable(),
    images: z.array(z.string().trim().url()).optional(),
    storage_image_ids: z.array(z.string().uuid()).optional(),

    // stock (v1 informational)
    stock_quantity: z.coerce.number().int().min(0).optional(),

    is_active: boolLike.optional(),
    is_featured: boolLike.optional(),

    tags: z.array(z.string().trim().min(1).max(64)).optional(),
  })
  .strict();

export type ProductCreateInput = z.infer<typeof productCreateSchema>;

export const productUpdateSchema = z
  .object({
    title: z.string().trim().min(2).max(255).optional(),
    slug: z.string().trim().min(2).max(255).optional(),

    species: speciesEnum.optional(),
    breed: z.string().trim().min(1).max(255).optional().nullable(),
    summary: z.string().trim().min(1).max(500).optional().nullable(),
    description: z.string().trim().min(1).optional().nullable(),

    price: z.coerce.number().min(0).optional(),

    image_url: z.string().trim().url().optional().nullable(),
    storage_asset_id: z.string().uuid().optional().nullable(),
    alt: z.string().trim().min(1).max(255).optional().nullable(),
    images: z.array(z.string().trim().url()).optional(),
    storage_image_ids: z.array(z.string().uuid()).optional(),

    stock_quantity: z.coerce.number().int().min(0).optional(),

    is_active: boolLike.optional(),
    is_featured: boolLike.optional(),

    tags: z.array(z.string().trim().min(1).max(64)).optional(),
  })
  .strict();

export type ProductUpdateInput = z.infer<typeof productUpdateSchema>;

export const productSetImagesSchema = z
  .object({
    image_url: z.string().trim().url().optional().nullable(),
    storage_asset_id: z.string().uuid().optional().nullable(),
    alt: z.string().trim().min(1).max(255).optional().nullable(),
    images: z.array(z.string().trim().url()).default([]),
    storage_image_ids: z.array(z.string().uuid()).default([]),
  })
  .strict();

export type ProductSetImagesInput = z.infer<typeof productSetImagesSchema>;
