// src/integrations/rtk/locations.api.ts
// =============================================================
// Tavvuk – Locations RTK (public + admin import)
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';

import type {
  CitiesListParams,
  DistrictsListParams,
  CityRaw,
  CityView,
  DistrictRaw,
  DistrictView,
  ImportLocationsBody,
  ImportLocationsResponse,
} from '@/integrations/types';

import { normalizeCity, normalizeDistrict } from '@/integrations/types';

const PUBLIC_BASE = '/locations';

function buildQS(params: Record<string, any>) {
  const sp = new URLSearchParams();

  Object.entries(params).forEach(([k, v]) => {
    if (v === undefined || v === null || v === '') return;
    sp.set(k, String(v));
  });

  const qs = sp.toString();
  return qs ? `?${qs}` : '';
}

export const locationsApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** ----------------------------- PUBLIC ----------------------------- */

    /** GET /locations/cities */
    locationsCities: b.query<CityView[], CitiesListParams | void>({
      query: (params) => {
        const p = (params ?? {}) as CitiesListParams;
        const qs = buildQS({
          q: p.q,
          is_active: p.is_active,
          limit: p.limit,
          offset: p.offset,
          order: p.order,
          direction: p.direction,
        });
        return { url: `${PUBLIC_BASE}/cities${qs}`, method: 'GET' };
      },
      transformResponse: (res: unknown): CityView[] => {
        if (!Array.isArray(res)) return [];
        return (res as CityRaw[]).map(normalizeCity);
      },
      providesTags: (result) =>
        result && result.length
          ? [
              ...result.map((c) => ({ type: 'LocationsCities' as const, id: c.id })),
              { type: 'LocationsCities' as const, id: 'LIST' },
            ]
          : [{ type: 'LocationsCities' as const, id: 'LIST' }],
    }),

    /** GET /locations/districts (requires city_id OR city_code) */
    locationsDistricts: b.query<DistrictView[], DistrictsListParams>({
      query: (params) => {
        const p = (params ?? {}) as DistrictsListParams;

        const qs = buildQS({
          city_id: p.city_id,
          city_code: p.city_code,
          q: p.q,
          is_active: p.is_active,
          limit: p.limit,
          offset: p.offset,
          order: p.order,
          direction: p.direction,
        });

        return { url: `${PUBLIC_BASE}/districts${qs}`, method: 'GET' };
      },
      transformResponse: (res: unknown): DistrictView[] => {
        if (!Array.isArray(res)) return [];
        return (res as DistrictRaw[]).map(normalizeDistrict);
      },
      providesTags: (result) =>
        result && result.length
          ? [
              ...result.map((d) => ({ type: 'LocationsDistricts' as const, id: d.id })),
              { type: 'LocationsDistricts' as const, id: 'LIST' },
            ]
          : [{ type: 'LocationsDistricts' as const, id: 'LIST' }],
    }),

    /** GET /locations/cities/:cityId/districts */
    locationsDistrictsByCityId: b.query<
      DistrictView[],
      { cityId: string } & Omit<DistrictsListParams, 'city_id' | 'city_code'>
    >({
      query: ({ cityId, ...rest }) => {
        const qs = buildQS({
          q: rest.q,
          is_active: rest.is_active,
          limit: rest.limit,
          offset: rest.offset,
          order: rest.order,
          direction: rest.direction,
        });
        return {
          url: `${PUBLIC_BASE}/cities/${encodeURIComponent(cityId)}/districts${qs}`,
          method: 'GET',
        };
      },
      transformResponse: (res: unknown): DistrictView[] => {
        if (!Array.isArray(res)) return [];
        return (res as DistrictRaw[]).map(normalizeDistrict);
      },
      providesTags: (result, _e, arg) =>
        result && result.length
          ? [
              ...result.map((d) => ({ type: 'LocationsDistricts' as const, id: d.id })),
              { type: 'LocationsDistricts' as const, id: `CITY:${arg.cityId}` },
            ]
          : [{ type: 'LocationsDistricts' as const, id: `CITY:${arg.cityId}` }],
    }),

  }),
  overrideExisting: true,
});

export const {
  useLocationsCitiesQuery,
  useLocationsDistrictsQuery,
  useLocationsDistrictsByCityIdQuery,
} = locationsApi;
