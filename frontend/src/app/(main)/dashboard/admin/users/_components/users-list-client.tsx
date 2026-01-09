'use client';

// src/app/(main)/dashboard/admin/users/_components/users-list-client.tsx

import * as React from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { Search, Filter, RefreshCcw, ChevronLeft, ChevronRight } from 'lucide-react';
import { toast } from 'sonner';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';

import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

import { Badge } from '@/components/ui/badge';

import type { Role } from '@/integrations/types';
import type { AdminUsersListParams, AdminUserView } from '@/integrations/types';
import { useAdminListQuery } from '@/integrations/rtk/hooks';

function roleLabel(r: Role) {
  if (r === 'admin') return 'Admin';
  if (r === 'seller') return 'Satıcı';
  if (r === 'driver') return 'Şoför';
  return r;
}

function boolParam(v: string | null): boolean | undefined {
  if (v == null) return undefined;
  const s = v.trim();
  if (s === '1' || s === 'true') return true;
  if (s === '0' || s === 'false') return false;
  return undefined;
}

function safeInt(v: string | null, fb: number): number {
  const n = Number(v ?? '');
  return Number.isFinite(n) && n >= 0 ? n : fb;
}

function pickQuery(sp: URLSearchParams): AdminUsersListParams {
  const q = sp.get('q') ?? undefined;
  const role = (sp.get('role') ?? undefined) as Role | undefined;
  const is_active = boolParam(sp.get('is_active'));
  const limit = safeInt(sp.get('limit'), 20) || 20;
  const offset = safeInt(sp.get('offset'), 0);

  const sort = (sp.get('sort') ?? undefined) as AdminUsersListParams['sort'] | undefined;
  const order = (sp.get('order') ?? undefined) as AdminUsersListParams['order'] | undefined;

  return {
    ...(q ? { q } : {}),
    ...(role ? { role } : {}),
    ...(typeof is_active === 'boolean' ? { is_active } : {}),
    limit,
    offset,
    ...(sort ? { sort } : {}),
    ...(order ? { order } : {}),
  };
}

function toSearchParams(p: AdminUsersListParams): string {
  const sp = new URLSearchParams();
  if (p.q) sp.set('q', p.q);
  if (p.role) sp.set('role', p.role);
  if (typeof p.is_active === 'boolean') sp.set('is_active', p.is_active ? '1' : '0');
  if (p.limit != null) sp.set('limit', String(p.limit));
  if (p.offset != null) sp.set('offset', String(p.offset));
  if (p.sort) sp.set('sort', p.sort);
  if (p.order) sp.set('order', p.order);
  return sp.toString();
}

function statusBadge(u: AdminUserView) {
  if (!u.is_active) return <Badge variant="destructive">Pasif</Badge>;
  return <Badge variant="secondary">Aktif</Badge>;
}

function displayName(u: Pick<AdminUserView, 'full_name'>) {
  const n = String(u.full_name ?? '').trim();
  return n || 'İsimsiz Kullanıcı';
}

export default function UsersListClient() {
  const router = useRouter();
  const sp = useSearchParams();

  const params = React.useMemo(() => pickQuery(sp), [sp]);

  const usersQ = useAdminListQuery(params);

  // UI state (controlled) – URL ile senkron
  const [q, setQ] = React.useState(params.q ?? '');
  const [role, setRole] = React.useState<Role | 'all'>(params.role ?? 'all');
  const [onlyActive, setOnlyActive] = React.useState<boolean | 'all'>(
    typeof params.is_active === 'boolean' ? (params.is_active ? true : false) : 'all',
  );

  React.useEffect(() => {
    setQ(params.q ?? '');
    setRole(params.role ?? 'all');
    setOnlyActive(
      typeof params.is_active === 'boolean' ? (params.is_active ? true : false) : 'all',
    );
  }, [params.q, params.role, params.is_active]);

  function apply(next: Partial<AdminUsersListParams>) {
    const merged: AdminUsersListParams = {
      ...params,
      ...next,
      offset: next.offset != null ? next.offset : 0,
    };

    if (!merged.q) delete (merged as any).q;
    if (!merged.role) delete (merged as any).role;
    if (typeof merged.is_active !== 'boolean') delete (merged as any).is_active;

    const qs = toSearchParams(merged);
    router.push(qs ? `/dashboard/admin/users?${qs}` : `/dashboard/admin/users`);
  }

  function onSearchSubmit(e: React.FormEvent) {
    e.preventDefault();
    apply({ q: q.trim() || undefined });
  }

  const limit = params.limit ?? 20;
  const offset = params.offset ?? 0;

  const canPrev = offset > 0;
  const canNext = (usersQ.data?.length ?? 0) >= limit;

  return (
    <div className="space-y-6">
      <div className="space-y-1">
        <h1 className="text-lg font-semibold">Kullanıcılar</h1>
        <p className="text-sm text-muted-foreground">
          Kullanıcıları görüntüleyin, düzenleyin ve rollerini yönetin.
        </p>
      </div>

      <Card>
        <CardHeader className="gap-2">
          <CardTitle className="text-base">Filtreler</CardTitle>
          <CardDescription>Arama ve filtreleme ayarları.</CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          <form onSubmit={onSearchSubmit} className="flex flex-col gap-3 lg:flex-row lg:items-end">
            <div className="flex-1 space-y-2">
              <Label htmlFor="q">Arama</Label>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  id="q"
                  value={q}
                  onChange={(e) => setQ(e.target.value)}
                  placeholder="Ad, telefon..."
                  className="pl-9"
                />
              </div>
            </div>

            <div className="w-full space-y-2 lg:w-56">
              <Label>Rol</Label>
              <Select
                value={role}
                onValueChange={(v) => {
                  const vv = v as Role | 'all';
                  setRole(vv);
                  apply({ role: vv === 'all' ? undefined : (vv as Role) });
                }}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Tümü" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Tümü</SelectItem>
                  <SelectItem value="admin">Admin</SelectItem>
                  <SelectItem value="seller">Satıcı</SelectItem>
                  <SelectItem value="driver">Şoför</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="flex items-center gap-2">
              <Filter className="size-4 text-muted-foreground" />
              <Label className="text-sm">Sadece aktif</Label>
              <Switch
                checked={onlyActive === true}
                onCheckedChange={(v) => {
                  const next = v ? true : 'all';
                  setOnlyActive(next);
                  apply({ is_active: v ? true : undefined });
                }}
              />
            </div>

            <div className="flex gap-2">
              <Button type="submit" disabled={usersQ.isFetching}>
                Ara
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  setQ('');
                  setRole('all');
                  setOnlyActive('all');
                  router.push('/dashboard/admin/users');
                }}
                disabled={usersQ.isFetching}
              >
                Sıfırla
              </Button>
              <Button
                type="button"
                variant="ghost"
                onClick={() => usersQ.refetch()}
                disabled={usersQ.isFetching}
                title="Yenile"
              >
                <RefreshCcw className="size-4" />
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Kullanıcı Listesi</CardTitle>
          <CardDescription>
            {usersQ.isFetching
              ? 'Yükleniyor…'
              : `Toplam: ${usersQ.data?.length ?? 0} kayıt (sayfa)`}
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          {usersQ.isError ? (
            <div className="rounded-md border p-4 text-sm">
              Liste yüklenemedi.{' '}
              <Button
                variant="link"
                className="px-1"
                onClick={() => {
                  toast.error('Liste yüklenemedi. Tekrar deneyin.');
                  usersQ.refetch();
                }}
              >
                Yeniden dene
              </Button>
            </div>
          ) : null}

          <div className="rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Ad Soyad</TableHead>
                  <TableHead>Telefon</TableHead>
                  <TableHead>Durum</TableHead>
                  <TableHead>Roller</TableHead>
                  <TableHead className="text-right">İşlem</TableHead>
                </TableRow>
              </TableHeader>

              <TableBody>
                {(usersQ.data ?? []).map((u) => (
                  <TableRow key={u.id}>
                    <TableCell className="font-medium">{displayName(u)}</TableCell>
                    <TableCell>{u.phone ?? '—'}</TableCell>
                    <TableCell>{statusBadge(u)}</TableCell>
                    <TableCell className="space-x-1">
                      {(u.roles ?? []).length ? (
                        u.roles.map((r) => (
                          <Badge key={r} variant={r === 'admin' ? 'default' : 'secondary'}>
                            {roleLabel(r)}
                          </Badge>
                        ))
                      ) : (
                        <span className="text-muted-foreground">—</span>
                      )}
                    </TableCell>
                    <TableCell className="text-right">
                      <Button asChild variant="outline" size="sm">
                        <Link
                          prefetch={false}
                          href={`/dashboard/admin/users/${encodeURIComponent(u.id)}`}
                        >
                          Detay
                        </Link>
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}

                {!usersQ.isFetching && (usersQ.data?.length ?? 0) === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} className="py-10 text-center text-muted-foreground">
                      Kayıt bulunamadı.
                    </TableCell>
                  </TableRow>
                ) : null}
              </TableBody>
            </Table>
          </div>

          <div className="flex items-center justify-between">
            <div className="text-xs text-muted-foreground">
              Offset: {offset} • Limit: {limit}
            </div>

            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                disabled={!canPrev || usersQ.isFetching}
                onClick={() => apply({ offset: Math.max(0, offset - limit) })}
              >
                <ChevronLeft className="mr-1 size-4" />
                Önceki
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={!canNext || usersQ.isFetching}
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
  );
}
