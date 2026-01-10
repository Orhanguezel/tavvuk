'use client';

// =============================================================
// FILE: src/app/(main)/admin/_components/dashboard-data-table.columns.tsx
// FINAL — Columns (default template style) for dashboard table (TR)
// - TR: UI text Turkish
// - Removed: "Durum/Tamamlandı" column (not needed)
// - Uses Row type from dashboard-data-table.tsx (includes trend + numeric totals)
// =============================================================

import type { ColumnDef } from '@tanstack/react-table';
import { EllipsisVertical } from 'lucide-react';

import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu';

import { DataTableColumnHeader } from '@/components/data-table/data-table-column-header';
import { DashboardCellViewer } from './dashboard-data-table.viewer';
import type { Row } from './dashboard-data-table';

function typeLabel(v: Row['type']): string {
  if (v === 'Driver') return 'Şoför';
  if (v === 'Seller') return 'Satıcı';
  return v;
}

export const dashboardTableColumns: ColumnDef<Row>[] = [
  {
    id: 'select',
    header: ({ table }) => (
      <div className="flex items-center justify-center">
        <Checkbox
          checked={
            table.getIsAllPageRowsSelected() ||
            (table.getIsSomePageRowsSelected() && 'indeterminate')
          }
          onCheckedChange={(value) => table.toggleAllPageRowsSelected(!!value)}
          aria-label="Tümünü seç"
        />
      </div>
    ),
    cell: ({ row }) => (
      <div className="flex items-center justify-center">
        <Checkbox
          checked={row.getIsSelected()}
          onCheckedChange={(value) => row.toggleSelected(!!value)}
          aria-label="Satır seç"
        />
      </div>
    ),
    enableSorting: false,
    enableHiding: false,
  },

  {
    accessorKey: 'header',
    header: ({ column }) => <DataTableColumnHeader column={column} title="Kişi" />,
    cell: ({ row }) => (
      <DashboardCellViewer
        header={row.original.header}
        description="Detay görünüm"
        trend={row.original.trend}
        totals={{
          delivered_orders: row.original.orders_n,
          units_delivered: row.original.units_n,
          incentives: row.original.incentives_n,
        }}
      />
    ),
    enableSorting: false,
  },

  {
    accessorKey: 'type',
    header: ({ column }) => <DataTableColumnHeader column={column} title="Tür" />,
    cell: ({ row }) => (
      <div className="w-32">
        <Badge variant="outline" className="px-1.5 text-muted-foreground">
          {typeLabel(row.original.type)}
        </Badge>
      </div>
    ),
    enableSorting: false,
  },

  {
    accessorKey: 'target',
    header: ({ column }) => (
      <DataTableColumnHeader className="w-full text-right" column={column} title="Adet" />
    ),
    cell: ({ row }) => <div className="text-right tabular-nums">{row.original.target}</div>,
    enableSorting: false,
  },

  {
    accessorKey: 'limit',
    header: ({ column }) => (
      <DataTableColumnHeader className="w-full text-right" column={column} title="Sipariş" />
    ),
    cell: ({ row }) => <div className="text-right tabular-nums">{row.original.limit}</div>,
    enableSorting: false,
  },

  {
    accessorKey: 'reviewer',
    header: ({ column }) => <DataTableColumnHeader column={column} title="Prim" />,
    cell: ({ row }) => <div className="tabular-nums">{row.original.reviewer}</div>,
    enableSorting: false,
  },

  {
    id: 'actions',
    cell: () => (
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button
            variant="ghost"
            className="flex size-8 text-muted-foreground data-[state=open]:bg-muted"
            size="icon"
          >
            <EllipsisVertical />
            <span className="sr-only">Menüyü aç</span>
          </Button>
        </DropdownMenuTrigger>

        <DropdownMenuContent align="end" className="w-32">
          <DropdownMenuItem>Düzenle</DropdownMenuItem>
          <DropdownMenuItem>Kopyala</DropdownMenuItem>
          <DropdownMenuItem>Favorilere ekle</DropdownMenuItem>
          <DropdownMenuSeparator />
          <DropdownMenuItem variant="destructive">Sil</DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    ),
    enableSorting: false,
  },
];
