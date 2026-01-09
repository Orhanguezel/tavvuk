'use client';

// =============================================================
// FILE: src/app/(main)/dashboard/admin/locations/_components/admin-locations-client.tsx
// FINAL — Admin Locations (Cities/Districts + Import)
// - Public lists: /locations/cities, /locations/districts
// - Admin import: /admin/locations/import
// - URL state: tab, q, city_id, limit, offset
// =============================================================

import * as React from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { toast } from 'sonner';
import {
  RefreshCcw,
  Upload,
  ChevronLeft,
  ChevronRight,
  Search,
  MapPinned,
  Building2,
} from 'lucide-react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';

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

import type {
  CityView,
  DistrictView,
  CitiesListParams,
  DistrictsListParams,
  ImportLocationsBody,
  ImportMode,
  ImportLocationCityInput,
  ImportLocationDistrictInput,
} from '@/integrations/types';

import {
  useLocationsCitiesQuery,
  useLocationsDistrictsQuery,
  useAdminImportLocationsMutation,
} from '@/integrations/rtk/hooks';

/* ----------------------------- helpers ----------------------------- */

type TabKey = 'cities' | 'districts' | 'import';

function safeText(v: unknown, fb = ''): string {
  const s = String(v ?? '').trim();
  return s ? s : fb;
}

function safeInt(v: string | null, fb: number): number {
  const n = Number(v ?? '');
  return Number.isFinite(n) && n >= 0 ? n : fb;
}

function pickTab(sp: URLSearchParams): TabKey {
  const t = (sp.get('tab') ?? 'cities').toLowerCase();
  if (t === 'districts' || t === 'import') return t;
  return 'cities';
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

function isPlainObject(v: unknown): v is Record<string, any> {
  return !!v && typeof v === 'object' && !Array.isArray(v);
}

function isDistrictInput(v: any): v is ImportLocationDistrictInput {
  if (!isPlainObject(v)) return false;
  if (typeof v.name !== 'string' || !v.name.trim()) return false;
  if (v.code != null && !Number.isFinite(Number(v.code))) return false;
  return true;
}

function isCityInput(v: any): v is ImportLocationCityInput {
  if (!isPlainObject(v)) return false;
  if (!Number.isFinite(Number(v.code))) return false;
  if (typeof v.name !== 'string' || !v.name.trim()) return false;
  if (v.districts != null) {
    if (!Array.isArray(v.districts)) return false;
    if (!v.districts.every(isDistrictInput)) return false;
  }
  return true;
}

function isImportLocationsBody(v: unknown): v is ImportLocationsBody {
  if (!isPlainObject(v)) return false;
  if (!Array.isArray((v as any).cities)) return false;
  if (!(v as any).cities.every(isCityInput)) return false;
  // mode/activate_all opsiyonel; kontrol gerekmez
  return true;
}

/* ----------------------------- component ----------------------------- */

export default function AdminLocationsClient() {
  const router = useRouter();
  const sp = useSearchParams();

  const tab = React.useMemo(() => pickTab(sp), [sp]);

  // shared list state
  const q = sp.get('q') ?? '';
  const limit = safeInt(sp.get('limit'), 50) || 50;
  const offset = safeInt(sp.get('offset'), 0);

  // districts needs city_id
  const city_id = sp.get('city_id') ?? '';

  // local inputs
  const [term, setTerm] = React.useState(q);
  React.useEffect(() => setTerm(q), [q]);

  function apply(
    next: Partial<{ tab: TabKey; q: string; limit: number; offset: number; city_id: string }>,
  ) {
    const merged = { tab, q, limit, offset, city_id, ...next };
    if (next.offset == null) merged.offset = 0;

    // clean
    if (!merged.q) merged.q = '';
    if (!merged.city_id) merged.city_id = '';
    if (!merged.limit) merged.limit = 50;

    const qs = toQS({
      tab: merged.tab,
      q: merged.q || undefined,
      limit: merged.limit,
      offset: merged.offset,
      city_id: merged.city_id || undefined,
    });

    router.push(`/dashboard/admin/locations${qs}`);
  }

  function onSearchSubmit(e: React.FormEvent) {
    e.preventDefault();
    apply({ q: term.trim() });
  }

  /* ----------------------------- queries (dynamic) ----------------------------- */

  const citiesParams = React.useMemo(() => {
    const p: CitiesListParams = {
      q: q || undefined,
      limit,
      offset,
      order: 'name',
      direction: 'asc',
    } as any;
    return p;
  }, [q, limit, offset]);

  // cities, districts sekmelerinde şehirleri çekiyoruz (districts select için de lazım)
  const citiesQ = useLocationsCitiesQuery(
    tab === 'cities' || tab === 'districts' ? (citiesParams as any) : (undefined as any),
    { skip: !(tab === 'cities' || tab === 'districts') } as any,
  ) as any;

  const districtsParams = React.useMemo(() => {
    const p: DistrictsListParams = {
      city_id: city_id || undefined,
      q: q || undefined,
      limit,
      offset,
      order: 'name',
      direction: 'asc',
    } as any;
    return p;
  }, [city_id, q, limit, offset]);

  const districtsQ = useLocationsDistrictsQuery(
    districtsParams as any,
    {
      skip: !(tab === 'districts' && !!city_id),
    } as any,
  ) as any;

  /* ----------------------------- import ----------------------------- */

  const [importLocations, importState] = useAdminImportLocationsMutation();

  const [importMode, setImportMode] = React.useState<ImportMode>('upsert');
  const [activateAll, setActivateAll] = React.useState(true);

  // statik örnek istemiyorsun: boş başla (istersen minimal template bırakabilirsin)
  const [jsonText, setJsonText] = React.useState<string>('');

  function buildTemplate(): string {
    const tmpl: ImportLocationsBody = { cities: [] };
    return JSON.stringify(tmpl, null, 2);
  }

  async function doImport() {
    const rawText = jsonText.trim();
    if (!rawText) {
      toast.error('JSON boş. Lütfen import body girin.');
      return;
    }

    let parsed: unknown;
    try {
      parsed = JSON.parse(rawText);
    } catch {
      toast.error('JSON geçersiz. Lütfen formatı kontrol edin.');
      return;
    }

    if (!isImportLocationsBody(parsed)) {
      toast.error('JSON şeması hatalı. "cities" dizisi ve her şehir için code/name zorunlu.');
      return;
    }

    // artık parsed kesin ImportLocationsBody
    const body: ImportLocationsBody = {
      ...parsed,
      mode: importMode,
      activate_all: activateAll,
    };

    if (!Array.isArray(body.cities) || body.cities.length === 0) {
      toast.error('cities alanı zorunlu ve boş olamaz.');
      return;
    }

    try {
      await importLocations(body).unwrap();
      toast.success('Import başarılı.');

      // import sonrası listeye geçmek istersen:
      // apply({ tab: 'cities', offset: 0, q: '' });
    } catch (err: any) {
      toast.error(safeText(err?.data?.error?.message, 'Import başarısız.'));
    }
  }

  /* ----------------------------- derived ----------------------------- */

  const busy = citiesQ.isFetching || districtsQ.isFetching || importState.isLoading;

  const canPrev = offset > 0;
  const canNextCities = (citiesQ.data?.length ?? 0) >= limit;
  const canNextDistricts = (districtsQ.data?.length ?? 0) >= limit;

  const cities: CityView[] = Array.isArray(citiesQ.data) ? (citiesQ.data as any) : [];
  const districts: DistrictView[] = Array.isArray(districtsQ.data) ? (districtsQ.data as any) : [];

  return (
    <div className="space-y-6">
      {/* header */}
      <div className="flex flex-col gap-2 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <h1 className="text-lg font-semibold">Lokasyonlar (Admin)</h1>
          <p className="text-sm text-muted-foreground">
            Şehir/ilçe listelerini görüntüleyin ve JSON ile import edin.
          </p>
        </div>

        <div className="flex gap-2">
          <Button
            type="button"
            variant="ghost"
            onClick={() => {
              if (tab === 'cities') citiesQ.refetch();
              if (tab === 'districts' && city_id) districtsQ.refetch();
            }}
            disabled={busy}
            title="Yenile"
          >
            <RefreshCcw className="size-4" />
          </Button>
        </div>
      </div>

      {/* tabs */}
      <Card>
        <CardHeader className="gap-2">
          <CardTitle className="text-base">Sekmeler</CardTitle>
          <CardDescription>Şehirler • İlçeler • Import</CardDescription>
        </CardHeader>
        <CardContent className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
          <div className="flex flex-wrap gap-2">
            <Button
              type="button"
              variant={tab === 'cities' ? 'default' : 'outline'}
              onClick={() => apply({ tab: 'cities', offset: 0 })}
            >
              <Building2 className="mr-2 size-4" />
              Şehirler
            </Button>
            <Button
              type="button"
              variant={tab === 'districts' ? 'default' : 'outline'}
              onClick={() => apply({ tab: 'districts', offset: 0 })}
            >
              <MapPinned className="mr-2 size-4" />
              İlçeler
            </Button>
            <Button
              type="button"
              variant={tab === 'import' ? 'default' : 'outline'}
              onClick={() => apply({ tab: 'import', offset: 0 })}
            >
              <Upload className="mr-2 size-4" />
              Import
            </Button>
          </div>

          <div className="text-xs text-muted-foreground">
            Offset: {offset} • Limit: {limit}
          </div>
        </CardContent>
      </Card>

      {/* filters (dynamic lists) */}
      {tab !== 'import' ? (
        <Card>
          <CardHeader className="gap-2">
            <CardTitle className="text-base">Filtre</CardTitle>
            <CardDescription>Arama ve sayfalama parametreleri.</CardDescription>
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
                    placeholder={tab === 'cities' ? 'Şehir adı / kod…' : 'İlçe adı / kod…'}
                    className="pl-9"
                  />
                </div>
              </div>

              {tab === 'districts' ? (
                <div className="w-full space-y-2 lg:w-80">
                  <Label>Şehir</Label>
                  <Select
                    value={city_id || 'none'}
                    onValueChange={(v) => apply({ city_id: v === 'none' ? '' : v, offset: 0 })}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Şehir seç…" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="none">Şehir seç…</SelectItem>
                      {cities.map((c) => (
                        <SelectItem key={c.id} value={c.id}>
                          {c.name} (#{c.code})
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                  <p className="text-xs text-muted-foreground">
                    İlçe listesi için şehir seçimi zorunludur.
                  </p>
                </div>
              ) : null}

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
                    apply({ q: '', offset: 0 });
                  }}
                >
                  Sıfırla
                </Button>
              </div>
            </form>

            <Separator />

            <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
              <div className="text-xs text-muted-foreground">
                {tab === 'cities'
                  ? `Kayıt: ${citiesQ.isFetching ? '—' : cities.length} (sayfa)`
                  : `Kayıt: ${districtsQ.isFetching ? '—' : districts.length} (sayfa)`}
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
                  disabled={
                    busy ||
                    (tab === 'cities' ? !canNextCities : !canNextDistricts) ||
                    (tab === 'districts' && !city_id)
                  }
                  onClick={() => apply({ offset: offset + limit })}
                >
                  Sonraki
                  <ChevronRight className="ml-1 size-4" />
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>
      ) : null}

      {/* cities */}
      {tab === 'cities' ? (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Şehirler</CardTitle>
            <CardDescription>/locations/cities</CardDescription>
          </CardHeader>
          <CardContent>
            {citiesQ.isError ? (
              <div className="rounded-md border p-4 text-sm">
                Şehirler yüklenemedi.{' '}
                <Button variant="link" className="px-1" onClick={() => citiesQ.refetch()}>
                  Yeniden dene
                </Button>
              </div>
            ) : (
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Şehir</TableHead>
                      <TableHead>Kod</TableHead>
                      <TableHead>Durum</TableHead>
                      <TableHead className="text-right">ID</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {cities.map((c) => (
                      <TableRow key={c.id}>
                        <TableCell className="font-medium">{c.name}</TableCell>
                        <TableCell>{c.code}</TableCell>
                        <TableCell>
                          {c.is_active ? (
                            <Badge>Aktif</Badge>
                          ) : (
                            <Badge variant="secondary">Pasif</Badge>
                          )}
                        </TableCell>
                        <TableCell className="text-right text-xs text-muted-foreground">
                          #{c.id.slice(0, 8)}
                        </TableCell>
                      </TableRow>
                    ))}
                    {!citiesQ.isFetching && cities.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={4} className="py-10 text-center text-muted-foreground">
                          Kayıt bulunamadı.
                        </TableCell>
                      </TableRow>
                    ) : null}
                  </TableBody>
                </Table>
              </div>
            )}
          </CardContent>
        </Card>
      ) : null}

      {/* districts */}
      {tab === 'districts' ? (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">İlçeler</CardTitle>
            <CardDescription>/locations/districts (city_id zorunlu)</CardDescription>
          </CardHeader>
          <CardContent>
            {!city_id ? (
              <div className="rounded-md border p-4 text-sm text-muted-foreground">
                İlçeleri görmek için önce şehir seçin.
              </div>
            ) : districtsQ.isError ? (
              <div className="rounded-md border p-4 text-sm">
                İlçeler yüklenemedi.{' '}
                <Button variant="link" className="px-1" onClick={() => districtsQ.refetch()}>
                  Yeniden dene
                </Button>
              </div>
            ) : (
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>İlçe</TableHead>
                      <TableHead>Kod</TableHead>
                      <TableHead>Durum</TableHead>
                      <TableHead className="text-right">ID</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {districts.map((d) => (
                      <TableRow key={d.id}>
                        <TableCell className="font-medium">{d.name}</TableCell>
                        <TableCell>{d.code}</TableCell>
                        <TableCell>
                          {d.is_active ? (
                            <Badge>Aktif</Badge>
                          ) : (
                            <Badge variant="secondary">Pasif</Badge>
                          )}
                        </TableCell>
                        <TableCell className="text-right text-xs text-muted-foreground">
                          #{d.id.slice(0, 8)}
                        </TableCell>
                      </TableRow>
                    ))}
                    {!districtsQ.isFetching && districts.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={4} className="py-10 text-center text-muted-foreground">
                          Kayıt bulunamadı.
                        </TableCell>
                      </TableRow>
                    ) : null}
                  </TableBody>
                </Table>
              </div>
            )}
          </CardContent>
        </Card>
      ) : null}

      {/* import */}
      {tab === 'import' ? (
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Import</CardTitle>
            <CardDescription>/admin/locations/import</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid gap-3 md:grid-cols-3">
              <div className="space-y-2">
                <Label>Mode</Label>
                <Select value={importMode} onValueChange={(v) => setImportMode(v as ImportMode)}>
                  <SelectTrigger>
                    <SelectValue placeholder="Mode" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="upsert">upsert</SelectItem>
                    <SelectItem value="replace">replace</SelectItem>
                  </SelectContent>
                </Select>
                <p className="text-xs text-muted-foreground">
                  upsert: ekle/güncelle • replace: komple değiştir
                </p>
              </div>

              <div className="space-y-2">
                <Label>activate_all</Label>
                <Select
                  value={activateAll ? 'true' : 'false'}
                  onValueChange={(v) => setActivateAll(v === 'true')}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="activate_all" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="true">true</SelectItem>
                    <SelectItem value="false">false</SelectItem>
                  </SelectContent>
                </Select>
                <p className="text-xs text-muted-foreground">
                  Import sonrası tüm kayıtları aktif et.
                </p>
              </div>

              <div className="flex items-end gap-2">
                <Button
                  type="button"
                  variant="outline"
                  className="w-full"
                  onClick={() => setJsonText(buildTemplate())}
                  disabled={importState.isLoading}
                >
                  Şablon
                </Button>
                <Button className="w-full" onClick={doImport} disabled={importState.isLoading}>
                  <Upload className="mr-2 size-4" />
                  Import Et
                </Button>
              </div>
            </div>

            <div className="space-y-2">
              <Label htmlFor="json">JSON Body</Label>
              <Textarea
                id="json"
                value={jsonText}
                onChange={(e) => setJsonText(e.target.value)}
                className="min-h-[340px] font-mono text-xs"
                spellCheck={false}
                placeholder={`{\n  "cities": [\n    { "code": 16, "name": "Bursa", "districts": [ { "code": 1, "name": "Osmangazi" } ] }\n  ]\n}`}
              />
              <p className="text-xs text-muted-foreground">
                Beklenen:{' '}
                <code>{`{ cities: [{ code:number, name:string, districts?:[{code?:number,name:string}]}], mode?, activate_all? }`}</code>
              </p>
            </div>

            {importState.isError ? (
              <div className="rounded-md border p-4 text-sm">
                Import başarısız. Lütfen JSON ve backend log’larını kontrol edin.
              </div>
            ) : null}
          </CardContent>
        </Card>
      ) : null}
    </div>
  );
}
