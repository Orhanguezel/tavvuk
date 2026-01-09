// ===================================================================
// FILE: src/integrations/types/notifications.types.ts
// FINAL — Notifications types (DTO + Query + Payloads)
// Backend: src/modules/notifications/*
// ===================================================================

import { BoolLike} from '@/integrations/types';

export type NotificationType =
  | 'order_created'
  | 'order_paid'
  | 'order_failed'
  | 'booking_created'
  | 'booking_status_changed'
  | 'system'
  | 'custom'
  | (string & {});

export interface NotificationDto {
  id: string;
  user_id: string;

  title: string;
  message: string;

  type: NotificationType;

  is_read: 0 | 1;

  created_at: string; // ISO
}

export interface NotificationsListQuery {
  is_read?: BoolLike;
  type?: string;
  limit?: number | string;
  offset?: number | string;
}

export interface NotificationsUnreadCountDto {
  count: number;
}

export interface NotificationCreateBody {
  // optional: admin başka kullanıcıya gönderebilir (backend: optional)
  user_id?: string;

  title: string;
  message: string;
  type: NotificationType | string;
}

export interface NotificationPatchBody {
  is_read?: boolean;
}

export interface NotificationOkDto {
  ok: true;
}
