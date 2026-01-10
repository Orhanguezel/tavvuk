// =============================================================
// FILE: src/integrations/rtk/dashboard_admin.api.ts
// FINAL — Dashboard ADMIN RTK
// Base: /api/admin
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  DashboardRangeKey,
  DashboardAnalyticsDto,
  AdminDashboardAnalyticsQuery,
} from '@/integrations/types';

const BASE = '/admin/dashboard';

export const dashboardAdminApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /* ----------------------------- Analytics ----------------------------- */

    adminDashboardAnalytics: b.query<DashboardAnalyticsDto, AdminDashboardAnalyticsQuery | void>({
      query: (params) => {
        const sp = new URLSearchParams();

        // params: { range?: '7d'|'30d'|'90d' }
        Object.entries(params ?? {}).forEach(([k, v]) => {
          if (v !== undefined && v !== null) sp.set(k, String(v));
        });

        // default range client-side (opsiyonel)
        if (!sp.get('range')) sp.set('range', '30d' satisfies DashboardRangeKey);

        const qs = sp.toString();
        return {
          url: `${BASE}/analytics${qs ? `?${qs}` : ''}`,
          method: 'GET',
        };
      },
      providesTags: [{ type: 'DashboardAnalytics', id: 'ADMIN' }],
    }),
  }),
  overrideExisting: true,
});

export const { useAdminDashboardAnalyticsQuery } = dashboardAdminApi;
