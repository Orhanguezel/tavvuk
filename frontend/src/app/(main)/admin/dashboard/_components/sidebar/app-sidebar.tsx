'use client';

// =============================================================
// FILE: src/app/(main)/dashboard/_components/sidebar/app-sidebar.tsx
// Tavvuk – Sidebar (FIXED types)
// - NavGroup.id: number
// - NavGroup.items: NavMainItem[] (mutable)
// =============================================================

import Link from 'next/link';
import { useShallow } from 'zustand/react/shallow';
import {
  LayoutDashboard,
  Users,
  ShieldCheck,
  ShoppingCart,
  Package,
  MapPin,
  Route,
  BadgePercent,
  Bell,
  BarChart3,
} from 'lucide-react';

import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
} from '@/components/ui/sidebar';

import { APP_CONFIG } from '@/config/app-config';
import { usePreferencesStore } from '@/stores/preferences/preferences-provider';

import { NavMain } from './nav-main';
import { NavUser } from './nav-user';

import type { NavGroup, NavMainItem } from '@/navigation/sidebar/sidebar-items';

type Role = 'admin' | 'seller' | 'driver' | string;

type SidebarMe = {
  id: string;
  name: string;
  email: string;
  role: string;
  avatar: string;
  roles?: Role[];
};

function hasRole(me: SidebarMe, role: Role) {
  if (me.role === role) return true;
  const rs = Array.isArray(me.roles) ? me.roles : [];
  return rs.includes(role);
}

function comingSoon(_url?: string) {
  return '/admin/dashboard/coming-soon';
}

export function AppSidebar({
  me,
  ...props
}: React.ComponentProps<typeof Sidebar> & { me: SidebarMe }) {
  const { sidebarVariant, sidebarCollapsible, isSynced } = usePreferencesStore(
    useShallow((s) => ({
      sidebarVariant: s.sidebarVariant,
      sidebarCollapsible: s.sidebarCollapsible,
      isSynced: s.isSynced,
    })),
  );

  const variant = isSynced ? sidebarVariant : props.variant;
  const collapsible = isSynced ? sidebarCollapsible : props.collapsible;

  // ✅ NavMainItem[] (mutable)
  const adminItems: NavMainItem[] = [
    { title: 'Genel Bakış', url: '/admin/dashboard', icon: LayoutDashboard },

    { title: 'Kullanıcılar', url: '/admin/dashboard/users', icon: Users },
    { title: 'Roller', url: '/admin/dashboard/user-roles', icon: ShieldCheck },

    { title: 'Siparişler', url: '/admin/dashboard/orders', icon: ShoppingCart },
    { title: 'Ürünler', url: '/admin/dashboard/products', icon: Package },
    { title: 'Lokasyonlar', url: '/admin/dashboard/locations', icon: MapPin },
    { title: 'Atamalar', url: comingSoon('/admin/dashboard/assignments'), icon: Route },
    { title: 'Primler', url: '/admin/dashboard/incentives', icon: BadgePercent },
  ];

  // ✅ always mutable array
  const itemsForMe: NavMainItem[] = hasRole(me, 'admin')
    ? adminItems
    : [
        { title: 'Genel Bakış', url: '/admin/dashboard', icon: LayoutDashboard },
        { title: 'Yakında', url: '/admin/dashboard/coming-soon', icon: LayoutDashboard },
      ];

  // ✅ NavGroup.id must be number, items must be NavMainItem[]
  const groups: NavGroup[] = [
    {
      id: 1,
      label: 'Tavvuk',
      items: itemsForMe,
    },
  ];

  return (
    <Sidebar {...props} variant={variant} collapsible={collapsible}>
      <SidebarHeader>
        <SidebarMenu>
          <SidebarMenuItem>
            <SidebarMenuButton asChild>
              <Link prefetch={false} href="/admin/dashboard">
                <LayoutDashboard />
                <span className="font-semibold text-base">{APP_CONFIG.name}</span>
              </Link>
            </SidebarMenuButton>
          </SidebarMenuItem>
        </SidebarMenu>
      </SidebarHeader>

      <SidebarContent>
        <NavMain items={groups} />
      </SidebarContent>

      <SidebarFooter>
        <NavUser
          user={{
            name: me.name,
            email: me.email,
            avatar: me.avatar,
          }}
        />
      </SidebarFooter>
    </Sidebar>
  );
}
