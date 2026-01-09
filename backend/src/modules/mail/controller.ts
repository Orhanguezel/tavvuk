// ===================================================================
// FILE: src/modules/mail/controller.ts
// FINAL — Mail controller (raw + template)
// ===================================================================

import type { RouteHandler } from 'fastify';
import { sendMailRaw, sendOrderCreatedMail, sendTemplatedMailByKey } from './service';
import { sendMailSchema, sendTemplatedMailSchema, orderCreatedMailSchema } from './validation';

/**
 * req.user içinden email'i güvenli çek
 */
const getUserEmail = (req: any): string | undefined => {
  const u = req.user;
  if (!u || typeof u !== 'object') return undefined;
  if ('email' in u && (u as any).email != null) return String((u as any).email);
  return undefined;
};

/**
 * POST /mail/test
 * Body: { to?: string }
 */
export const sendTestMail: RouteHandler = async (req, reply) => {
  try {
    const body = (req.body ?? {}) as { to?: string };
    const to = body.to && body.to.length > 0 ? body.to : getUserEmail(req);

    if (!to) {
      return reply.code(400).send({ error: { message: 'to_required_for_test_mail' } });
    }

    await sendMailRaw({
      to,
      subject: 'SMTP Test – GZL Temizlik',
      text: 'Bu bir test mailidir. SMTP ayarlarınız başarılı görünüyor.',
      html: '<p>Bu bir <strong>test mailidir</strong>. SMTP ayarlarınız başarılı görünüyor.</p>',
    });

    return reply.send({ ok: true });
  } catch (e: any) {
    req.log.error(e);
    return reply.code(500).send({
      error: { message: 'mail_test_failed', details: e?.message },
    });
  }
};

/**
 * POST /mail/send
 * Body: { to, subject, text?, html? }
 */
export const sendMailHandler: RouteHandler = async (req, reply) => {
  try {
    const body = sendMailSchema.parse(req.body ?? {});
    await sendMailRaw(body);
    return reply.code(201).send({ ok: true });
  } catch (e: any) {
    if (e?.name === 'ZodError') {
      return reply.code(400).send({
        error: { message: 'validation_error', details: e.issues },
      });
    }
    req.log.error(e);
    return reply.code(500).send({
      error: { message: 'mail_send_failed', details: e?.message },
    });
  }
};

/**
 * POST /mail/template
 * Body: { to, key, params?, allowMissing? }
 */
export const sendTemplatedMailHandler: RouteHandler = async (req, reply) => {
  try {
    const body = sendTemplatedMailSchema.parse(req.body ?? {});
    const rendered = await sendTemplatedMailByKey(body);
    return reply.code(201).send({
      ok: true,
      template_key: rendered.template.template_key,
      missing_variables: rendered.missing_variables,
    });
  } catch (e: any) {
    if (e?.name === 'ZodError') {
      return reply.code(400).send({
        error: { message: 'validation_error', details: e.issues },
      });
    }
    req.log.error(e);
    return reply.code(500).send({
      error: { message: 'templated_mail_send_failed', details: e?.message },
    });
  }
};

/**
 * POST /mail/order-created
 * Body: OrderCreatedMailInput
 * Uses template key: "order_received"
 */
export const sendOrderCreatedMailHandler: RouteHandler = async (req, reply) => {
  try {
    const body = orderCreatedMailSchema.parse(req.body ?? {});
    const rendered = await sendOrderCreatedMail(body);

    return reply.code(201).send({
      ok: true,
      template_key: rendered.template.template_key,
      missing_variables: rendered.missing_variables,
    });
  } catch (e: any) {
    if (e?.name === 'ZodError') {
      return reply.code(400).send({
        error: { message: 'validation_error', details: e.issues },
      });
    }
    req.log.error(e);
    return reply.code(500).send({
      error: { message: 'order_created_mail_failed', details: e?.message },
    });
  }
};
