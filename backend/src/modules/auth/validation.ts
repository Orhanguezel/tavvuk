// =============================================================
// FILE: src/modules/auth/validation.ts
// FINAL — Tavvuk Auth validations (clean)
// =============================================================
import { z } from 'zod';
import { boolLike } from '@/modules/_shared/common';

export const roleEnum = z.enum(['admin', 'seller', 'driver']);
export type RoleEnum = z.infer<typeof roleEnum>;

/** Optional profile image payload (opsiyonel) */
export const profileImageData = z
  .object({
    profile_image: z.string().trim().url().optional(),
    profile_image_asset_id: z.string().uuid().optional(),
    profile_image_alt: z.string().trim().min(1).max(255).optional(),
  })
  .partial();

/* ----------------------------- AUTH (public) ---------------------------- */

export const registerBody = z.object({
  email: z.string().trim().email(),
  password: z.string().min(6),

  full_name: z.string().trim().min(2).max(100).optional(),
  phone: z.string().trim().min(6).max(50).optional(),

  ...profileImageData.shape,

  options: z
    .object({
      emailRedirectTo: z.string().url().optional(),
      data: z
        .object({
          full_name: z.string().trim().min(2).max(100).optional(),
          phone: z.string().trim().min(6).max(50).optional(),
        })
        .merge(profileImageData)
        .partial()
        .optional(),
    })
    .optional(),
});

export const loginBody = z.object({
  email: z.string().trim().email(),
  password: z.string().min(6),
});

export const updateBody = z
  .object({
    email: z.string().trim().email().optional(),
    password: z.string().min(6).optional(),
  })
  .strict();

/* ----------------------------- PASSWORD RESET --------------------------- */

export const passwordResetRequestBody = z.object({
  email: z.string().trim().email(),
});

export const passwordResetConfirmBody = z.object({
  token: z.string().min(10),
  password: z.string().min(6),
});

/* ----------------------------- /admin/users module ----------------------- */

export const adminUsersListQuery = z.object({
  q: z.string().optional(),
  role: roleEnum.optional(),
  is_active: z.coerce.boolean().optional(),
  limit: z.coerce.number().int().min(1).max(200).default(50),
  offset: z.coerce.number().int().min(0).max(1_000_000).default(0),
  sort: z.enum(['created_at', 'email', 'last_login_at']).optional(),
  order: z.enum(['asc', 'desc']).optional(),
});

export const adminUserUpdateBody = z
  .object({
    full_name: z.string().trim().min(2).max(100).optional(),
    phone: z.string().trim().min(6).max(50).optional(),
    email: z.string().trim().email().optional(),
    is_active: boolLike.optional(),
    ...profileImageData.shape,
  })
  .strict();

export const adminUserSetActiveBody = z.object({
  is_active: boolLike,
});

export const adminUserSetRolesBody = z.object({
  roles: z.array(roleEnum).default([]),
});

export const adminUserSetPasswordBody = z.object({
  password: z.string().min(8).max(200),
});
