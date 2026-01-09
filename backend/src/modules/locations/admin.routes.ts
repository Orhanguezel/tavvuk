// =============================================================
// FILE: src/modules/locations/admin.routes.ts
// FINAL — Locations admin routes (import)
// =============================================================
import type { FastifyInstance } from 'fastify';
import { requireAuth } from '@/common/middleware/auth';
import { requireAdmin } from '@/common/middleware/roles';
import { importLocations } from './admin.controller';

export async function registerLocationsAdmin(app: FastifyInstance) {
  const BASE = '/locations';

  // Admin: one-time import (or occasional updates)
  app.post(
    `${BASE}/import`,
    {
      preHandler: [requireAuth, requireAdmin],
      config: { rateLimit: { max: 10, timeWindow: '1 minute' } },
    },
    importLocations,
  );
}
