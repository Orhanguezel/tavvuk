'use client';

// =============================================================
// FILE: src/app/(main)/admin/_components/admin-dashboard-client.tsx
// FINAL — Admin Dashboard Client (DEFAULT-like layout)
// - SectionCards + ChartAreaInteractive + DataTable (modular)
// =============================================================

import * as React from 'react';
import { toast } from 'sonner';

import { useAdminDashboardAnalyticsQuery } from '@/integrations/rtk/hooks';
import type { DashboardRangeKey } from '@/integrations/types';

import { DashboardSectionCards } from './dashboard-section-cards';
import { DashboardChartAreaInteractive } from './dashboard-chart-area-interactive';
import { DashboardDataTable } from './dashboard-data-table';

function getErrMessage(err: unknown): string {
  const anyErr = err as any;
  const m1 = anyErr?.data?.error?.message;
  if (typeof m1 === 'string' && m1.trim()) return m1;
  const m2 = anyErr?.data?.message;
  if (typeof m2 === 'string' && m2.trim()) return m2;
  const m3 = anyErr?.error;
  if (typeof m3 === 'string' && m3.trim()) return m3;
  return 'Veri yüklenemedi. Lütfen tekrar deneyin.';
}

export default function AdminDashboardClient() {
  // Default dashboard’daki gibi 90d/30d/7d timeRange UX’ini chart component içinde yöneteceğiz.
  // RTK range paramı: 7d | 30d | 90d
  const [range, setRange] = React.useState<DashboardRangeKey>('90d');

  const q = useAdminDashboardAnalyticsQuery({ range });

  React.useEffect(() => {
    if (!q.isError) return;
    toast.error(getErrMessage(q.error));
  }, [q.isError, q.error]);

  return (
    <div className="@container/main flex flex-col gap-4 md:gap-6">
      <DashboardSectionCards
        range={range}
        setRange={setRange}
        data={q.data}
        loading={q.isFetching && !q.data}
        onRefresh={() => q.refetch()}
      />

      <DashboardChartAreaInteractive
        range={range}
        setRange={setRange}
        data={q.data}
        loading={q.isFetching && !q.data}
      />

      <DashboardDataTable data={q.data} loading={q.isFetching && !q.data} />
    </div>
  );
}
