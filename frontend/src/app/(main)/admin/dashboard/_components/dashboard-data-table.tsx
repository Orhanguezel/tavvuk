'use client';

// =============================================================
// FILE: src/app/(main)/admin/_components/dashboard-data-table.tsx
// FINAL — Dashboard DataTable (TR)
// - <lg (mobile+tablet): DataTable yerine kart liste (overflow yok)
// - >=lg: DataTable (kontrollü overflow-x)
// - Kartlarda id gösterilmez, telefon gösterilir
// - Tabs: Genel / Şoförler / Satıcılar
// =============================================================

import * as React from 'react';
import { Plus } from 'lucide-react';

import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

import { useDataTableInstance } from '@/hooks/use-data-table-instance';

import { DataTable as DataTableNew } from '@/components/data-table/data-table';
import { DataTablePagination } from '@/components/data-table/data-table-pagination';
import { DataTableViewOptions } from '@/components/data-table/data-table-view-options';
import { withDndColumn } from '@/components/data-table/table-utils';

import { dashboardTableColumns } from './dashboard-data-table.columns';
import { DashboardCellViewer } from './dashboard-data-table.viewer';
import type { TrendRow } from './dashboard-data-table.viewer';

type DashboardAnalyticsDto = any;

export type Row = {
  id: string;
  header: string;
  type: 'Driver' | 'Seller';

  // telefon (backend DTO’dan gelmeli)
  phone?: string;

  // table display (formatlı)
  target: string; // adet
  limit: string; // sipariş
  reviewer: string; // prim

  // viewer için gerçek sayılar
  orders_n: number;
  units_n: number;
  incentives_n: number;

  // viewer için gerçek trend
  trend: TrendRow[];
};

function fmtInt(n: number): string {
  if (!Number.isFinite(n)) return '0';
  return new Intl.NumberFormat('tr-TR').format(Math.round(n));
}

function fmtMoneyTry(n: number): string {
  if (!Number.isFinite(n)) return '₺0';
  return new Intl.NumberFormat('tr-TR', {
    style: 'currency',
    currency: 'TRY',
    maximumFractionDigits: 2,
  }).format(n);
}

function safePhone(v: unknown): string {
  const s = String(v ?? '').trim();
  return s ? s : '—';
}

function typeLabel(v: Row['type']): string {
  return v === 'Driver' ? 'Şoför' : 'Satıcı';
}

function buildRows(data: DashboardAnalyticsDto | undefined): Row[] {
  const drivers = Array.isArray(data?.drivers) ? (data!.drivers as any[]) : [];
  const sellers = Array.isArray(data?.sellers) ? (data!.sellers as any[]) : [];
  const trend = Array.isArray(data?.trend) ? (data!.trend as any[]) : [];

  const dRows: Row[] = drivers.map((d) => {
    const ordersN = Number(d.delivered_orders ?? 0);
    const unitsN = Number(d.units_delivered ?? 0);
    const incN = Number(d.incentives ?? 0);

    return {
      id: `driver:${String(d.driver_id ?? '')}`,
      header: String(d.driver_name ?? '—'),
      type: 'Driver',
      phone: safePhone(d.driver_phone ?? d.phone ?? d.driver?.phone),
      target: fmtInt(unitsN),
      limit: fmtInt(ordersN),
      reviewer: fmtMoneyTry(incN),
      orders_n: ordersN,
      units_n: unitsN,
      incentives_n: incN,
      trend,
    };
  });

  const sRows: Row[] = sellers.map((s) => {
    const ordersN = Number(s.delivered_orders ?? 0);
    const unitsN = Number(s.units_delivered ?? 0);
    const incN = Number(s.incentives ?? 0);

    return {
      id: `seller:${String(s.seller_id ?? '')}`,
      header: String(s.seller_name ?? '—'),
      type: 'Seller',
      phone: safePhone(s.seller_phone ?? s.phone ?? s.seller?.phone),
      target: fmtInt(unitsN),
      limit: fmtInt(ordersN),
      reviewer: fmtMoneyTry(incN),
      orders_n: ordersN,
      units_n: unitsN,
      incentives_n: incN,
      trend,
    };
  });

  return [...dRows, ...sRows];
}

function filterByTab(rows: Row[], tab: string): Row[] {
  if (tab === 'drivers') return rows.filter((r) => r.type === 'Driver');
  if (tab === 'sellers') return rows.filter((r) => r.type === 'Seller');
  return rows;
}

/** <lg kart listesi: taşma yok, kompakt */
function MobileCardList(props: { table: any; loading: boolean }) {
  const rows = props.table.getRowModel().rows as Array<{ original: Row; id: string }>;

  if (props.loading && rows.length === 0) {
    return (
      <div className="grid gap-3">
        <div className="rounded-lg border p-4 text-sm text-muted-foreground">Yükleniyor…</div>
        <div className="rounded-lg border p-4 text-sm text-muted-foreground">Yükleniyor…</div>
        <div className="rounded-lg border p-4 text-sm text-muted-foreground">Yükleniyor…</div>
      </div>
    );
  }

  if (rows.length === 0) {
    return (
      <div className="rounded-lg border p-4 text-sm text-muted-foreground">Kayıt bulunamadı.</div>
    );
  }

  return (
    <div className="grid gap-3">
      {rows.map((r) => {
        const item = r.original;

        return (
          <div key={r.id} className="rounded-lg border bg-card p-4">
            <div className="flex items-start justify-between gap-3">
              <div className="min-w-0">
                <DashboardCellViewer
                  header={item.header}
                  description="Detay görünüm"
                  trend={item.trend}
                  totals={{
                    delivered_orders: item.orders_n,
                    units_delivered: item.units_n,
                    incentives: item.incentives_n,
                  }}
                />

                {/* ID yok, telefon var */}
                <div className="mt-1 text-xs text-muted-foreground">{safePhone(item.phone)}</div>
              </div>

              <Badge variant="outline" className="shrink-0 px-2 text-muted-foreground">
                {typeLabel(item.type)}
              </Badge>
            </div>

            {/* Mobilde 3 kolon bazen sıkışıyor: 2 kolon + alt satır daha dengeli */}
            <div className="mt-4 grid grid-cols-2 gap-2 text-sm">
              <div className="rounded-md border p-2">
                <div className="text-xs text-muted-foreground">Adet</div>
                <div className="font-medium tabular-nums">{item.target}</div>
              </div>
              <div className="rounded-md border p-2">
                <div className="text-xs text-muted-foreground">Sipariş</div>
                <div className="font-medium tabular-nums">{item.limit}</div>
              </div>
              <div className="col-span-2 rounded-md border p-2">
                <div className="text-xs text-muted-foreground">Prim</div>
                <div className="font-medium tabular-nums">{item.reviewer}</div>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}

export function DashboardDataTable(props: {
  data: DashboardAnalyticsDto | undefined;
  loading: boolean;
}) {
  const allRows = React.useMemo(() => buildRows(props.data), [props.data]);
  const [tab, setTab] = React.useState<'outline' | 'drivers' | 'sellers'>('outline');

  const filteredRows = React.useMemo(() => filterByTab(allRows, tab), [allRows, tab]);

  const columns = React.useMemo(() => withDndColumn(dashboardTableColumns), []);
  const [data, setData] = React.useState<Row[]>(() => filteredRows);

  React.useEffect(() => {
    setData(filteredRows);
  }, [filteredRows]);

  const table = useDataTableInstance({ data, columns, getRowId: (row) => row.id });

  const totalCount = allRows.length;
  const driversCount = allRows.filter((r) => r.type === 'Driver').length;
  const sellersCount = allRows.filter((r) => r.type === 'Seller').length;

  return (
    <Tabs
      value={tab}
      onValueChange={(v) => setTab(v as any)}
      className="w-full flex-col justify-start gap-6"
    >
      <div className="flex items-center justify-between gap-3">
        <Label htmlFor="view-selector" className="sr-only">
          Görünüm
        </Label>

        {/* Küçük ekranlarda Select görünür */}
        <Select value={tab} onValueChange={(v) => setTab(v as any)}>
          <SelectTrigger className="flex @4xl/main:hidden w-fit" size="sm" id="view-selector">
            <SelectValue placeholder="Görünüm seç" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="outline">Genel</SelectItem>
            <SelectItem value="drivers">Şoförler</SelectItem>
            <SelectItem value="sellers">Satıcılar</SelectItem>
          </SelectContent>
        </Select>

        {/* Büyük ekranda Tabs görünür */}
        <TabsList className="@4xl/main:flex hidden **:data-[slot=badge]:size-5 **:data-[slot=badge]:rounded-full **:data-[slot=badge]:bg-muted-foreground/30 **:data-[slot=badge]:px-1">
          <TabsTrigger value="outline">
            Genel <Badge variant="secondary">{props.loading ? '…' : String(totalCount)}</Badge>
          </TabsTrigger>
          <TabsTrigger value="drivers">
            Şoförler <Badge variant="secondary">{props.loading ? '…' : String(driversCount)}</Badge>
          </TabsTrigger>
          <TabsTrigger value="sellers">
            Satıcılar{' '}
            <Badge variant="secondary">{props.loading ? '…' : String(sellersCount)}</Badge>
          </TabsTrigger>
        </TabsList>

        <div className="flex items-center gap-2">
          {/* <lg’de tablo yok -> view options gereksiz, lg+’da göster */}
          <div className="hidden lg:block">
            <DataTableViewOptions table={table} />
          </div>

          <Button variant="outline" size="sm" disabled>
            <Plus />
            <span className="hidden lg:inline">Bölüm ekle</span>
          </Button>
        </div>
      </div>

      {/* GENEL */}
      <TabsContent value="outline" className="relative flex flex-col gap-4 overflow-hidden">
        {/* <lg: kart liste | >=lg: tablo */}
        <div className="block lg:hidden">
          <MobileCardList table={table} loading={props.loading} />
          <DataTablePagination table={table} />
        </div>

        <div className="hidden lg:block">
          <div className="overflow-x-auto rounded-lg border">
            <div className="min-w-180">
              <DataTableNew dndEnabled table={table} columns={columns} onReorder={setData} />
            </div>
          </div>
          <DataTablePagination table={table} />
        </div>
      </TabsContent>

      {/* ŞOFÖRLER */}
      <TabsContent value="drivers" className="relative flex flex-col gap-4 overflow-hidden">
        <div className="block lg:hidden">
          <MobileCardList table={table} loading={props.loading} />
          <DataTablePagination table={table} />
        </div>

        <div className="hidden lg:block">
          <div className="overflow-x-auto rounded-lg border">
            <div className="min-w-180">
              <DataTableNew dndEnabled table={table} columns={columns} onReorder={setData} />
            </div>
          </div>
          <DataTablePagination table={table} />
        </div>
      </TabsContent>

      {/* SATICILAR */}
      <TabsContent value="sellers" className="relative flex flex-col gap-4 overflow-hidden">
        <div className="block lg:hidden">
          <MobileCardList table={table} loading={props.loading} />
          <DataTablePagination table={table} />
        </div>

        <div className="hidden lg:block">
          <div className="overflow-x-auto rounded-lg border">
            <div className="min-w-180">
              <DataTableNew dndEnabled table={table} columns={columns} onReorder={setData} />
            </div>
          </div>
          <DataTablePagination table={table} />
        </div>
      </TabsContent>
    </Tabs>
  );
}
