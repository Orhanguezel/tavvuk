// src/integrations/rtk/locations_admin.api.ts
// =============================================================
// Tavvuk – Locations ADMIN RTK (import)
// Base prefix: /api/admin (baseApi içinde varsayılır)
// =============================================================

import { baseApi } from '@/integrations/rtk/baseApi';

import type { ImportLocationsBody, ImportLocationsResponse } from '@/integrations/types';

const ADMIN_LOCATIONS_BASE = '/admin/locations';

export const locationsAdminApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** POST /admin/locations/import */
    adminImportLocations: b.mutation<ImportLocationsResponse, ImportLocationsBody>({
      query: (body) => ({
        url: `${ADMIN_LOCATIONS_BASE}/import`,
        method: 'POST',
        body,
      }),
      transformResponse: (res: any): ImportLocationsResponse => {
        // backend: { ok: true }
        if (res && typeof res === 'object' && 'ok' in res) {
          return { ok: !!res.ok } as ImportLocationsResponse;
        }
        // fallback: kabul et
        return { ok: true as const };
      },
      invalidatesTags: () => [
        // import sonrası şehir/ilçe listeleri değişir
        { type: 'LocationsCities' as const, id: 'LIST' },
        { type: 'LocationsDistricts' as const, id: 'LIST' },
      ],
    }),
  }),
  overrideExisting: true,
});

export const { useAdminImportLocationsMutation } = locationsAdminApi;
