import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  ProfileRow,
  ProfileUpsertInput,
  ProfileUpsertRequest,
  ProfilePublicGetParams,
} from '@/integrations/types';
import { normalizeProfileRow } from '@/integrations/types';

const PROFILES_BASE = '/profiles';

export const profilesApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** Public: GET /profiles/:id */
    profileGetByIdPublic: b.query<ProfileRow, ProfilePublicGetParams>({
      query: ({ id }) => ({
        url: `${PROFILES_BASE}/${encodeURIComponent(id)}`,
        method: 'GET',
      }),
      transformResponse: (res: unknown): ProfileRow => normalizeProfileRow(res as any),
      providesTags: (_r, _e, arg) => [{ type: 'Profiles' as const, id: arg.id }],
    }),

    /** Auth: GET /profiles/me */
    profileGetMe: b.query<ProfileRow | null, void>({
      query: () => ({ url: `${PROFILES_BASE}/me`, method: 'GET' }),
      transformResponse: (res: unknown): ProfileRow | null => {
        if (res == null) return null;
        return normalizeProfileRow(res as any);
      },
      providesTags: [{ type: 'Profiles' as const, id: 'ME' }],
    }),

    /** Auth: PUT /profiles/me  body: { profile: ProfileUpsertInput } */
    profileUpsertMe: b.mutation<ProfileRow | null, ProfileUpsertInput>({
      query: (profile) => {
        const body: ProfileUpsertRequest = { profile };
        return { url: `${PROFILES_BASE}/me`, method: 'PUT', body };
      },
      transformResponse: (res: unknown): ProfileRow | null => {
        if (res == null) return null;
        return normalizeProfileRow(res as any);
      },
      invalidatesTags: (_r) => [
        { type: 'Profiles' as const, id: 'ME' },
        // Public profile sayfalarında da cache varsa (author profile), id bazlı invalidate etmek için
        // UI tarafında upsert sonrası /profiles/:id çağrısı yapan yerler ME id'sini biliyorsa ayrıca invalidate edebilir.
        { type: 'Profiles' as const, id: 'LIST' },
      ],
    }),
  }),
  overrideExisting: true,
});

export const { useProfileGetByIdPublicQuery, useProfileGetMeQuery, useProfileUpsertMeMutation } =
  profilesApi;
