'use client';

// =============================================================
// FILE: src/app/(main)/admin/orders/_components/admin-orders-list-client.tsx
// FINAL — Admin Orders List (Better responsive table)
// + Driver column:
//   - If assigned_driver_full_name exists => show it
//   - Else fallback to driver object full_name (if API provides)
//   - Else "-" (dash)
// Notes:
// - Cards on <lg, table on lg+
// - Actions wrap, no overlap
// =============================================================

import * as React from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { toast } from 'sonner';
import {
  RefreshCcw,
  ChevronLeft,
  ChevronRight,
  Search,
  CheckCircle2,
  UserPlus,
  Ban,
  Eye,
  X,
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
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

import type { AdminListOrdersQuery, OrderStatus, OrderView } from '@/integrations/types';

import {
  useAdminListOrdersQuery,
  useAdminApproveOrderMutation,
  useAdminAssignDriverMutation,
  useAdminCancelOrderMutation,
} from '@/integrations/rtk/hooks';

import { DriverPicker, type DriverOption } from './driver-picker';

/* ----------------------------- helpers ----------------------------- */

const STATUS_LABELS: Record<OrderStatus, string> = {
  submitted: 'Gönderildi',
  approved: 'Onaylandı',
  assigned: 'Atandı',
  on_delivery: 'Dağıtımda',
  delivered: 'Teslim',
  cancelled: 'İptal',
};

const STATUS_OPTIONS: { value: OrderStatus | 'all'; label: string }[] = [
  { value: 'all', label: 'Tümü' },
  { value: 'submitted', label: 'Gönderildi' },
  { value: 'approved', label: 'Onaylandı' },
  { value: 'assigned', label: 'Atandı' },
  { value: 'on_delivery', label: 'Dağıtımda' },
  { value: 'delivered', label: 'Teslim' },
  { value: 'cancelled', label: 'İptal' },
];

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
 * Görüntü odaklı adres:
 * 1) city/district varsa: "Kırşehir/Kaman"
 * 2) yoksa address_text: normalize edilmiş metin
 * 3) yoksa "—"
 */
function addressText(o: OrderView): string {
  const city =
    safeText((o as any)?.city_name, '') ||
    safeText((o as any)?.city?.name, '') ||
    safeText((o as any)?.city, '') ||
    safeText((o as any)?.address_city, '');

  const district =
    safeText((o as any)?.district_name, '') ||
    safeText((o as any)?.district?.name, '') ||
    safeText((o as any)?.district, '') ||
    safeText((o as any)?.address_district, '');

  if (city && district) return `${city}/${district}`;
  if (city) return city;

  const raw = safeText((o as any)?.address_text, '');
  if (raw) return raw.replace(/\s+/g, ' ').trim() || '—';

  return '—';
}

/**
 * ✅ Driver display:
 * - preferred: assigned_driver_full_name (backend can send via join)
 * - fallback: driver.full_name / assigned_driver.name-like object
 * - else: "-"
 */
function driverText(o: OrderView): string {
  const full =
    safeText((o as any)?.assigned_driver_full_name, '') ||
    safeText((o as any)?.assigned_driver_name, '') ||
    safeText((o as any)?.driver_full_name, '') ||
    safeText((o as any)?.driver?.full_name, '') ||
    safeText((o as any)?.assigned_driver?.full_name, '') ||
    safeText((o as any)?.assigned_driver?.name, '');

  if (full) return full;

  const id = safeText((o as any)?.assigned_driver_id, '');
  if (!id) return '-';

  // assigned but name not provided by API
  return '-';
}

function pickQuery(sp: URLSearchParams): AdminListOrdersQuery {
  const status = (sp.get('status') ?? undefined) as OrderStatus | undefined;
  const q = sp.get('q') ?? undefined;
  const city_id = sp.get('city_id') ?? undefined;
  const district_id = sp.get('district_id') ?? undefined;
  const date_from = sp.get('date_from') ?? undefined;
  const date_to = sp.get('date_to') ?? undefined;

  const limit = safeInt(sp.get('limit'), 50) || 50;
  const offset = safeInt(sp.get('offset'), 0);

  const sort = (sp.get('sort') ?? undefined) as any;
  const order = (sp.get('order') ?? undefined) as any;

  return {
    ...(status ? { status } : {}),
    ...(q ? { q } : {}),
    ...(city_id ? { city_id } : {}),
    ...(district_id ? { district_id } : {}),
    ...(date_from ? { date_from } : {}),
    ...(date_to ? { date_to } : {}),
    ...(sort ? { sort } : {}),
    ...(order ? { order } : {}),
    limit,
    offset,
  } as any;
}

function toSearchParams(p: AdminListOrdersQuery): string {
  const sp = new URLSearchParams();

  if ((p as any).status) sp.set('status', String((p as any).status));
  if ((p as any).q) sp.set('q', String((p as any).q));
  if ((p as any).city_id) sp.set('city_id', String((p as any).city_id));
  if ((p as any).district_id) sp.set('district_id', String((p as any).district_id));
  if ((p as any).date_from) sp.set('date_from', String((p as any).date_from));
  if ((p as any).date_to) sp.set('date_to', String((p as any).date_to));

  if ((p as any).sort) sp.set('sort', String((p as any).sort));
  if ((p as any).order) sp.set('order', String((p as any).order));

  if (p.limit != null) sp.set('limit', String(p.limit));
  if (p.offset != null) sp.set('offset', String(p.offset));

  return sp.toString();
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

/* ----------------------------- dialogs ----------------------------- */

type AssignDlgState =
  | { open: false }
  | { open: true; orderId: string; currentDriverId?: string | null };

type CancelDlgState = { open: false } | { open: true; orderId: string };

export default function AdminOrdersListClient() {
  const router = useRouter();
  const sp = useSearchParams();

  const params = React.useMemo(() => pickQuery(sp), [sp]);
  const listQ = useAdminListOrdersQuery(params);

  const [approveOrder, approveState] = useAdminApproveOrderMutation();
  const [assignDriver, assignState] = useAdminAssignDriverMutation();
  const [cancelOrder, cancelState] = useAdminCancelOrderMutation();

  const [term, setTerm] = React.useState(params.q ?? '');
  const [status, setStatus] = React.useState<OrderStatus | 'all'>((params.status as any) ?? 'all');

  React.useEffect(() => {
    setTerm(params.q ?? '');
    setStatus((params.status as any) ?? 'all');
  }, [params.q, params.status]);

  function apply(next: Partial<AdminListOrdersQuery>) {
    const merged: any = { ...params, ...next, offset: next.offset != null ? next.offset : 0 };

    if (!merged.q) delete merged.q;
    if (!merged.status) delete merged.status;
    if (!merged.city_id) delete merged.city_id;
    if (!merged.district_id) delete merged.district_id;
    if (!merged.date_from) delete merged.date_from;
    if (!merged.date_to) delete merged.date_to;

    const qs = toSearchParams(merged);
    router.push(qs ? `/admin/dashboard/orders?${qs}` : `/admin/dashboard/orders`);
  }

  function onSubmitFilters(e: React.FormEvent) {
    e.preventDefault();
    apply({
      q: term.trim() || undefined,
      status: status === 'all' ? undefined : (status as OrderStatus),
    } as any);
  }

  const limit = params.limit ?? 50;
  const offset = params.offset ?? 0;
  const canPrev = offset > 0;
  const canNext = (listQ.data?.length ?? 0) >= limit;

  const [assignDlg, setAssignDlg] = React.useState<AssignDlgState>({ open: false });
  const [driverId, setDriverId] = React.useState('');
  const [driverLabel, setDriverLabel] = React.useState<string>(''); // UI label
  const [assignNote, setAssignNote] = React.useState('');

  const [cancelDlg, setCancelDlg] = React.useState<CancelDlgState>({ open: false });
  const [cancelReason, setCancelReason] = React.useState('');

  function openAssign(o: OrderView) {
    const current = safeText((o as any).assigned_driver_id, '');
    setDriverId(current);
    setDriverLabel('');
    setAssignNote('');
    setAssignDlg({ open: true, orderId: o.id, currentDriverId: (o as any).assigned_driver_id });
  }

  function closeAssign() {
    setAssignDlg({ open: false });
    setDriverId('');
    setDriverLabel('');
    setAssignNote('');
  }

  function openCancel(o: OrderView) {
    setCancelReason('');
    setCancelDlg({ open: true, orderId: o.id });
  }

  function closeCancel() {
    setCancelDlg({ open: false });
    setCancelReason('');
  }

  async function doApprove(orderId: string) {
    try {
      await approveOrder({ id: orderId }).unwrap();
      toast.success('Sipariş onaylandı.');
      listQ.refetch();
    } catch (err: any) {
      toast.error(safeText(err?.data?.error?.message, 'Onaylanamadı.'));
    }
  }

  async function doAssign() {
    if (!assignDlg.open) return;

    const id = assignDlg.orderId;
    const dId = driverId.trim();

    if (!dId) {
      toast.error('Sürücü seçimi zorunlu.');
      return;
    }

    try {
      const res = await assignDriver({ id, body: { driver_id: dId } }).unwrap();
      toast.success('Sürücü atandı.');
      closeAssign();
      listQ.refetch();

      const aId = (res as any)?.assignment?.id;
      if (aId) toast.message(`Atama: #${String(aId).slice(0, 8)}`);
    } catch (err: any) {
      toast.error(safeText(err?.data?.error?.message, 'Atama yapılamadı.'));
    }
  }

  async function doCancel() {
    if (!cancelDlg.open) return;

    const id = cancelDlg.orderId;
    try {
      await cancelOrder({ id, body: { cancel_reason: cancelReason.trim() || undefined } }).unwrap();
      toast.success('Sipariş iptal edildi.');
      closeCancel();
      listQ.refetch();
    } catch (err: any) {
      toast.error(safeText(err?.data?.error?.message, 'İptal edilemedi.'));
    }
  }

  const busy =
    listQ.isFetching || approveState.isLoading || assignState.isLoading || cancelState.isLoading;

  const rows: OrderView[] = (listQ.data ?? []) as any;

  return (
    <div className="space-y-6">
      {/* header */}
      <div className="flex flex-col gap-2 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <h1 className="text-lg font-semibold">Siparişler (Admin)</h1>
          <p className="text-sm text-muted-foreground">
            Siparişleri listeleyin, onaylayın, sürücü atayın veya iptal edin.
          </p>
        </div>

        <div className="flex gap-2">
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
      </div>

      {/* filters */}
      <Card>
        <CardHeader className="gap-2">
          <CardTitle className="text-base">Filtreler</CardTitle>
          <CardDescription>Telefon/ad ile arama, durum filtresi.</CardDescription>
        </CardHeader>

        <CardContent>
          <form onSubmit={onSubmitFilters} className="flex flex-col gap-3 lg:flex-row lg:items-end">
            <div className="flex-1 space-y-2">
              <Label htmlFor="q">Arama</Label>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  id="q"
                  value={term}
                  onChange={(e) => setTerm(e.target.value)}
                  placeholder="Müşteri adı veya telefon..."
                  className="pl-9"
                />
              </div>
            </div>

            <div className="w-full space-y-2 lg:w-64">
              <Label>Durum</Label>
              <Select
                value={status}
                onValueChange={(v) => {
                  const vv = v as OrderStatus | 'all';
                  setStatus(vv);
                  apply({ status: vv === 'all' ? undefined : (vv as any) } as any);
                }}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Tümü" />
                </SelectTrigger>
                <SelectContent>
                  {STATUS_OPTIONS.map((s) => (
                    <SelectItem key={s.value} value={s.value}>
                      {s.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <Button asChild>
              <Link prefetch={false} href="/admin/dashboard/orders/new">
                Yeni Sipariş
              </Link>
            </Button>

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
                  setStatus('all');
                  router.push('/admin/dashboard/orders');
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
            {listQ.isFetching ? 'Yükleniyor…' : `Kayıt: ${rows.length} (sayfa)`}
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

          {/* Cards on <lg */}
          <div className="grid gap-3 lg:hidden">
            {rows.map((o) => (
              <div key={o.id} className="rounded-md border p-3">
                <div className="flex items-start justify-between gap-2">
                  <div className="min-w-0">
                    <div className="truncate font-medium">{o.customer_name}</div>
                    <div className="truncate text-xs text-muted-foreground">
                      {safeText(o.customer_phone, '—')}
                    </div>

                    <div className="mt-1 text-xs text-muted-foreground whitespace-normal line-clamp-2 leading-relaxed">
                      {addressText(o)}
                    </div>

                    <div className="mt-1 text-xs text-muted-foreground">
                      Sürücü: <span className="font-medium text-foreground">{driverText(o)}</span>
                    </div>
                  </div>

                  <div className="shrink-0">{statusBadge(o.status)}</div>
                </div>

                <div className="mt-2 flex items-center justify-between text-xs text-muted-foreground">
                  <span>Oluşturma</span>
                  <span>{formatDateTime(o.created_at as any)}</span>
                </div>

                <div className="mt-3 grid grid-cols-2 gap-2">
                  <Button asChild variant="outline" size="sm">
                    <Link
                      prefetch={false}
                      href={`/admin/dashboard/orders/${encodeURIComponent(o.id)}`}
                    >
                      <Eye className="mr-2 size-4" />
                      Detay
                    </Link>
                  </Button>

                  <Button
                    size="sm"
                    disabled={busy || !canApprove(o)}
                    onClick={() => doApprove(o.id)}
                  >
                    <CheckCircle2 className="mr-2 size-4" />
                    Onayla
                  </Button>

                  <Button
                    size="sm"
                    variant="secondary"
                    disabled={busy || !canAssign(o)}
                    onClick={() => openAssign(o)}
                  >
                    <UserPlus className="mr-2 size-4" />
                    Ata
                  </Button>

                  <Button
                    size="sm"
                    variant="destructive"
                    disabled={busy || !canCancel(o)}
                    onClick={() => openCancel(o)}
                  >
                    <Ban className="mr-2 size-4" />
                    İptal
                  </Button>
                </div>
              </div>
            ))}

            {!listQ.isFetching && rows.length === 0 ? (
              <div className="rounded-md border p-6 text-center text-sm text-muted-foreground">
                Kayıt bulunamadı.
              </div>
            ) : null}
          </div>

          {/* Table on lg+ */}
          <div className="hidden rounded-md border lg:block">
            <Table className="w-full">
              <TableHeader>
                <TableRow>
                  <TableHead className="min-w-55 w-[22%]">Müşteri</TableHead>
                  <TableHead className="min-w-55 w-[16%]">Sürücü</TableHead>
                  <TableHead className="min-w-60 w-[30%]">Adres</TableHead>
                  <TableHead className="w-[10%] whitespace-nowrap">Durum</TableHead>
                  <TableHead className="min-w-35 w-[12%] whitespace-nowrap">Oluşturma</TableHead>
                  <TableHead className="min-w-55 w-[10%] text-right whitespace-nowrap">
                    Aksiyon
                  </TableHead>
                </TableRow>
              </TableHeader>

              <TableBody>
                {rows.map((o) => (
                  <TableRow key={o.id} className="align-top">
                    {/* Customer */}
                    <TableCell className="py-5">
                      <div className="flex flex-col gap-1 min-w-0">
                        <span className="truncate font-medium">{o.customer_name}</span>
                        <span className="truncate text-xs text-muted-foreground">
                          {safeText(o.customer_phone, '—')}
                        </span>
                      </div>
                    </TableCell>

                    {/* Driver */}
                    <TableCell className="py-5">
                      <div className="min-w-0">
                        <div className="truncate text-sm font-medium">{driverText(o)}</div>
                        <div className="truncate text-xs text-muted-foreground">
                          {safeText((o as any)?.assigned_driver_phone, '') ||
                            safeText((o as any)?.driver?.phone, '') ||
                            safeText((o as any)?.assigned_driver?.phone, '') ||
                            ''}
                        </div>
                      </div>
                    </TableCell>

                    {/* Address */}
                    <TableCell className="py-5">
                      <div className="text-sm whitespace-normal leading-relaxed line-clamp-3 wrap-break-word">
                        {addressText(o)}
                      </div>
                    </TableCell>

                    {/* Status */}
                    <TableCell className="py-5 whitespace-nowrap">
                      {statusBadge(o.status)}
                    </TableCell>

                    {/* Created */}
                    <TableCell className="py-5 text-sm whitespace-nowrap">
                      {formatDateTime(o.created_at as any)}
                    </TableCell>

                    {/* Actions */}
                    <TableCell className="py-5 text-right">
                      <div className="flex justify-end gap-2 flex-wrap">
                        {/* compact icon-only on lg..xl */}
                        <div className="flex gap-2 xl:hidden">
                          <Button asChild variant="outline" size="icon" className="size-9">
                            <Link
                              prefetch={false}
                              href={`/admin/dashboard/orders/${encodeURIComponent(o.id)}`}
                              title="Detay"
                            >
                              <Eye className="size-4" />
                            </Link>
                          </Button>

                          <Button
                            size="icon"
                            className="size-9"
                            disabled={busy || !canApprove(o)}
                            onClick={() => doApprove(o.id)}
                            title="Onayla"
                          >
                            <CheckCircle2 className="size-4" />
                          </Button>

                          <Button
                            size="icon"
                            variant="secondary"
                            className="size-9"
                            disabled={busy || !canAssign(o)}
                            onClick={() => openAssign(o)}
                            title="Ata"
                          >
                            <UserPlus className="size-4" />
                          </Button>

                          <Button
                            size="icon"
                            variant="destructive"
                            className="size-9"
                            disabled={busy || !canCancel(o)}
                            onClick={() => openCancel(o)}
                            title="İptal"
                          >
                            <Ban className="size-4" />
                          </Button>
                        </div>

                        {/* full buttons on xl+ */}
                        <div className="hidden gap-2 xl:flex flex-wrap justify-end">
                          <Button asChild variant="outline" size="sm">
                            <Link
                              prefetch={false}
                              href={`/admin/dashboard/orders/${encodeURIComponent(o.id)}`}
                            >
                              <Eye className="mr-2 size-4" />
                              Detay
                            </Link>
                          </Button>

                          <Button
                            size="sm"
                            disabled={busy || !canApprove(o)}
                            onClick={() => doApprove(o.id)}
                            title={
                              canApprove(o) ? 'Onayla' : 'Sadece gönderilmiş sipariş onaylanır'
                            }
                          >
                            <CheckCircle2 className="mr-2 size-4" />
                            Onayla
                          </Button>

                          <Button
                            size="sm"
                            variant="secondary"
                            disabled={busy || !canAssign(o)}
                            onClick={() => openAssign(o)}
                            title={canAssign(o) ? 'Sürücü ata' : 'Sadece onaylı sipariş atanır'}
                          >
                            <UserPlus className="mr-2 size-4" />
                            Ata
                          </Button>

                          <Button
                            size="sm"
                            variant="destructive"
                            disabled={busy || !canCancel(o)}
                            onClick={() => openCancel(o)}
                            title={
                              canCancel(o) ? 'İptal et' : 'Teslim/iptal sipariş iptal edilemez'
                            }
                          >
                            <Ban className="mr-2 size-4" />
                            İptal
                          </Button>
                        </div>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}

                {!listQ.isFetching && rows.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="py-10 text-center text-muted-foreground">
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
                onClick={() => apply({ offset: Math.max(0, offset - limit) } as any)}
              >
                <ChevronLeft className="mr-1 size-4" />
                Önceki
              </Button>

              <Button
                variant="outline"
                size="sm"
                disabled={!canNext || listQ.isFetching}
                onClick={() => apply({ offset: offset + limit } as any)}
              >
                Sonraki
                <ChevronRight className="ml-1 size-4" />
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Assign driver dialog */}
      <Dialog open={assignDlg.open} onOpenChange={(v) => !v && closeAssign()}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Sürücü Ata</DialogTitle>
            <DialogDescription>
              Sipariş onaylı olmalıdır. Atama işlemi siparişi “Atandı” durumuna geçirir.
            </DialogDescription>
          </DialogHeader>

          <div className="space-y-4">
            <div className="grid gap-3 md:grid-cols-2">
              <div className="rounded-md border p-3">
                <div className="text-xs text-muted-foreground">Sipariş</div>
                <div className="font-medium">
                  #{assignDlg.open ? assignDlg.orderId.slice(0, 8) : '—'}
                </div>
              </div>

              <div className="rounded-md border p-3">
                <div className="text-xs text-muted-foreground">Sürücü</div>
                <div className="font-medium truncate">
                  {driverLabel || (driverId ? `#${driverId.slice(0, 8)}` : '—')}
                </div>
              </div>
            </div>

            <div className="space-y-2">
              <Label>Sürücü Seç</Label>
              <DriverPicker
                value={driverId}
                onChange={(nextId, d?: DriverOption) => {
                  setDriverId(nextId);
                  setDriverLabel(d ? `${d.full_name}${d.phone ? ` • ${d.phone}` : ''}` : '');
                }}
                disabled={assignState.isLoading}
                placeholder="Sürücü seç…"
                initialLabel={driverId ? `#${driverId.slice(0, 8)}` : undefined}
              />
              <p className="text-xs text-muted-foreground">
                İsim/telefon ile arayın; seçince sistem sürücü ID’sini otomatik kullanır.
              </p>
            </div>

            <div className="space-y-2">
              <Label htmlFor="note">Not (opsiyonel)</Label>
              <Textarea
                id="note"
                value={assignNote}
                onChange={(e) => setAssignNote(e.target.value)}
                placeholder="Örn: Acil teslimat"
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={closeAssign} disabled={assignState.isLoading}>
              <X className="mr-2 size-4" />
              Kapat
            </Button>

            <Button onClick={doAssign} disabled={assignState.isLoading || !driverId.trim()}>
              <UserPlus className="mr-2 size-4" />
              Ata
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Cancel dialog */}
      <Dialog open={cancelDlg.open} onOpenChange={(v) => !v && closeCancel()}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Siparişi İptal Et</DialogTitle>
            <DialogDescription>Teslim edilmiş siparişler MVP’de iptal edilemez.</DialogDescription>
          </DialogHeader>

          <div className="space-y-4">
            <div className="rounded-md border p-3">
              <div className="text-xs text-muted-foreground">Sipariş</div>
              <div className="font-medium">
                #{cancelDlg.open ? cancelDlg.orderId.slice(0, 8) : '—'}
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="cancelReason">İptal Sebebi (opsiyonel)</Label>
              <Textarea
                id="cancelReason"
                value={cancelReason}
                onChange={(e) => setCancelReason(e.target.value)}
                placeholder="Örn: Müşteri iptal etti / stok yok / adres hatalı..."
              />
            </div>
          </div>

          <DialogFooter>
            <Button variant="outline" onClick={closeCancel} disabled={cancelState.isLoading}>
              <X className="mr-2 size-4" />
              Vazgeç
            </Button>

            <Button variant="destructive" onClick={doCancel} disabled={cancelState.isLoading}>
              <Ban className="mr-2 size-4" />
              İptal Et
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
