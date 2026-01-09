'use client';

// src/app/(main)/dashboard/driver/orders/_components/driver-orders-client.tsx
// =============================================================
// FINAL — Driver Orders page (responsive) — NEW RTK NAMES
// - List assigned orders (driver self): GET /driver/orders
// - Deliver dialog: GET /orders/:id (public detail) then POST /driver/orders/:id/deliver
// =============================================================

import * as React from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { toast } from 'sonner';
import {
  RefreshCcw,
  ChevronLeft,
  ChevronRight,
  Truck,
  ClipboardList,
  Save,
  Search,
} from 'lucide-react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

import type {
  OrderStatus,
  ListOrdersQuery,
  OrderView,
  OrderDetailResponse,
  DriverDeliverBody,
} from '@/integrations/types';

import {
  useListDriverOrdersQuery,
  useDeliverOrderMutation,
  useGetOrderDetailQuery, // Public Orders RTK: GET /orders/:id
} from '@/integrations/rtk/hooks';

/* ----------------------------- helpers ----------------------------- */

const STATUS_LABELS: Record<OrderStatus, string> = {
  submitted: 'Gönderildi',
  approved: 'Onaylandı',
  assigned: 'Atandı',
  on_delivery: 'Dağıtımda',
  delivered: 'Teslim',
  cancelled: 'İptal',
};

function safeText(v: any, fb = ''): string {
  const s = String(v ?? '').trim();
  return s ? s : fb;
}

function safeInt(v: string | null, fb: number): number {
  const n = Number(v ?? '');
  return Number.isFinite(n) && n >= 0 ? n : fb;
}

function formatDateTime(iso?: string | null): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return '—';
  try {
    return new Intl.DateTimeFormat('tr-TR', {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
    }).format(d);
  } catch {
    return d.toISOString();
  }
}

function statusBadge(s: OrderStatus) {
  if (s === 'delivered') return <Badge variant="outline">Teslim</Badge>;
  if (s === 'cancelled') return <Badge variant="destructive">İptal</Badge>;
  if (s === 'on_delivery') return <Badge>Dağıtımda</Badge>;
  if (s === 'assigned') return <Badge>Atandı</Badge>;
  if (s === 'approved') return <Badge>Onaylandı</Badge>;
  return <Badge variant="secondary">{STATUS_LABELS[s] ?? s}</Badge>;
}

/**
 * Driver list query:
 * - Backend /driver/orders: listOrdersQuerySchema (status/date_from/date_to/limit/offset)
 * - URL’e ayrıca client-side arama "q" koyuyoruz (backend’e göndermiyoruz).
 */
type DriverOrdersUrlState = ListOrdersQuery & { q?: string };

function pickQuery(sp: URLSearchParams): DriverOrdersUrlState {
  const q = sp.get('q') ?? undefined;
  const limit = safeInt(sp.get('limit'), 100) || 100;
  const offset = safeInt(sp.get('offset'), 0);

  const status = (sp.get('status') ?? undefined) as OrderStatus | undefined;
  const date_from = sp.get('date_from') ?? undefined;
  const date_to = sp.get('date_to') ?? undefined;

  return {
    ...(status ? { status } : {}),
    ...(date_from ? { date_from } : {}),
    ...(date_to ? { date_to } : {}),
    limit,
    offset,
    ...(q ? { q } : {}),
  };
}

function toSearchParams(p: DriverOrdersUrlState): string {
  const sp = new URLSearchParams();
  if (p.status) sp.set('status', String(p.status));
  if (p.date_from) sp.set('date_from', String(p.date_from));
  if (p.date_to) sp.set('date_to', String(p.date_to));
  if (p.q) sp.set('q', String(p.q));
  if (p.limit != null) sp.set('limit', String(p.limit));
  if (p.offset != null) sp.set('offset', String(p.offset));
  return sp.toString();
}

function canDeliver(o: OrderView) {
  return o.status !== 'cancelled' && o.status !== 'delivered';
}

/* ----------------------------- deliver dialog model ----------------------------- */

type DeliverDialogState = { open: false } | { open: true; orderId: string };

type EditableItem = {
  order_item_id: string;
  product_id: string;
  qty_ordered: number;
  qty_delivered: number;
};

export default function DriverOrdersClient() {
  const router = useRouter();
  const sp = useSearchParams();

  const params = React.useMemo(() => pickQuery(sp), [sp]);

  // Backend'e giden query (q yok!)
  const listParams = React.useMemo(() => {
    const p: any = {
      status: params.status,
      date_from: params.date_from,
      date_to: params.date_to,
      limit: params.limit ?? 100,
      offset: params.offset ?? 0,
    };
    // undefined temizliği
    Object.keys(p).forEach((k) => (p[k] == null ? delete p[k] : null));
    return p as ListOrdersQuery;
  }, [params.status, params.date_from, params.date_to, params.limit, params.offset]);

  const listQ = useListDriverOrdersQuery(listParams as any);

  // client-side search term
  const [term, setTerm] = React.useState(params.q ?? '');

  React.useEffect(() => {
    setTerm(params.q ?? '');
  }, [params.q]);

  function apply(next: Partial<DriverOrdersUrlState>) {
    const merged: DriverOrdersUrlState = {
      ...params,
      ...next,
      offset: next.offset != null ? next.offset : 0,
    };

    if (!merged.q) delete (merged as any).q;
    if (!merged.status) delete (merged as any).status;
    if (!merged.date_from) delete (merged as any).date_from;
    if (!merged.date_to) delete (merged as any).date_to;

    const qs = toSearchParams(merged);
    router.push(qs ? `/dashboard/driver/orders?${qs}` : `/dashboard/driver/orders`);
  }

  function onSearchSubmit(e: React.FormEvent) {
    e.preventDefault();
    apply({ q: term.trim() || undefined });
  }

  // deliver dialog
  const [deliverDlg, setDeliverDlg] = React.useState<DeliverDialogState>({ open: false });

  const detailQ = useGetOrderDetailQuery(
    deliverDlg.open ? { id: deliverDlg.orderId } : (undefined as any),
    { skip: !deliverDlg.open } as any,
  ) as any;

  const [deliverOrder, deliverState] = useDeliverOrderMutation();

  const [note, setNote] = React.useState('');
  const [items, setItems] = React.useState<EditableItem[]>([]);

  React.useEffect(() => {
    if (!deliverDlg.open) return;
    const data: OrderDetailResponse | undefined = detailQ.data;
    if (!data?.order || !Array.isArray(data.items)) return;

    setNote(safeText((data.order as any).delivery_note, ''));
    setItems(
      data.items.map((it: any) => ({
        order_item_id: String(it.id),
        product_id: String(it.product_id),
        qty_ordered: Number(it.qty_ordered ?? 0),
        qty_delivered: Number(it.qty_delivered ?? 0),
      })),
    );
  }, [deliverDlg.open, detailQ.data]);

  function openDeliver(orderId: string) {
    setNote('');
    setItems([]);
    setDeliverDlg({ open: true, orderId });
  }

  function closeDeliver() {
    setDeliverDlg({ open: false });
    setNote('');
    setItems([]);
  }

  function setDelivered(order_item_id: string, v: string) {
    const n = Number(v);
    const val = Number.isFinite(n) && n >= 0 ? Math.floor(n) : 0;
    setItems((prev) =>
      prev.map((x) => (x.order_item_id === order_item_id ? { ...x, qty_delivered: val } : x)),
    );
  }

  function setAllDeliveredToOrdered() {
    setItems((prev) => prev.map((x) => ({ ...x, qty_delivered: x.qty_ordered })));
  }

  async function submitDeliver() {
    if (!deliverDlg.open) return;

    if (items.length === 0) {
      toast.error('Kalem bulunamadı.');
      return;
    }

    const payload: DriverDeliverBody = {
      delivery_note: note.trim() || undefined,
      items: items.map((x) => ({
        order_item_id: x.order_item_id,
        qty_delivered: x.qty_delivered,
      })),
    };

    try {
      await deliverOrder({ id: deliverDlg.orderId, body: payload }).unwrap();
      toast.success('Teslim işlemi kaydedildi.');
      closeDeliver();
      listQ.refetch();
    } catch (err: any) {
      toast.error(safeText(err?.data?.error?.message, 'Teslim kaydedilemedi.'));
    }
  }

  const limit = params.limit ?? 100;
  const offset = params.offset ?? 0;
  const canPrev = offset > 0;
  const canNext = (listQ.data?.length ?? 0) >= limit;

  const rows: OrderView[] = (listQ.data ?? []) as any;

  const filteredRows = React.useMemo(() => {
    const t = term.trim().toLowerCase();
    if (!t) return rows;
    return rows.filter((o) => {
      const a = String((o as any).customer_name ?? '').toLowerCase();
      const p = String((o as any).customer_phone ?? '').toLowerCase();
      const id = String((o as any).id ?? '').toLowerCase();
      return a.includes(t) || p.includes(t) || id.startsWith(t);
    });
  }, [rows, term]);

  const busy = listQ.isFetching || deliverState.isLoading;

  return (
    <div className="space-y-6">
      {/* header */}
      <div className="flex flex-col gap-2 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <h1 className="text-lg font-semibold">Sürücü Siparişleri</h1>
          <p className="text-sm text-muted-foreground">
            Size atanmış siparişleri görüntüleyin ve teslim işlemini kaydedin.
          </p>
        </div>

        <Button
          type="button"
          variant="ghost"
          onClick={() => listQ.refetch()}
          disabled={listQ.isFetching}
          title="Yenile"
        >
          <RefreshCcw className="size-4" />
        </Button>
      </div>

      {/* search */}
      <Card>
        <CardHeader className="gap-2">
          <CardTitle className="text-base">Arama</CardTitle>
          <CardDescription>Ad / telefon / sipariş id ile hızlı filtre.</CardDescription>
        </CardHeader>

        <CardContent>
          <form onSubmit={onSearchSubmit} className="flex flex-col gap-2 sm:flex-row sm:items-end">
            <div className="flex-1 space-y-2">
              <Label htmlFor="q">Arama</Label>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  id="q"
                  value={term}
                  onChange={(e) => setTerm(e.target.value)}
                  placeholder="Örn: 05xx, Ahmet, 7f3a..."
                  className="pl-9"
                />
              </div>
            </div>

            <div className="flex gap-2">
              <Button type="submit" disabled={listQ.isFetching}>
                Uygula
              </Button>
              <Button
                type="button"
                variant="outline"
                disabled={listQ.isFetching}
                onClick={() => {
                  setTerm('');
                  router.push('/dashboard/driver/orders');
                }}
              >
                Sıfırla
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      {/* list */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Liste</CardTitle>
          <CardDescription>
            {listQ.isFetching ? 'Yükleniyor…' : `Kayıt: ${filteredRows.length}`}
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          {listQ.isError ? (
            <div className="rounded-md border p-4 text-sm">
              Liste yüklenemedi.{' '}
              <Button
                variant="link"
                className="px-1"
                onClick={() => {
                  toast.error('Liste yüklenemedi. Tekrar deneyin.');
                  listQ.refetch();
                }}
              >
                Yeniden dene
              </Button>
            </div>
          ) : null}

          {/* Mobile cards */}
          <div className="grid gap-3 md:hidden">
            {filteredRows.map((o) => (
              <div key={o.id} className="rounded-md border p-3">
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <div className="truncate font-medium">{(o as any).customer_name}</div>
                    <div className="truncate text-xs text-muted-foreground">
                      {(o as any).customer_phone}
                    </div>
                  </div>
                  <div className="shrink-0">{statusBadge(o.status)}</div>
                </div>

                <div className="mt-2 flex items-center justify-between text-xs text-muted-foreground">
                  <span>Oluşturma</span>
                  <span>{formatDateTime((o as any).created_at)}</span>
                </div>

                <div className="mt-3">
                  <Button
                    size="sm"
                    className="w-full"
                    disabled={busy || !canDeliver(o)}
                    onClick={() => openDeliver(o.id)}
                  >
                    <Truck className="mr-2 size-4" />
                    Teslim Et
                  </Button>
                </div>
              </div>
            ))}

            {!listQ.isFetching && filteredRows.length === 0 ? (
              <div className="rounded-md border p-6 text-center text-sm text-muted-foreground">
                Kayıt bulunamadı.
              </div>
            ) : null}
          </div>

          {/* Desktop table */}
          <div className="hidden rounded-md border md:block">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Müşteri</TableHead>
                  <TableHead>Telefon</TableHead>
                  <TableHead>Durum</TableHead>
                  <TableHead>Oluşturma</TableHead>
                  <TableHead className="text-right">İşlem</TableHead>
                </TableRow>
              </TableHeader>

              <TableBody>
                {filteredRows.map((o) => (
                  <TableRow key={o.id}>
                    <TableCell className="font-medium">
                      <div className="flex flex-col">
                        <span className="truncate">{(o as any).customer_name}</span>
                        <span className="truncate text-xs text-muted-foreground">
                          #{String(o.id).slice(0, 8)}
                        </span>
                      </div>
                    </TableCell>
                    <TableCell className="text-sm">{(o as any).customer_phone}</TableCell>
                    <TableCell>{statusBadge(o.status)}</TableCell>
                    <TableCell className="text-sm">
                      {formatDateTime((o as any).created_at)}
                    </TableCell>
                    <TableCell className="text-right">
                      <Button
                        size="sm"
                        disabled={busy || !canDeliver(o)}
                        onClick={() => openDeliver(o.id)}
                      >
                        <Truck className="mr-2 size-4" />
                        Teslim Et
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}

                {!listQ.isFetching && filteredRows.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} className="py-10 text-center text-muted-foreground">
                      Kayıt bulunamadı.
                    </TableCell>
                  </TableRow>
                ) : null}
              </TableBody>
            </Table>
          </div>

          {/* pagination */}
          <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
            <div className="text-xs text-muted-foreground">
              Offset: {offset} • Limit: {limit}
            </div>

            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={!canPrev || listQ.isFetching}
                onClick={() => apply({ offset: Math.max(0, offset - limit) })}
              >
                <ChevronLeft className="mr-1 size-4" />
                Önceki
              </Button>

              <Button
                variant="outline"
                size="sm"
                disabled={!canNext || listQ.isFetching}
                onClick={() => apply({ offset: offset + limit })}
              >
                Sonraki
                <ChevronRight className="ml-1 size-4" />
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Deliver dialog */}
      <Dialog open={deliverDlg.open} onOpenChange={(v) => !v && closeDeliver()}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>Teslim İşlemi</DialogTitle>
            <DialogDescription>
              Kalem bazında teslim miktarlarını girin ve kaydedin.
            </DialogDescription>
          </DialogHeader>

          {deliverDlg.open && detailQ.isFetching ? (
            <div className="rounded-md border p-4 text-sm text-muted-foreground">
              Sipariş detayları yükleniyor…
            </div>
          ) : null}

          {deliverDlg.open && detailQ.isError ? (
            <div className="rounded-md border p-4 text-sm">
              Detay yüklenemedi.{' '}
              <Button variant="link" className="px-1" onClick={() => detailQ.refetch()}>
                Yeniden dene
              </Button>
            </div>
          ) : null}

          <div className="space-y-4">
            <div className="grid gap-3 md:grid-cols-2">
              <div className="rounded-md border p-3">
                <div className="text-xs text-muted-foreground">Sipariş</div>
                <div className="font-medium">
                  #{deliverDlg.open ? deliverDlg.orderId.slice(0, 8) : '—'}
                </div>
              </div>
              <div className="rounded-md border p-3">
                <div className="text-xs text-muted-foreground">Durum</div>
                <div className="font-medium">
                  {detailQ.data?.order?.status
                    ? STATUS_LABELS[detailQ.data.order.status as OrderStatus]
                    : '—'}
                </div>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="note">Teslim Notu (opsiyonel)</Label>
              <Textarea
                id="note"
                value={note}
                onChange={(e) => setNote(e.target.value)}
                placeholder="Örn: Kapıya bırakıldı, arandı ulaşılamadı..."
              />
            </div>

            <div className="flex items-center justify-between gap-2">
              <div className="text-sm font-medium flex items-center gap-2">
                <ClipboardList className="size-4" />
                Kalemler
              </div>
              <Button
                type="button"
                variant="outline"
                size="sm"
                onClick={setAllDeliveredToOrdered}
                disabled={items.length === 0}
              >
                Hepsini “Sipariş Adedi” Yap
              </Button>
            </div>

            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Ürün</TableHead>
                    <TableHead className="text-right">Sipariş</TableHead>
                    <TableHead className="text-right">Teslim</TableHead>
                  </TableRow>
                </TableHeader>

                <TableBody>
                  {items.map((it) => (
                    <TableRow key={it.order_item_id}>
                      <TableCell className="font-medium">
                        <div className="flex flex-col">
                          <span className="truncate">#{it.product_id.slice(0, 8)}</span>
                          <span className="truncate text-xs text-muted-foreground">
                            item: {it.order_item_id.slice(0, 8)}
                          </span>
                        </div>
                      </TableCell>
                      <TableCell className="text-right">{it.qty_ordered}</TableCell>
                      <TableCell className="text-right">
                        <Input
                          inputMode="numeric"
                          value={String(it.qty_delivered)}
                          onChange={(e) => setDelivered(it.order_item_id, e.target.value)}
                          className="ml-auto w-28 text-right"
                        />
                      </TableCell>
                    </TableRow>
                  ))}

                  {items.length === 0 && !detailQ.isFetching ? (
                    <TableRow>
                      <TableCell colSpan={3} className="py-8 text-center text-muted-foreground">
                        Kalem bulunamadı.
                      </TableCell>
                    </TableRow>
                  ) : null}
                </TableBody>
              </Table>
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={closeDeliver} disabled={deliverState.isLoading}>
              Kapat
            </Button>
            <Button
              onClick={submitDeliver}
              disabled={deliverState.isLoading || detailQ.isFetching || items.length === 0}
            >
              <Save className="mr-2 size-4" />
              Kaydet (Teslim Et)
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
