// =============================================================
// FILE: src/modules/assignments/validation.ts
// FINAL — Assignments validation (Zod)
// =============================================================

import { z } from 'zod';
import { boolLike } from '@/modules/_shared/common';

export const assignmentStatusEnum = z.enum(['active', 'cancelled']);
export const assignmentSortEnum = z.enum(['created_at', 'updated_at']);

export const adminAssignmentListQuerySchema = z.object({
  q: z.string().optional(),
  status: assignmentStatusEnum.optional(),

  order_id: z.string().optional(),
  driver_id: z.string().optional(),
  assigned_by: z.string().optional(),

  limit: z.union([z.string(), z.number()]).optional(),
  offset: z.union([z.string(), z.number()]).optional(),

  sort: assignmentSortEnum.optional(),
  order: z.enum(['asc', 'desc']).optional(),

  // include cancelled as well? default true
  include_cancelled: boolLike.optional(),
});

export type AdminAssignmentListQuery = z.infer<typeof adminAssignmentListQuerySchema>;

export const adminAssignmentCreateBodySchema = z.object({
  order_id: z.string().min(6),
  driver_id: z.string().min(6),
  note: z.string().max(1000).optional(),
});

export type AdminAssignmentCreateBody = z.infer<typeof adminAssignmentCreateBodySchema>;

export const adminAssignmentPatchBodySchema = z.object({
  driver_id: z.string().min(6).optional(),
  note: z.string().max(1000).optional(),
});

export type AdminAssignmentPatchBody = z.infer<typeof adminAssignmentPatchBodySchema>;

export const adminAssignmentCancelBodySchema = z.object({
  cancel_reason: z.string().max(255).optional(),
});

export type AdminAssignmentCancelBody = z.infer<typeof adminAssignmentCancelBodySchema>;

export const driverAssignmentListQuerySchema = z.object({
  status: assignmentStatusEnum.optional(),
  limit: z.union([z.string(), z.number()]).optional(),
  offset: z.union([z.string(), z.number()]).optional(),
});

export type DriverAssignmentListQuery = z.infer<typeof driverAssignmentListQuerySchema>;
