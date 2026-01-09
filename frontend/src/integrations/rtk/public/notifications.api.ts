// ===================================================================
// FILE: src/integrations/rtk/notifications.api.ts
// FINAL — Notifications RTK (Public, auth required)
// Base: /api/notifications
// ===================================================================

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  NotificationDto,
  NotificationsListQuery,
  NotificationsUnreadCountDto,
  NotificationCreateBody,
  NotificationPatchBody,
  NotificationOkDto,
} from '@/integrations/types';

const BASE = '/notifications';

function toSearchParams(params?: Record<string, unknown>) {
  const sp = new URLSearchParams();
  Object.entries(params ?? {}).forEach(([k, v]) => {
    if (v === undefined || v === null) return;
    const s = String(v).trim();
    if (!s) return;
    sp.set(k, s);
  });
  const qs = sp.toString();
  return qs ? `?${qs}` : '';
}

export const notificationsApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /* ----------------------------- list ----------------------------- */

    listNotifications: b.query<NotificationDto[], NotificationsListQuery | void>({
      query: (params) => ({
        url: `${BASE}${toSearchParams(params as any)}`,
        method: 'GET',
      }),
      providesTags: (res) => [
        { type: 'Notifications', id: 'LIST' },
        { type: 'Notifications', id: 'UNREAD' },
        ...(Array.isArray(res)
          ? res.map((n) => ({ type: 'Notifications' as const, id: n.id }))
          : []),
      ],
    }),

    /* ----------------------------- unread count ----------------------------- */

    getUnreadNotificationCount: b.query<NotificationsUnreadCountDto, void>({
      query: () => ({
        url: `${BASE}/unread-count`,
        method: 'GET',
      }),
      providesTags: [{ type: 'Notifications', id: 'UNREAD' }],
    }),

    /* ----------------------------- create ----------------------------- */

    createNotification: b.mutation<NotificationDto, NotificationCreateBody>({
      query: (body) => ({
        url: `${BASE}`,
        method: 'POST',
        body,
      }),
      invalidatesTags: [
        { type: 'Notifications', id: 'LIST' },
        { type: 'Notifications', id: 'UNREAD' },
      ],
    }),

    /* ----------------------------- patch (mark read/unread) ----------------------------- */

    patchNotification: b.mutation<NotificationDto, { id: string; body: NotificationPatchBody }>({
      query: ({ id, body }) => ({
        url: `${BASE}/${encodeURIComponent(id)}`,
        method: 'PATCH',
        body,
      }),
      invalidatesTags: (_r, _e, a) => [
        { type: 'Notifications', id: a.id },
        { type: 'Notifications', id: 'LIST' },
        { type: 'Notifications', id: 'UNREAD' },
      ],
    }),

    /* ----------------------------- mark all read ----------------------------- */

    markAllNotificationsRead: b.mutation<NotificationOkDto, void>({
      query: () => ({
        url: `${BASE}/mark-all-read`,
        method: 'POST',
        body: {}, // backend empty object accepted
      }),
      invalidatesTags: [
        { type: 'Notifications', id: 'LIST' },
        { type: 'Notifications', id: 'UNREAD' },
      ],
    }),

    /* ----------------------------- delete ----------------------------- */

    deleteNotification: b.mutation<NotificationOkDto, { id: string }>({
      query: ({ id }) => ({
        url: `${BASE}/${encodeURIComponent(id)}`,
        method: 'DELETE',
      }),
      invalidatesTags: (_r, _e, a) => [
        { type: 'Notifications', id: a.id },
        { type: 'Notifications', id: 'LIST' },
        { type: 'Notifications', id: 'UNREAD' },
      ],
    }),
  }),
  overrideExisting: true,
});

export const {
  useListNotificationsQuery,
  useGetUnreadNotificationCountQuery,
  useCreateNotificationMutation,
  usePatchNotificationMutation,
  useMarkAllNotificationsReadMutation,
  useDeleteNotificationMutation,
} = notificationsApi;
