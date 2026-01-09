// ===================================================================
// FILE: src/modules/mail/service.ts
// FINAL — SMTP sender + templated mail integration (single language)
// - Exports: sendWelcomeMail, sendPasswordChangedMail (auth modülü için)
// - Template keys: "welcome" and "password_changed"
// ===================================================================

import nodemailer from 'nodemailer';
import type { Transporter } from 'nodemailer';

import {
  sendMailSchema,
  type SendMailInput,
  sendTemplatedMailSchema,
  type SendTemplatedMailInput,
  orderCreatedMailSchema,
  type OrderCreatedMailInput,

  // ✅ new
  welcomeMailSchema,
  type WelcomeMailInput,
  passwordChangedMailSchema,
  type PasswordChangedMailInput,
} from './validation';

import { getSmtpSettings, type SmtpSettings } from '@/modules/siteSettings/service';
import { sendTemplatedEmail } from '@/modules/email-templates/mailer';
import { enrichParamsWithSiteName } from '@/modules/_shared/email';

// Basit cache (aynı config için transporter'ı tekrar tekrar kurmamak için)
let cachedTransporter: Transporter | null = null;
let cachedSignature: string | null = null;

function buildSignature(cfg: SmtpSettings): string {
  return [
    cfg.host ?? '',
    String(cfg.port ?? ''),
    cfg.username ?? '',
    cfg.password ? 'pw:1' : 'pw:0',
    cfg.secure ? '1' : '0',
    cfg.fromEmail ?? '',
    cfg.fromName ?? '',
  ].join('|');
}

async function getTransporter(): Promise<Transporter> {
  const cfg = await getSmtpSettings();

  if (!cfg.host) {
    throw new Error('smtp_host_not_configured');
  }

  // Port fallback:
  // - secure=true => 465
  // - secure=false => 587
  const port = cfg.port ?? (cfg.secure ? 465 : 587);
  cfg.port = port;

  const signature = buildSignature(cfg);
  if (cachedTransporter && cachedSignature === signature) {
    return cachedTransporter;
  }

  const auth =
    cfg.username && cfg.password ? { user: cfg.username, pass: cfg.password } : undefined;

  if (process.env.NODE_ENV !== 'production') {
    // eslint-disable-next-line no-console
    console.log('[SMTP CFG]', {
      host: cfg.host,
      port: cfg.port,
      username: cfg.username,
      secure: cfg.secure,
      hasPassword: !!cfg.password,
      hasAuth: !!auth,
    });
  }

  const transporter = nodemailer.createTransport({
    host: cfg.host,
    port: cfg.port,
    secure: cfg.secure,
    auth,
  });

  cachedTransporter = transporter;
  cachedSignature = signature;
  return transporter;
}

/**
 * Low-level mail sender
 */
export async function sendMailRaw(input: SendMailInput) {
  const data = sendMailSchema.parse(input);
  const smtpCfg = await getSmtpSettings();

  const fromEmail = smtpCfg.fromEmail || smtpCfg.username;
  if (!fromEmail) {
    throw new Error('smtp_from_not_configured');
  }

  const from = smtpCfg.fromName ? `${smtpCfg.fromName} <${fromEmail}>` : fromEmail;

  const transporter = await getTransporter();

  const info = await transporter.sendMail({
    from,
    to: data.to,
    subject: data.subject,
    text: data.text,
    html: data.html,
  });

  return info;
}

/**
 * Backward-compatible alias
 */
export async function sendMail(input: SendMailInput) {
  return sendMailRaw(input);
}

/**
 * High-level: send email by template_key (email_templates)
 */
export async function sendTemplatedMailByKey(input: SendTemplatedMailInput) {
  const data = sendTemplatedMailSchema.parse(input);

  const params = await enrichParamsWithSiteName(data.params || {});

  const rendered = await sendTemplatedEmail({
    to: data.to,
    key: data.key,
    params,
    allowMissing: data.allowMissing ?? false,
  });

  return rendered;
}

/* ==================================================================
   ORDER CREATED MAIL (email_templates → "order_received")
   ================================================================== */

const ORDER_CREATED_TEMPLATE_KEY = 'order_received';

export async function sendOrderCreatedMail(input: OrderCreatedMailInput) {
  const data = orderCreatedMailSchema.parse(input);

  const statusLabelMap: Record<string, string> = {
    pending: 'Beklemede',
    processing: 'Hazırlanıyor',
    completed: 'Tamamlandı',
    cancelled: 'İptal Edildi',
    refunded: 'İade Edildi',
  };

  const status_label = statusLabelMap[data.status] ?? data.status;

  const baseParams: Record<string, unknown> = {
    customer_name: data.customer_name,
    order_number: data.order_number,
    final_amount: data.final_amount,
    status: data.status,
    status_label,
  };

  const params =
    data.site_name && data.site_name.trim().length > 0
      ? { ...baseParams, site_name: data.site_name.trim() }
      : await enrichParamsWithSiteName(baseParams);

  const rendered = await sendTemplatedEmail({
    to: data.to,
    key: ORDER_CREATED_TEMPLATE_KEY,
    params,
    allowMissing: false,
  });

  return rendered;
}

/* ==================================================================
   AUTH MAILS (email_templates)
   - welcome          → "welcome"
   - password_changed → "password_changed"
   ================================================================== */

const WELCOME_TEMPLATE_KEY = 'welcome';
const PASSWORD_CHANGED_TEMPLATE_KEY = 'password_changed';

/**
 * ✅ Auth: welcome email
 * Used by auth/controller.ts on signup
 */
export async function sendWelcomeMail(input: WelcomeMailInput) {
  const data = welcomeMailSchema.parse(input);

  const baseParams: Record<string, unknown> = {
    user_name: data.user_name,
    user_email: data.user_email,
  };

  const params =
    data.site_name && data.site_name.trim().length > 0
      ? { ...baseParams, site_name: data.site_name.trim() }
      : await enrichParamsWithSiteName(baseParams);

  return sendTemplatedEmail({
    to: data.to,
    key: WELCOME_TEMPLATE_KEY,
    params,
    allowMissing: false,
  });
}

/**
 * ✅ Auth: password changed email
 * Used by auth/controller.ts and auth/admin.controller.ts
 */
export async function sendPasswordChangedMail(input: PasswordChangedMailInput) {
  const data = passwordChangedMailSchema.parse(input);

  const baseParams: Record<string, unknown> = {
    user_name: data.user_name,
  };

  const params =
    data.site_name && data.site_name.trim().length > 0
      ? { ...baseParams, site_name: data.site_name.trim() }
      : await enrichParamsWithSiteName(baseParams);

  return sendTemplatedEmail({
    to: data.to,
    key: PASSWORD_CHANGED_TEMPLATE_KEY,
    params,
    allowMissing: false,
  });
}
