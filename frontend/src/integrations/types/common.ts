// =============================================================
// FILE: src/integrations/types/common.ts
// =============================================================

/** Genel satır tipi */
export type UnknownRow = Record<string, unknown>;

export type BoolLike = boolean | 0 | 1 | '0' | '1' | 'true' | 'false' | string | number;

export type SortOrder = 'asc' | 'desc';

export type Role = 'admin' | 'seller' | 'driver';

export type ApiOk = { ok: true };

export type OkResponse = { ok: true };
