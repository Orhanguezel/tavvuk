import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  AdminUserRaw,
  AdminUserView,
  AdminUsersListParams,
  AdminUpdateUserBody,
  AdminSetActiveBody,
  AdminSetRolesBody,
  AdminSetPasswordBody,
  AdminRemoveUserBody,
} from '@/integrations/types';
import { normalizeAdminUser } from '@/integrations/types';

const ADMIN_USERS_BASE = '/admin/users';

export const authAdminApi = baseApi.injectEndpoints({
  endpoints: (b) => ({
    /** GET /admin/users */
    adminList: b.query<AdminUserView[], AdminUsersListParams | void>({
      query: (params) => {
        const p = (params ?? {}) as AdminUsersListParams;
        const sp = new URLSearchParams();

        if (p.q) sp.set('q', p.q);
        if (p.role) sp.set('role', p.role);
        if (typeof p.is_active === 'boolean') sp.set('is_active', p.is_active ? '1' : '0');
        if (p.limit != null) sp.set('limit', String(p.limit));
        if (p.offset != null) sp.set('offset', String(p.offset));
        if (p.sort) sp.set('sort', p.sort);
        if (p.order) sp.set('order', p.order);

        const qs = sp.toString();
        return { url: qs ? `${ADMIN_USERS_BASE}?${qs}` : ADMIN_USERS_BASE, method: 'GET' };
      },
      transformResponse: (res: unknown): AdminUserView[] => {
        if (!Array.isArray(res)) return [];
        return (res as AdminUserRaw[]).map(normalizeAdminUser);
      },
      providesTags: (result) =>
        result && result.length
          ? [
              ...result.map((u) => ({ type: 'AdminUsers' as const, id: u.id })),
              { type: 'AdminUsers' as const, id: 'LIST' },
            ]
          : [{ type: 'AdminUsers' as const, id: 'LIST' }],
    }),

    /** GET /admin/users/:id */
    adminGet: b.query<AdminUserView, { id: string }>({
      query: ({ id }) => ({ url: `${ADMIN_USERS_BASE}/${encodeURIComponent(id)}`, method: 'GET' }),
      transformResponse: (res: unknown): AdminUserView => normalizeAdminUser(res as AdminUserRaw),
      providesTags: (_r, _e, arg) => [{ type: 'AdminUsers' as const, id: arg.id }],
    }),

    /** PATCH /admin/users/:id */
    adminUpdateUser: b.mutation<AdminUserView, AdminUpdateUserBody>({
      query: ({ id, ...patch }) => ({
        url: `${ADMIN_USERS_BASE}/${encodeURIComponent(id)}`,
        method: 'PATCH',
        body: patch,
      }),
      transformResponse: (res: unknown): AdminUserView => normalizeAdminUser(res as AdminUserRaw),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminUsers' as const, id: arg.id },
        { type: 'AdminUsers' as const, id: 'LIST' },
      ],
    }),

    /** POST /admin/users/:id/active */
    adminSetActive: b.mutation<{ ok: true }, AdminSetActiveBody>({
      query: ({ id, is_active }) => ({
        url: `${ADMIN_USERS_BASE}/${encodeURIComponent(id)}/active`,
        method: 'POST',
        body: { is_active },
      }),
      transformResponse: () => ({ ok: true as const }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminUsers' as const, id: arg.id },
        { type: 'AdminUsers' as const, id: 'LIST' },
      ],
    }),

    /** POST /admin/users/:id/roles */
    adminSetRoles: b.mutation<{ ok: true }, AdminSetRolesBody>({
      query: ({ id, roles }) => ({
        url: `${ADMIN_USERS_BASE}/${encodeURIComponent(id)}/roles`,
        method: 'POST',
        body: { roles },
      }),
      transformResponse: () => ({ ok: true as const }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminUsers' as const, id: arg.id },
        { type: 'AdminUsers' as const, id: 'LIST' },
        { type: 'UserRoles' as const, id: 'LIST' },
      ],
    }),

    /** POST /admin/users/:id/password */
    adminSetPassword: b.mutation<{ ok: true }, AdminSetPasswordBody>({
      query: ({ id, password }) => ({
        url: `${ADMIN_USERS_BASE}/${encodeURIComponent(id)}/password`,
        method: 'POST',
        body: { password },
      }),
      transformResponse: () => ({ ok: true as const }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminUsers' as const, id: arg.id },
        { type: 'AdminUsers' as const, id: 'LIST' },
      ],
    }),

    /** DELETE /admin/users/:id */
    adminRemoveUser: b.mutation<{ ok: true }, AdminRemoveUserBody>({
      query: ({ id }) => ({
        url: `${ADMIN_USERS_BASE}/${encodeURIComponent(id)}`,
        method: 'DELETE',
      }),
      transformResponse: () => ({ ok: true as const }),
      invalidatesTags: (_r, _e, arg) => [
        { type: 'AdminUsers' as const, id: arg.id },
        { type: 'AdminUsers' as const, id: 'LIST' },
      ],
    }),
  }),
  overrideExisting: true,
});

export const {
  useAdminListQuery,
  useAdminGetQuery,
  useAdminUpdateUserMutation,
  useAdminSetActiveMutation,
  useAdminSetRolesMutation,
  useAdminSetPasswordMutation,
  useAdminRemoveUserMutation,
} = authAdminApi;
