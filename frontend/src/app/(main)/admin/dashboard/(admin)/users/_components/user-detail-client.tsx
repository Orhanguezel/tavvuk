'use client';

// src/app/(main)/admin/users/[id]/user-detail-client.tsx

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { toast } from 'sonner';
import { ArrowLeft, Save, ShieldCheck, KeyRound, Trash2 } from 'lucide-react';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
import { Label } from '@/components/ui/label';
import { Input } from '@/components/ui/input';

import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '@/components/ui/card';
import { Separator } from '@/components/ui/separator';

import type { Role } from '@/integrations/types';

import {
  useAdminGetQuery,
  useAdminUpdateUserMutation,
  useAdminSetActiveMutation,
  useAdminSetRolesMutation,
  useAdminSetPasswordMutation,
  useAdminRemoveUserMutation,
} from '@/integrations/rtk/hooks';

function roleLabel(r: Role) {
  if (r === 'admin') return 'Admin';
  if (r === 'seller') return 'Satıcı';
  if (r === 'driver') return 'Şoför';
  return r;
}

const ALL_ROLES: Role[] = ['admin', 'seller', 'driver'];

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

export default function UserDetailClient({ id }: { id: string }) {
  const router = useRouter();

  const userQ = useAdminGetQuery({ id });

  const [updateUser, updateState] = useAdminUpdateUserMutation();
  const [setActive, setActiveState] = useAdminSetActiveMutation();
  const [setRoles, setRolesState] = useAdminSetRolesMutation();
  const [setPassword, setPasswordState] = useAdminSetPasswordMutation();
  const [removeUser, removeState] = useAdminRemoveUserMutation();

  const u = userQ.data;

  // form state
  const [fullName, setFullName] = React.useState('');
  const [phone, setPhone] = React.useState('');
  const [email, setEmail] = React.useState('');
  const [password, setPasswordLocal] = React.useState('');
  const [active, setActiveLocal] = React.useState(true);
  const [roles, setRolesLocal] = React.useState<Role[]>([]);

  React.useEffect(() => {
    if (!u) return;
    setFullName(u.full_name ?? '');
    setPhone(u.phone ?? '');
    setEmail(u.email ?? '');
    setActiveLocal(!!u.is_active);
    setRolesLocal(Array.isArray(u.roles) ? u.roles : []);
  }, [u, id]);

  const busy =
    userQ.isFetching ||
    updateState.isLoading ||
    setActiveState.isLoading ||
    setRolesState.isLoading ||
    setPasswordState.isLoading ||
    removeState.isLoading;

  async function onSaveProfile() {
    try {
      await updateUser({
        id,
        full_name: fullName.trim() || undefined,
        phone: phone.trim() || undefined,
        email: email.trim() || undefined,
      }).unwrap();

      toast.success('Kullanıcı bilgileri güncellendi.');
      userQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  async function onToggleActive(next: boolean) {
    const prev = active;
    try {
      setActiveLocal(next);
      await setActive({ id, is_active: next ? 1 : 0 }).unwrap();
      toast.success(next ? 'Kullanıcı aktif edildi.' : 'Kullanıcı pasif edildi.');
      userQ.refetch();
    } catch (err) {
      setActiveLocal(prev);
      toast.error(getErrMessage(err));
    }
  }

  async function onSaveRoles() {
    try {
      await setRoles({ id, roles }).unwrap();
      toast.success('Roller güncellendi.');
      userQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  async function onSetPassword() {
    const p = password.trim();
    if (p.length < 8) {
      toast.error('Şifre en az 8 karakter olmalıdır.');
      return;
    }
    try {
      await setPassword({ id, password: p }).unwrap();
      toast.success('Şifre güncellendi.');
      setPasswordLocal('');
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  async function onDeleteUser() {
    if (!confirm('Bu kullanıcı silinecek. Devam edilsin mi?')) return;
    try {
      await removeUser({ id }).unwrap();
      toast.success('Kullanıcı silindi.');
      router.replace('/admin/dashboard/users');
      router.refresh();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  function toggleRole(r: Role) {
    setRolesLocal((prev) => {
      const set = new Set(prev);
      if (set.has(r)) set.delete(r);
      else set.add(r);
      return Array.from(set);
    });
  }

  if (userQ.isError) {
    return (
      <div className="space-y-3">
        <Button variant="outline" onClick={() => router.back()}>
          <ArrowLeft className="mr-2 size-4" />
          Geri
        </Button>
        <div className="rounded-md border p-4 text-sm">
          Kullanıcı yüklenemedi.{' '}
          <Button variant="link" className="px-1" onClick={() => userQ.refetch()}>
            Yeniden dene
          </Button>
        </div>
      </div>
    );
  }

  if (!u) {
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
            <h1 className="text-lg font-semibold">Kullanıcı Detay</h1>
          </div>
          {/* ID göstermek istemiyorsan tamamen kaldır */}
          <p className="text-sm text-muted-foreground">
            {u.full_name ? u.full_name : 'İsimsiz Kullanıcı'}
          </p>
        </div>

        <div className="flex items-center gap-2">
          {u.is_admin ? <Badge>Admin</Badge> : <Badge variant="secondary">Kullanıcı</Badge>}
          {u.is_active ? (
            <Badge variant="secondary">Aktif</Badge>
          ) : (
            <Badge variant="destructive">Pasif</Badge>
          )}
        </div>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Temel Bilgiler</CardTitle>
          <CardDescription>
            Ad, telefon ve gerekirse e-posta alanlarını güncelleyin.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-3 md:grid-cols-3">
            <div className="space-y-2">
              <Label htmlFor="email">E-posta</Label>
              <Input
                id="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                disabled={busy}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="full_name">Ad Soyad</Label>
              <Input
                id="full_name"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                disabled={busy}
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="phone">Telefon</Label>
              <Input
                id="phone"
                value={phone}
                onChange={(e) => setPhone(e.target.value)}
                disabled={busy}
              />
            </div>
          </div>

          <div className="flex justify-end">
            <Button onClick={onSaveProfile} disabled={busy}>
              <Save className="mr-2 size-4" />
              Kaydet
            </Button>
          </div>

          <Separator />

          <div className="flex items-center justify-between">
            <div className="space-y-1">
              <div className="font-medium">Kullanıcı Durumu</div>
              <div className="text-sm text-muted-foreground">Aktif/pasif durumunu değiştirin.</div>
            </div>

            <div className="flex items-center gap-2">
              <Label className="text-sm text-muted-foreground">{active ? 'Aktif' : 'Pasif'}</Label>
              <Switch checked={active} onCheckedChange={onToggleActive} disabled={busy} />
            </div>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Rol Yönetimi</CardTitle>
          <CardDescription>
            Roller “tam set” olarak kaydedilir. Seçtiğiniz roller aynen uygulanır.
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex flex-wrap gap-2">
            {ALL_ROLES.map((r) => {
              const checked = roles.includes(r);
              return (
                <Button
                  key={r}
                  type="button"
                  variant={checked ? 'default' : 'outline'}
                  onClick={() => toggleRole(r)}
                  disabled={busy}
                >
                  <ShieldCheck className="mr-2 size-4" />
                  {roleLabel(r)}
                </Button>
              );
            })}
          </div>

          <div className="text-sm text-muted-foreground">
            Seçili roller:{' '}
            {roles.length
              ? roles.map((r) => (
                  <Badge key={r} className="ml-1">
                    {roleLabel(r)}
                  </Badge>
                ))
              : '—'}
          </div>

          <div className="flex justify-end">
            <Button onClick={onSaveRoles} disabled={busy}>
              <Save className="mr-2 size-4" />
              Rolleri Kaydet
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Şifre Güncelle</CardTitle>
          <CardDescription>Güvenlik amacıyla yeni bir şifre belirleyin.</CardDescription>
        </CardHeader>
        <CardContent className="space-y-3">
          <div className="grid gap-3 md:grid-cols-2">
            <div className="space-y-2">
              <Label htmlFor="password">Yeni Şifre</Label>
              <Input
                id="password"
                type="password"
                placeholder="En az 8 karakter"
                value={password}
                onChange={(e) => setPasswordLocal(e.target.value)}
                disabled={busy}
              />
            </div>
          </div>

          <div className="flex justify-end">
            <Button onClick={onSetPassword} disabled={busy}>
              <KeyRound className="mr-2 size-4" />
              Şifreyi Güncelle
            </Button>
          </div>
        </CardContent>
      </Card>

      <Card className="border-destructive/40">
        <CardHeader>
          <CardTitle className="text-base">Tehlikeli İşlem</CardTitle>
          <CardDescription>Kullanıcıyı kalıcı olarak siler.</CardDescription>
        </CardHeader>
        <CardContent className="flex justify-end">
          <Button variant="destructive" onClick={onDeleteUser} disabled={busy}>
            <Trash2 className="mr-2 size-4" />
            Kullanıcıyı Sil
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
