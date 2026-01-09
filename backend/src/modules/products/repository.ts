// =============================================================
// FILE: src/modules/products/repository.ts
// FINAL — Tavvuk Products repository
// =============================================================
import { db } from '@/db/client';
import { products, type ProductRow, type NewProductRow } from './schema';
import { and, asc, desc, eq, like, sql } from 'drizzle-orm';
import type { ProductListQuery } from './validation';

/* ----------------------------- helpers ----------------------------- */

function uniqStrings(arr: (string | null | undefined)[]): string[] {
  return Array.from(new Set(arr.map((x) => String(x ?? '').trim()).filter(Boolean)));
}

export function slugify(input: string): string {
  const s = String(input ?? '')
    .trim()
    .toLowerCase();
  return s
    .replace(/ğ/g, 'g')
    .replace(/ü/g, 'u')
    .replace(/ş/g, 's')
    .replace(/ı/g, 'i')
    .replace(/ö/g, 'o')
    .replace(/ç/g, 'c')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 200);
}

async function ensureUniqueSlug(base: string, excludeId?: string): Promise<string> {
  const clean = slugify(base) || 'item';
  let candidate = clean;

  for (let i = 0; i < 50; i++) {
    const existing = await db
      .select({ id: products.id })
      .from(products)
      .where(
        and(
          eq(products.slug, candidate),
          ...(excludeId ? [sql`${products.id} <> ${excludeId}`] : ([] as any)),
        ),
      )
      .limit(1);

    if (existing.length === 0) return candidate;
    candidate = `${clean}-${i + 2}`;
  }
  return `${clean}-${Date.now()}`;
}

/* ----------------------------- queries ----------------------------- */

export async function listProducts(q: ProductListQuery): Promise<ProductRow[]> {
  const conds: any[] = [];

  if (q.q) {
    const needle = `%${q.q}%`;
    conds.push(
      sql`(${products.title} like ${needle} or ${products.slug} like ${needle} or ${products.breed} like ${needle})`,
    );
  }
  if (q.species) conds.push(eq(products.species, q.species));
  if (q.breed) conds.push(like(products.breed, `%${q.breed}%`));
  if (q.is_active != null) conds.push(eq(products.is_active, q.is_active as any));
  if (q.is_featured != null) conds.push(eq(products.is_featured, q.is_featured as any));

  // tag filter (JSON_CONTAINS)
  if (q.tag) {
    const tag = JSON.stringify(String(q.tag).trim());
    conds.push(sql`JSON_CONTAINS(${products.tags}, ${tag})`);
  }

  const where = conds.length === 0 ? undefined : conds.length === 1 ? conds[0] : and(...conds);

  const sortCol =
    q.sort === 'title'
      ? products.title
      : q.sort === 'price'
      ? products.price
      : q.sort === 'stock_quantity'
      ? products.stock_quantity
      : q.sort === 'updated_at'
      ? products.updated_at
      : products.created_at;

  const orderFn = q.order === 'asc' ? asc : desc;

  let qb = db.select().from(products).$dynamic();
  if (where) qb = qb.where(where as any);

  qb = qb.orderBy(orderFn(sortCol));
  qb = qb.limit(q.limit && q.limit > 0 ? q.limit : 50);
  if (q.offset && q.offset >= 0) qb = qb.offset(q.offset);

  return qb;
}

export async function getProductById(id: string): Promise<ProductRow | null> {
  return (await db.select().from(products).where(eq(products.id, id)).limit(1))[0] ?? null;
}

export async function getProductBySlug(slug: string): Promise<ProductRow | null> {
  return (await db.select().from(products).where(eq(products.slug, slug)).limit(1))[0] ?? null;
}

/* ----------------------------- mutations ----------------------------- */

export async function createProduct(
  input: Omit<NewProductRow, 'id' | 'created_at' | 'updated_at'>,
): Promise<ProductRow> {
  const id = crypto.randomUUID?.() ?? (await import('crypto')).randomUUID();
  const slug = await ensureUniqueSlug(input.slug || input.title);

  const toInsert: NewProductRow = {
    id,
    title: input.title,
    slug,
    species: (input as any).species ?? 'chicken',
    breed: (input as any).breed ?? null,
    summary: (input as any).summary ?? null,
    description: (input as any).description ?? null,
    price: (input as any).price ?? '0.00',

    image_url: (input as any).image_url ?? null,
    storage_asset_id: (input as any).storage_asset_id ?? null,
    alt: (input as any).alt ?? null,
    images: uniqStrings((input as any).images ?? []),
    storage_image_ids: uniqStrings((input as any).storage_image_ids ?? []),

    stock_quantity: Number((input as any).stock_quantity ?? 0),

    is_active: (input as any).is_active ?? 1,
    is_featured: (input as any).is_featured ?? 0,
    tags: uniqStrings((input as any).tags ?? []),
  } as any;

  await db.insert(products).values(toInsert);
  return (await getProductById(id))!;
}

export async function updateProduct(
  id: string,
  patch: Partial<Omit<NewProductRow, 'id' | 'created_at' | 'updated_at'>>,
): Promise<ProductRow | null> {
  const existing = await getProductById(id);
  if (!existing) return null;

  const nextSlug = patch.slug
    ? await ensureUniqueSlug(patch.slug, id)
    : patch.title
    ? await ensureUniqueSlug(existing.slug || patch.title, id)
    : undefined;

  const toUpdate: Partial<NewProductRow> = {
    ...(patch.title !== undefined ? { title: patch.title as any } : {}),
    ...(nextSlug !== undefined ? { slug: nextSlug as any } : {}),

    ...(patch.species !== undefined ? { species: patch.species as any } : {}),
    ...(patch.breed !== undefined ? { breed: patch.breed as any } : {}),
    ...(patch.summary !== undefined ? { summary: patch.summary as any } : {}),
    ...(patch.description !== undefined ? { description: patch.description as any } : {}),

    ...(patch.price !== undefined ? { price: String(patch.price) as any } : {}),

    ...(patch.image_url !== undefined ? { image_url: patch.image_url as any } : {}),
    ...(patch.storage_asset_id !== undefined
      ? { storage_asset_id: patch.storage_asset_id as any }
      : {}),
    ...(patch.alt !== undefined ? { alt: patch.alt as any } : {}),
    ...(patch.images !== undefined ? { images: uniqStrings(patch.images as any) as any } : {}),
    ...(patch.storage_image_ids !== undefined
      ? { storage_image_ids: uniqStrings(patch.storage_image_ids as any) as any }
      : {}),

    ...(patch.stock_quantity !== undefined
      ? { stock_quantity: Number(patch.stock_quantity) as any }
      : {}),

    ...(patch.is_active !== undefined ? { is_active: patch.is_active as any } : {}),
    ...(patch.is_featured !== undefined ? { is_featured: patch.is_featured as any } : {}),
    ...(patch.tags !== undefined ? { tags: uniqStrings(patch.tags as any) as any } : {}),

    updated_at: new Date() as any,
  };

  await db
    .update(products)
    .set(toUpdate as any)
    .where(eq(products.id, id));
  return await getProductById(id);
}

export async function deleteProduct(id: string): Promise<boolean> {
  const existing = await getProductById(id);
  if (!existing) return false;
  await db.delete(products).where(eq(products.id, id));
  return true;
}
