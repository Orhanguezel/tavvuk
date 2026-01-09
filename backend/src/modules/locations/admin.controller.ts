// =============================================================
// FILE: src/modules/locations/admin.controller.ts
// FINAL — Locations admin controller (import)
// =============================================================
import type { RouteHandler } from 'fastify';
import { randomUUID } from 'crypto';
import { db } from '@/db/client';
import { cities, districts } from './schema';
import { importLocationsBodySchema } from './validation';
import { eq } from 'drizzle-orm';

function toBool01(v: boolean): 0 | 1 {
  return v ? 1 : 0;
}

export const importLocations: RouteHandler = async (req, reply) => {
  const body = importLocationsBodySchema.parse(req.body ?? {});
  const activate = toBool01(body.activate_all);

  await db.transaction(async (tx: any) => {
    if (body.mode === 'replace') {
      // Dikkat: FK sırası
      await tx.delete(districts);
      await tx.delete(cities);
    }

    for (const c of body.cities) {
      // 1) upsert city (code unique)
      const existingCity =
        (await tx.select().from(cities).where(eq(cities.code, c.code)).limit(1))[0] ?? null;

      const cityId = existingCity?.id ?? randomUUID();

      if (!existingCity) {
        await tx.insert(cities).values({
          id: cityId,
          code: c.code,
          name: c.name,
          is_active: activate,
        });
      } else {
        await tx
          .update(cities)
          .set({ name: c.name, is_active: activate, updated_at: new Date() })
          .where(eq(cities.id, cityId));
      }

      // 2) upsert districts by (city_id + name) unique
      for (let i = 0; i < (c.districts?.length ?? 0); i++) {
        const d = c.districts[i]!;
        const name = d.name.trim();

        const existingDistrict =
          (
            await tx
              .select()
              .from(districts)
              .where(eq(districts.city_id, cityId))
              .where(eq(districts.name, name))
              .limit(1)
          )[0] ?? null;

        const distId = existingDistrict?.id ?? randomUUID();
        const distCode = typeof d.code === 'number' ? d.code : i + 1;

        if (!existingDistrict) {
          await tx.insert(districts).values({
            id: distId,
            city_id: cityId,
            code: distCode,
            name,
            is_active: activate,
          });
        } else {
          await tx
            .update(districts)
            .set({ code: distCode, is_active: activate, updated_at: new Date() })
            .where(eq(districts.id, distId));
        }
      }
    }
  });

  return reply.send({ ok: true });
};
