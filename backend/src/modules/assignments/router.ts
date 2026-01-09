// =============================================================
// FILE: src/modules/assignments/router.ts
// FINAL — Assignments public/driver routes
// Prefix: createApp() içinde /api ile register edilecek
// =============================================================

import type { FastifyInstance } from 'fastify';
import { listMyAssignments } from './controller';

export async function registerAssignments(app: FastifyInstance) {
  const BASE = '/assignments';

  // Driver convenience: my assignments
  app.get(
    `${BASE}`,
    { config: { rateLimit: { max: 120, timeWindow: '1 minute' } } },
    listMyAssignments,
  );
}
