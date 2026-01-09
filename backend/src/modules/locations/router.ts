// =============================================================
// FILE: src/modules/locations/router.ts
// FINAL — Locations public router
// =============================================================
import type { FastifyInstance } from 'fastify';
import { getCities, getDistricts, getDistrictsByCityId } from './controller';

export async function registerLocations(app: FastifyInstance) {
  const BASE = '/locations';

  app.get(
    `${BASE}/cities`,
    { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    getCities,
  );

  // ✅ nested
  app.get(
    `${BASE}/cities/:cityId/districts`,
    { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    getDistrictsByCityId,
  );

  app.get(
    `${BASE}/districts`,
    { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    getDistricts,
  );

}
