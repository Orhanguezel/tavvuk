// =============================================================
// FILE: src/integrations/rtk/assignments_admin.api.ts
// FINAL — Assignments ADMIN RTK
// Base prefix: /api
// Admin prefix: /admin
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  AssignmentDto,
  AdminAssignmentListQuery,
  AdminAssignmentCreateBody,
  AdminAssignmentPatchBody,
  AdminAssignmentCancelBody,
  AssignmentCreateResponse,
  AssignmentPatchResponse,
  OkResponse,
} from '@/integrations/types';

const ADMIN_BASE = '/admin/assignments';

function cleanQuery(q?: AdminAssignmentListQuery) {
  const params: any = {};
  if (!q) return params;

  if (q.q) params.q = q.q;
  if (q.status) params.status = q.status;

  if (q.order_id) params.order_id = q.order_id;
  if (q.driver_id) params.driver_id = q.driver_id;
  if (q.assigned_by) params.assigned_by = q.assigned_by;

  if (q.limit != null) params.limit = q.limit;
  if (q.offset != null) params.offset = q.offset;

  if (q.sort) params.sort = q.sort;
  if (q.order) params.order = q.order;

  if (q.include_cancelled != null) params.include_cancelled = q.include_cancelled as any;

  return params;
}

export const assignmentsAdminApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** GET /admin/assignments -> AssignmentDto[] */
    adminListAssignments: b.query<AssignmentDto[], AdminAssignmentListQuery | void>({
      query: (q) => ({
        url: ADMIN_BASE,
        method: 'GET',
        params: cleanQuery(q as any),
      }),
      transformResponse: (res: any): AssignmentDto[] => (Array.isArray(res) ? res : []),
      providesTags: (result) =>
        result?.length
          ? [
              ...result.map((a) => ({ type: 'AdminAssignments' as const, id: a.id })),
              { type: 'AdminAssignments' as const, id: 'LIST' },
            ]
          : [{ type: 'AdminAssignments' as const, id: 'LIST' }],
    }),

    /** GET /admin/assignments/:id -> AssignmentDto */
    adminGetAssignment: b.query<AssignmentDto | null, { id: string }>({
      query: ({ id }) => ({
        url: `${ADMIN_BASE}/${encodeURIComponent(id)}`,
        method: 'GET',
      }),
      transformResponse: (res: any): AssignmentDto | null => (res && res.id ? (res as any) : null),
      providesTags: (_r, _e, arg) => [{ type: 'AdminAssignments' as const, id: arg.id }],
    }),

    /** POST /admin/assignments -> { ok, assignment } */
    adminCreateAssignment: b.mutation<AssignmentCreateResponse, AdminAssignmentCreateBody>({
      query: (body) => ({
        url: ADMIN_BASE,
        method: 'POST',
        body,
      }),
      transformResponse: (res: any): AssignmentCreateResponse => ({
        ok: true,
        assignment: (res?.assignment ?? null) as any,
      }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminAssignments' as const, id: 'LIST' },
        { type: 'Assignments' as const, id: 'MY_LIST' }, // driver assignments list may change
        { type: 'Orders' as const, id: arg.order_id }, // order status assigned
        { type: 'AdminOrders' as const, id: 'LIST' }, // admin orders list changes
        { type: 'DriverOrders' as const, id: 'LIST' }, // driver orders list changes
      ],
    }),

    /** PATCH /admin/assignments/:id -> { ok, assignment } */
    adminPatchAssignment: b.mutation<
      AssignmentPatchResponse,
      { id: string; body: AdminAssignmentPatchBody }
    >({
      query: ({ id, body }) => ({
        url: `${ADMIN_BASE}/${encodeURIComponent(id)}`,
        method: 'PATCH',
        body,
      }),
      transformResponse: (res: any): AssignmentPatchResponse => ({
        ok: true,
        assignment: (res?.assignment ?? null) as any,
      }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminAssignments' as const, id: arg.id },
        { type: 'AdminAssignments' as const, id: 'LIST' },
        { type: 'Assignments' as const, id: 'MY_LIST' },
        { type: 'DriverOrders' as const, id: 'LIST' },
        { type: 'AdminOrders' as const, id: 'LIST' },
      ],
    }),

    /** POST /admin/assignments/:id/cancel -> { ok:true } */
    adminCancelAssignment: b.mutation<OkResponse, { id: string; body?: AdminAssignmentCancelBody }>(
      {
        query: ({ id, body }) => ({
          url: `${ADMIN_BASE}/${encodeURIComponent(id)}/cancel`,
          method: 'POST',
          body: body ?? {},
        }),
        transformResponse: (_res: any): OkResponse => ({ ok: true }),
        invalidatesTags: (_r, _e, arg) => [
          { type: 'AdminAssignments' as const, id: arg.id },
          { type: 'AdminAssignments' as const, id: 'LIST' },
          { type: 'Assignments' as const, id: 'MY_LIST' },
          { type: 'AdminOrders' as const, id: 'LIST' }, // order goes back to approved
          { type: 'DriverOrders' as const, id: 'LIST' },
        ],
      },
    ),
  }),
  overrideExisting: true,
});

export const {
  useAdminListAssignmentsQuery,
  useAdminGetAssignmentQuery,
  useAdminCreateAssignmentMutation,
  useAdminPatchAssignmentMutation,
  useAdminCancelAssignmentMutation,
} = assignmentsAdminApi;
