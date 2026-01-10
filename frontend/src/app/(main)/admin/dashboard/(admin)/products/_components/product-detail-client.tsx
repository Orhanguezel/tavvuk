'use client';

// src/app/(main)/admin/products/[id]/_components/product-detail-client.tsx

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { ArrowLeft, Save, Trash2, Image as ImageIcon } from 'lucide-react';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

import type { PoultrySpecies } from '@/integrations/types';
import {
  useAdminProductGetQuery,
  useAdminProductUpdateMutation,
  useAdminProductSetImagesMutation,
  useAdminProductDeleteMutation,
} from '@/integrations/rtk/hooks';

const SPECIES: { value: PoultrySpecies; label: string }[] = [
  { value: 'chicken', label: 'Tavuk' },
  { value: 'duck', label: 'Ördek' },
  { value: 'goose', label: 'Kaz' },
  { value: 'turkey', label: 'Hindi' },
  { value: 'quail', label: 'Bıldırcın' },
  { value: 'other', label: 'Diğer' },
];

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

function uniqStrings(input: string): string[] {
  // newline / comma separated
  const parts = String(input ?? '')
    .split(/\r?\n|,/g)
    .map((x) => x.trim())
    .filter(Boolean);
  return Array.from(new Set(parts));
}

export default function ProductDetailClient({ id }: { id: string }) {
  const router = useRouter();

  const productQ = useAdminProductGetQuery({ id }, { skip: !id });

  const [updateProduct, updateState] = useAdminProductUpdateMutation();
  const [setImages, setImagesState] = useAdminProductSetImagesMutation();
  const [deleteProduct, deleteState] = useAdminProductDeleteMutation();

  const p = productQ.data;

  // form state
  const [title, setTitle] = React.useState('');
  const [slug, setSlug] = React.useState('');
  const [species, setSpecies] = React.useState<PoultrySpecies>('chicken');
  const [breed, setBreed] = React.useState('');
  const [summary, setSummary] = React.useState('');
  const [price, setPrice] = React.useState('0');
  const [stock, setStock] = React.useState('0');
  const [active, setActive] = React.useState(true);
  const [featured, setFeatured] = React.useState(false);

  // images form
  const [coverUrl, setCoverUrl] = React.useState('');
  const [alt, setAlt] = React.useState('');
  const [galleryUrlsText, setGalleryUrlsText] = React.useState('');
  const [tagsText, setTagsText] = React.useState('');

  React.useEffect(() => {
    if (!p) return;

    setTitle(p.title ?? '');
    setSlug(p.slug ?? '');
    setSpecies((p.species as PoultrySpecies) ?? 'chicken');
    setBreed(p.breed ?? '');
    setSummary(p.summary ?? '');
    setPrice(String(p.price ?? 0));
    setStock(String(p.stock_quantity ?? 0));
    setActive(!!p.is_active);
    setFeatured(!!p.is_featured);

    setCoverUrl(p.image_url ?? '');
    setAlt(p.alt ?? '');
    setGalleryUrlsText((p.images ?? []).join('\n'));
    setTagsText((p.tags ?? []).join(', '));
  }, [p?.id]);

  const busy =
    productQ.isFetching ||
    updateState.isLoading ||
    setImagesState.isLoading ||
    deleteState.isLoading;

  async function onSaveMain() {
    if (!id) return;
    const t = title.trim();
    if (t.length < 2) {
      toast.error('Başlık en az 2 karakter olmalıdır.');
      return;
    }

    try {
      await updateProduct({
        id,
        title: t,
        ...(slug.trim() ? { slug: slug.trim() } : {}),
        species,
        breed: breed.trim() ? breed.trim() : null,
        summary: summary.trim() ? summary.trim() : null,
        price: Number(price) || 0,
        stock_quantity: Number(stock) || 0,
        is_active: active ? 1 : 0,
        is_featured: featured ? 1 : 0,
        tags: uniqStrings(tagsText),
      } as any).unwrap();

      toast.success('Ürün güncellendi.');
      productQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  async function onSaveImages() {
    if (!id) return;
    try {
      await setImages({
        id,
        image_url: coverUrl.trim() ? coverUrl.trim() : null,
        alt: alt.trim() ? alt.trim() : null,
        images: uniqStrings(galleryUrlsText),
        // storage_* admin UI’da şimdilik yok; eklemek istersen alanları açarız
      } as any).unwrap();

      toast.success('Görseller güncellendi.');
      productQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  async function onDelete() {
    if (!id) return;
    if (!confirm('Bu ürün silinecek. Devam edilsin mi?')) return;

    try {
      await deleteProduct({ id }).unwrap();
      toast.success('Ürün silindi.');
      router.replace('/admin/dashboard/products');
      router.refresh();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  if (!id) {
    return (
      <div className="rounded-md border p-4 text-sm text-muted-foreground">Geçersiz ürün ID.</div>
    );
  }

  if (productQ.isError) {
    return (
      <div className="space-y-3">
        <Button variant="outline" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 size-4" />
          Geri
        </Button>
        <div className="rounded-md border p-4 text-sm">
          Ürün yüklenemedi.{' '}
          <Button variant="link" className="px-1" onClick={() => productQ.refetch()}>
            Yeniden dene
          </Button>
        </div>
      </div>
    );
  }

  if (!p) {
    return (
      <div className="space-y-3">
        <Button variant="outline" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 size-4" />
          Geri
        </Button>
        <div className="rounded-md border p-4 text-sm text-muted-foreground">Yükleniyor…</div>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
        <div className="space-y-1">
          <div className="flex items-center gap-2">
            <Button variant="outline" onClick={() => router.back()} disabled={busy}>
              <ArrowLeft className="mr-2 size-4" />
              Geri
            </Button>
            <h1 className="text-lg font-semibold">Ürün Detay</h1>
          </div>
          <p className="text-sm text-muted-foreground">
            <span className="font-medium">{p.title}</span> •{' '}
            <span className="text-muted-foreground">{p.slug}</span>
          </p>
        </div>

        <div className="flex items-center gap-2">
          {p.is_active ? (
            <Badge variant="secondary">Aktif</Badge>
          ) : (
            <Badge variant="destructive">Pasif</Badge>
          )}
          {p.is_featured ? <Badge>Öne Çıkan</Badge> : null}
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Temel Bilgiler</CardTitle>
          <CardDescription>
            Başlık, tür, fiyat, stok ve durum bilgilerini güncelleyin.
          </CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          <div className="grid gap-3 md:grid-cols-3">
            <div className="space-y-2 md:col-span-2">
              <Label htmlFor="title">Başlık</Label>
              <Input
                id="title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                disabled={busy}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="slug">Slug</Label>
              <Input
                id="slug"
                value={slug}
                onChange={(e) => setSlug(e.target.value)}
                disabled={busy}
              />
            </div>

            <div className="space-y-2">
              <Label>Tür (Species)</Label>
              <Select value={species} onValueChange={(v) => setSpecies(v as PoultrySpecies)}>
                <SelectTrigger disabled={busy}>
                  <SelectValue />
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

            <div className="space-y-2">
              <Label htmlFor="breed">Breed</Label>
              <Input
                id="breed"
                value={breed}
                onChange={(e) => setBreed(e.target.value)}
                disabled={busy}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="price">Fiyat</Label>
              <Input
                id="price"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
                inputMode="decimal"
                disabled={busy}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="stock">Stok</Label>
              <Input
                id="stock"
                value={stock}
                onChange={(e) => setStock(e.target.value)}
                inputMode="numeric"
                disabled={busy}
              />
            </div>

            <div className="space-y-2 md:col-span-3">
              <Label htmlFor="summary">Summary (kısa açıklama)</Label>
              <Input
                id="summary"
                value={summary}
                onChange={(e) => setSummary(e.target.value)}
                disabled={busy}
              />
            </div>

            <div className="space-y-2 md:col-span-3">
              <Label htmlFor="tags">Etiketler (comma/newline)</Label>
              <Input
                id="tags"
                value={tagsText}
                onChange={(e) => setTagsText(e.target.value)}
                disabled={busy}
                placeholder="ör: damızlık, hızlı-büyüme"
              />
            </div>
          </div>

          <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
            <div className="flex items-center gap-6">
              <div className="flex items-center gap-2">
                <Label className="text-sm text-muted-foreground">
                  {active ? 'Aktif' : 'Pasif'}
                </Label>
                <Switch checked={active} onCheckedChange={setActive} disabled={busy} />
              </div>
              <div className="flex items-center gap-2">
                <Label className="text-sm text-muted-foreground">
                  {featured ? 'Öne Çıkan' : 'Normal'}
                </Label>
                <Switch checked={featured} onCheckedChange={setFeatured} disabled={busy} />
              </div>
            </div>

            <Button onClick={onSaveMain} disabled={busy}>
              <Save className="mr-2 size-4" />
              Kaydet
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Görseller</CardTitle>
          <CardDescription>Kapak görseli ve galeri URL’lerini yönetin.</CardDescription>
        </CardHeader>

        <CardContent className="space-y-4">
          <div className="grid gap-3 md:grid-cols-3">
            <div className="space-y-2 md:col-span-2">
              <Label htmlFor="cover">Kapak URL</Label>
              <Input
                id="cover"
                value={coverUrl}
                onChange={(e) => setCoverUrl(e.target.value)}
                disabled={busy}
                placeholder="https://..."
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="alt">Alt</Label>
              <Input
                id="alt"
                value={alt}
                onChange={(e) => setAlt(e.target.value)}
                disabled={busy}
              />
            </div>

            <div className="space-y-2 md:col-span-3">
              <Label htmlFor="gallery">Galeri URL’leri (satır satır veya virgül)</Label>
              <textarea
                id="gallery"
                className="min-h-28 w-full rounded-md border bg-transparent p-3 text-sm outline-none disabled:cursor-not-allowed disabled:opacity-50"
                value={galleryUrlsText}
                onChange={(e) => setGalleryUrlsText(e.target.value)}
                disabled={busy}
                placeholder="https://...\nhttps://..."
              />
            </div>
          </div>

          <div className="flex justify-end">
            <Button variant="outline" onClick={onSaveImages} disabled={busy}>
              <ImageIcon className="mr-2 size-4" />
              Görselleri Kaydet
            </Button>
          </div>

          <Separator />

          {p.image_url ? (
            <div className="rounded-md border p-3">
              <div className="text-sm font-medium">Önizleme (kapak)</div>
              <div className="mt-2">
                {/* Remote image domain problemi yaşamamak için img kullanıyoruz */}
                <img
                  src={p.image_url}
                  alt={p.alt ?? p.title}
                  className="h-44 w-full rounded-md object-cover"
                  loading="lazy"
                />
              </div>
            </div>
          ) : null}
        </CardContent>
      </Card>

      <Card className="border-destructive/40">
        <CardHeader>
          <CardTitle className="text-base">Tehlikeli İşlem</CardTitle>
          <CardDescription>Ürünü kalıcı olarak siler.</CardDescription>
        </CardHeader>
        <CardContent className="flex justify-end">
          <Button variant="destructive" onClick={onDelete} disabled={busy}>
            <Trash2 className="mr-2 size-4" />
            Ürünü Sil
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
