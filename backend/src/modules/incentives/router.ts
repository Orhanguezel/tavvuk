// =============================================================
// FILE: src/modules/incentives/router.ts
// FINAL — Incentives public routes
// =============================================================

import type { FastifyInstance } from 'fastify';
import { getMySummary } from './controller';

export async function registerIncentives(app: FastifyInstance) {
  const BASE = '/incentives';

  app.get(
    `${BASE}/my-summary`,
    { config: { rateLimit: { max: 60, timeWindow: '1 minute' } } },
    getMySummary,
  );
}
