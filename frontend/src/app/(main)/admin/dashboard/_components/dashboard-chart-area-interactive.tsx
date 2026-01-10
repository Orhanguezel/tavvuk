'use client';

// =============================================================
// FILE: src/app/(main)/admin/_components/dashboard-chart-area-interactive.tsx
// FINAL — Interactive AREA Chart (2 series, selectable + dual Y axes)
// - Same card UX as shadcn sample
// - Fix: orders vs units are different scales -> use left/right YAxis
// - User can toggle series (one or both)
// - TR: labels + range texts Turkish
// =============================================================

import * as React from 'react';
import { Area, AreaChart, CartesianGrid, XAxis, YAxis } from 'recharts';

import type { DashboardRangeKey } from '@/integrations/types';

import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  type ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from '@/components/ui/chart';
import { Checkbox } from '@/components/ui/checkbox';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { ToggleGroup, ToggleGroupItem } from '@/components/ui/toggle-group';
import { useIsMobile } from '@/hooks/use-mobile';

type DashboardAnalyticsDto = any;

type TrendRow = {
  bucket: string; // YYYY-MM-DD | YYYY-Wxx
  delivered_orders: number;
  units_delivered: number;
  incentives: number;
};

function toNumber(v: unknown, fb = 0) {
  const n = Number(v);
  return Number.isFinite(n) ? n : fb;
}

function isIsoDate(s: string) {
  return /^\d{4}-\d{2}-\d{2}$/.test(s);
}
function isIsoWeek(s: string) {
  return /^\d{4}-W\d{2}$/.test(s);
}

function formatTick(bucket: string) {
  if (isIsoWeek(bucket)) return bucket.replace('-', ' '); // 2025 W42
  if (isIsoDate(bucket)) {
    const d = new Date(bucket);
    if (!Number.isFinite(d.getTime())) return bucket;
    return d.toLocaleDateString('tr-TR', { month: 'short', day: 'numeric' });
  }
  return bucket;
}

function niceTick(n: number): string {
  if (!Number.isFinite(n)) return '0';
  return new Intl.NumberFormat('tr-TR').format(Math.round(n));
}

export function DashboardChartAreaInteractive(props: {
  range: DashboardRangeKey;
  setRange: (r: DashboardRangeKey) => void;
  data: DashboardAnalyticsDto | undefined;
  loading: boolean;
}) {
  const isMobile = useIsMobile();

  React.useEffect(() => {
    if (isMobile && props.range !== '7d') props.setRange('7d');
  }, [isMobile, props.range, props.setRange]);

  const trend: TrendRow[] = Array.isArray(props.data?.trend) ? (props.data!.trend as any) : [];

  const chartData = trend.map((t) => ({
    date: String(t.bucket),
    orders: toNumber((t as any).delivered_orders, 0),
    units: toNumber((t as any).units_delivered, 0),
  }));

  const chartConfig = {
    orders: { label: 'Sipariş', color: 'var(--chart-1)' },
    units: { label: 'Tavuk (Adet)', color: 'var(--chart-2)' },
  } satisfies ChartConfig;

  const rangeLabel =
    props.range === '90d' ? 'Son 3 ay' : props.range === '30d' ? 'Son 30 gün' : 'Son 7 gün';

  // ---- series toggle (one or both) ----
  const [showOrders, setShowOrders] = React.useState(true);
  const [showUnits, setShowUnits] = React.useState(true);

  // En az 1 seri açık kalsın
  function toggleOrders(next: boolean) {
    if (!next && !showUnits) return;
    setShowOrders(next);
  }
  function toggleUnits(next: boolean) {
    if (!next && !showOrders) return;
    setShowUnits(next);
  }

  // Tooltip’te sadece seçili serileri göster
  const tooltipCfg = React.useMemo(() => {
    const allow = new Set<string>();
    if (showOrders) allow.add('orders');
    if (showUnits) allow.add('units');

    return {
      formatter: (_value: any, name: string) => {
        // ChartTooltipContent config label already handled; keep default
        return [_value, name];
      },
      filter: (item: any) => allow.has(String(item?.dataKey)),
    };
  }, [showOrders, showUnits]);

  return (
    <Card className="@container/card">
      <CardHeader>
        <div className="flex items-start justify-between gap-4">
          <div className="min-w-0">
            <CardTitle>Teslimat Grafiği</CardTitle>
            <CardDescription>
              <span className="@[540px]/card:block hidden">Seçili metrikler — {rangeLabel}</span>
              <span className="@[540px]/card:hidden">{rangeLabel}</span>
            </CardDescription>
          </div>

          <CardAction className="flex flex-col items-end gap-2">
            <ToggleGroup
              type="single"
              value={props.range}
              onValueChange={(v) => v && props.setRange(v as DashboardRangeKey)}
              variant="outline"
              className="@[767px]/card:flex hidden *:data-[slot=toggle-group-item]:px-4!"
            >
              <ToggleGroupItem value="90d">Son 3 ay</ToggleGroupItem>
              <ToggleGroupItem value="30d">Son 30 gün</ToggleGroupItem>
              <ToggleGroupItem value="7d">Son 7 gün</ToggleGroupItem>
            </ToggleGroup>

            <Select
              value={props.range}
              onValueChange={(v) => props.setRange(v as DashboardRangeKey)}
            >
              <SelectTrigger
                className="flex @[767px]/card:hidden w-36 **:data-[slot=select-value]:block **:data-[slot=select-value]:truncate"
                size="sm"
                aria-label="Aralık seç"
              >
                <SelectValue placeholder="Son 3 ay" />
              </SelectTrigger>
              <SelectContent className="rounded-xl">
                <SelectItem value="90d" className="rounded-lg">
                  Son 3 ay
                </SelectItem>
                <SelectItem value="30d" className="rounded-lg">
                  Son 30 gün
                </SelectItem>
                <SelectItem value="7d" className="rounded-lg">
                  Son 7 gün
                </SelectItem>
              </SelectContent>
            </Select>
          </CardAction>
        </div>

        {/* Series selector (aynı anda seçilebilir) */}
        <div className="mt-3 flex flex-wrap items-center gap-3">
          <div className="flex items-center gap-2">
            <Checkbox
              id="toggle-orders"
              checked={showOrders}
              onCheckedChange={(v) => toggleOrders(Boolean(v))}
            />
            <Label htmlFor="toggle-orders" className="text-sm">
              Sipariş
            </Label>
          </div>

          <div className="flex items-center gap-2">
            <Checkbox
              id="toggle-units"
              checked={showUnits}
              onCheckedChange={(v) => toggleUnits(Boolean(v))}
            />
            <Label htmlFor="toggle-units" className="text-sm">
              Tavuk (Adet)
            </Label>
          </div>

          <div className="text-xs text-muted-foreground">
            Not: Ölçekler farklı olduğu için eksenler ayrıdır (Sipariş: sol, Tavuk: sağ).
          </div>
        </div>
      </CardHeader>

      <CardContent className="px-2 pt-4 sm:px-6 sm:pt-6">
        <ChartContainer config={chartConfig} className="aspect-auto h-65 w-full">
          <AreaChart data={chartData}>
            <defs>
              <linearGradient id="fillOrders" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="var(--color-orders)" stopOpacity={1.0} />
                <stop offset="95%" stopColor="var(--color-orders)" stopOpacity={0.08} />
              </linearGradient>

              <linearGradient id="fillUnits" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="var(--color-units)" stopOpacity={0.9} />
                <stop offset="95%" stopColor="var(--color-units)" stopOpacity={0.08} />
              </linearGradient>
            </defs>

            <CartesianGrid vertical={false} />

            <XAxis
              dataKey="date"
              tickLine={false}
              axisLine={false}
              tickMargin={8}
              minTickGap={32}
              tickFormatter={(value) => formatTick(String(value))}
            />

            {/* Dual Y axes: biri sipariş, diğeri tavuk/adet */}
            {showOrders && (
              <YAxis
                yAxisId="yOrders"
                orientation="left"
                tickLine={false}
                axisLine={false}
                width={40}
                tickFormatter={niceTick}
              />
            )}

            {showUnits && (
              <YAxis
                yAxisId="yUnits"
                orientation="right"
                tickLine={false}
                axisLine={false}
                width={40}
                tickFormatter={niceTick}
              />
            )}

            <ChartTooltip
              cursor={false}
              defaultIndex={isMobile ? -1 : 10}
              content={
                <ChartTooltipContent
                  labelFormatter={(value) => formatTick(String(value))}
                  indicator="dot"
                  // @ts-expect-error: shadcn wrapper forwards props to recharts tooltip
                  filter={tooltipCfg.filter}
                />
              }
            />

            {showOrders && (
              <Area
                dataKey="orders"
                yAxisId="yOrders"
                type="natural"
                fill="url(#fillOrders)"
                stroke="var(--color-orders)"
              />
            )}

            {showUnits && (
              <Area
                dataKey="units"
                yAxisId="yUnits"
                type="natural"
                fill="url(#fillUnits)"
                stroke="var(--color-units)"
              />
            )}
          </AreaChart>
        </ChartContainer>
      </CardContent>
    </Card>
  );
}
