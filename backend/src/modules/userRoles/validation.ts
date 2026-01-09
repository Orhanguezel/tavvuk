// =============================================================
// FILE: src/modules/userRoles/validation.ts
// FINAL — Tavvuk userRoles validations (single source)
// =============================================================
import { z } from 'zod';
import { USER_ROLES } from './schema';

export const roleEnum = z.enum(USER_ROLES);

export const userRoleListQuerySchema = z.object({
  user_id: z.string().uuid().optional(),
  role: roleEnum.optional(),
  order: z.enum(['created_at']).optional(),
  direction: z.enum(['asc', 'desc']).optional(),
  limit: z.coerce.number().int().min(1).max(200).optional(),
  offset: z.coerce.number().int().min(0).max(1_000_000).optional(),
});

export const createUserRoleSchema = z.object({
  user_id: z.string().uuid(),
  role: roleEnum,
});

export type UserRoleListQuery = z.infer<typeof userRoleListQuerySchema>;
export type CreateUserRoleInput = z.infer<typeof createUserRoleSchema>;
