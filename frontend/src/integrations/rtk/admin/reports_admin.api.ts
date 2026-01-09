// =============================================================
// FILE: src/integrations/rtk/reports_admin.api.ts
// FINAL — Reports ADMIN RTK
// Base prefix: /api/admin (baseApi içinde varsayılır)
// Endpoints:
//   GET /reports/kpi
//   GET /reports/users/performance
//   GET /reports/locations
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';

import type {
  AdminKpiQuery,
  AdminUserPerformanceQuery,
  AdminLocationsQuery,
  KpiRow,
  UserPerformanceRow,
  LocationRow,
} from '@/integrations/types';

const BASE = '/admin/reports';

function buildQS(params: Record<string, any>) {
  const sp = new URLSearchParams();
  Object.entries(params ?? {}).forEach(([k, v]) => {
    if (v === undefined || v === null || v === '') return;
    sp.set(k, String(v));
  });
  const qs = sp.toString();
  return qs ? `?${qs}` : '';
}

export const reportsAdminApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** GET /admin/reports/kpi */
    adminReportsKpi: b.query<KpiRow[], AdminKpiQuery | void>({
      query: (params) => ({
        url: `${BASE}/kpi${buildQS(params as any)}`,
        method: 'GET',
      }),
      transformResponse: (res: unknown): KpiRow[] => (Array.isArray(res) ? (res as any) : []),
      providesTags: () => [{ type: 'ReportsKpi' as const, id: 'LIST' }],
    }),

    /** GET /admin/reports/users/performance */
    adminReportsUsersPerformance: b.query<UserPerformanceRow[], AdminUserPerformanceQuery>({
      query: (params) => ({
        url: `${BASE}/users/performance${buildQS(params as any)}`,
        method: 'GET',
      }),
      transformResponse: (res: unknown): UserPerformanceRow[] =>
        Array.isArray(res) ? (res as any) : [],
      providesTags: (_r, _e, arg) => [
        { type: 'ReportsUsersPerformance' as const, id: `${arg.role}` },
      ],
    }),

    /** GET /admin/reports/locations */
    adminReportsLocations: b.query<LocationRow[], AdminLocationsQuery | void>({
      query: (params) => ({
        url: `${BASE}/locations${buildQS(params as any)}`,
        method: 'GET',
      }),
      transformResponse: (res: unknown): LocationRow[] => (Array.isArray(res) ? (res as any) : []),
      providesTags: () => [{ type: 'ReportsLocations' as const, id: 'LIST' }],
    }),
  }),
  overrideExisting: true,
});

export const {
  useAdminReportsKpiQuery,
  useAdminReportsUsersPerformanceQuery,
  useAdminReportsLocationsQuery,
} = reportsAdminApi;
