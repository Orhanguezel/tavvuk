'use client';

// src/app/(main)/admin/products/new/_components/product-new-client.tsx

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { ArrowLeft, Save } from 'lucide-react';

import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';

import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

import type { PoultrySpecies } from '@/integrations/types';
import { useAdminProductCreateMutation } from '@/integrations/rtk/hooks';

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

export default function ProductNewClient() {
  const router = useRouter();
  const [createProduct, createState] = useAdminProductCreateMutation();

  const [title, setTitle] = React.useState('');
  const [slug, setSlug] = React.useState('');
  const [species, setSpecies] = React.useState<PoultrySpecies>('chicken');
  const [breed, setBreed] = React.useState('');
  const [price, setPrice] = React.useState('0');
  const [stock, setStock] = React.useState('0');

  const [isActive, setIsActive] = React.useState(true);
  const [isFeatured, setIsFeatured] = React.useState(false);

  const busy = createState.isLoading;

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    const t = title.trim();
    if (t.length < 2) {
      toast.error('Başlık en az 2 karakter olmalıdır.');
      return;
    }

    try {
      const created = await createProduct({
        title: t,
        ...(slug.trim() ? { slug: slug.trim() } : {}),
        species,
        ...(breed.trim() ? { breed: breed.trim() } : { breed: null }),
        price: Number(price) || 0,
        stock_quantity: Number(stock) || 0,
        is_active: isActive ? 1 : 0,
        is_featured: isFeatured ? 1 : 0,
      } as any).unwrap();

      toast.success('Ürün oluşturuldu.');
      router.replace(`/admin/dashboard/products/${encodeURIComponent(created.id)}`);
      router.refresh();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <Button variant="outline" onClick={() => router.back()} disabled={busy}>
          <ArrowLeft className="mr-2 size-4" />
          Geri
        </Button>
        <h1 className="text-lg font-semibold">Yeni Ürün</h1>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Temel Bilgiler</CardTitle>
          <CardDescription>Ürün başlığı, tür ve fiyat bilgilerini girin.</CardDescription>
        </CardHeader>

        <CardContent>
          <form onSubmit={onSubmit} className="space-y-4">
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
                <Label htmlFor="slug">Slug (opsiyonel)</Label>
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
                <Label htmlFor="breed">Breed (opsiyonel)</Label>
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
            </div>

            <div className="flex flex-col gap-3 md:flex-row md:items-center md:justify-between">
              <div className="flex items-center gap-6">
                <div className="flex items-center gap-2">
                  <Label className="text-sm text-muted-foreground">Aktif</Label>
                  <Switch checked={isActive} onCheckedChange={setIsActive} disabled={busy} />
                </div>
                <div className="flex items-center gap-2">
                  <Label className="text-sm text-muted-foreground">Öne Çıkan</Label>
                  <Switch checked={isFeatured} onCheckedChange={setIsFeatured} disabled={busy} />
                </div>
              </div>

              <Button type="submit" disabled={busy}>
                <Save className="mr-2 size-4" />
                Oluştur
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
