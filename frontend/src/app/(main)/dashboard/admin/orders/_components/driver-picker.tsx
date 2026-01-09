'use client';

// =============================================================
// FILE: src/app/(main)/dashboard/admin/orders/_components/driver-picker.tsx
// FINAL — DriverPicker (AdminUsers -> role=driver)
// =============================================================

import * as React from 'react';
import { Check, ChevronsUpDown, Loader2 } from 'lucide-react';

import { cn } from '@/lib/utils';
import { Button } from '@/components/ui/button';
import { Popover, PopoverContent, PopoverTrigger } from '@/components/ui/popover';
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
} from '@/components/ui/command';

import type { AdminUserView } from '@/integrations/types';
import { useAdminListQuery } from '@/integrations/rtk/hooks';

export type DriverOption = {
  id: string;
  full_name: string;
  phone?: string | null;
  email?: string | null;
};

function labelOf(d: DriverOption) {
  const parts = [d.full_name?.trim(), d.phone?.trim()].filter(Boolean);
  return parts.join(' • ') || d.id.slice(0, 8);
}

function toDriverOption(u: AdminUserView): DriverOption {
  return {
    id: String((u as any).id),
    full_name:
      String((u as any).full_name ?? '').trim() || String((u as any).email ?? '').trim() || '—',
    phone: (u as any).phone ?? null,
    email: (u as any).email ?? null,
  };
}

export function DriverPicker(props: {
  value?: string; // selected driver_id
  onChange: (nextId: string, driver?: DriverOption) => void;
  disabled?: boolean;
  placeholder?: string;
  initialLabel?: string; // mevcut atamada gösterilecek label fallback
  roleKey?: string; // backend rol anahtarı (default: driver)
}) {
  const {
    value,
    onChange,
    disabled,
    placeholder = 'Sürücü seç…',
    initialLabel,
    roleKey = 'driver',
  } = props;

  const [open, setOpen] = React.useState(false);
  const [q, setQ] = React.useState('');
  const debouncedQ = useDebouncedValue(q, 250);

  // ✅ Doğru kaynak: Admin Users list (role=driver)
  const usersQ = useAdminListQuery(
    open
      ? ({
          q: debouncedQ || undefined,
          role: roleKey as any,
          limit: 20,
          offset: 0,
        } as any)
      : (undefined as any),
    { skip: !open } as any,
  ) as any;

  const options: DriverOption[] = Array.isArray(usersQ.data)
    ? (usersQ.data as AdminUserView[]).map(toDriverOption)
    : [];

  const selected = value ? options.find((x) => x.id === value) : undefined;
  const buttonText = selected ? labelOf(selected) : initialLabel || placeholder;

  return (
    <Popover open={open} onOpenChange={(v) => setOpen(v)}>
      <PopoverTrigger asChild>
        <Button
          variant="outline"
          role="combobox"
          aria-expanded={open}
          disabled={disabled}
          className="w-full justify-between"
        >
          <span className="truncate">{buttonText}</span>
          <span className="ml-2 inline-flex items-center gap-2">
            {usersQ.isFetching ? <Loader2 className="size-4 animate-spin" /> : null}
            <ChevronsUpDown className="size-4 opacity-50" />
          </span>
        </Button>
      </PopoverTrigger>

      <PopoverContent className="w-[--radix-popover-trigger-width] p-0" align="start">
        <Command shouldFilter={false}>
          <CommandInput value={q} onValueChange={setQ} placeholder="İsim/telefon ile ara…" />
          <CommandEmpty>{usersQ.isFetching ? 'Yükleniyor…' : 'Sürücü bulunamadı.'}</CommandEmpty>

          <CommandGroup>
            {options.map((d) => {
              const isSelected = d.id === value;
              return (
                <CommandItem
                  key={d.id}
                  value={d.id}
                  onSelect={() => {
                    onChange(d.id, d);
                    setOpen(false);
                  }}
                >
                  <Check className={cn('mr-2 size-4', isSelected ? 'opacity-100' : 'opacity-0')} />
                  <span className="truncate">{labelOf(d)}</span>
                </CommandItem>
              );
            })}
          </CommandGroup>
        </Command>
      </PopoverContent>
    </Popover>
  );
}

function useDebouncedValue<T>(value: T, delayMs: number) {
  const [v, setV] = React.useState(value);
  React.useEffect(() => {
    const t = setTimeout(() => setV(value), delayMs);
    return () => clearTimeout(t);
  }, [value, delayMs]);
  return v;
}
