// =============================================================
// FILE: src/app/(main)/admin/layout.tsx
// FINAL — Dashboard Layout (SSR auth gate) — FIXED (await-safe)
// - Robust cookie forwarding (no cookieStore.toString())
// - Absolute same-origin URL from request headers (await headers())
// =============================================================

import type { ReactNode } from 'react';
import { cookies, headers } from 'next/headers';
import { redirect } from 'next/navigation';

import { AppSidebar } from '@/app/(main)/admin/dashboard/_components/sidebar/app-sidebar';
import { Separator } from '@/components/ui/separator';
import { SidebarInset, SidebarProvider, SidebarTrigger } from '@/components/ui/sidebar';
import { SIDEBAR_COLLAPSIBLE_VALUES, SIDEBAR_VARIANT_VALUES } from '@/lib/preferences/layout';
import { cn } from '@/lib/utils';
import { getPreference } from '@/server/server-actions';

import { AccountSwitcher } from './_components/sidebar/account-switcher';
import { LayoutControls } from './_components/sidebar/layout-controls';
import { ThemeSwitcher } from './_components/sidebar/theme-switcher';

type Role = 'admin' | 'seller' | 'driver' | string;

type AuthStatusResponse =
  | { authenticated: false; is_admin: false; user?: never }
  | {
      authenticated: true;
      is_admin: boolean;
      user: { id: string; email: string | null; roles: Role[] };
    };

type Me = {
  id: string;
  email: string | null;
  role: string;
  roles: Role[];
};

function pickPrimaryRole(roles: Role[]): string {
  if (roles.includes('admin')) return 'admin';
  if (roles.includes('seller')) return 'seller';
  if (roles.includes('driver')) return 'driver';
  return roles[0] ?? 'seller';
}

async function buildCookieHeader(): Promise<string> {
  const store = await cookies();
  const all = store.getAll(); // ✅ now OK (store is resolved)
  // "name=value; name2=value2"
  return all.map((c) => `${c.name}=${c.value}`).join('; ');
}

async function originFromRequest(): Promise<string> {
  const h = await headers(); // ✅ await required in your setup
  const host = h.get('x-forwarded-host') ?? h.get('host') ?? 'localhost:3000';
  const proto = h.get('x-forwarded-proto') ?? 'http';
  return `${proto}://${host}`;
}

async function requireDashboardAdmin(): Promise<Me> {
  const origin = await originFromRequest();
  const url = new URL('/api/auth/status', origin);

  const cookieHeader = await buildCookieHeader();

  try {
    const res = await fetch(url, {
      method: 'GET',
      headers: {
        accept: 'application/json',
        ...(cookieHeader ? { cookie: cookieHeader } : {}),
      },
      cache: 'no-store',
    });

    if (!res.ok) redirect('/auth/login');

    const data = (await res.json()) as AuthStatusResponse;

    if (!data || data.authenticated !== true) redirect('/auth/login');

    const roles = Array.isArray(data.user?.roles) ? data.user.roles : [];
    const isAdmin = roles.includes('admin') || data.is_admin === true;
    if (!isAdmin) redirect('/auth/login');

    return {
      id: data.user.id,
      email: data.user.email ?? null,
      role: pickPrimaryRole(roles),
      roles,
    };
  } catch {
    redirect('/auth/login');
  }
}

export default async function Layout({ children }: Readonly<{ children: ReactNode }>) {
  const me = await requireDashboardAdmin();

  const store = await cookies();
  const defaultOpen = store.get('sidebar_state')?.value !== 'false';

  const [variant, collapsible] = await Promise.all([
    getPreference('sidebar_variant', SIDEBAR_VARIANT_VALUES, 'inset'),
    getPreference('sidebar_collapsible', SIDEBAR_COLLAPSIBLE_VALUES, 'icon'),
  ]);

  return (
    <SidebarProvider defaultOpen={defaultOpen}>
      <AppSidebar
        variant={variant}
        collapsible={collapsible}
        me={{
          id: me.id,
          name: me.email ?? 'Admin',
          email: me.email ?? 'admin',
          role: me.role,
          roles: me.roles,
          avatar: '',
        }}
      />

      <SidebarInset
        className={cn(
          '[html[data-content-layout=centered]_&]:mx-auto! [html[data-content-layout=centered]_&]:max-w-screen-2xl!',
          'max-[113rem]:peer-data-[variant=inset]:mr-2! min-[101rem]:peer-data-[variant=inset]:peer-data-[state=collapsed]:peer-data-[state=collapsed]:mr-auto!',
        )}
      >
        <header
          className={cn(
            'flex h-12 shrink-0 items-center gap-2 border-b transition-[width,height] ease-linear group-has-data-[collapsible=icon]/sidebar-wrapper:h-12',
            '[html[data-navbar-style=sticky]_&]:sticky [html[data-navbar-style=sticky]_&]:top-0 [html[data-navbar-style=sticky]_&]:z-50 [html[data-navbar-style=sticky]_&]:overflow-hidden [html[data-navbar-style=sticky]_&]:rounded-t-[inherit] [html[data-navbar-style=sticky]_&]:bg-background/50 [html[data-navbar-style=sticky]_&]:backdrop-blur-md',
          )}
        >
          <div className="flex w-full items-center justify-between px-4 lg:px-6">
            <div className="flex items-center gap-1 lg:gap-2">
              <SidebarTrigger className="-ml-1" />
              <Separator orientation="vertical" className="mx-2 data-[orientation=vertical]:h-4" />
            </div>

            <div className="flex items-center gap-2">
              <LayoutControls />
              <ThemeSwitcher />
              <AccountSwitcher me={{ id: me.id, email: me.email, role: me.role }} />
            </div>
          </div>
        </header>

        <div className="h-full p-4 md:p-6">{children}</div>
      </SidebarInset>
    </SidebarProvider>
  );
}
