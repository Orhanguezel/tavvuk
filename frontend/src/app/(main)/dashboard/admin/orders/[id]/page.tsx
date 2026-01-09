// =============================================================
// FILE: src/app/(main)/dashboard/admin/orders/[id]/page.tsx
// FINAL — Admin Order Detail page
// =============================================================

import OrderDetailClient from './order-detail-client';

type Params = { id: string };

export default async function Page({ params }: { params: Promise<Params> | Params }) {
  const p = (await params) as Params;
  return <OrderDetailClient id={p.id} />;
}
