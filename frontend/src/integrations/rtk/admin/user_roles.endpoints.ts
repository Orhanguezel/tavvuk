import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  UserRoleRowRaw,
  UserRoleRowView,
  UserRolesListParams,
  CreateUserRoleBody,
  DeleteUserRoleBody,
} from '@/integrations/types';
import { normalizeUserRoleRow } from '@/integrations/types';

const BASE = '/admin/user_roles';

export const userRolesAdminApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** GET /admin/user_roles */
    adminUserRolesList: b.query<UserRoleRowView[], UserRolesListParams | void>({
      query: (params) => {
        const p = (params ?? {}) as UserRolesListParams;
        const sp = new URLSearchParams();

        if (p.user_id) sp.set('user_id', p.user_id);
        if (p.role) sp.set('role', p.role);

        if (p.order) sp.set('order', p.order);
        if (p.direction) sp.set('direction', p.direction);

        if (p.limit != null) sp.set('limit', String(p.limit));
        if (p.offset != null) sp.set('offset', String(p.offset));

        const qs = sp.toString();
        return { url: qs ? `${BASE}?${qs}` : BASE, method: 'GET' };
      },
      transformResponse: (res: unknown): UserRoleRowView[] => {
        if (!Array.isArray(res)) return [];
        return (res as UserRoleRowRaw[]).map(normalizeUserRoleRow);
      },
      providesTags: (result) =>
        result && result.length
          ? [
              ...result.map((r) => ({ type: 'UserRoles' as const, id: r.id })),
              { type: 'UserRoles' as const, id: 'LIST' },
            ]
          : [{ type: 'UserRoles' as const, id: 'LIST' }],
    }),

    /** POST /admin/user_roles */
    adminUserRoleCreate: b.mutation<UserRoleRowView, CreateUserRoleBody>({
      query: (body) => ({ url: BASE, method: 'POST', body }),
      transformResponse: (res: unknown): UserRoleRowView =>
        normalizeUserRoleRow(res as UserRoleRowRaw),
      invalidatesTags: (_r, _e, _arg) => [{ type: 'UserRoles' as const, id: 'LIST' }],
    }),

    /** DELETE /admin/user_roles/:id (204) */
    adminUserRoleDelete: b.mutation<{ ok: true }, DeleteUserRoleBody>({
      query: ({ id }) => ({ url: `${BASE}/${encodeURIComponent(id)}`, method: 'DELETE' }),
      transformResponse: () => ({ ok: true as const }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'UserRoles' as const, id: arg.id },
        { type: 'UserRoles' as const, id: 'LIST' },
      ],
    }),
  }),
  overrideExisting: true,
});

export const {
  useAdminUserRolesListQuery,
  useAdminUserRoleCreateMutation,
  useAdminUserRoleDeleteMutation,
} = userRolesAdminApi;
