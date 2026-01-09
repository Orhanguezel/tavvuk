import { baseApi } from '@/integrations/rtk/baseApi';
import type {
  AuthTokenResponse,
  AuthStatusResponse,
  AuthMeResponse,
  PasswordResetRequestResponse,
  PasswordResetConfirmResponse,
  AuthTokenRefreshResponse,
  AuthRegisterBody,
  AuthLoginBody,
  AuthUpdateBody,
  PasswordResetRequestBody,
  PasswordResetConfirmBody,
} from '@/integrations/types';

export const authPublicApi = baseApi.injectEndpoints({
  endpoints: (build) => ({
    /** POST /auth/register */
    authRegister: build.mutation<AuthTokenResponse, AuthRegisterBody>({
      query: (body) => ({ url: '/auth/register', method: 'POST', body }),
      invalidatesTags: ['User'],
    }),

    /** POST /auth/login */
    authLogin: build.mutation<AuthTokenResponse, AuthLoginBody>({
      query: (body) => ({ url: '/auth/login', method: 'POST', body }),
      invalidatesTags: ['User'],
    }),

    /** POST /auth/refresh */
    authRefresh: build.mutation<AuthTokenRefreshResponse, void>({
      query: () => ({ url: '/auth/refresh', method: 'POST' }),
      invalidatesTags: ['User'],
    }),

    /** GET /auth/me */
    authMe: build.query<AuthMeResponse, void>({
      query: () => ({ url: '/auth/me', method: 'GET' }),
      providesTags: ['User'],
    }),

    /** GET /auth/status */
    authStatus: build.query<AuthStatusResponse, void>({
      query: () => ({ url: '/auth/status', method: 'GET' }),
      providesTags: ['User'],
    }),

    /** PUT /auth/me */
    authUpdate: build.mutation<AuthMeResponse, AuthUpdateBody>({
      query: (body) => ({ url: '/auth/me', method: 'PUT', body }),
      invalidatesTags: ['User'],
    }),

    /** POST /auth/password-reset/request */
    authPasswordResetRequest: build.mutation<
      PasswordResetRequestResponse,
      PasswordResetRequestBody
    >({
      query: (body) => ({ url: '/auth/password-reset/request', method: 'POST', body }),
    }),

    /** POST /auth/password-reset/confirm */
    authPasswordResetConfirm: build.mutation<
      PasswordResetConfirmResponse,
      PasswordResetConfirmBody
    >({
      query: (body) => ({ url: '/auth/password-reset/confirm', method: 'POST', body }),
    }),

    /** POST /auth/logout (204) */
    authLogout: build.mutation<{ ok: true }, void>({
      query: () => ({ url: '/auth/logout', method: 'POST' }),
      transformResponse: () => ({ ok: true as const }),
      invalidatesTags: ['User', 'AdminUsers', 'UserRoles'],
    }),
  }),
  overrideExisting: true,
});

export const {
  useAuthRegisterMutation,
  useAuthLoginMutation,
  useAuthRefreshMutation,
  useAuthMeQuery,
  useAuthStatusQuery,
  useAuthUpdateMutation,
  useAuthPasswordResetRequestMutation,
  useAuthPasswordResetConfirmMutation,
  useAuthLogoutMutation,
} = authPublicApi;
