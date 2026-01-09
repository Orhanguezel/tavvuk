// src/integrations/types/locations.types.ts
// =============================================================
// Tavvuk – Locations Types (cities + districts + import)
// =============================================================

import { BoolLike } from '@/integrations/types';

/** ----------------------------- Entities ----------------------------- */

export type CityRaw = {
  id: string;
  code: number;
  name: string;
  is_active: number | boolean;
  created_at?: string;
  updated_at?: string;
};

export type DistrictRaw = {
  id: string;
  city_id: string;
  code: number;
  name: string;
  is_active: number | boolean;
  created_at?: string;
  updated_at?: string;
};

export type CityView = {
  id: string;
  code: number;
  name: string;
  is_active: boolean;
  created_at?: string;
  updated_at?: string;
};

export type DistrictView = {
  id: string;
  city_id: string;
  code: number;
  name: string;
  is_active: boolean;
  created_at?: string;
  updated_at?: string;
};

/** ----------------------------- Queries ----------------------------- */

export type CitiesOrder = 'name' | 'code' | 'created_at';
export type DistrictsOrder = 'name' | 'code' | 'created_at';
export type Direction = 'asc' | 'desc';

export type CitiesListParams = {
  q?: string;
  is_active?: BoolLike;

  limit?: number;
  offset?: number;

  order?: CitiesOrder;
  direction?: Direction;
};

export type DistrictsListParams = {
  /** backend refine: city_id OR city_code required */
  city_id?: string;
  city_code?: number;

  q?: string;
  is_active?: BoolLike;

  limit?: number;
  offset?: number;

  order?: DistrictsOrder;
  direction?: Direction;
};

/** ----------------------------- Admin Import ----------------------------- */

export type ImportMode = 'upsert' | 'replace';

export type ImportLocationDistrictInput = {
  code?: number;
  name: string;
};

export type ImportLocationCityInput = {
  code: number;
  name: string;
  districts?: ImportLocationDistrictInput[];
};

export type ImportLocationsBody = {
  mode?: ImportMode; // default upsert
  cities: ImportLocationCityInput[];
  activate_all?: boolean; // default true
};

export type ImportLocationsResponse = {
  ok: true;
};

/** ----------------------------- Normalizers ----------------------------- */

function toBool(v: any): boolean {
  return v === true || v === 1 || v === '1' || v === 'true';
}

export function normalizeCity(x: CityRaw): CityView {
  return {
    id: String(x?.id ?? ''),
    code: Number((x as any)?.code ?? 0),
    name: String((x as any)?.name ?? ''),
    is_active: toBool((x as any)?.is_active),
    created_at: (x as any)?.created_at,
    updated_at: (x as any)?.updated_at,
  };
}

export function normalizeDistrict(x: DistrictRaw): DistrictView {
  return {
    id: String(x?.id ?? ''),
    city_id: String((x as any)?.city_id ?? ''),
    code: Number((x as any)?.code ?? 0),
    name: String((x as any)?.name ?? ''),
    is_active: toBool((x as any)?.is_active),
    created_at: (x as any)?.created_at,
    updated_at: (x as any)?.updated_at,
  };
}
