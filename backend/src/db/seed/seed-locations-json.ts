// =============================================================
// FILE: src/db/seed/seed-locations-json.ts
// FINAL — Seed cities+districts from JSON (robust)
// Usage:
//   bun run db:seed:locations -- --mode=replace
//   bun run db:seed:locations -- --mode=upsert
// =============================================================

import fs from 'node:fs';
import path from 'node:path';
import { randomUUID } from 'node:crypto';

import { db } from '@/db/client';
import { cities, districts } from '@/modules/locations/schema';
import { and, eq } from 'drizzle-orm';

type Mode = 'upsert' | 'replace';

type JsonDistrict = string | { name: string; code?: number };
type JsonCity =
  | { code: number; name: string; districts?: JsonDistrict[] }
  | { plate?: number; cityCode?: number; city?: string; name?: string; districts?: JsonDistrict[] };

function argMode(): Mode {
  const a = process.argv.find((x) => x.startsWith('--mode='));
  const v = (a?.split('=')[1] ?? 'upsert') as Mode;
  return v === 'replace' ? 'replace' : 'upsert';
}

function toName(v: any): string {
  return String(v ?? '').trim();
}

function toCode(v: any): number {
  const n = Number(v);
  if (!Number.isFinite(n)) return 0;
  return Math.trunc(n);
}

/**
 * Match your existing DB deterministic city IDs:
 * c0000000-0000-4000-8000-000000000016 (plate=16)
 */
function cityIdFromCode(code: number): string {
  const n = Math.max(0, Math.trunc(code));
  const suffix = String(n).padStart(12, '0'); // last 12 digits
  return `c0000000-0000-4000-8000-${suffix}`;
}

function normalizeInput(raw: any): {
  cities: Array<{ code: number; name: string; districts: Array<{ code: number; name: string }> }>;
} {
  const list: JsonCity[] = Array.isArray(raw) ? raw : Array.isArray(raw?.cities) ? raw.cities : [];
  if (!list.length) {
    throw new Error('tr_locations.json format unsupported: expected array or {cities:[...]}');
  }

  const out: Array<{
    code: number;
    name: string;
    districts: Array<{ code: number; name: string }>;
  }> = [];

  for (const c of list) {
    const code = toCode((c as any).code ?? (c as any).plate ?? (c as any).cityCode);
    const name = toName((c as any).name ?? (c as any).city);
    if (!code || !name) continue;

    const ds = Array.isArray((c as any).districts) ? (c as any).districts : [];
    const districtsNorm: Array<{ code: number; name: string }> = [];

    for (let i = 0; i < ds.length; i++) {
      const d = ds[i];
      if (typeof d === 'string') {
        const dn = toName(d);
        if (!dn) continue;
        districtsNorm.push({ code: i + 1, name: dn });
      } else if (d && typeof d === 'object') {
        const dn = toName((d as any).name);
        if (!dn) continue;
        const dc = toCode((d as any).code ?? i + 1);
        districtsNorm.push({ code: dc || i + 1, name: dn });
      }
    }

    out.push({ code, name, districts: districtsNorm });
  }

  if (!out.length) throw new Error('No valid city records found in JSON.');
  return { cities: out };
}

function chunk<T>(arr: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

function readJsonFile(jsonPath: string): any {
  if (!fs.existsSync(jsonPath)) {
    throw new Error(`JSON file not found: ${jsonPath}`);
  }
  const txt = fs.readFileSync(jsonPath, 'utf-8');
  const trimmed = txt.trim();
  if (!trimmed) {
    throw new Error(`JSON file is empty: ${jsonPath}`);
  }
  try {
    return JSON.parse(trimmed);
  } catch (e: any) {
    // Common for Unexpected EOF (truncated file)
    throw new Error(
      `JSON parse failed for ${jsonPath}: ${e?.message ?? e}. ` +
        `File may be truncated. Check file size and tail output.`,
    );
  }
}

async function main() {
  const mode = argMode();

  const jsonPath = path.resolve(process.cwd(), 'src/db/seed/tr_locations.json');
  const raw = readJsonFile(jsonPath);
  const data = normalizeInput(raw);

  // eslint-disable-next-line no-console
  console.log(`[INFO] parsed cities=${data.cities.length} from ${jsonPath}`);

  await db.transaction(async (tx: any) => {
    if (mode === 'replace') {
      // FK: districts -> cities
      await tx.delete(districts);
      await tx.delete(cities);
    }

    const cityRows = data.cities.map((c) => ({
      id: cityIdFromCode(c.code),
      code: c.code,
      name: c.name,
      is_active: 1 as const,
    }));

    for (const batch of chunk(cityRows, 200)) {
      await tx
        .insert(cities)
        .values(batch)
        .onDuplicateKeyUpdate({
          set: {
            // keep existing column references; we set real values below
            is_active: 1,
            updated_at: new Date(),
          },
        });

      // ensure name is updated per-row (safe path)
      for (const r of batch) {
        await tx
          .update(cities)
          .set({ name: r.name, is_active: 1, updated_at: new Date() })
          .where(eq(cities.code, r.code));
      }
    }

    const districtRows: Array<{
      id: string;
      city_id: string;
      code: number;
      name: string;
      is_active: 1;
    }> = [];

    for (const c of data.cities) {
      const city_id = cityIdFromCode(c.code);
      for (const d of c.districts) {
        districtRows.push({
          id: randomUUID(),
          city_id,
          code: d.code || 0,
          name: d.name,
          is_active: 1,
        });
      }
    }

    for (const batch of chunk(districtRows, 500)) {
      await tx
        .insert(districts)
        .values(batch)
        .onDuplicateKeyUpdate({
          set: {
            is_active: 1,
            updated_at: new Date(),
          },
        });

      // ensure code updated per-row
      for (const r of batch) {
        await tx
          .update(districts)
          .set({ code: r.code, is_active: 1, updated_at: new Date() })
          .where(and(eq(districts.city_id, r.city_id), eq(districts.name, r.name)));
      }
    }
  });

  // eslint-disable-next-line no-console
  console.log(`[OK] locations seeded from JSON (mode=${mode})`);
}

main().catch((e) => {
  // eslint-disable-next-line no-console
  console.error('[FAIL]', e?.message ?? e);
  process.exit(1);
});
