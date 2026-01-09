// =============================================================
// FILE: src/modules/locations/repository.ts
// FINAL — Locations repository (db access)
// =============================================================
import { db } from '@/db/client';
import { cities, districts } from './schema';
import { and, asc, desc, eq, like, sql } from 'drizzle-orm';
import type { ListCitiesQuery, ListDistrictsQuery } from './validation';

function toBool01(v: any): 0 | 1 {
  if (v === true || v === 1 || v === '1' || v === 'true') return 1;
  return 0;
}

export async function listCities(q: ListCitiesQuery) {
  const conds: any[] = [];
  if (q.q) conds.push(like(cities.name, `%${q.q}%`));
  if (q.is_active != null) conds.push(eq(cities.is_active, toBool01(q.is_active)));

  const where = conds.length ? (conds.length === 1 ? conds[0] : and(...conds)) : undefined;

  const dir = q.direction === 'desc' ? desc : asc;
  const orderCol =
    q.order === 'code' ? cities.code : q.order === 'created_at' ? cities.created_at : cities.name;

  const limit = q.limit && q.limit > 0 ? q.limit : 200;
  const offset = q.offset && q.offset >= 0 ? q.offset : 0;

  const rows = await db
    .select()
    .from(cities)
    .where(where)
    .orderBy(dir(orderCol))
    .limit(limit)
    .offset(offset);
  return rows;
}

export async function listDistricts(q: ListDistrictsQuery) {
  const conds: any[] = [];
  if (q.q) conds.push(like(districts.name, `%${q.q}%`));
  if (q.is_active != null) conds.push(eq(districts.is_active, toBool01(q.is_active)));

  if (q.city_id) conds.push(eq(districts.city_id, q.city_id));

  // city_code -> city_id mapping
  let cityId = q.city_id;
  if (!cityId && q.city_code) {
    const c = (
      await db.select({ id: cities.id }).from(cities).where(eq(cities.code, q.city_code)).limit(1)
    )[0];
    cityId = c?.id;
    if (!cityId) return [];
    conds.push(eq(districts.city_id, cityId));
  }

  const where = conds.length ? (conds.length === 1 ? conds[0] : and(...conds)) : undefined;

  const dir = q.direction === 'desc' ? desc : asc;
  const orderCol =
    q.order === 'code'
      ? districts.code
      : q.order === 'created_at'
      ? districts.created_at
      : districts.name;

  const limit = q.limit && q.limit > 0 ? q.limit : 500;
  const offset = q.offset && q.offset >= 0 ? q.offset : 0;

  const rows = await db
    .select()
    .from(districts)
    .where(where)
    .orderBy(dir(orderCol))
    .limit(limit)
    .offset(offset);
  return rows;
}

export async function countLocations() {
  const c = await db.select({ n: sql<number>`count(*)`.as('n') }).from(cities);
  const d = await db.select({ n: sql<number>`count(*)`.as('n') }).from(districts);
  return { cities: Number(c?.[0]?.n ?? 0), districts: Number(d?.[0]?.n ?? 0) };
}
