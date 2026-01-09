// =============================================================
// FILE: src/integrations/rtk/assignments_public.api.ts
// FINAL — Assignments PUBLIC/DRIVER RTK
// Base prefix: /api
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  AssignmentDto,
  DriverAssignmentListQuery,
} from '@/integrations/types/assignments.types';

const BASE = '/assignments';

function cleanQuery(q?: DriverAssignmentListQuery) {
  const params: any = {};
  if (!q) return params;

  if (q.status) params.status = q.status;
  if (q.limit != null) params.limit = q.limit;
  if (q.offset != null) params.offset = q.offset;

  return params;
}

export const assignmentsPublicApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** GET /assignments -> AssignmentDto[] (driver self) */
    listMyAssignments: b.query<AssignmentDto[], DriverAssignmentListQuery | void>({
      query: (q) => ({
        url: BASE,
        method: 'GET',
        params: cleanQuery(q as any),
      }),
      transformResponse: (res: any): AssignmentDto[] => (Array.isArray(res) ? res : []),
      providesTags: (result) =>
        result?.length
          ? [
              ...result.map((a) => ({ type: 'Assignments' as const, id: a.id })),
              { type: 'Assignments' as const, id: 'MY_LIST' },
            ]
          : [{ type: 'Assignments' as const, id: 'MY_LIST' }],
    }),
  }),
  overrideExisting: true,
});

export const { useListMyAssignmentsQuery } = assignmentsPublicApi;
