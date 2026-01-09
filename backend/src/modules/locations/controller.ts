// =============================================================
// FILE: src/modules/locations/controller.ts
// FINAL — Locations public controller
// =============================================================
import type { RouteHandler } from 'fastify';
import { listCitiesQuerySchema, listDistrictsQuerySchema } from './validation';
import { listCities, listDistricts } from './repository';

export const getCities: RouteHandler = async (req, reply) => {
  const q = listCitiesQuerySchema.parse(req.query ?? {});
  const rows = await listCities(q);
  return reply.send(rows);
};

export const getDistricts: RouteHandler = async (req, reply) => {
  const q = listDistrictsQuerySchema.parse(req.query ?? {});
  const rows = await listDistricts(q);
  return reply.send(rows);
};

// ✅ NEW: /locations/cities/:cityId/districts
export const getDistrictsByCityId: RouteHandler = async (req, reply) => {
  const params = (req.params ?? {}) as { cityId?: string };
  const cityId = (params.cityId ?? '').trim();
  if (!cityId) return reply.status(400).send({ error: { message: 'city_id_required' } });

  const q = listDistrictsQuerySchema.parse({ ...(req.query ?? {}), city_id: cityId });
  const rows = await listDistricts(q);
  return reply.send(rows);
};
