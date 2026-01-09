// ===================================================================
// FILE: src/modules/mail/validation.ts
// FINAL — Mail validation (single language templates)
// ===================================================================

import { z } from 'zod';

/**
 * Low-level send
 */
export const sendMailSchema = z
  .object({
    to: z.string().email(),
    subject: z.string().min(1).max(255),
    text: z.string().optional(),
    html: z.string().optional(),
  })
  .superRefine((v, ctx) => {
    const hasText = typeof v.text === 'string' && v.text.trim().length > 0;
    const hasHtml = typeof v.html === 'string' && v.html.trim().length > 0;
    if (!hasText && !hasHtml) {
      ctx.addIssue({
        code: z.ZodIssueCode.custom,
        path: ['text'],
        message: 'either text or html is required',
      });
    }
  });

export type SendMailInput = z.infer<typeof sendMailSchema>;

/**
 * Templated send (email_templates)
 */
export const sendTemplatedMailSchema = z.object({
  to: z.string().email(),
  key: z.string().trim().min(1).max(100), // template_key
  params: z.record(z.unknown()).optional().default({}),
  allowMissing: z.coerce.boolean().optional(),
});

export type SendTemplatedMailInput = z.infer<typeof sendTemplatedMailSchema>;

/**
 * Order created payload
 * NOTE: single language → no locale
 * Will map to template key: "order_received" (or your chosen key)
 */
export const orderCreatedMailSchema = z.object({
  to: z.string().email(),
  customer_name: z.string().min(1),
  order_number: z.string().min(1),
  final_amount: z.string().min(1), // "199.90"
  status: z.string().min(1), // "pending" | ...
  site_name: z.string().min(1).optional(),
});

export type OrderCreatedMailInput = z.infer<typeof orderCreatedMailSchema>;

export const welcomeMailSchema = z.object({
  to: z.string().trim().email(),
  user_name: z.string().trim().min(1),
  user_email: z.string().trim().email(),
  site_name: z.string().trim().optional(),
});
export type WelcomeMailInput = z.infer<typeof welcomeMailSchema>;

export const passwordChangedMailSchema = z.object({
  to: z.string().trim().email(),
  user_name: z.string().trim().min(1),
  site_name: z.string().trim().optional(),
});
export type PasswordChangedMailInput = z.infer<typeof passwordChangedMailSchema>;
