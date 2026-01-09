// =============================================================
// FILE: src/modules/email-templates/service.ts
// FINAL — Single Language render service
// =============================================================

import { and, eq } from 'drizzle-orm';
import { db } from '@/db/client';
import { emailTemplates, type EmailTemplateRow } from './schema';
import { extractVariablesFromText, parseVariablesColumn, renderTextWithParams } from './utils';

export interface RenderedEmailTemplate {
  template: EmailTemplateRow;
  subject: string;
  html: string;
  required_variables: string[];
  missing_variables: string[];
}

/**
 * DB'den template'i (key) bulur, params ile render eder.
 * - is_active = 1 zorunlu
 */
export async function renderEmailTemplateByKey(
  key: string,
  params: Record<string, unknown> = {},
): Promise<RenderedEmailTemplate | null> {
  const rows = await db
    .select()
    .from(emailTemplates)
    .where(and(eq(emailTemplates.template_key, key), eq(emailTemplates.is_active, 1)))
    .limit(1);

  if (!rows.length) return null;

  const template = rows[0] as EmailTemplateRow;

  const subject = renderTextWithParams(template.subject ?? '', params);
  const html = renderTextWithParams(template.content ?? '', params);

  const required =
    parseVariablesColumn(template.variables as any) ??
    extractVariablesFromText(template.content ?? '');

  const missing = required.filter((k) => !(k in (params || {})));

  return {
    template,
    subject,
    html,
    required_variables: required,
    missing_variables: missing,
  };
}
