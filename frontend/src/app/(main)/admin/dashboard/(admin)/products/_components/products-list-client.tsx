'use client';

// src/app/(main)/admin/products/_components/products-list-client.tsx

import * as React from 'react';
import Link from 'next/link';
import { useRouter, useSearchParams } from 'next/navigation';
import { Search, Filter, RefreshCcw, ChevronLeft, ChevronRight, Plus, Trash2 } from 'lucide-react';
import { toast } from 'sonner';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';

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

import type {
  PoultrySpecies,
  ProductListParams,
  ProductSort,
  ProductView,
} from '@/integrations/types';

import {
  useAdminProductsListQuery,
  useAdminProductUpdateMutation,
  useAdminProductDeleteMutation,
} from '@/integrations/rtk/hooks';

/* ----------------------------- labels ----------------------------- */

const SPECIES: { value: PoultrySpecies | 'all'; label: string }[] = [
  { value: 'all', label: 'Tümü' },
  { value: 'chicken', label: 'Tavuk' },
  { value: 'duck', label: 'Ördek' },
  { value: 'goose', label: 'Kaz' },
  { value: 'turkey', label: 'Hindi' },
  { value: 'quail', label: 'Bıldırcın' },
  { value: 'other', label: 'Diğer' },
];

const SPECIES_LABEL: Record<string, string> = Object.fromEntries(
  SPECIES.filter((x) => x.value !== 'all').map((x) => [x.value, x.label]),
);

function speciesLabel(v?: string | null): string {
  if (!v) return '—';
  return SPECIES_LABEL[v] ?? v;
}

const SORTS: { value: ProductSort; label: string }[] = [
  { value: 'created_at', label: 'Oluşturma' },
  { value: 'updated_at', label: 'Güncelleme' },
  { value: 'title', label: 'Başlık' },
  { value: 'price', label: 'Fiyat' },
  { value: 'stock_quantity', label: 'Stok' },
];

/* ----------------------------- helpers ----------------------------- */

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

function pickQuery(sp: URLSearchParams): ProductListParams {
  const q = sp.get('q') ?? undefined;
  const species = (sp.get('species') ?? undefined) as PoultrySpecies | undefined;
  const breed = sp.get('breed') ?? undefined;
  const tag = sp.get('tag') ?? undefined;

  const is_active = boolParam(sp.get('is_active'));
  const is_featured = boolParam(sp.get('is_featured'));

  const sort = (sp.get('sort') ?? undefined) as ProductSort | undefined;
  const order = (sp.get('order') ?? undefined) as 'asc' | 'desc' | undefined;

  const limit = safeInt(sp.get('limit'), 20) || 20;
  const offset = safeInt(sp.get('offset'), 0);

  return {
    ...(q ? { q } : {}),
    ...(species ? { species } : {}),
    ...(breed ? { breed } : {}),
    ...(tag ? { tag } : {}),
    ...(typeof is_active === 'boolean' ? { is_active } : {}),
    ...(typeof is_featured === 'boolean' ? { is_featured } : {}),
    ...(sort ? { sort } : {}),
    ...(order ? { order } : {}),
    limit,
    offset,
  };
}

function toSearchParams(p: ProductListParams): string {
  const sp = new URLSearchParams();

  if (p.q) sp.set('q', p.q);
  if (p.species) sp.set('species', p.species);
  if (p.breed) sp.set('breed', p.breed);
  if (p.tag) sp.set('tag', p.tag);

  if (typeof p.is_active === 'boolean') sp.set('is_active', p.is_active ? '1' : '0');
  if (typeof p.is_featured === 'boolean') sp.set('is_featured', p.is_featured ? '1' : '0');

  if (p.sort) sp.set('sort', p.sort);
  if (p.order) sp.set('order', p.order);

  if (p.limit != null) sp.set('limit', String(p.limit));
  if (p.offset != null) sp.set('offset', String(p.offset));

  return sp.toString();
}

function money(v: number): string {
  try {
    return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(v ?? 0);
  } catch {
    return String(v ?? 0);
  }
}

function statusBadges(p: ProductView) {
  return (
    <div className="flex flex-wrap gap-1">
      {p.is_active ? (
        <Badge variant="secondary">Aktif</Badge>
      ) : (
        <Badge variant="destructive">Pasif</Badge>
      )}
      {p.is_featured ? <Badge>Öne Çıkan</Badge> : null}
    </div>
  );
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

/* ----------------------------- component ----------------------------- */

export default function ProductsListClient() {
  const router = useRouter();
  const sp = useSearchParams();

  const params = React.useMemo(() => pickQuery(sp), [sp]);

  const productsQ = useAdminProductsListQuery(params);
  const [updateProduct, updateState] = useAdminProductUpdateMutation();
  const [deleteProduct, deleteState] = useAdminProductDeleteMutation();

  const busyAny = productsQ.isFetching || updateState.isLoading || deleteState.isLoading;

  // controlled UI
  const [q, setQ] = React.useState(params.q ?? '');
  const [species, setSpecies] = React.useState<PoultrySpecies | 'all'>(params.species ?? 'all');
  const [sort, setSort] = React.useState<ProductSort>(params.sort ?? 'created_at');
  const [order, setOrder] = React.useState<'asc' | 'desc'>(params.order ?? 'desc');

  const [onlyActive, setOnlyActive] = React.useState<boolean | 'all'>(
    typeof params.is_active === 'boolean' ? (params.is_active ? true : false) : 'all',
  );
  const [onlyFeatured, setOnlyFeatured] = React.useState<boolean | 'all'>(
    typeof params.is_featured === 'boolean' ? (params.is_featured ? true : false) : 'all',
  );

  // row-level busy (toggle spam engelle)
  const [rowBusy, setRowBusy] = React.useState<Record<string, boolean>>({});

  React.useEffect(() => {
    setQ(params.q ?? '');
    setSpecies(params.species ?? 'all');
    setSort(params.sort ?? 'created_at');
    setOrder(params.order ?? 'desc');
    setOnlyActive(
      typeof params.is_active === 'boolean' ? (params.is_active ? true : false) : 'all',
    );
    setOnlyFeatured(
      typeof params.is_featured === 'boolean' ? (params.is_featured ? true : false) : 'all',
    );
  }, [params.q, params.species, params.sort, params.order, params.is_active, params.is_featured]);

  function apply(next: Partial<ProductListParams>) {
    const merged: ProductListParams = {
      ...params,
      ...next,
      offset: next.offset != null ? next.offset : 0,
    };

    // clear empties
    if (!merged.q) delete (merged as any).q;
    if (!merged.species) delete (merged as any).species;
    if (!merged.breed) delete (merged as any).breed;
    if (!merged.tag) delete (merged as any).tag;
    if (typeof merged.is_active !== 'boolean') delete (merged as any).is_active;
    if (typeof merged.is_featured !== 'boolean') delete (merged as any).is_featured;
    if (!merged.sort) delete (merged as any).sort;
    if (!merged.order) delete (merged as any).order;

    const qs = toSearchParams(merged);
    router.push(qs ? `/admin/dashboard/products?${qs}` : `/admin/dashboard/products`);
  }

  function onSearchSubmit(e: React.FormEvent) {
    e.preventDefault();
    apply({
      q: q.trim() || undefined,
      species: species === 'all' ? undefined : (species as PoultrySpecies),
      sort,
      order,
      is_active: onlyActive === true ? (true as any) : undefined,
      is_featured: onlyFeatured === true ? (true as any) : undefined,
    });
  }

  const limit = params.limit ?? 20;
  const offset = params.offset ?? 0;
  const canPrev = offset > 0;
  const canNext = (productsQ.data?.length ?? 0) >= limit;

  async function toggleActive(p: ProductView, next: boolean) {
    if (rowBusy[p.id]) return;
    setRowBusy((s) => ({ ...s, [p.id]: true }));
    try {
      await updateProduct({ id: p.id, is_active: next ? 1 : 0 } as any).unwrap();
      toast.success(next ? 'Ürün aktif edildi.' : 'Ürün pasif edildi.');
      productsQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    } finally {
      setRowBusy((s) => ({ ...s, [p.id]: false }));
    }
  }

  async function toggleFeatured(p: ProductView, next: boolean) {
    if (rowBusy[p.id]) return;
    setRowBusy((s) => ({ ...s, [p.id]: true }));
    try {
      await updateProduct({ id: p.id, is_featured: next ? 1 : 0 } as any).unwrap();
      toast.success(next ? 'Ürün öne çıkarıldı.' : 'Öne çıkarma kaldırıldı.');
      productsQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    } finally {
      setRowBusy((s) => ({ ...s, [p.id]: false }));
    }
  }

  async function onDelete(p: ProductView) {
    if (rowBusy[p.id]) return;
    if (!confirm(`"${p.title}" silinecek. Devam edilsin mi?`)) return;

    setRowBusy((s) => ({ ...s, [p.id]: true }));
    try {
      await deleteProduct({ id: p.id } as any).unwrap();
      toast.success('Ürün silindi.');
      productsQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    } finally {
      setRowBusy((s) => ({ ...s, [p.id]: false }));
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <h1 className="text-lg font-semibold">Ürünler</h1>
          <p className="text-sm text-muted-foreground">
            Ürünleri listeleyin, düzenleyin ve görsellerini yönetin.
          </p>
        </div>

        <Button asChild>
          <Link prefetch={false} href="/admin/products/new">
            <Plus className="mr-2 size-4" />
            Yeni Ürün
          </Link>
        </Button>
      </div>

      <Card>
        <CardHeader className="gap-2">
          <CardTitle className="text-base">Filtreler</CardTitle>
          <CardDescription>Arama, tür ve durum filtreleri.</CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          {/* mobilde de düzgün akış için: grid */}
          <form onSubmit={onSearchSubmit} className="grid gap-3 lg:grid-cols-12 lg:items-end">
            <div className="lg:col-span-4 space-y-2">
              <Label htmlFor="q">Arama</Label>
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  id="q"
                  value={q}
                  onChange={(e) => setQ(e.target.value)}
                  placeholder="Başlık, slug, breed..."
                  className="pl-9"
                />
              </div>
            </div>

            <div className="lg:col-span-2 space-y-2">
              <Label>Tür</Label>
              <Select
                value={species}
                onValueChange={(v) => {
                  const vv = v as PoultrySpecies | 'all';
                  setSpecies(vv);
                  apply({ species: vv === 'all' ? undefined : (vv as PoultrySpecies) });
                }}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Tümü" />
                </SelectTrigger>
                <SelectContent>
                  {SPECIES.map((s) => (
                    <SelectItem key={s.value} value={s.value}>
                      {s.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="lg:col-span-2 space-y-2">
              <Label>Sıralama</Label>
              <Select
                value={sort}
                onValueChange={(v) => {
                  const vv = v as ProductSort;
                  setSort(vv);
                  apply({ sort: vv });
                }}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  {SORTS.map((s) => (
                    <SelectItem key={s.value} value={s.value}>
                      {s.label}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="lg:col-span-2 space-y-2">
              <Label>Sıra</Label>
              <Select
                value={order}
                onValueChange={(v) => {
                  const vv = v as 'asc' | 'desc';
                  setOrder(vv);
                  apply({ order: vv });
                }}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="desc">Azalan</SelectItem>
                  <SelectItem value="asc">Artan</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="lg:col-span-2 flex flex-wrap items-center gap-3">
              <div className="flex items-center gap-2">
                <Filter className="size-4 text-muted-foreground" />
                <Label className="text-sm">Aktif</Label>
                <Switch
                  checked={onlyActive === true}
                  onCheckedChange={(v) => {
                    const next = v ? true : 'all';
                    setOnlyActive(next);
                    apply({ is_active: v ? (true as any) : undefined });
                  }}
                />
              </div>

              <div className="flex items-center gap-2">
                <Label className="text-sm">Öne Çıkan</Label>
                <Switch
                  checked={onlyFeatured === true}
                  onCheckedChange={(v) => {
                    const next = v ? true : 'all';
                    setOnlyFeatured(next);
                    apply({ is_featured: v ? (true as any) : undefined });
                  }}
                />
              </div>
            </div>

            <div className="lg:col-span-12 flex flex-wrap gap-2">
              <Button type="submit" disabled={busyAny}>
                Ara
              </Button>
              <Button
                type="button"
                variant="outline"
                onClick={() => {
                  setQ('');
                  setSpecies('all');
                  setSort('created_at');
                  setOrder('desc');
                  setOnlyActive('all');
                  setOnlyFeatured('all');
                  router.push('/admin/dashboard/products');
                }}
                disabled={busyAny}
              >
                Sıfırla
              </Button>
              <Button
                type="button"
                variant="ghost"
                onClick={() => productsQ.refetch()}
                disabled={busyAny}
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
          <CardTitle className="text-base">Ürün Listesi</CardTitle>
          <CardDescription>
            {productsQ.isFetching ? 'Yükleniyor…' : `Kayıt: ${productsQ.data?.length ?? 0} (sayfa)`}
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          {productsQ.isError ? (
            <div className="rounded-md border p-4 text-sm">
              Liste yüklenemedi.{' '}
              <Button
                variant="link"
                className="px-1"
                onClick={() => {
                  toast.error('Liste yüklenemedi. Tekrar deneyin.');
                  productsQ.refetch();
                }}
              >
                Yeniden dene
              </Button>
            </div>
          ) : null}

          {/* ------------------ DESKTOP TABLE (md+) ------------------ */}
          <div className="hidden md:block rounded-md border">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Başlık</TableHead>
                  <TableHead>Tür</TableHead>
                  <TableHead>Cins</TableHead>
                  <TableHead>Fiyat</TableHead>
                  <TableHead>Stok</TableHead>
                  <TableHead>Durum</TableHead>
                  <TableHead className="text-right">Hızlı</TableHead>
                  <TableHead className="text-right">İşlem</TableHead>
                </TableRow>
              </TableHeader>

              <TableBody>
                {(productsQ.data ?? []).map((p) => {
                  const rb = !!rowBusy[p.id];
                  return (
                    <TableRow key={p.id}>
                      <TableCell className="font-medium">
                        <div className="flex flex-col">
                          <span className="truncate">{p.title}</span>
                          <span className="truncate text-xs text-muted-foreground">{p.slug}</span>
                        </div>
                      </TableCell>

                      <TableCell className="text-sm">{speciesLabel(p.species)}</TableCell>
                      <TableCell className="text-sm">{p.breed ?? '—'}</TableCell>
                      <TableCell className="text-sm">{money(p.price)}</TableCell>
                      <TableCell className="text-sm">{p.stock_quantity ?? 0}</TableCell>
                      <TableCell>{statusBadges(p)}</TableCell>

                      <TableCell className="text-right">
                        <div className="inline-flex items-center gap-4">
                          <div className="flex items-center gap-2">
                            <Label className="text-xs text-muted-foreground">Aktif</Label>
                            <Switch
                              checked={!!p.is_active}
                              onCheckedChange={(v) => toggleActive(p, v)}
                              disabled={busyAny || rb}
                            />
                          </div>
                          <div className="flex items-center gap-2">
                            <Label className="text-xs text-muted-foreground">Öne</Label>
                            <Switch
                              checked={!!p.is_featured}
                              onCheckedChange={(v) => toggleFeatured(p, v)}
                              disabled={busyAny || rb}
                            />
                          </div>
                        </div>
                      </TableCell>

                      <TableCell className="text-right">
                        <div className="inline-flex items-center gap-2">
                          <Button asChild variant="outline" size="sm" disabled={busyAny || rb}>
                            <Link
                              prefetch={false}
                              href={`/admin/dashboard/products/${encodeURIComponent(p.id)}`}
                            >
                              Detay
                            </Link>
                          </Button>

                          <Button
                            variant="destructive"
                            size="sm"
                            onClick={() => onDelete(p)}
                            disabled={busyAny || rb}
                            title="Sil"
                          >
                            <Trash2 className="size-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  );
                })}

                {!productsQ.isFetching && (productsQ.data?.length ?? 0) === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} className="py-10 text-center text-muted-foreground">
                      Kayıt bulunamadı.
                    </TableCell>
                  </TableRow>
                ) : null}
              </TableBody>
            </Table>
          </div>

          {/* ------------------ MOBILE CARDS (sm) ------------------ */}
          <div className="md:hidden space-y-3">
            {(productsQ.data ?? []).map((p) => {
              const rb = !!rowBusy[p.id];
              return (
                <div key={p.id} className="rounded-md border p-3 space-y-3">
                  <div className="flex items-start justify-between gap-3">
                    <div className="min-w-0">
                      <div className="font-medium truncate">{p.title}</div>
                      <div className="text-xs text-muted-foreground truncate">{p.slug}</div>
                      <div className="mt-2 flex flex-wrap gap-2">
                        <Badge variant="outline">{speciesLabel(p.species)}</Badge>
                        {p.breed ? <Badge variant="outline">{p.breed}</Badge> : null}
                      </div>
                    </div>

                    <div className="text-right">
                      <div className="text-sm font-medium">{money(p.price)}</div>
                      <div className="text-xs text-muted-foreground">
                        Stok: {p.stock_quantity ?? 0}
                      </div>
                    </div>
                  </div>

                  <div className="flex items-center justify-between">
                    {statusBadges(p)}
                    <div className="flex items-center gap-3">
                      <div className="flex items-center gap-2">
                        <Label className="text-xs text-muted-foreground">Aktif</Label>
                        <Switch
                          checked={!!p.is_active}
                          onCheckedChange={(v) => toggleActive(p, v)}
                          disabled={busyAny || rb}
                        />
                      </div>
                      <div className="flex items-center gap-2">
                        <Label className="text-xs text-muted-foreground">Öne</Label>
                        <Switch
                          checked={!!p.is_featured}
                          onCheckedChange={(v) => toggleFeatured(p, v)}
                          disabled={busyAny || rb}
                        />
                      </div>
                    </div>
                  </div>

                  <div className="flex gap-2">
                    <Button asChild variant="outline" className="flex-1" disabled={busyAny || rb}>
                      <Link prefetch={false} href={`/admin/dashboard/products/${encodeURIComponent(p.id)}`}>
                        Detay
                      </Link>
                    </Button>

                    <Button
                      variant="destructive"
                      className="px-4"
                      onClick={() => onDelete(p)}
                      disabled={busyAny || rb}
                      title="Sil"
                    >
                      <Trash2 className="size-4" />
                    </Button>
                  </div>
                </div>
              );
            })}

            {!productsQ.isFetching && (productsQ.data?.length ?? 0) === 0 ? (
              <div className="rounded-md border py-10 text-center text-sm text-muted-foreground">
                Kayıt bulunamadı.
              </div>
            ) : null}
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
                disabled={!canPrev || busyAny}
                onClick={() => apply({ offset: Math.max(0, offset - limit) })}
              >
                <ChevronLeft className="mr-1 size-4" />
                Önceki
              </Button>
              <Button
                variant="outline"
                size="sm"
                disabled={!canNext || busyAny}
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
