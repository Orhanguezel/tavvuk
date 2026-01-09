'use client';

// =============================================================
// FILE: src/app/(main)/dashboard/admin/incentives/_components/admin-incentives-client.tsx
// FINAL — Admin Incentives (Plans + Rules + Summary quick view)
// - Plans: list/create/patch
// - Rules: get + replace (PUT hard replace)
// - Uses RTK: incentives_admin.api.ts hooks
// =============================================================

import * as React from 'react';
import { toast } from 'sonner';
import {
  Plus,
  RefreshCcw,
  Save,
  Calendar,
  ShieldCheck,
  Truck,
  BadgePercent,
  Loader2,
} from 'lucide-react';

import { cn } from '@/lib/utils';

import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Switch } from '@/components/ui/switch';
import { Separator } from '@/components/ui/separator';
import { Textarea } from '@/components/ui/textarea';

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
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';

import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';

import type {
  IncentivePlanDto,
  IncentiveRuleDto,
  IncentiveRoleContext,
  IncentiveRuleType,
  AdminPlanCreateBody,
  AdminPlanPatchBody,
  AdminReplaceRulesBody,
} from '@/integrations/types';

import {
  useAdminListIncentivePlansQuery,
  useAdminCreateIncentivePlanMutation,
  useAdminPatchIncentivePlanMutation,
  useAdminGetIncentiveRulesQuery,
  useAdminReplaceIncentiveRulesMutation,
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

function toNumber(v: any, fb = 0): number {
  const n = Number(v);
  return Number.isFinite(n) ? n : fb;
}

function yyyyMmDd(d: Date): string {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function parseRuleAmount(v: string): number {
  const s = v.trim().replace(',', '.');
  const n = Number(s);
  if (!Number.isFinite(n) || n < 0) return 0;
  // keep 2 decimals
  return Math.round(n * 100) / 100;
}

type RuleFormRow = {
  id?: string; // backend id (optional)
  role_context: IncentiveRoleContext;
  rule_type: IncentiveRuleType;
  amount: string; // UI string
  product_id?: string | null;
  is_active: boolean;
};

function mapDtoToRow(r: IncentiveRuleDto): RuleFormRow {
  return {
    id: String(r.id),
    role_context: r.role_context,
    rule_type: r.rule_type,
    amount: String(r.amount ?? '0'),
    product_id: (r.product_id ?? null) as any,
    is_active: r.is_active === 1,
  };
}

function makeEmptyRule(role: IncentiveRoleContext, type: IncentiveRuleType): RuleFormRow {
  return {
    role_context: role,
    rule_type: type,
    amount: '0.00',
    product_id: null,
    is_active: true,
  };
}

function roleLabel(role: IncentiveRoleContext) {
  return role === 'driver' ? 'Sürücü' : 'Oluşturan';
}

function ruleTypeLabel(t: IncentiveRuleType) {
  return t === 'per_delivery' ? 'Teslimat Başına' : 'Tavuk Başına';
}

/* ----------------------------- component ----------------------------- */

export default function AdminIncentivesClient() {
  /* ----------------------------- plans ----------------------------- */

  const plansQ = useAdminListIncentivePlansQuery({
    limit: 200,
    offset: 0,
    sort: 'effective_from',
    order: 'desc',
  } as any);

  const [createPlan, createState] = useAdminCreateIncentivePlanMutation();
  const [patchPlan, patchState] = useAdminPatchIncentivePlanMutation();

  const plans: IncentivePlanDto[] = Array.isArray(plansQ.data) ? (plansQ.data as any) : [];

  const [selectedPlanId, setSelectedPlanId] = React.useState<string>('');

  // auto-select first plan
  React.useEffect(() => {
    if (selectedPlanId) return;
    if (plans.length) setSelectedPlanId(plans[0].id);
  }, [plans.length, selectedPlanId]);

  const selectedPlan = selectedPlanId ? plans.find((p) => p.id === selectedPlanId) : undefined;

  /* ----------------------------- rules ----------------------------- */

  const rulesQ = useAdminGetIncentiveRulesQuery(
    selectedPlan ? { planId: selectedPlan.id } : (undefined as any),
    { skip: !selectedPlan } as any,
  ) as any;

  const [replaceRules, replaceRulesState] = useAdminReplaceIncentiveRulesMutation();

  const [activeRoleTab, setActiveRoleTab] = React.useState<IncentiveRoleContext>('creator');

  const [ruleRows, setRuleRows] = React.useState<RuleFormRow[]>([]);
  const [rulesDirty, setRulesDirty] = React.useState(false);

  // hydrate rule form when plan changes / rules fetch
  React.useEffect(() => {
    if (!selectedPlan) {
      setRuleRows([]);
      setRulesDirty(false);
      return;
    }
    const arr: IncentiveRuleDto[] = Array.isArray(rulesQ.data) ? rulesQ.data : [];
    setRuleRows(arr.map(mapDtoToRow));
    setRulesDirty(false);
  }, [selectedPlan?.id, rulesQ.data]);

  function addRule(role: IncentiveRoleContext, type: IncentiveRuleType) {
    setRuleRows((prev) => [...prev, makeEmptyRule(role, type)]);
    setRulesDirty(true);
  }

  function removeRule(idx: number) {
    setRuleRows((prev) => prev.filter((_, i) => i !== idx));
    setRulesDirty(true);
  }

  function updateRule(idx: number, patch: Partial<RuleFormRow>) {
    setRuleRows((prev) => prev.map((r, i) => (i === idx ? { ...r, ...patch } : r)));
    setRulesDirty(true);
  }

  function rulesFor(role: IncentiveRoleContext, type: IncentiveRuleType) {
    return ruleRows
      .map((r, idx) => ({ r, idx }))
      .filter((x) => x.r.role_context === role && x.r.rule_type === type);
  }

  async function onSaveRules() {
    if (!selectedPlan) return;

    // build backend payload
    const body: AdminReplaceRulesBody = {
      rules: ruleRows.map((r) => ({
        role_context: r.role_context,
        rule_type: r.rule_type,
        amount: parseRuleAmount(r.amount),
        product_id: r.product_id ? String(r.product_id) : null,
        is_active: r.is_active,
      })),
    };

    // basic guard
    if (!Array.isArray(body.rules)) {
      toast.error('Rules formatı geçersiz.');
      return;
    }
    if (body.rules.length > 200) {
      toast.error('En fazla 200 kural eklenebilir.');
      return;
    }

    try {
      await replaceRules({ planId: selectedPlan.id, body }).unwrap();
      toast.success('Kurallar kaydedildi.');
      setRulesDirty(false);
      rulesQ.refetch();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  /* ----------------------------- plan edit ----------------------------- */

  const [planName, setPlanName] = React.useState('');
  const [planActive, setPlanActive] = React.useState(true);
  const [planEffective, setPlanEffective] = React.useState(yyyyMmDd(new Date()));

  const [planDirty, setPlanDirty] = React.useState(false);

  React.useEffect(() => {
    if (!selectedPlan) return;
    setPlanName(String(selectedPlan.name ?? ''));
    setPlanActive(selectedPlan.is_active === 1);
    setPlanEffective(String(selectedPlan.effective_from ?? yyyyMmDd(new Date())));
    setPlanDirty(false);
  }, [selectedPlan?.id]);

async function onSavePlan() {
  if (!selectedPlan) return;

  const nameTrim = planName.trim();
  const eff = planEffective.trim();

  if (!nameTrim || nameTrim.length < 2) {
    toast.error('Plan adı en az 2 karakter olmalı.');
    return;
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(eff)) {
    toast.error('effective_from formatı YYYY-MM-DD olmalı.');
    return;
  }

  const patch: AdminPlanPatchBody = {
    id: selectedPlan.id,
    ...(nameTrim !== String(selectedPlan.name ?? '') ? { name: nameTrim } : {}),
    ...(planActive !== (selectedPlan.is_active === 1) ? { is_active: planActive as any } : {}),
    ...(eff !== String(selectedPlan.effective_from ?? '') ? { effective_from: eff } : {}),
  };

  // nothing changed
  if (!patch.name && patch.is_active === undefined && !patch.effective_from) {
    toast.message('Değişiklik yok.');
    setPlanDirty(false);
    return;
  }

  try {
    await patchPlan(patch).unwrap();
    toast.success('Plan güncellendi.');
    setPlanDirty(false);
    plansQ.refetch();
  } catch (err) {
    toast.error(getErrMessage(err));
  }
}


  /* ----------------------------- create plan dialog ----------------------------- */

  const [createOpen, setCreateOpen] = React.useState(false);
  const [newName, setNewName] = React.useState('');
  const [newActive, setNewActive] = React.useState(true);
  const [newEffective, setNewEffective] = React.useState(yyyyMmDd(new Date()));

  async function onCreatePlan() {
    const body: AdminPlanCreateBody = {
      name: newName.trim(),
      is_active: newActive as any,
      effective_from: newEffective,
    };

    if (!body.name || body.name.length < 2) {
      toast.error('Plan adı en az 2 karakter olmalı.');
      return;
    }
    if (!/^\d{4}-\d{2}-\d{2}$/.test(body.effective_from)) {
      toast.error('effective_from formatı YYYY-MM-DD olmalı.');
      return;
    }

    try {
      const created = await createPlan(body).unwrap();
      toast.success('Plan oluşturuldu.');
      setCreateOpen(false);
      setNewName('');
      setNewActive(true);
      setNewEffective(yyyyMmDd(new Date()));
      plansQ.refetch();

      // select newly created plan if id returned
      if (created?.id) setSelectedPlanId(created.id);
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  }

  /* ----------------------------- derived ----------------------------- */

  const busy =
    plansQ.isFetching ||
    createState.isLoading ||
    patchState.isLoading ||
    rulesQ.isFetching ||
    replaceRulesState.isLoading;

  return (
    <div className="space-y-6">
      {/* header */}
      <div className="flex flex-col gap-2 md:flex-row md:items-end md:justify-between">
        <div className="space-y-1">
          <h1 className="text-lg font-semibold">Primler (Admin)</h1>
          <p className="text-sm text-muted-foreground">
            Prim planlarını yönetin, kuralları belirleyin ve teslimat sonrası ledger hesaplarını
            yapılandırın.
          </p>
        </div>

        <div className="flex gap-2">
          <Button
            type="button"
            variant="outline"
            onClick={() => {
              plansQ.refetch();
              if (selectedPlan) rulesQ.refetch();
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

          <Button type="button" onClick={() => setCreateOpen(true)} disabled={busy}>
            <Plus className="mr-2 size-4" />
            Yeni Plan
          </Button>
        </div>
      </div>

      {/* layout */}
      <div className="grid gap-6 lg:grid-cols-12">
        {/* left: plans */}
        <Card className="lg:col-span-5">
          <CardHeader>
            <CardTitle className="text-base">Planlar</CardTitle>
            <CardDescription>Aktif planlar ve geçmiş planlar.</CardDescription>
          </CardHeader>
          <CardContent>
            {plansQ.isError ? (
              <div className="rounded-md border p-4 text-sm">
                Planlar yüklenemedi.{' '}
                <Button variant="link" className="px-1" onClick={() => plansQ.refetch()}>
                  Yeniden dene
                </Button>
              </div>
            ) : (
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Plan</TableHead>
                      <TableHead>Başlangıç</TableHead>
                      <TableHead>Durum</TableHead>
                      <TableHead className="text-right">Seç</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {plans.map((p) => {
                      const isSel = p.id === selectedPlanId;
                      return (
                        <TableRow key={p.id} className={cn(isSel ? 'bg-muted/40' : '')}>
                          <TableCell className="font-medium">
                            <div className="flex flex-col gap-1">
                              <span className="truncate">{p.name}</span>
                              <span className="text-xs text-muted-foreground">
                                #{String(p.id).slice(0, 8)}
                              </span>
                            </div>
                          </TableCell>
                          <TableCell className="text-sm">
                            <span className="inline-flex items-center gap-2">
                              <Calendar className="size-4 text-muted-foreground" />
                              {String(p.effective_from)}
                            </span>
                          </TableCell>
                          <TableCell>
                            {p.is_active === 1 ? (
                              <Badge>Aktif</Badge>
                            ) : (
                              <Badge variant="secondary">Pasif</Badge>
                            )}
                          </TableCell>
                          <TableCell className="text-right">
                            <Button
                              size="sm"
                              variant={isSel ? 'default' : 'outline'}
                              onClick={() => setSelectedPlanId(p.id)}
                              disabled={busy}
                            >
                              Seç
                            </Button>
                          </TableCell>
                        </TableRow>
                      );
                    })}

                    {!plansQ.isFetching && plans.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={4} className="py-10 text-center text-muted-foreground">
                          Plan bulunamadı.
                        </TableCell>
                      </TableRow>
                    ) : null}
                  </TableBody>
                </Table>
              </div>
            )}
          </CardContent>
        </Card>

        {/* right: editor */}
        <Card className="lg:col-span-7">
          <CardHeader>
            <CardTitle className="text-base">Plan ve Kurallar</CardTitle>
            <CardDescription>
              Seçili planın alanlarını güncelleyin ve kural setini yönetin.
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-6">
            {!selectedPlan ? (
              <div className="rounded-md border p-4 text-sm text-muted-foreground">
                Düzenlemek için bir plan seçin.
              </div>
            ) : (
              <>
                {/* plan edit */}
                <div className="grid gap-4 md:grid-cols-3">
                  <div className="space-y-2 md:col-span-2">
                    <Label htmlFor="planName">Plan adı</Label>
                    <Input
                      id="planName"
                      value={planName}
                      onChange={(e) => {
                        setPlanName(e.target.value);
                        setPlanDirty(true);
                      }}
                      disabled={busy}
                      placeholder="Örn: 2026 Ocak Prim Planı"
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="planEffective">effective_from</Label>
                    <Input
                      id="planEffective"
                      value={planEffective}
                      onChange={(e) => {
                        setPlanEffective(e.target.value);
                        setPlanDirty(true);
                      }}
                      disabled={busy}
                      placeholder="YYYY-MM-DD"
                    />
                  </div>

                  <div className="flex items-center gap-3 md:col-span-3">
                    <Switch
                      checked={planActive}
                      onCheckedChange={(v) => {
                        setPlanActive(v);
                        setPlanDirty(true);
                      }}
                      disabled={busy}
                    />
                    <div className="text-sm">
                      <div className="font-medium">Aktif</div>
                      <div className="text-xs text-muted-foreground">
                        Aktif planlar delivered_at tarihine göre seçilir.
                      </div>
                    </div>

                    <div className="ml-auto">
                      <Button onClick={onSavePlan} disabled={busy || !planDirty}>
                        <Save className="mr-2 size-4" />
                        Planı Kaydet
                      </Button>
                    </div>
                  </div>
                </div>

                <Separator />

                {/* rules editor */}
                <div className="space-y-4">
                  <div className="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
                    <div className="space-y-1">
                      <div className="inline-flex items-center gap-2 font-medium">
                        <BadgePercent className="size-4" />
                        Kurallar
                      </div>
                      <p className="text-xs text-muted-foreground">
                        Kaydet butonu tüm kuralları “replace” eder (PUT).
                      </p>
                    </div>

                    <Button onClick={onSaveRules} disabled={busy || !rulesDirty}>
                      <Save className="mr-2 size-4" />
                      Kuralları Kaydet
                    </Button>
                  </div>

                  {rulesQ.isError ? (
                    <div className="rounded-md border p-4 text-sm">
                      Kurallar yüklenemedi.{' '}
                      <Button variant="link" className="px-1" onClick={() => rulesQ.refetch()}>
                        Yeniden dene
                      </Button>
                    </div>
                  ) : null}

                  <Tabs
                    value={activeRoleTab}
                    onValueChange={(v) => setActiveRoleTab(v as IncentiveRoleContext)}
                  >
                    <TabsList>
                      <TabsTrigger value="creator" className="gap-2">
                        <ShieldCheck className="size-4" />
                        Oluşturan
                      </TabsTrigger>
                      <TabsTrigger value="driver" className="gap-2">
                        <Truck className="size-4" />
                        Sürücü
                      </TabsTrigger>
                    </TabsList>

                    {(['creator', 'driver'] as IncentiveRoleContext[]).map((role) => (
                      <TabsContent key={role} value={role} className="space-y-6">
                        {/* per_delivery group */}
                        <RuleGroup
                          title="Teslimat Başına"
                          description="Her teslim edilen sipariş için sabit prim (product_id boş)."
                          rows={rulesFor(role, 'per_delivery')}
                          onAdd={() => addRule(role, 'per_delivery')}
                          onRemove={removeRule}
                          onUpdate={updateRule}
                          busy={busy}
                          type="per_delivery"
                        />

                        {/* per_chicken group */}
                        <RuleGroup
                          title="Tavuk Başına"
                          description="Teslim edilen adet üzerinden prim (genel veya ürün bazlı)."
                          rows={rulesFor(role, 'per_chicken')}
                          onAdd={() => addRule(role, 'per_chicken')}
                          onRemove={removeRule}
                          onUpdate={updateRule}
                          busy={busy}
                          type="per_chicken"
                        />
                      </TabsContent>
                    ))}
                  </Tabs>

                  {/* raw preview (optional, helpful while building) */}
                  <details className="rounded-md border p-3">
                    <summary className="cursor-pointer text-sm font-medium">JSON Preview</summary>
                    <div className="mt-3">
                      <Textarea
                        readOnly
                        value={JSON.stringify(
                          {
                            rules: ruleRows.map((r) => ({
                              role_context: r.role_context,
                              rule_type: r.rule_type,
                              amount: parseRuleAmount(r.amount),
                              product_id: r.product_id ? String(r.product_id) : null,
                              is_active: r.is_active,
                            })),
                          },
                          null,
                          2,
                        )}
                        className="min-h-[220px] font-mono text-xs"
                      />
                    </div>
                  </details>
                </div>
              </>
            )}
          </CardContent>
        </Card>
      </div>

      {/* create dialog */}
      <Dialog open={createOpen} onOpenChange={setCreateOpen}>
        <DialogContent className="max-w-lg">
          <DialogHeader>
            <DialogTitle>Yeni Prim Planı</DialogTitle>
            <DialogDescription>
              Yeni plan oluşturun. effective_from tarihi, delivered_at’e göre plan seçiminde
              kullanılır.
            </DialogDescription>
          </DialogHeader>

          <div className="grid gap-4">
            <div className="space-y-2">
              <Label htmlFor="newName">Plan adı</Label>
              <Input
                id="newName"
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                placeholder="Örn: 2026 Şubat"
                disabled={createState.isLoading}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="newEffective">effective_from (YYYY-MM-DD)</Label>
              <Input
                id="newEffective"
                value={newEffective}
                onChange={(e) => setNewEffective(e.target.value)}
                disabled={createState.isLoading}
              />
            </div>

            <div className="flex items-center gap-3">
              <Switch
                checked={newActive}
                onCheckedChange={setNewActive}
                disabled={createState.isLoading}
              />
              <div className="text-sm">
                <div className="font-medium">Aktif</div>
                <div className="text-xs text-muted-foreground">Plan oluşturulunca aktif olsun.</div>
              </div>
            </div>
          </div>

          <DialogFooter>
            <Button
              variant="outline"
              onClick={() => setCreateOpen(false)}
              disabled={createState.isLoading}
            >
              Vazgeç
            </Button>
            <Button onClick={onCreatePlan} disabled={createState.isLoading}>
              {createState.isLoading ? (
                <Loader2 className="mr-2 size-4 animate-spin" />
              ) : (
                <Plus className="mr-2 size-4" />
              )}
              Oluştur
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}

/* ----------------------------- rule group ----------------------------- */

function RuleGroup(props: {
  title: string;
  description: string;
  type: IncentiveRuleType;
  rows: Array<{ r: RuleFormRow; idx: number }>;
  onAdd: () => void;
  onRemove: (idx: number) => void;
  onUpdate: (idx: number, patch: Partial<RuleFormRow>) => void;
  busy: boolean;
}) {
  const { title, description, type, rows, onAdd, onRemove, onUpdate, busy } = props;

  return (
    <Card>
      <CardHeader className="pb-3">
        <CardTitle className="text-sm">{title}</CardTitle>
        <CardDescription>{description}</CardDescription>
      </CardHeader>

      <CardContent className="space-y-3">
        <div className="flex items-center justify-between gap-2">
          <div className="text-xs text-muted-foreground">Kayıt: {rows.length}</div>
          <Button size="sm" variant="outline" onClick={onAdd} disabled={busy}>
            <Plus className="mr-2 size-4" />
            Kural Ekle
          </Button>
        </div>

        <div className="rounded-md border">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Tip</TableHead>
                <TableHead>Ürün</TableHead>
                <TableHead className="text-right">Tutar</TableHead>
                <TableHead>Aktif</TableHead>
                <TableHead className="text-right">İşlem</TableHead>
              </TableRow>
            </TableHeader>

            <TableBody>
              {rows.map(({ r, idx }) => (
                <TableRow key={`${idx}-${r.role_context}-${r.rule_type}`}>
                  <TableCell className="text-sm">
                    <Badge variant="secondary">{ruleTypeLabel(r.rule_type)}</Badge>
                    <div className="text-xs text-muted-foreground mt-1">
                      {roleLabel(r.role_context)}
                    </div>
                  </TableCell>

                  <TableCell className="text-sm">
                    {type === 'per_delivery' ? (
                      <span className="text-muted-foreground">Genel (product_id yok)</span>
                    ) : (
                      <Input
                        value={r.product_id ? String(r.product_id) : ''}
                        onChange={(e) =>
                          onUpdate(idx, { product_id: e.target.value.trim() || null })
                        }
                        placeholder="product_id (opsiyonel)"
                        disabled={busy}
                      />
                    )}
                  </TableCell>

                  <TableCell className="text-right">
                    <Input
                      value={String(r.amount ?? '')}
                      onChange={(e) => onUpdate(idx, { amount: e.target.value })}
                      inputMode="decimal"
                      className="ml-auto w-28 text-right"
                      disabled={busy}
                    />
                    <div className="text-xs text-muted-foreground mt-1">
                      {type === 'per_delivery' ? '₺ / teslimat' : '₺ / adet'}
                    </div>
                  </TableCell>

                  <TableCell>
                    <Switch
                      checked={!!r.is_active}
                      onCheckedChange={(v) => onUpdate(idx, { is_active: v })}
                      disabled={busy}
                    />
                  </TableCell>

                  <TableCell className="text-right">
                    <Button
                      size="sm"
                      variant="destructive"
                      onClick={() => onRemove(idx)}
                      disabled={busy}
                    >
                      Sil
                    </Button>
                  </TableCell>
                </TableRow>
              ))}

              {rows.length === 0 ? (
                <TableRow>
                  <TableCell colSpan={5} className="py-8 text-center text-muted-foreground">
                    Kural bulunamadı.
                  </TableCell>
                </TableRow>
              ) : null}
            </TableBody>
          </Table>
        </div>

        {type === 'per_chicken' ? (
          <div className="text-xs text-muted-foreground">
            İpucu: product_id boş ise “genel” tavuk başı kuralı olur; dolu ise ürün bazlı
            hesaplanır.
          </div>
        ) : (
          <div className="text-xs text-muted-foreground">
            Not: per_delivery kurallarında product_id kullanılmaz (boş bırakılır).
          </div>
        )}
      </CardContent>
    </Card>
  );
}
