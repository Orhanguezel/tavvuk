// =============================================================
// FILE: src/modules/assignments/types.ts
// FINAL — Assignments module types
// =============================================================

export type AssignmentStatus = 'active' | 'cancelled';

export type AssignmentSort = 'created_at' | 'updated_at';

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
