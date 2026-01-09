// =============================================================
// FILE: src/modules/email-templates/mailer.ts
// FINAL — Single Language templated mail sender
// =============================================================

import { renderEmailTemplateByKey } from './service';
import { sendMail } from '@/modules/mail/service';

export interface SendTemplatedEmailOptions {
  to: string;
  key: string; // template_key
  params?: Record<string, unknown>;
  /**
   * true ise missing_variables olsa bile mail gönderilir.
   * false ise (default) eksik variable varsa error fırlatılır.
   */
  allowMissing?: boolean;
}

export async function sendTemplatedEmail(opts: SendTemplatedEmailOptions) {
  const { key, to, params = {}, allowMissing = false } = opts;

  const rendered = await renderEmailTemplateByKey(key, params);

  if (!rendered) {
    throw new Error(`email_template_not_found:${key}`);
  }

  if (!allowMissing && rendered.missing_variables.length > 0) {
    throw new Error(`email_template_missing_params:${key}:${rendered.missing_variables.join(',')}`);
  }

  await sendMail({
    to,
    subject: rendered.subject,
    html: rendered.html,
  });

  return rendered;
}
