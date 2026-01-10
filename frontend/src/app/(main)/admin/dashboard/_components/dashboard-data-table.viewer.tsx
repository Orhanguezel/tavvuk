'use client';

// =============================================================
// FILE: src/app/(main)/admin/_components/dashboard-data-table.viewer.tsx
// FINAL — Drawer viewer (default template style) for table cell — REAL DATA
// - Uses real dashboard trend (orders + units) passed from table
// - TR: UI strings Turkish
// =============================================================

import * as React from 'react';
import { TrendingUp } from 'lucide-react';
import { Area, AreaChart, CartesianGrid, XAxis } from 'recharts';

import { Button } from '@/components/ui/button';
import {
  type ChartConfig,
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from '@/components/ui/chart';
import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
} from '@/components/ui/drawer';
import { Separator } from '@/components/ui/separator';
import { useIsMobile } from '@/hooks/use-mobile';

export type TrendRow = {
  bucket: string; // YYYY-MM-DD | YYYY-Wxx
  delivered_orders: number;
  units_delivered: number;
  incentives?: number;
};

function isIsoDate(s: string) {
  return /^\d{4}-\d{2}-\d{2}$/.test(s);
}
function isIsoWeek(s: string) {
  return /^\d{4}-W\d{2}$/.test(s);
}
function formatBucket(bucket: string) {
  if (isIsoWeek(bucket)) return bucket.replace('-', ' ');
  if (isIsoDate(bucket)) {
    const d = new Date(bucket);
    if (!Number.isFinite(d.getTime())) return bucket;
    return d.toLocaleDateString('tr-TR', { month: 'short', day: 'numeric' });
  }
  return bucket;
}

function toNumber(v: unknown, fb = 0) {
  const n = Number(v);
  return Number.isFinite(n) ? n : fb;
}

const chartConfig = {
  orders: { label: 'Sipariş', color: 'var(--chart-1)' },
  units: { label: 'Adet', color: 'var(--chart-2)' },
} satisfies ChartConfig;

export function DashboardCellViewer(props: {
  header: string;
  description?: string;

  trend: TrendRow[];
  totals?: {
    delivered_orders?: number;
    units_delivered?: number;
    incentives?: number;
  };
}) {
  const isMobile = useIsMobile();

  const chartData = React.useMemo(() => {
    const rows = Array.isArray(props.trend) ? props.trend : [];
    return rows.map((t) => ({
      date: String((t as any).bucket ?? ''),
      orders: toNumber((t as any).delivered_orders, 0),
      units: toNumber((t as any).units_delivered, 0),
    }));
  }, [props.trend]);

  const totals = props.totals ?? {};
  const ordersTxt = new Intl.NumberFormat('tr-TR').format(
    Math.round(toNumber(totals.delivered_orders, 0)),
  );
  const unitsTxt = new Intl.NumberFormat('tr-TR').format(
    Math.round(toNumber(totals.units_delivered, 0)),
  );
  const incTxt = new Intl.NumberFormat('tr-TR', {
    style: 'currency',
    currency: 'TRY',
    maximumFractionDigits: 2,
  }).format(toNumber(totals.incentives, 0));

  return (
    <Drawer direction={isMobile ? 'bottom' : 'right'}>
      <DrawerTrigger asChild>
        <Button variant="link" className="w-fit px-0 text-left text-foreground">
          {props.header}
        </Button>
      </DrawerTrigger>

      <DrawerContent>
        <DrawerHeader className="gap-1">
          <DrawerTitle>{props.header}</DrawerTitle>
          <DrawerDescription>{props.description ?? 'Detay görünüm'}</DrawerDescription>
        </DrawerHeader>

        <div className="flex flex-col gap-4 overflow-y-auto px-4 text-sm">
          {!isMobile && (
            <>
              <ChartContainer config={chartConfig}>
                <AreaChart data={chartData} margin={{ left: 0, right: 10 }}>
                  <defs>
                    <linearGradient id="fillOrdersMini" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="var(--color-orders)" stopOpacity={1.0} />
                      <stop offset="95%" stopColor="var(--color-orders)" stopOpacity={0.1} />
                    </linearGradient>
                    <linearGradient id="fillUnitsMini" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="var(--color-units)" stopOpacity={0.8} />
                      <stop offset="95%" stopColor="var(--color-units)" stopOpacity={0.1} />
                    </linearGradient>
                  </defs>

                  <CartesianGrid vertical={false} />

                  <XAxis
                    dataKey="date"
                    tickLine={false}
                    axisLine={false}
                    tickMargin={8}
                    minTickGap={32}
                    tickFormatter={(v) => formatBucket(String(v))}
                  />

                  <ChartTooltip
                    cursor={false}
                    content={
                      <ChartTooltipContent
                        labelFormatter={(v) => formatBucket(String(v))}
                        indicator="dot"
                      />
                    }
                  />

                  {/* stackId YOK: iki seri ayrı */}
                  <Area
                    dataKey="units"
                    type="natural"
                    fill="url(#fillUnitsMini)"
                    stroke="var(--color-units)"
                  />
                  <Area
                    dataKey="orders"
                    type="natural"
                    fill="url(#fillOrdersMini)"
                    stroke="var(--color-orders)"
                  />
                </AreaChart>
              </ChartContainer>

              <Separator />

              <div className="grid gap-2">
                <div className="flex gap-2 font-medium leading-none">
                  Özet <TrendingUp className="size-4" />
                </div>

                <div className="grid grid-cols-3 gap-3 text-sm">
                  <div className="rounded-md border p-2">
                    <div className="text-muted-foreground">Sipariş</div>
                    <div className="font-medium tabular-nums">{ordersTxt}</div>
                  </div>
                  <div className="rounded-md border p-2">
                    <div className="text-muted-foreground">Adet</div>
                    <div className="font-medium tabular-nums">{unitsTxt}</div>
                  </div>
                  <div className="rounded-md border p-2">
                    <div className="text-muted-foreground">Prim</div>
                    <div className="font-medium tabular-nums">{incTxt}</div>
                  </div>
                </div>

                <div className="text-muted-foreground">
                  Mini grafik, seçili aralık için teslimat trendini (sipariş/adet) gösterir.
                </div>
              </div>

              <Separator />
            </>
          )}
        </div>

        <DrawerFooter>
          <DrawerClose asChild>
            <Button variant="outline">Kapat</Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
}
