// ===================================================================
// FILE: src/modules/mail/router.ts
// FINAL — Mail routes (templated + raw)
// ===================================================================

import type { FastifyInstance } from 'fastify';
import { requireAuth } from '@/common/middleware/auth';
import {
  sendTestMail,
  sendMailHandler,
  sendTemplatedMailHandler,
  sendOrderCreatedMailHandler,
} from './controller';

const BASE = '/mail';

export async function registerMail(app: FastifyInstance) {
  app.post(`${BASE}/test`, { preHandler: [requireAuth] }, sendTestMail);

  // low-level raw send (admin/tavvuk use)
  app.post(`${BASE}/send`, { preHandler: [requireAuth] }, sendMailHandler);

  // high-level template send
  app.post(`${BASE}/template`, { preHandler: [requireAuth] }, sendTemplatedMailHandler);

  // business endpoint example
  app.post(`${BASE}/order-created`, { preHandler: [requireAuth] }, sendOrderCreatedMailHandler);
}
