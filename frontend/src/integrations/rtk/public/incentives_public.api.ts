// =============================================================
// FILE: src/integrations/rtk/incentives.api.ts
// FINAL — Incentives PUBLIC RTK
// Base: /api/incentives
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';
import type { IncentiveSummaryRow, MySummaryQuery } from '@/integrations/types';

const BASE = '/incentives';

export const incentivesApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    myIncentiveSummary: b.query<IncentiveSummaryRow[], MySummaryQuery | void>({
      query: (params) => {
        const sp = new URLSearchParams();
        Object.entries(params ?? {}).forEach(([k, v]) => {
          if (v !== undefined && v !== null) sp.set(k, String(v));
        });
        const qs = sp.toString();
        return {
          url: `${BASE}/my-summary${qs ? `?${qs}` : ''}`,
          method: 'GET',
        };
      },
      providesTags: [{ type: 'MyIncentives', id: 'SUMMARY' }],
    }),
  }),
  overrideExisting: true,
});

export const { useMyIncentiveSummaryQuery } = incentivesApi;
