'use client';

// src/app/(main)/admin/products/[id]/page.tsx

import { useParams } from 'next/navigation';
import ProductDetailClient from '../_components/product-detail-client';

export default function Page() {
  const params = useParams<{ id: string }>();
  const id = String(params?.id ?? '');
  return <ProductDetailClient id={id} />;
}
