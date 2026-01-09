// ===================================================================
// FILE: src/modules/notifications/validation.ts
// FINAL — Notifications Validation
// ===================================================================

import { z } from 'zod';
import type { NotificationType } from './schema';

const safeTrim = (v: unknown) => (typeof v === 'string' ? v.trim() : String(v ?? '').trim());

export const notificationCreateSchema = z.object({
  // Eğer admin başka kullanıcıya bildirim gönderecekse kullanılabilir.
  // Default: auth user
  user_id: z.string().uuid().optional(),

  title: z.string().trim().min(1).max(255).transform(safeTrim),
  message: z.string().trim().min(1).transform(safeTrim),

  // DB serbest string; biz sadece temel doğrulama yapıyoruz.
  type: z
    .string()
    .trim()
    .min(1)
    .max(50)
    .transform((v) => safeTrim(v) as NotificationType),
});

export const notificationUpdateSchema = z.object({
  // Şimdilik sadece okundu bilgisini güncelliyoruz
  is_read: z.boolean().optional(),
});

// Body boş olabilir. İleride filtre eklersen burada genişletirsin.
export const notificationMarkAllReadSchema = z.object({});

export type NotificationCreateInput = z.infer<typeof notificationCreateSchema>;
export type NotificationUpdateInput = z.infer<typeof notificationUpdateSchema>;
