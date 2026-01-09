// =============================================================
// FILE: src/modules/reports/validation.ts
// FINAL — Reports validation schemas (admin)
// =============================================================

import { z } from 'zod';

export const roleSchema = z.enum(['seller', 'driver']);

function parseDate(v?: string): Date | null {
  if (!v) return null;
  const d = new Date(v);
  return Number.isNaN(d.getTime()) ? null : d;
}

// 1) Base object: extend edilebilir olmalı
export const dateRangeBaseSchema = z.object({
  from: z.string().optional(),
  to: z.string().optional(),
});

// 2) Refine edilmiş schema: artık ZodEffects (extend edilmez)
export const dateRangeSchema = dateRangeBaseSchema.refine(
  (x) => {
    const df = parseDate(x.from);
    const dt = parseDate(x.to);

    if (x.from && !df) return false;
    if (x.to && !dt) return false;
    if (df && dt && df.getTime() > dt.getTime()) return false;

    return true;
  },
  { message: 'invalid_date_range' },
);

// KPI: sadece dateRange
export const adminKpiQuerySchema = dateRangeSchema;

// User performance: base’i extend et, sonra refine uygula
export const adminUserPerformanceQuerySchema = dateRangeBaseSchema
  .extend({
    role: roleSchema,
  })
  .refine(
    (x) => {
      const df = parseDate(x.from);
      const dt = parseDate(x.to);

      if (x.from && !df) return false;
      if (x.to && !dt) return false;
      if (df && dt && df.getTime() > dt.getTime()) return false;

      return true;
    },
    { message: 'invalid_date_range' },
  );

// Locations: sadece dateRange
export const adminLocationsQuerySchema = dateRangeSchema;
