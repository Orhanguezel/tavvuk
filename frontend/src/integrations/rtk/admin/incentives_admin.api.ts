// =============================================================
// FILE: src/integrations/rtk/incentives_admin.api.ts
// FINAL — Incentives ADMIN RTK
// Base: /api/admin
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  IncentivePlanDto,
  IncentiveRuleDto,
  IncentiveLedgerDto,
  IncentiveSummaryRow,
  AdminPlanListQuery,
  AdminPlanCreateBody,
  AdminPlanPatchBody,
  AdminReplaceRulesBody,
  AdminLedgerListQuery,
  AdminSummaryQuery,
} from '@/integrations/types';

const BASE = '/admin/incentives';

export const incentivesAdminApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /* ----------------------------- Plans ----------------------------- */

    adminListIncentivePlans: b.query<IncentivePlanDto[], AdminPlanListQuery | void>({
      query: (params) => {
        const sp = new URLSearchParams();
        Object.entries(params ?? {}).forEach(([k, v]) => {
          if (v !== undefined && v !== null) sp.set(k, String(v));
        });
        const qs = sp.toString();
        return {
          url: `${BASE}/plans${qs ? `?${qs}` : ''}`,
          method: 'GET',
        };
      },
      providesTags: [{ type: 'IncentivePlans', id: 'LIST' }],
    }),

    adminCreateIncentivePlan: b.mutation<IncentivePlanDto, AdminPlanCreateBody>({
      query: (body) => ({
        url: `${BASE}/plans`,
        method: 'POST',
        body,
      }),
      invalidatesTags: [{ type: 'IncentivePlans', id: 'LIST' }],
    }),

    adminPatchIncentivePlan: b.mutation<IncentivePlanDto, AdminPlanPatchBody>({
      query: ({ id, ...patch }) => ({
        url: `${BASE}/plans/${encodeURIComponent(id)}`,
        method: 'PATCH',
        body: patch,
      }),
      invalidatesTags: [{ type: 'IncentivePlans', id: 'LIST' }],
    }),

    /* ----------------------------- Rules ----------------------------- */

    adminGetIncentiveRules: b.query<IncentiveRuleDto[], { planId: string }>({
      query: ({ planId }) => ({
        url: `${BASE}/plans/${encodeURIComponent(planId)}/rules`,
        method: 'GET',
      }),
      providesTags: (_r, _e, a) => [{ type: 'IncentiveRules', id: a.planId }],
    }),

    adminReplaceIncentiveRules: b.mutation<
      { ok: true },
      { planId: string; body: AdminReplaceRulesBody }
    >({
      query: ({ planId, body }) => ({
        url: `${BASE}/plans/${encodeURIComponent(planId)}/rules`,
        method: 'PUT',
        body,
      }),
      invalidatesTags: (_r, _e, a) => [{ type: 'IncentiveRules', id: a.planId }],
    }),

    /* ----------------------------- Ledger ----------------------------- */

    adminListIncentiveLedger: b.query<IncentiveLedgerDto[], AdminLedgerListQuery | void>({
      query: (params) => {
        const sp = new URLSearchParams();
        Object.entries(params ?? {}).forEach(([k, v]) => {
          if (v !== undefined && v !== null) sp.set(k, String(v));
        });
        const qs = sp.toString();
        return {
          url: `${BASE}/ledger${qs ? `?${qs}` : ''}`,
          method: 'GET',
        };
      },
      providesTags: [{ type: 'IncentiveLedger', id: 'LIST' }],
    }),

    /* ----------------------------- Summary ----------------------------- */

    adminIncentiveSummary: b.query<IncentiveSummaryRow[], AdminSummaryQuery | void>({
      query: (params) => {
        const sp = new URLSearchParams();
        Object.entries(params ?? {}).forEach(([k, v]) => {
          if (v !== undefined && v !== null) sp.set(k, String(v));
        });
        const qs = sp.toString();
        return {
          url: `${BASE}/summary${qs ? `?${qs}` : ''}`,
          method: 'GET',
        };
      },
    }),
  }),
  overrideExisting: true,
});

export const {
  useAdminListIncentivePlansQuery,
  useAdminCreateIncentivePlanMutation,
  useAdminPatchIncentivePlanMutation,
  useAdminGetIncentiveRulesQuery,
  useAdminReplaceIncentiveRulesMutation,
  useAdminListIncentiveLedgerQuery,
  useAdminIncentiveSummaryQuery,
} = incentivesAdminApi;
