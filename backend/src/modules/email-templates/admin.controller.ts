// =============================================================
// FILE: src/modules/email-templates/admin.controller.ts
// FINAL — Admin controller (Single Language, No i18n)
// =============================================================

import type { RouteHandler } from 'fastify';
import { randomUUID } from 'crypto';
import { and, desc, eq, like, or, type SQL } from 'drizzle-orm';
import { db } from '@/db/client';
import { emailTemplates, type EmailTemplateRow, type NewEmailTemplateRow } from './schema';
import {
  emailTemplateCreateSchema,
  emailTemplateUpdateSchema,
  listQuerySchema,
} from './validation';
import {
  extractVariablesFromText,
  parseVariablesColumn,
  toBool,
  now,
  normalizeVariablesInput,
} from './utils';
import { ZodError } from 'zod';
import { mapTemplateRowPublic } from '@/modules/_shared/email';

// and(...) için: filter yoksa undefined döndürelim
function buildWhere(filters: SQL[]): SQL | undefined {
  return filters.length ? (and(...filters) as SQL) : undefined;
}

/** GET /admin/email_templates */
export const listEmailTemplatesAdmin: RouteHandler = async (req, reply) => {
  try {
    const parsed = listQuerySchema.safeParse((req as any).query);
    const qdata = parsed.success ? parsed.data : {};

    const filters: SQL[] = [];

    if (qdata.q && qdata.q.trim()) {
      const likeQ = `%${qdata.q.trim()}%`;
      const search = or(
        like(emailTemplates.template_key, likeQ),
        like(emailTemplates.template_name, likeQ),
        like(emailTemplates.subject, likeQ),
      );
      if (search) filters.push(search as SQL);
    }

    if (typeof qdata.is_active !== 'undefined') {
      filters.push(eq(emailTemplates.is_active, toBool(qdata.is_active) ? 1 : 0) as SQL);
    }

    const where = buildWhere(filters);

    const base = db.select().from(emailTemplates).orderBy(desc(emailTemplates.updated_at));

    const rows = where ? await base.where(where) : await base;

    // Admin çıktısı: public mapper + extra debug fields (detected_variables)
    const out = rows.map((r) => ({
      ...mapTemplateRowPublic(r),
      detected_variables: r.content ? extractVariablesFromText(r.content) : [],
      variables_raw: r.variables ?? null,
    }));

    return reply.send(out);
  } catch (e) {
    (req as any).log?.error?.(e);
    return reply.code(500).send({ error: { message: 'email_templates_list_failed' } });
  }
};

/** GET /admin/email_templates/:id */
export const getEmailTemplateAdmin: RouteHandler = async (req, reply) => {
  try {
    const { id } = (req.params as { id?: string }) ?? {};
    if (!id) return reply.code(400).send({ error: { message: 'invalid_id' } });

    const [row] = await db.select().from(emailTemplates).where(eq(emailTemplates.id, id)).limit(1);

    if (!row) return reply.code(404).send({ error: { message: 'not_found' } });

    return reply.send({
      id: row.id,
      template_key: row.template_key,
      template_name: row.template_name,
      subject: row.subject,
      content: row.content,
      variables: parseVariablesColumn(row.variables),
      variables_raw: row.variables ?? null,
      detected_variables: row.content ? extractVariablesFromText(row.content) : [],
      is_active: toBool(row.is_active),
      created_at: row.created_at,
      updated_at: row.updated_at,
    });
  } catch (e) {
    (req as any).log?.error?.(e);
    return reply.code(500).send({ error: { message: 'email_template_get_failed' } });
  }
};

/** POST /admin/email_templates */
export const createEmailTemplateAdmin: RouteHandler = async (req, reply) => {
  try {
    const input = emailTemplateCreateSchema.parse(req.body ?? {});
    const id = randomUUID();
    const d = now();

    const row: NewEmailTemplateRow = {
      id,
      template_key: input.template_key,
      template_name: input.template_name,
      subject: input.subject,
      content: input.content,
      variables: normalizeVariablesInput(input.variables),
      is_active: typeof input.is_active === 'undefined' ? 1 : toBool(input.is_active) ? 1 : 0,
      created_at: d,
      updated_at: d,
    };

    await db.insert(emailTemplates).values(row);

    const [created] = await db
      .select()
      .from(emailTemplates)
      .where(eq(emailTemplates.id, id))
      .limit(1);

    return reply.code(201).send(mapTemplateRowPublic(created));
  } catch (e: any) {
    const msg = String(e?.message || '');
    if (msg.includes('ux_email_tpl_key')) {
      return reply.code(409).send({ error: { message: 'key_exists' } });
    }
    if (e instanceof ZodError) {
      return reply.code(400).send({ error: { message: 'validation_error', details: e.issues } });
    }
    (req as any).log?.error?.(e);
    return reply.code(500).send({ error: { message: 'email_template_create_failed' } });
  }
};

/** PATCH /admin/email_templates/:id */
export const updateEmailTemplateAdmin: RouteHandler = async (req, reply) => {
  try {
    const { id } = (req.params as { id?: string }) ?? {};
    if (!id) return reply.code(400).send({ error: { message: 'invalid_id' } });

    const patch = emailTemplateUpdateSchema.parse(req.body ?? {});

    const [existing] = await db
      .select()
      .from(emailTemplates)
      .where(eq(emailTemplates.id, id))
      .limit(1);

    if (!existing) return reply.code(404).send({ error: { message: 'not_found' } });

    const updateData: Partial<EmailTemplateRow> = { updated_at: now() };

    if (typeof patch.template_key !== 'undefined') updateData.template_key = patch.template_key;
    if (typeof patch.template_name !== 'undefined') updateData.template_name = patch.template_name;
    if (typeof patch.subject !== 'undefined') updateData.subject = patch.subject;
    if (typeof patch.content !== 'undefined') updateData.content = patch.content;
    if (typeof patch.variables !== 'undefined')
      updateData.variables = normalizeVariablesInput(patch.variables);
    if (typeof patch.is_active !== 'undefined')
      updateData.is_active = toBool(patch.is_active) ? 1 : 0;

    await db.update(emailTemplates).set(updateData).where(eq(emailTemplates.id, id));

    const [updated] = await db
      .select()
      .from(emailTemplates)
      .where(eq(emailTemplates.id, id))
      .limit(1);

    return reply.send(mapTemplateRowPublic(updated));
  } catch (e: any) {
    const msg = String(e?.message || '');
    if (msg.includes('ux_email_tpl_key')) {
      return reply.code(409).send({ error: { message: 'key_exists' } });
    }
    if (e instanceof ZodError) {
      return reply.code(400).send({ error: { message: 'validation_error', details: e.issues } });
    }
    (req as any).log?.error?.(e);
    return reply.code(500).send({ error: { message: 'email_template_update_failed' } });
  }
};

/** DELETE /admin/email_templates/:id */
export const deleteEmailTemplateAdmin: RouteHandler = async (req, reply) => {
  try {
    const { id } = (req.params as { id?: string }) ?? {};
    if (!id) return reply.code(400).send({ error: { message: 'invalid_id' } });

    await db.delete(emailTemplates).where(eq(emailTemplates.id, id));
    return reply.code(204).send();
  } catch (e) {
    (req as any).log?.error?.(e);
    return reply.code(500).send({ error: { message: 'email_template_delete_failed' } });
  }
};
