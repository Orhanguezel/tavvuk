// =============================================================
// FILE: src/modules/email-templates/controller.ts
// FINAL — Public endpoints (Single Language)
// =============================================================

import type { FastifyReply, FastifyRequest } from 'fastify';
import { and, desc, eq, like, or, type SQL } from 'drizzle-orm';
import { db } from '@/db/client';
import { emailTemplates } from './schema';
import {
  renderTextWithParams,
  toBool,
  extractVariablesFromText,
  parseVariablesColumn,
} from './utils';
import { renderByKeySchema } from './validation';
import { enrichParamsWithSiteName, mapTemplateRowPublic } from '@/modules/_shared/email';

type ListQuery = {
  is_active?: string | number | boolean;
  q?: string;
};

export async function listEmailTemplatesPublic(
  req: FastifyRequest<{ Querystring: ListQuery }>,
  reply: FastifyReply,
) {
  try {
    const { is_active, q } = req.query || {};

    const filters: SQL[] = [];

    // default: sadece aktifler
    if (typeof is_active !== 'undefined') {
      filters.push(eq(emailTemplates.is_active, toBool(is_active) ? 1 : 0));
    } else {
      filters.push(eq(emailTemplates.is_active, 1));
    }

    if (q && q.trim().length > 0) {
      const qq = `%${q.trim()}%`;
      const search = or(
        like(emailTemplates.template_key, qq),
        like(emailTemplates.template_name, qq),
        like(emailTemplates.subject, qq),
      );
      if (search) filters.push(search);
    }

    const where = filters.length ? and(...filters) : undefined;

    const base = db.select().from(emailTemplates).orderBy(desc(emailTemplates.updated_at));

    const rows = where ? await base.where(where) : await base;
    return reply.send(rows.map(mapTemplateRowPublic));
  } catch (e) {
    req.log.error(e);
    return reply.code(500).send({ error: { message: 'email_templates_list_failed' } });
  }
}

export async function getEmailTemplateByKeyPublic(
  req: FastifyRequest<{ Params: { key: string } }>,
  reply: FastifyReply,
) {
  try {
    const { key } = req.params;

    const rows = await db
      .select()
      .from(emailTemplates)
      .where(and(eq(emailTemplates.template_key, key), eq(emailTemplates.is_active, 1)))
      .limit(1);

    if (!rows.length) {
      return reply.code(404).send({ error: { message: 'not_found' } });
    }

    return reply.send(mapTemplateRowPublic(rows[0]));
  } catch (e) {
    req.log.error(e);
    return reply.code(500).send({ error: { message: 'email_template_get_failed' } });
  }
}

export async function renderTemplateByKeyPublic(
  req: FastifyRequest<{
    Params: { key: string };
    Body: { params?: Record<string, unknown> };
  }>,
  reply: FastifyReply,
) {
  try {
    const parsed = renderByKeySchema.parse({
      key: req.params.key,
      params: req.body?.params ?? {},
    });

    const params = await enrichParamsWithSiteName(parsed.params || {});

    const rows = await db
      .select()
      .from(emailTemplates)
      .where(and(eq(emailTemplates.template_key, parsed.key), eq(emailTemplates.is_active, 1)))
      .limit(1);

    if (!rows.length) {
      return reply.code(404).send({ error: { message: 'not_found' } });
    }

    const tpl = rows[0];

    const subject = renderTextWithParams(tpl.subject ?? '', params);
    const body = renderTextWithParams(tpl.content ?? '', params);

    const required =
      parseVariablesColumn(tpl.variables) ??
      (tpl.content ? extractVariablesFromText(tpl.content) : []);

    const missing = required.filter((k) => !(k in (params || {})));

    return reply.send({
      id: tpl.id,
      key: tpl.template_key,
      name: tpl.template_name,
      subject,
      body,
      required_variables: required,
      missing_variables: missing,
      updated_at: tpl.updated_at,
    });
  } catch (e: any) {
    if (e?.name === 'ZodError') {
      return reply.code(400).send({
        error: { message: 'validation_error', details: e.issues },
      });
    }
    req.log.error(e);
    return reply.code(500).send({ error: { message: 'email_template_render_failed' } });
  }
}
