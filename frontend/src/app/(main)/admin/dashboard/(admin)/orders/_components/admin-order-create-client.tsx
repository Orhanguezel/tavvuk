'use client';

// =============================================================
// FILE: src/app/(main)/admin/orders/_components/admin-order-create-client.tsx
// FINAL — Admin Manual Create Order (with Locations pickers)
// - City/District from Locations RTK (no UUID inputs)
// - Product search + add items
// - Customer/address inputs
// - Submit -> POST /admin/orders
// =============================================================

import * as React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { Plus, Trash2, ChevronLeft, Search, MapPin, Building2 } from 'lucide-react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';

import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

import type {
  CreateOrderBody,
  OrderItemInput,
  ProductView,
  CityView,
  DistrictView,
} from '@/integrations/types';

import {
  useAdminCreateOrderMutation,
  useAdminProductsListQuery,
  useLocationsCitiesQuery,
  useLocationsDistrictsByCityIdQuery,
} from '@/integrations/rtk/hooks';

/* ----------------------------- helpers ----------------------------- */

function safeText(v: any, fb = ''): string {
  const s = String(v ?? '').trim();
  return s ? s : fb;
}

function toInt(v: any, fb = 1): number {
  const n = Number(String(v ?? '').trim());
  if (!Number.isFinite(n)) return fb;
  return Math.max(1, Math.floor(n));
}

function money(n: number): string {
  try {
    return new Intl.NumberFormat('tr-TR', { style: 'currency', currency: 'TRY' }).format(n);
  } catch {
    return String(n);
  }
}

type Line = {
  product: ProductView;
  qty: number;
};

/* ----------------------------- component ----------------------------- */

export default function AdminOrderCreateClient() {
  const router = useRouter();

  // Location selection (from Locations API)
  const [cityTerm, setCityTerm] = React.useState('');
  const [districtTerm, setDistrictTerm] = React.useState('');

  const [cityId, setCityId] = React.useState<string>(''); // selected city uuid
  const [districtId, setDistrictId] = React.useState<string>(''); // selected district uuid (optional)

  const citiesQ = useLocationsCitiesQuery(
    { q: cityTerm.trim() || undefined, limit: 50, offset: 0, is_active: '1' as any },
    { skip: false },
  );

  const districtsQ = useLocationsDistrictsByCityIdQuery(
    {
      cityId: cityId,
      q: districtTerm.trim() || undefined,
      limit: 80,
      offset: 0,
      is_active: '1' as any,
    } as any,
    { skip: !cityId },
  );

  const selectedCity: CityView | undefined = React.useMemo(() => {
    const rows = (citiesQ.data ?? []) as CityView[];
    return rows.find((c) => c.id === cityId);
  }, [citiesQ.data, cityId]);

  const selectedDistrict: DistrictView | undefined = React.useMemo(() => {
    const rows = (districtsQ.data ?? []) as DistrictView[];
    return rows.find((d) => d.id === districtId);
  }, [districtsQ.data, districtId]);

  // Customer fields
  const [customerName, setCustomerName] = React.useState('');
  const [customerPhone, setCustomerPhone] = React.useState('');
  const [addressText, setAddressText] = React.useState('');

  // Product search
  const [pTerm, setPTerm] = React.useState('');
  const productsQ = useAdminProductsListQuery(
    { q: pTerm.trim() || undefined, limit: 20, offset: 0, is_active: '1' as any },
    { skip: false },
  );

  const [lines, setLines] = React.useState<Line[]>([]);
  const [createOrder, createState] = useAdminCreateOrderMutation();

  const busy =
    createState.isLoading || productsQ.isFetching || citiesQ.isFetching || districtsQ.isFetching;

  // When city changes, reset district
  React.useEffect(() => {
    setDistrictId('');
    setDistrictTerm('');
  }, [cityId]);

  function addProduct(p: ProductView) {
    setLines((prev) => {
      const idx = prev.findIndex((x) => x.product.id === p.id);
      if (idx >= 0) {
        const copy = prev.slice();
        copy[idx] = { ...copy[idx], qty: copy[idx].qty + 1 };
        return copy;
      }
      return [...prev, { product: p, qty: 1 }];
    });
  }

  function setQty(productId: string, qty: number) {
    setLines((prev) =>
      prev.map((x) => (x.product.id === productId ? { ...x, qty: Math.max(1, qty) } : x)),
    );
  }

  function removeLine(productId: string) {
    setLines((prev) => prev.filter((x) => x.product.id !== productId));
  }

  const total = React.useMemo(() => {
    return lines.reduce((sum, x) => sum + (x.product.price || 0) * x.qty, 0);
  }, [lines]);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();

    const items: OrderItemInput[] = lines.map((x) => ({
      product_id: x.product.id,
      qty_ordered: x.qty,
    }));

    const body: CreateOrderBody = {
      city_id: cityId,
      district_id: districtId ? districtId : null,

      customer_name: customerName.trim(),
      customer_phone: customerPhone.trim(),
      address_text: addressText.trim(),

      items,
    };

    // UI validation (server already validates via createOrderBodySchema)
    if (!body.city_id) return toast.error('Şehir seçimi zorunlu.');
    if (!body.customer_name) return toast.error('Müşteri adı zorunlu.');
    if (!body.customer_phone) return toast.error('Telefon zorunlu.');
    if (!body.address_text) return toast.error('Adres zorunlu.');
    if (!body.items.length) return toast.error('En az 1 ürün eklemelisiniz.');

    try {
      const res = await createOrder(body).unwrap();
      const id = safeText(res?.order?.id, '');
      toast.success('Sipariş oluşturuldu.');

      if (id) router.push(`/admin/dashboard/orders/${encodeURIComponent(id)}`);
      else router.push('/admin/dashboard/orders');
    } catch (err: any) {
      toast.error(safeText(err?.data?.error?.message, 'Sipariş oluşturulamadı.'));
    }
  }

  const products: ProductView[] = (productsQ.data ?? []) as any;
  const cities: CityView[] = (citiesQ.data ?? []) as any;
  const districts: DistrictView[] = (districtsQ.data ?? []) as any;

  return (
    <div className="space-y-6">
      {/* header */}
      <div className="flex flex-col gap-2 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <h1 className="text-lg font-semibold">Yeni Sipariş (Admin)</h1>
          <p className="text-sm text-muted-foreground">
            Admin panelinden manuel sipariş oluşturun, ürün ekleyin ve kaydedin.
          </p>
        </div>

        <div className="flex gap-2">
          <Button asChild variant="outline">
            <Link prefetch={false} href="/admin/dashboard/orders">
              <ChevronLeft className="mr-2 size-4" />
              Listeye dön
            </Link>
          </Button>
        </div>
      </div>

      <form onSubmit={onSubmit} className="grid gap-6 lg:grid-cols-12">
        {/* left: customer + address */}
        <div className="space-y-6 lg:col-span-5">
          {/* Locations */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Lokasyon</CardTitle>
              <CardDescription>Şehir ve (opsiyonel) ilçe seçin.</CardDescription>
            </CardHeader>

            <CardContent className="space-y-4">
              {/* city search */}
              <div className="space-y-2">
                <Label htmlFor="city_search">Şehir Ara</Label>
                <div className="relative">
                  <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                  <Input
                    id="city_search"
                    value={cityTerm}
                    onChange={(e) => setCityTerm(e.target.value)}
                    placeholder="Şehir adı..."
                    className="pl-9"
                  />
                </div>
              </div>

              <div className="grid gap-3 md:grid-cols-2">
                <div className="space-y-2">
                  <Label>Şehir</Label>
                  <Select
                    value={cityId || undefined}
                    onValueChange={(v) => setCityId(v)}
                    disabled={citiesQ.isFetching}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder={citiesQ.isFetching ? 'Yükleniyor…' : 'Şehir seç'} />
                    </SelectTrigger>
                    <SelectContent>
                      {cities.map((c) => (
                        <SelectItem key={c.id} value={c.id}>
                          {c.name} {Number.isFinite(c.code) ? `(${c.code})` : ''}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>

                  <div className="text-xs text-muted-foreground flex items-center gap-2">
                    <Building2 className="size-3" />
                    <span>
                      Seçili: {selectedCity ? `${selectedCity.name}` : '—'}
                      {selectedCity ? ` • #${selectedCity.id.slice(0, 8)}` : ''}
                    </span>
                  </div>
                </div>

                <div className="space-y-2">
                  <Label>İlçe (opsiyonel)</Label>
                  <Select
                    value={districtId || undefined}
                    onValueChange={(v) => setDistrictId(v)}
                    disabled={!cityId || districtsQ.isFetching}
                  >
                    <SelectTrigger>
                      <SelectValue
                        placeholder={
                          !cityId
                            ? 'Önce şehir seçin'
                            : districtsQ.isFetching
                            ? 'Yükleniyor…'
                            : 'İlçe seç'
                        }
                      />
                    </SelectTrigger>
                    <SelectContent>
                      <div className="p-2">
                        <div className="relative">
                          <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                          <Input
                            value={districtTerm}
                            onChange={(e) => setDistrictTerm(e.target.value)}
                            placeholder="İlçe ara..."
                            className="pl-9 h-9"
                          />
                        </div>
                      </div>

                      {/* allow clearing */}
                      <SelectItem value="__none__">İlçe seçme</SelectItem>

                      {districts.map((d) => (
                        <SelectItem key={d.id} value={d.id}>
                          {d.name} {Number.isFinite(d.code) ? `(${d.code})` : ''}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>

                  <div className="text-xs text-muted-foreground flex items-center gap-2">
                    <MapPin className="size-3" />
                    <span>
                      Seçili: {selectedDistrict ? `${selectedDistrict.name}` : '—'}
                      {selectedDistrict ? ` • #${selectedDistrict.id.slice(0, 8)}` : ''}
                    </span>
                  </div>
                </div>
              </div>

              {/* Clear district if "__none__" selected */}
              <input
                type="hidden"
                value={districtId}
                onChange={() => {
                  // no-op
                }}
              />
            </CardContent>
          </Card>

          {/* Customer */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Müşteri Bilgileri</CardTitle>
              <CardDescription>Ad/telefon/adres bilgilerini girin.</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="customer_name">Müşteri Adı</Label>
                <Input
                  id="customer_name"
                  value={customerName}
                  onChange={(e) => setCustomerName(e.target.value)}
                  placeholder="Örn: Ahmet Yılmaz"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="customer_phone">Telefon</Label>
                <Input
                  id="customer_phone"
                  value={customerPhone}
                  onChange={(e) => setCustomerPhone(e.target.value)}
                  placeholder="Örn: 05xx xxx xx xx"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="address_text">Adres</Label>
                <Textarea
                  id="address_text"
                  value={addressText}
                  onChange={(e) => setAddressText(e.target.value)}
                  placeholder="Açık adres..."
                />
              </div>
            </CardContent>
          </Card>

          {/* Summary */}
          <Card>
            <CardHeader>
              <CardTitle className="text-base">Özet</CardTitle>
              <CardDescription>Kalem sayısı ve toplam.</CardDescription>
            </CardHeader>
            <CardContent className="flex items-center justify-between">
              <div className="text-sm text-muted-foreground">
                Kalem: <span className="font-medium text-foreground">{lines.length}</span>
              </div>
              <div className="text-sm">
                Toplam: <span className="font-semibold">{money(total)}</span>
              </div>
            </CardContent>
          </Card>

          <div className="flex gap-2">
            <Button type="submit" disabled={busy || !lines.length || !cityId}>
              Siparişi Oluştur
            </Button>
            <Button
              type="button"
              variant="outline"
              disabled={busy}
              onClick={() => {
                setLines([]);
                toast.message('Ürünler temizlendi.');
              }}
            >
              Temizle
            </Button>
          </div>
        </div>

        {/* right: product search + cart */}
        <div className="space-y-6 lg:col-span-7">
          <Card>
            <CardHeader className="gap-2">
              <CardTitle className="text-base">Ürün Seç</CardTitle>
              <CardDescription>Arayın ve siparişe ekleyin.</CardDescription>
            </CardHeader>

            <CardContent className="space-y-3">
              <div className="relative">
                <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
                <Input
                  value={pTerm}
                  onChange={(e) => setPTerm(e.target.value)}
                  placeholder="Ürün ara (başlık, etiket, tür)..."
                  className="pl-9"
                />
              </div>

              <div className="rounded-md border">
                <div className="max-h-80overflow-auto">
                  {productsQ.isError ? (
                    <div className="p-4 text-sm text-muted-foreground">Ürünler yüklenemedi.</div>
                  ) : null}

                  {!productsQ.isFetching && products.length === 0 ? (
                    <div className="p-4 text-sm text-muted-foreground">Ürün bulunamadı.</div>
                  ) : null}

                  {products.map((p) => (
                    <button
                      key={p.id}
                      type="button"
                      className="w-full text-left border-b last:border-b-0 p-3 hover:bg-muted/50"
                      onClick={() => addProduct(p)}
                      disabled={createState.isLoading}
                      title="Tıkla ve ekle"
                    >
                      <div className="flex items-start justify-between gap-3">
                        <div className="min-w-0">
                          <div className="font-medium truncate">{p.title}</div>
                          <div className="text-xs text-muted-foreground truncate">
                            {p.slug} • stok: {p.stock_quantity}
                          </div>
                          {p.tags?.length ? (
                            <div className="mt-1 flex flex-wrap gap-1">
                              {p.tags.slice(0, 4).map((t) => (
                                <Badge key={t} variant="secondary">
                                  {t}
                                </Badge>
                              ))}
                            </div>
                          ) : null}
                        </div>

                        <div className="shrink-0 flex items-center gap-2">
                          <span className="text-sm font-medium">{money(p.price || 0)}</span>
                          <span className="inline-flex items-center justify-center rounded-md border px-2 py-1 text-xs">
                            <Plus className="mr-1 size-3" />
                            Ekle
                          </span>
                        </div>
                      </div>
                    </button>
                  ))}
                </div>
              </div>

              <p className="text-xs text-muted-foreground">
                Ürün satırına tıklayın: kalem eklenir; aynı ürün tekrar eklenirse adet +1 artar.
              </p>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="text-base">Sipariş Kalemleri</CardTitle>
              <CardDescription>Adet düzenleyin veya kaldırın.</CardDescription>
            </CardHeader>

            <CardContent className="space-y-3">
              {lines.length === 0 ? (
                <div className="rounded-md border p-6 text-center text-sm text-muted-foreground">
                  Henüz ürün eklenmedi.
                </div>
              ) : null}

              <div className="space-y-2">
                {lines.map((x) => (
                  <div key={x.product.id} className="rounded-md border p-3">
                    <div className="flex items-start justify-between gap-3">
                      <div className="min-w-0">
                        <div className="font-medium truncate">{x.product.title}</div>
                        <div className="text-xs text-muted-foreground truncate">
                          {money(x.product.price || 0)} • stok: {x.product.stock_quantity}
                        </div>
                      </div>

                      <Button
                        type="button"
                        variant="ghost"
                        size="icon"
                        onClick={() => removeLine(x.product.id)}
                        title="Kaldır"
                      >
                        <Trash2 className="size-4" />
                      </Button>
                    </div>

                    <div className="mt-3 flex items-center justify-between gap-3">
                      <div className="flex items-center gap-2">
                        <Label className="text-xs text-muted-foreground">Adet</Label>
                        <Input
                          value={String(x.qty)}
                          onChange={(e) => setQty(x.product.id, toInt(e.target.value, 1))}
                          inputMode="numeric"
                          className="h-9 w-24"
                        />
                      </div>

                      <div className="text-sm">
                        Satır:{' '}
                        <span className="font-semibold">
                          {money((x.product.price || 0) * x.qty)}
                        </span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>

              <div className="flex items-center justify-between rounded-md border p-3">
                <span className="text-sm text-muted-foreground">Genel Toplam</span>
                <span className="text-sm font-semibold">{money(total)}</span>
              </div>
            </CardContent>
          </Card>
        </div>
      </form>
    </div>
  );
}
