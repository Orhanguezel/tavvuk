'use client';

// =============================================================
// FILE: src/app/(main)/admin/_components/dashboard-section-cards.tsx
// FINAL — Section cards (default style) driven by RTK analytics (TR)
// - TR: UI strings Turkish
// - Fix: remove EN strings, clarify metrics
// - Note: setRange is not used here (kept as _setRange to avoid lint noise)
// =============================================================

import * as React from 'react';
import { RefreshCcw, TrendingDown, TrendingUp } from 'lucide-react';

import type { DashboardRangeKey } from '@/integrations/types';

import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardAction,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';

type DashboardAnalyticsDto = any;

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

function asRangeLabel(r: DashboardRangeKey) {
  if (r === '7d') return 'Son 7 gün';
  if (r === '30d') return 'Son 30 gün';
  return 'Son 3 ay';
}

export function DashboardSectionCards(props: {
  range: DashboardRangeKey;
  setRange: (r: DashboardRangeKey) => void;
  data: DashboardAnalyticsDto | undefined;
  loading: boolean;
  onRefresh: () => void;
}) {
  // Bu bileşende range seçimi yapılmıyor; state üst bileşende yönetiliyor.
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const _setRange = props.setRange;

  const totals = props.data?.totals;

  const deliveredOrders = Number(totals?.delivered_orders ?? 0);
  const unitsDelivered = Number(totals?.total_units_delivered ?? 0);
  const totalIncentives = Number(totals?.total_incentives ?? 0);

  const avgIncentivePerOrder = deliveredOrders > 0 ? totalIncentives / deliveredOrders : 0;

  return (
    <div className="space-y-3">
      <div className="flex items-center justify-end gap-2">
        <Button variant="outline" size="sm" onClick={props.onRefresh} disabled={props.loading}>
          <RefreshCcw className={props.loading ? 'animate-spin' : ''} />
          Yenile
        </Button>
      </div>

      <div className="grid @5xl/main:grid-cols-4 @xl/main:grid-cols-2 grid-cols-1 gap-4 *:data-[slot=card]:bg-linear-to-t *:data-[slot=card]:from-primary/5 *:data-[slot=card]:to-card *:data-[slot=card]:shadow-xs dark:*:data-[slot=card]:bg-card">
        {/* 1) Sipariş */}
        <Card className="@container/card">
          <CardHeader>
            <CardDescription>Teslim Edilen Sipariş</CardDescription>
            <CardTitle className="font-semibold @[250px]/card:text-3xl text-2xl tabular-nums">
              {props.loading ? '—' : fmtInt(deliveredOrders)}
            </CardTitle>
            <CardAction>
              <Badge variant="outline" className="gap-1">
                <TrendingUp className="size-4" />
                {asRangeLabel(props.range)}
              </Badge>
            </CardAction>
          </CardHeader>
          <CardFooter className="flex-col items-start gap-1.5 text-sm">
            <div className="line-clamp-1 flex gap-2 font-medium">Durum: teslim edildi</div>
            <div className="text-muted-foreground">Teslim edilen sipariş adedi</div>
          </CardFooter>
        </Card>

        {/* 2) Adet */}
        <Card className="@container/card">
          <CardHeader>
            <CardDescription>Teslim Edilen Adet</CardDescription>
            <CardTitle className="font-semibold @[250px]/card:text-3xl text-2xl tabular-nums">
              {props.loading ? '—' : fmtInt(unitsDelivered)}
            </CardTitle>
            <CardAction>
              <Badge variant="outline" className="gap-1">
                <TrendingUp className="size-4" />
                Toplam adet
              </Badge>
            </CardAction>
          </CardHeader>
          <CardFooter className="flex-col items-start gap-1.5 text-sm">
            <div className="line-clamp-1 flex gap-2 font-medium">Toplam adet</div>
            <div className="text-muted-foreground">Teslim edilen toplam birim</div>
          </CardFooter>
        </Card>

        {/* 3) Prim */}
        <Card className="@container/card">
          <CardHeader>
            <CardDescription>Hak Edilen Prim</CardDescription>
            <CardTitle className="font-semibold @[250px]/card:text-3xl text-2xl tabular-nums">
              {props.loading ? '—' : fmtMoneyTry(totalIncentives)}
            </CardTitle>
            <CardAction>
              <Badge variant="outline" className="gap-1">
                <TrendingUp className="size-4" />
                Prim toplamı
              </Badge>
            </CardAction>
          </CardHeader>
          <CardFooter className="flex-col items-start gap-1.5 text-sm">
            <div className="line-clamp-1 flex gap-2 font-medium">Satıcı + Şoför</div>
            <div className="text-muted-foreground">Hesaplanan prim toplamı</div>
          </CardFooter>
        </Card>

        {/* 4) Ortalama */}
        <Card className="@container/card">
          <CardHeader>
            <CardDescription>Ortalama Prim / Sipariş</CardDescription>
            <CardTitle className="font-semibold @[250px]/card:text-3xl text-2xl tabular-nums">
              {props.loading ? '—' : fmtMoneyTry(avgIncentivePerOrder)}
            </CardTitle>
            <CardAction>
              <Badge variant="outline" className="gap-1">
                {deliveredOrders > 0 ? (
                  <TrendingUp className="size-4" />
                ) : (
                  <TrendingDown className="size-4" />
                )}
                Ortalama
              </Badge>
            </CardAction>
          </CardHeader>
          <CardFooter className="flex-col items-start gap-1.5 text-sm">
            <div className="line-clamp-1 flex gap-2 font-medium">Toplam prim / sipariş</div>
            <div className="text-muted-foreground">Basit KPI</div>
          </CardFooter>
        </Card>
      </div>
    </div>
  );
}
