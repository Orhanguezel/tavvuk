'use client';

// =============================================================
// FILE: src/app/(main)/admin/notifications/_components/admin-notifications-client.tsx
// FINAL — Admin Notifications UI
// - List + filters + pagination (URL state)
// - Toggle read/unread (PATCH)
// - Mark all read (POST)
// - Delete (DELETE)
// - Unread count (GET)
// =============================================================

import * as React from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { toast } from 'sonner';
import {
  Bell,
  RefreshCcw,
  Search,
  Trash2,
  CheckCheck,
  MailOpen,
  Mail,
  ChevronLeft,
  ChevronRight,
  Loader2,
} from 'lucide-react';

import { cn } from '@/lib/utils';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Separator } from '@/components/ui/separator';
import { Switch } from '@/components/ui/switch';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

import type { NotificationDto } from '@/integrations/types';
import {
  useListNotificationsQuery,
  useGetUnreadNotificationCountQuery,
  usePatchNotificationMutation,
  useMarkAllNotificationsReadMutation,
  useDeleteNotificationMutation,
} from '@/integrations/rtk/hooks';

/* ----------------------------- helpers ----------------------------- */

function safeText(v: unknown, fb = ''): string {
  const s = String(v ?? '').trim();
  return s ? s : fb;
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

function safeInt(v: string | null, fb: number): number {
  const n = Number(v ?? '');
  return Number.isFinite(n) && n >= 0 ? n : fb;
}

function toQS(next: Record<string, any>) {
  const sp = new URLSearchParams();
  Object.entries(next).forEach(([k, v]) => {
    if (v === undefined || v === null || v === '') return;
    sp.set(k, String(v));
  });
  const qs = sp.toString();
  return qs ? `?${qs}` : '';
}

function isReadLabel(v: string) {
  if (v === '1') return 'Okundu';
  if (v === '0') return 'Okunmadı';
  return 'Hepsi';
}

function normalizeReadParam(v: string | null): '' | '0' | '1' {
  if (v === '0' || v === '1') return v;
  return '';
}

function normalizeTypeParam(v: string | null): string {
  const s = String(v ?? '').trim();
  return s;
}

function formatWhen(iso?: string): string {
  if (!iso) return '—';
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) return String(iso);
  // simple local format
  return d.toLocaleString();
}

/* ----------------------------- component ----------------------------- */

export default function AdminNotificationsClient() {
  const router = useRouter();
  const sp = useSearchParams();

  // URL state
  const q = sp.get('q') ?? '';
  const type = normalizeTypeParam(sp.get('type'));
  const is_read = normalizeReadParam(sp.get('is_read'));

  const limit = safeInt(sp.get('limit'), 50) || 50;
  const offset = safeInt(sp.get('offset'), 0);

  // local input state
  const [term, setTerm] = React.useState(q);
  React.useEffect(() => setTerm(q), [q]);

  function apply(
    next: Partial<{
      q: string;
      type: string;
      is_read: '' | '0' | '1';
      limit: number;
      offset: number;
    }>,
  ) {
    const merged = {
      q,
      type,
      is_read,
      limit,
      offset,
      ...next,
    };

    // reset offset unless explicitly set
    if (next.offset == null) merged.offset = 0;

    // clean
    if (!merged.q) merged.q = '';
    if (!merged.type) merged.type = '';
    if (!merged.is_read) merged.is_read = '';
    if (!merged.limit) merged.limit = 50;

    const qs = toQS({
      q: merged.q || undefined,
      type: merged.type || undefined,
      is_read: merged.is_read || undefined,
      limit: merged.limit,
      offset: merged.offset,
    });

    router.push(`/admin/dashboard/notifications${qs}`);
  }

  function onSearchSubmit(e: React.FormEvent) {
    e.preventDefault();
    apply({ q: term.trim() });
  }

  /* ----------------------------- queries ----------------------------- */

  const listQ = useListNotificationsQuery(
    {
      limit,
      offset,
      ...(type ? { type } : {}),
      ...(is_read ? { is_read } : {}),
    } as any,
    { refetchOnFocus: true } as any,
  );

  const unreadQ = useGetUnreadNotificationCountQuery(
    undefined as any,
    {
      refetchOnFocus: true,
    } as any,
  );

  const [patchOne, patchState] = usePatchNotificationMutation();
  const [markAll, markAllState] = useMarkAllNotificationsReadMutation();
  const [delOne, delState] = useDeleteNotificationMutation();

  const busy =
    listQ.isFetching ||
    unreadQ.isFetching ||
    patchState.isLoading ||
    markAllState.isLoading ||
    delState.isLoading;

  const rowsRaw: NotificationDto[] = Array.isArray(listQ.data) ? (listQ.data as any) : [];

  // client-side search (backend q yok)
  const rows = React.useMemo(() => {
    const t = q.trim().toLowerCase();
    if (!t) return rowsRaw;
    return rowsRaw.filter((n) => {
      const hay = `${n.title ?? ''} ${n.message ?? ''}`.toLowerCase();
      return hay.includes(t);
    });
  }, [rowsRaw, q]);

  const canPrev = offset > 0;
  const canNext = rowsRaw.length >= limit; // server page size heuristic

  async function toggleRead(n: NotificationDto) {
    try {
      const next = !(n.is_read === 1);
      await patchOne({ id: n.id, body: { is_read: next } }).unwrap();
      toast.success(next ? 'Okundu olarak işaretlendi.' : 'Okunmadı olarak işaretlendi.');
      listQ.refetch();
      unreadQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  async function onMarkAllRead() {
    try {
      await markAll().unwrap();
      toast.success('Tüm bildirimler okundu yapıldı.');
      listQ.refetch();
      unreadQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  async function onDelete(id: string) {
    try {
      await delOne({ id }).unwrap();
      toast.success('Bildirim silindi.');
      listQ.refetch();
      unreadQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  const unreadCount = Number((unreadQ.data as any)?.count ?? 0);

  return (
    <div className="space-y-6">
      {/* header */}
      <div className="flex flex-col gap-2 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <h1 className="text-lg font-semibold">Bildirimler</h1>
          <p className="text-sm text-muted-foreground">
            Bildirimleri görüntüleyin, okundu işaretleyin ve yönetin.
          </p>
        </div>

        <div className="flex gap-2">
          <Button
            type="button"
            variant="outline"
            onClick={() => {
              listQ.refetch();
              unreadQ.refetch();
            }}
            disabled={busy}
            title="Yenile"
          >
            {busy ? (
              <Loader2 className="mr-2 size-4 animate-spin" />
            ) : (
              <RefreshCcw className="mr-2 size-4" />
            )}
            Yenile
          </Button>

          <Button type="button" onClick={onMarkAllRead} disabled={busy || unreadCount === 0}>
            <CheckCheck className="mr-2 size-4" />
            Tümünü Okundu Yap
          </Button>
        </div>
      </div>

      {/* quick stats */}
      <div className="grid gap-4 md:grid-cols-3">
        <Card>
          <CardHeader className="pb-3">
            <CardTitle className="text-sm">Okunmamış</CardTitle>
            <CardDescription>Şu an okunmamış bildirim adedi</CardDescription>
          </CardHeader>
          <CardContent className="flex items-center justify-between">
            <div className="text-2xl font-semibold">{unreadQ.isFetching ? '—' : unreadCount}</div>
            <Bell className="size-5 text-muted-foreground" />
          </CardContent>
        </Card>

        <Card className="md:col-span-2">
          <CardHeader className="pb-3">
            <CardTitle className="text-sm">Filtre / Arama</CardTitle>
            <CardDescription>Sunucu filtreleri: type + is_read. Arama client-side.</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <form
              onSubmit={onSearchSubmit}
              className="flex flex-col gap-3 lg:flex-row lg:items-end"
            >
              <div className="flex-1 space-y-2">
                <Label htmlFor="q">Arama</Label>
                <div className="relative">
                  <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="q"
                    value={term}
                    onChange={(e) => setTerm(e.target.value)}
                    placeholder="Title / message içinde ara…"
                    className="pl-9"
                  />
                </div>
              </div>

              <div className="w-full space-y-2 lg:w-56">
                <Label>Durum</Label>
                <Select
                  value={is_read || 'all'}
                  onValueChange={(v) =>
                    apply({ is_read: v === 'all' ? '' : (v as any), offset: 0 })
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Hepsi" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Hepsi</SelectItem>
                    <SelectItem value="0">Okunmadı</SelectItem>
                    <SelectItem value="1">Okundu</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div className="w-full space-y-2 lg:w-64">
                <Label>Type</Label>
                <Input
                  value={type}
                  onChange={(e) => apply({ type: e.target.value.trim(), offset: 0 })}
                  placeholder="Örn: order_created"
                />
                <p className="text-xs text-muted-foreground">Boş bırak: tüm type’lar</p>
              </div>

              <div className="flex gap-2">
                <Button type="submit" disabled={busy}>
                  Uygula
                </Button>
                <Button
                  type="button"
                  variant="outline"
                  disabled={busy}
                  onClick={() => {
                    setTerm('');
                    apply({ q: '', type: '', is_read: '', offset: 0 });
                  }}
                >
                  Sıfırla
                </Button>
              </div>
            </form>

            <Separator />

            <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
              <div className="text-xs text-muted-foreground">
                Sayfa kayıt (server): {listQ.isFetching ? '—' : rowsRaw.length} • Görünen (client
                q): {listQ.isFetching ? '—' : rows.length} • Durum: {isReadLabel(is_read || '')}
              </div>

              <div className="flex gap-2">
                <Button
                  variant="outline"
                  size="sm"
                  disabled={!canPrev || busy}
                  onClick={() => apply({ offset: Math.max(0, offset - limit) })}
                >
                  <ChevronLeft className="mr-1 size-4" />
                  Önceki
                </Button>

                <Button
                  variant="outline"
                  size="sm"
                  disabled={busy || !canNext}
                  onClick={() => apply({ offset: offset + limit })}
                >
                  Sonraki
                  <ChevronRight className="ml-1 size-4" />
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* list */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Bildirim Listesi</CardTitle>
          <CardDescription>/notifications</CardDescription>
        </CardHeader>
        <CardContent>
          {listQ.isError ? (
            <div className="rounded-md border p-4 text-sm">
              Bildirimler yüklenemedi.{' '}
              <Button variant="link" className="px-1" onClick={() => listQ.refetch()}>
                Yeniden dene
              </Button>
            </div>
          ) : (
            <div className="rounded-md border">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Durum</TableHead>
                    <TableHead>Başlık / Mesaj</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Zaman</TableHead>
                    <TableHead className="text-right">İşlem</TableHead>
                  </TableRow>
                </TableHeader>

                <TableBody>
                  {rows.map((n) => {
                    const read = n.is_read === 1;
                    return (
                      <TableRow key={n.id} className={cn(!read ? 'bg-muted/30' : '')}>
                        <TableCell className="whitespace-nowrap">
                          <div className="flex items-center gap-2">
                            {read ? (
                              <MailOpen className="size-4 text-muted-foreground" />
                            ) : (
                              <Mail className="size-4 text-muted-foreground" />
                            )}
                            <Badge variant={read ? 'secondary' : 'default'}>
                              {read ? 'Okundu' : 'Okunmadı'}
                            </Badge>
                          </div>
                        </TableCell>

                        <TableCell className="min-w-90">
                          <div className="flex flex-col gap-1">
                            <div className="font-medium">{safeText(n.title, '—')}</div>
                            <div className="text-xs text-muted-foreground line-clamp-2">
                              {safeText(n.message, '—')}
                            </div>
                            <div className="text-xs text-muted-foreground">
                              #{String(n.id).slice(0, 8)}
                            </div>
                          </div>
                        </TableCell>

                        <TableCell className="whitespace-nowrap">
                          <Badge variant="outline">{safeText(n.type, '—')}</Badge>
                        </TableCell>

                        <TableCell className="whitespace-nowrap text-sm">
                          {formatWhen(n.created_at)}
                        </TableCell>

                        <TableCell className="text-right">
                          <div className="flex justify-end gap-2">
                            <Button
                              size="sm"
                              variant="outline"
                              onClick={() => toggleRead(n)}
                              disabled={busy}
                              title="Okundu/okunmadı değiştir"
                            >
                              {read ? 'Okunmadı Yap' : 'Okundu Yap'}
                            </Button>

                            <Button
                              size="sm"
                              variant="destructive"
                              onClick={() => onDelete(n.id)}
                              disabled={busy}
                              title="Sil"
                            >
                              <Trash2 className="mr-2 size-4" />
                              Sil
                            </Button>
                          </div>
                        </TableCell>
                      </TableRow>
                    );
                  })}

                  {!listQ.isFetching && rows.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={5} className="py-10 text-center text-muted-foreground">
                        Kayıt bulunamadı.
                      </TableCell>
                    </TableRow>
                  ) : null}
                </TableBody>
              </Table>
            </div>
          )}

          <div className="mt-3 text-xs text-muted-foreground">
            Not: Arama (q) sadece bu sayfadaki kayıtlar üzerinde çalışır. Server-side arama istersen
            backend list endpoint’ine q ekleriz.
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
