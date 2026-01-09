import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

type PmaRow = { id: string; il_id: string; name: string };
type PmaTable = { type: 'table'; name: string; data: PmaRow[] };
type PmaDoc = Array<any>;

type CityOut = {
  code: number;
  name: string;
  districts: Array<{ name: string }>;
};

function normalizeDistrictName(input: string): string {
  // Kaynak ALL CAPS. Türkçe karakterleri koruyup baş harfleri büyütelim.
  // "19 MAYIS" gibi değerlerde her kelimeyi Title Case yapar.
  const s = String(input ?? '').trim();
  if (!s) return s;

  return s
    .toLocaleLowerCase('tr-TR')
    .split(/\s+/g)
    .map((w) => (w ? w[0]!.toLocaleUpperCase('tr-TR') + w.slice(1) : ''))
    .join(' ');
}

function uniqByName(districts: Array<{ name: string }>) {
  const seen = new Set<string>();
  const out: Array<{ name: string }> = [];
  for (const d of districts) {
    const k = d.name.trim().toLocaleLowerCase('tr-TR');
    if (!k || seen.has(k)) continue;
    seen.add(k);
    out.push({ name: d.name.trim() });
  }
  return out;
}

async function main() {
  const ROOT = process.cwd();
  const pmaPath = path.join(ROOT, 'src/db/seed/il_ilce.pma.json');
  const mapPath = path.join(ROOT, 'src/db/seed/tr_cities_by_plate.json');
  const outPath = path.join(ROOT, 'src/db/seed/tr_locations.json');

  const pmaRaw = await readFile(pmaPath, 'utf8');
  const mapRaw = await readFile(mapPath, 'utf8');

  const pma = JSON.parse(pmaRaw) as PmaDoc;
  const plateToCity = JSON.parse(mapRaw) as Record<string, string>;

  const ilceTable = pma.find((x) => x?.type === 'table' && x?.name === 'ilce') as
    | PmaTable
    | undefined;
  if (!ilceTable?.data?.length) {
    throw new Error('pma json içinde type=table name=ilce bulunamadı veya boş.');
  }

  // il_id -> districts[]
  const byPlate = new Map<number, Array<{ name: string }>>();

  for (const r of ilceTable.data) {
    const plate = Number(r.il_id);
    if (!Number.isFinite(plate) || plate <= 0) continue;

    const name = normalizeDistrictName(r.name);
    if (!name) continue;

    const arr = byPlate.get(plate) ?? [];
    arr.push({ name });
    byPlate.set(plate, arr);
  }

  const cities: CityOut[] = [];
  const plates = Array.from(byPlate.keys()).sort((a, b) => a - b);

  for (const plate of plates) {
    const cityName = plateToCity[String(plate)];
    if (!cityName) {
      // mapping eksikse şehir atlanmasın, açık hata ver.
      throw new Error(`tr_cities_by_plate.json içinde il adı yok: plaka=${plate}`);
    }

    const districts = uniqByName(byPlate.get(plate) ?? []);

    cities.push({
      code: plate,
      name: cityName,
      districts,
    });
  }

  const payload = {
    mode: 'upsert',
    activate_all: true,
    cities,
  };

  await writeFile(outPath, JSON.stringify(payload, null, 2), 'utf8');
  console.log(`[OK] wrote ${outPath} (cities=${cities.length})`);
}

main().catch((e) => {
  console.error('[FAIL]', e);
  process.exit(1);
});
