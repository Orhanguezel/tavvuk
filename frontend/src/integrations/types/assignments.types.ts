// =============================================================
// FILE: src/integrations/types/assignments.types.ts
// FINAL — Assignments shared types (public + admin)
// =============================================================

import { BoolLike} from '@/integrations/types';

export type AssignmentStatus = 'active' | 'cancelled';
export type AssignmentSort = 'created_at' | 'updated_at';

export type AdminAssignmentListQuery = {
  q?: string;
  status?: AssignmentStatus;

  order_id?: string;
  driver_id?: string;
  assigned_by?: string;

  limit?: number;
  offset?: number;

  sort?: AssignmentSort;
  order?: 'asc' | 'desc';

  include_cancelled?: BoolLike;
};

export type AdminAssignmentCreateBody = {
  order_id: string;
  driver_id: string;
  note?: string;
};

export type AdminAssignmentPatchBody = {
  driver_id?: string;
  note?: string;
};

export type AdminAssignmentCancelBody = {
  cancel_reason?: string;
};

export type DriverAssignmentListQuery = {
  status?: AssignmentStatus;
  limit?: number;
  offset?: number;
};

export interface AssignmentDto {
  id: string;
  order_id: string;
  driver_id: string;
  assigned_by: string;

  status: AssignmentStatus;

  note?: string | null;
  cancelled_by?: string | null;
  cancelled_at?: string | Date | null;
  cancel_reason?: string | null;

  created_at: string | Date;
  updated_at: string | Date;

  // denormalized convenience (optional)
  order_status?: string | null;
  customer_name?: string | null;
  customer_phone?: string | null;
}

export type AssignmentCreateResponse = {
  ok: true;
  assignment: AssignmentDto | null;
};

export type AssignmentPatchResponse = {
  ok: true;
  assignment: AssignmentDto | null;
};


