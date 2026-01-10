'use client';

// =============================================================
// FILE: src/app/(main)/admin/orders/[id]/order-detail-client.tsx
// FINAL — Admin Order Detail (view + actions) + DriverPicker
// - Items table UI improved: product name/info + ordered/delivered/remaining + totals
// =============================================================

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { ArrowLeft, CheckCircle2, Ban, UserPlus, RefreshCcw } from 'lucide-react';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

import type { OrderStatus, OrderView } from '@/integrations/types';

import {
  useAdminGetOrderQuery,
  useAdminApproveOrderMutation,
  useAdminAssignDriverMutation,
  useAdminCancelOrderMutation,
} from '@/integrations/rtk/hooks';

import { DriverPicker, type DriverOption } from '../_components/driver-picker';

/* ----------------------------- helpers ----------------------------- */

function safeText(v: unknown, fb = ''): string {
  const s = String(v ?? '').trim();
  return s ? s : fb;
}

function n0(v: unknown): number {
  const n = Number(v ?? 0);
  return Number.isFinite(n) ? n : 0;
}

function clampInt(v: unknown, min = 0): number {
  const n = Math.floor(n0(v));
  return Math.max(min, n);
}

function getErrMessage(err: unknown): string {
  const anyErr = err as any;
  const m1 = anyErr?.data?.error?.message;
  if (typeof m1 === 'string' && m1.trim()) return m1;
  const m2 = anyErr?.data?.message;
  if (typeof m2 === 'string' && m2.trim()) return m2;
  const m3 = anyErr?.error;
  if (typeof m3 === 'string' && m3.trim()) return m3;
  return 'İşlem başarısız. Lütfen tekrar deneyin.';
}

const STATUS_LABELS: Record<OrderStatus, string> = {
  submitted: 'Gönderildi',
  approved: 'Onaylandı',
  assigned: 'Atandı',
  on_delivery: 'Dağıtımda',
  delivered: 'Teslim',
  cancelled: 'İptal',
};

function statusBadge(s: OrderStatus) {
  if (s === 'delivered') return <Badge variant="outline">Teslim</Badge>;
  if (s === 'cancelled') return <Badge variant="destructive">İptal</Badge>;
  if (s === 'on_delivery') return <Badge>Dağıtımda</Badge>;
  if (s === 'assigned') return <Badge>Atandı</Badge>;
  if (s === 'approved') return <Badge>Onaylandı</Badge>;
  return <Badge variant="secondary">{STATUS_LABELS[s] ?? s}</Badge>;
}

function canApprove(o: OrderView) {
  return o.status === 'submitted';
}
function canAssign(o: OrderView) {
  return o.status === 'approved';
}
function canCancel(o: OrderView) {
  return o.status !== 'delivered' && o.status !== 'cancelled';
}

/* ----------------------------- item mappers ----------------------------- */

type ItemRow = {
  id: string;
  productId: string;
  title: string;
  subtitle: string;
  ordered: number;
  delivered: number;
  remaining: number;
};

function mapItem(it: any): ItemRow {
  const product = it?.product ?? it?.product_view ?? null;

  const title =
    safeText(it?.product_title, '') ||
    safeText(product?.title, '') ||
    safeText(product?.name, '') ||
    'Ürün';

  const slug = safeText(it?.product_slug, '') || safeText(product?.slug, '');
  const sku = safeText(it?.product_sku, '') || safeText(product?.sku, '');
  const stock = product?.stock_quantity ?? product?.stock ?? undefined;
  const tags = Array.isArray(product?.tags) ? (product.tags as string[]) : [];

  const subtitleParts: string[] = [];
  if (sku) subtitleParts.push(`SKU: ${sku}`);
  if (slug) subtitleParts.push(slug);
  if (typeof stock === 'number') subtitleParts.push(`stok: ${stock}`);
  if (tags.length) subtitleParts.push(tags.slice(0, 3).join(', '));

  const ordered = clampInt(it?.qty_ordered, 0);
  const delivered = clampInt(it?.qty_delivered, 0);
  const remaining = Math.max(0, ordered - delivered);

  return {
    id: safeText(it?.id, ''),
    productId: safeText(it?.product_id, ''),
    title,
    subtitle: subtitleParts.join(' • '),
    ordered,
    delivered,
    remaining,
  };
}

/* ----------------------------- component ----------------------------- */

export default function OrderDetailClient({ id }: { id: string }) {
  const router = useRouter();

  const orderQ = useAdminGetOrderQuery({ id });

  const [approveOrder, approveState] = useAdminApproveOrderMutation();
  const [assignDriver, assignState] = useAdminAssignDriverMutation();
  const [cancelOrder, cancelState] = useAdminCancelOrderMutation();

  const busy =
    orderQ.isFetching || approveState.isLoading || assignState.isLoading || cancelState.isLoading;

  const order = orderQ.data?.order ?? null;
  const rawItems = orderQ.data?.items ?? [];

  const [driverId, setDriverId] = React.useState('');
  const [driverLabel, setDriverLabel] = React.useState<string>('');
  const [cancelReason, setCancelReason] = React.useState('');

  React.useEffect(() => {
    if (!order) return;
    const current = safeText((order as any).assigned_driver_id, '');
    setDriverId(current);
    setDriverLabel('');
  }, [order?.id]);

  const items: ItemRow[] = React.useMemo(() => {
    if (!Array.isArray(rawItems)) return [];
    return rawItems.map(mapItem);
  }, [rawItems]);

  const totals = React.useMemo(() => {
    const tOrdered = items.reduce((a, x) => a + x.ordered, 0);
    const tDelivered = items.reduce((a, x) => a + x.delivered, 0);
    const tRemaining = items.reduce((a, x) => a + x.remaining, 0);
    return { tOrdered, tDelivered, tRemaining };
  }, [items]);

  async function onApprove() {
    try {
      await approveOrder({ id }).unwrap();
      toast.success('Sipariş onaylandı.');
      orderQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  async function onAssignDriver() {
    const dId = driverId.trim();
    if (!dId) {
      toast.error('Sürücü seçimi zorunlu.');
      return;
    }
    try {
      await assignDriver({ id, body: { driver_id: dId } }).unwrap();
      toast.success('Sürücü atandı.');
      orderQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  async function onCancel() {
    try {
      await cancelOrder({ id, body: { cancel_reason: cancelReason.trim() || undefined } }).unwrap();
      toast.success('Sipariş iptal edildi.');
      orderQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  if (orderQ.isError) {
    return (
      <div className="space-y-3">
        <Button variant="outline" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 size-4" />
          Geri
        </Button>
        <div className="rounded-md border p-4 text-sm">
          Sipariş yüklenemedi.{' '}
          <Button variant="link" className="px-1" onClick={() => orderQ.refetch()}>
            Yeniden dene
          </Button>
        </div>
      </div>
    );
  }

  if (!order) {
    return (
      <div className="space-y-3">
        <Button variant="outline" onClick={() => router.back()} disabled={busy}>
          <ArrowLeft className="mr-2 size-4" />
          Geri
        </Button>
        <div className="rounded-md border p-4 text-sm text-muted-foreground">Yükleniyor…</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* header */}
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <Button variant="outline" onClick={() => router.back()} disabled={busy}>
              <ArrowLeft className="mr-2 size-4" />
              Geri
            </Button>
            <h1 className="text-lg font-semibold">Sipariş Detay</h1>
            {statusBadge(order.status)}
          </div>
          <p className="text-sm text-muted-foreground">
            #{order.id.slice(0, 8)} • {order.customer_name} • {order.customer_phone}
          </p>
        </div>

        <div className="flex items-center gap-2">
          <Button variant="ghost" onClick={() => orderQ.refetch()} disabled={busy} title="Yenile">
            <RefreshCcw className="size-4" />
          </Button>

          <Button onClick={onApprove} disabled={busy || !canApprove(order)}>
            <CheckCircle2 className="mr-2 size-4" />
            Onayla
          </Button>

          <Button variant="destructive" onClick={onCancel} disabled={busy || !canCancel(order)}>
            <Ban className="mr-2 size-4" />
            İptal Et
          </Button>
        </div>
      </div>

      {/* summary */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Sipariş Bilgileri</CardTitle>
          <CardDescription>Müşteri ve adres bilgileri.</CardDescription>
        </CardHeader>

        <CardContent className="space-y-3">
          <div className="grid gap-3 md:grid-cols-2">
            <div className="rounded-md border p-3">
              <div className="text-xs text-muted-foreground">Müşteri</div>
              <div className="font-medium">{safeText(order.customer_name, '—')}</div>
              <div className="text-sm text-muted-foreground">
                {safeText(order.customer_phone, '—')}
              </div>
            </div>

            <div className="rounded-md border p-3">
              <div className="text-xs text-muted-foreground">Adres</div>
              <div className="font-medium">{safeText(order.address_text, '—')}</div>
            </div>
          </div>

          <Separator />

          {/* assign */}
          <div className="space-y-2">
            <div className="font-medium">Sürücü Atama</div>

            <div className="grid gap-3 md:grid-cols-3 md:items-end">
              <div className="space-y-2 md:col-span-2">
                <Label>Sürücü Seç</Label>

                <DriverPicker
                  value={driverId}
                  onChange={(nextId, d?: DriverOption) => {
                    setDriverId(nextId);
                    setDriverLabel(d ? `${d.full_name}${d.phone ? ` • ${d.phone}` : ''}` : '');
                  }}
                  disabled={busy}
                  placeholder="Sürücü seç…"
                  initialLabel={driverId ? `#${driverId.slice(0, 8)}` : undefined}
                />

                <p className="text-xs text-muted-foreground">
                  Not: Atama sadece <b>Onaylandı</b> durumundaki siparişlerde aktiftir.
                  {driverLabel ? (
                    <>
                      {' '}
                      Seçili: <b>{driverLabel}</b>
                    </>
                  ) : null}
                </p>
              </div>

              <div>
                <Button
                  className="w-full"
                  variant="secondary"
                  onClick={onAssignDriver}
                  disabled={busy || !canAssign(order) || !driverId.trim()}
                >
                  <UserPlus className="mr-2 size-4" />
                  Ata
                </Button>
              </div>
            </div>
          </div>

          <Separator />

          {/* cancel reason */}
          <div className="space-y-2">
            <Label htmlFor="cancelReason">İptal Sebebi (opsiyonel)</Label>
            <Textarea
              id="cancelReason"
              value={cancelReason}
              onChange={(e) => setCancelReason(e.target.value)}
              placeholder="Örn: Müşteri iptal etti / stok yok / adres hatalı..."
              disabled={busy}
            />
          </div>
        </CardContent>
      </Card>

      {/* items */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Sipariş Kalemleri</CardTitle>
          <CardDescription>Ürün, sipariş adedi ve teslim bilgileri.</CardDescription>
        </CardHeader>

        <CardContent>
          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Ürün</TableHead>
                  <TableHead className="text-right">Sipariş</TableHead>
                  <TableHead className="text-right">Teslim</TableHead>
                  <TableHead className="text-right">Kalan</TableHead>
                </TableRow>
              </TableHeader>

              <TableBody>
                {items.map((it) => (
                  <TableRow key={it.id || it.productId || it.title}>
                    <TableCell className="align-top">
                      <div className="font-medium leading-5">{it.title}</div>
                      {it.subtitle ? (
                        <div className="mt-0.5 text-xs text-muted-foreground">{it.subtitle}</div>
                      ) : (
                        <div className="mt-0.5 text-xs text-muted-foreground">
                          Ürün bilgisi bulunamadı.
                        </div>
                      )}
                    </TableCell>

                    <TableCell className="text-right tabular-nums">{it.ordered}</TableCell>
                    <TableCell className="text-right tabular-nums">{it.delivered}</TableCell>
                    <TableCell className="text-right tabular-nums">
                      {it.remaining > 0 ? (
                        <span className="font-medium">{it.remaining}</span>
                      ) : (
                        <span className="text-muted-foreground">0</span>
                      )}
                    </TableCell>
                  </TableRow>
                ))}

                {!orderQ.isFetching && items.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4} className="py-10 text-center text-muted-foreground">
                      Kalem bulunamadı.
                    </TableCell>
                  </TableRow>
                ) : null}

                {/* totals */}
                {items.length > 0 ? (
                  <TableRow>
                    <TableCell className="font-medium">Toplam</TableCell>
                    <TableCell className="text-right tabular-nums font-medium">
                      {totals.tOrdered}
                    </TableCell>
                    <TableCell className="text-right tabular-nums font-medium">
                      {totals.tDelivered}
                    </TableCell>
                    <TableCell className="text-right tabular-nums font-medium">
                      {totals.tRemaining}
                    </TableCell>
                  </TableRow>
                ) : null}
              </TableBody>
            </Table>
          </div>

          {/* Small note for missing product join */}
          <div className="mt-3 text-xs text-muted-foreground">
            Not: Ürün adı/slug/tags gibi detaylar görünmüyorsa, backend <code>getOrderItems</code>{' '}
            query’sinde order_items → products join eklenmelidir (items içine product alanı).
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
