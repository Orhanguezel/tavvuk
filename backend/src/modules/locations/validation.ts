// =============================================================
// FILE: src/modules/locations/validation.ts
// FINAL — Locations validations (list + import)
// =============================================================
import { z } from 'zod';
import { boolLike } from '@/modules/_shared/common';

export const listCitiesQuerySchema = z.object({
  q: z.string().optional(),
  is_active: boolLike.optional(),
  limit: z.coerce.number().int().min(1).max(500).optional(),
  offset: z.coerce.number().int().min(0).max(1_000_000).optional(),
  order: z.enum(['name', 'code', 'created_at']).optional(),
  direction: z.enum(['asc', 'desc']).optional(),
});

export const listDistrictsQuerySchema = z
  .object({
    city_id: z.string().uuid().optional(),
    city_code: z.coerce.number().int().min(1).max(999).optional(),
    q: z.string().optional(),
    is_active: boolLike.optional(),
    limit: z.coerce.number().int().min(1).max(1000).optional(),
    offset: z.coerce.number().int().min(0).max(1_000_000).optional(),
    order: z.enum(['name', 'code', 'created_at']).optional(),
    direction: z.enum(['asc', 'desc']).optional(),
  })
  .refine((v) => v.city_id || v.city_code, { message: 'city_id_or_city_code_required' });

/**
 * Import payload
 * - mode:
 *   - upsert: mevcutları günceller/ekler (recommended)
 *   - replace: önce truncate, sonra yükle (dangerous)
 */
export const importLocationsBodySchema = z.object({
  mode: z.enum(['upsert', 'replace']).default('upsert'),

  cities: z
    .array(
      z.object({
        code: z.number().int().min(1).max(999),
        name: z.string().trim().min(1).max(128),
        districts: z
          .array(
            z.object({
              code: z.number().int().min(0).max(9999).optional(),
              name: z.string().trim().min(1).max(128),
            }),
          )
          .default([]),
      }),
    )
    .min(1),

  /** true ise is_active=1 set edilir (default true) */
  activate_all: z.coerce.boolean().default(true),
});

export type ListCitiesQuery = z.infer<typeof listCitiesQuerySchema>;
export type ListDistrictsQuery = z.infer<typeof listDistrictsQuerySchema>;
export type ImportLocationsBody = z.infer<typeof importLocationsBodySchema>;
