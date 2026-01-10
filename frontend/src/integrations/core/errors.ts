// =============================================================
// FILE: src/integrations/core/errors.ts
// FINAL — RTK error normalize
// =============================================================

import type { FetchBaseQueryError } from '@reduxjs/toolkit/query';
import type { SerializedError } from '@reduxjs/toolkit';

type MaybeStatus = { status?: unknown };
type MaybeData = { data?: unknown };

export function normalizeError(err: unknown): { message: string; status?: number } {
  // FetchBaseQueryError: { status, data? }
  if (isObject(err) && 'status' in err) {
    const statusRaw = (err as MaybeStatus).status;
    const status = typeof statusRaw === 'number' ? statusRaw : toNum(statusRaw);

    const data = (err as MaybeData).data;

    // data string => direkt göster
    if (typeof data === 'string' && data.trim()) {
      return { message: trimMsg(data), status };
    }

    // data object => yaygın alanları dene
    if (isObject(data)) {
      // Fastify sık kullanır: { error: { message } }
      const nestedMsg = isObject(data.error) ? pickStr(data.error as any, 'message') : null;

      const cand =
        nestedMsg ??
        pickStr(data, 'message') ??
        (typeof data.error === 'string' ? trimMsg(String(data.error)) : null) ??
        pickStr(data, 'detail') ??
        pickStr(data, 'hint') ??
        pickStr(data, 'description') ??
        pickStr(data, 'msg');

      if (cand) return { message: trimMsg(cand), status };

      try {
        return { message: trimMsg(JSON.stringify(data)), status };
      } catch {
        /* noop */
      }
    }

    return { message: status ? `request_failed_${status}` : 'request_failed', status };
  }

  // SerializedError: { message?, name?, stack? }
  if (isObject(err) && 'message' in err) {
    const m = (err as any).message;
    if (typeof m === 'string' && m.trim()) return { message: trimMsg(m) };
  }

  if (err instanceof Error) return { message: trimMsg(err.message) };

  return { message: 'unknown_error' };
}

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null;
}

function pickStr(obj: Record<string, unknown>, key: string): string | null {
  const v = obj[key];
  return typeof v === 'string' && v.trim() ? v : null;
}

function toNum(v: unknown): number | undefined {
  const n = Number(v);
  return Number.isFinite(n) ? n : undefined;
}

function trimMsg(s: string, max = 280): string {
  const t = String(s ?? '').trim();
  if (!t) return 'request_failed';
  return t.length > max ? t.slice(0, max) + '…' : t;
}

// 🔹 RTK helper'larının beklediği ortak sonuç tipi
export type FetchResult<T> = {
  data: T | null;
  error: { message: string; status?: number } | null;
};

// RTK union tipi (gerekirse)
export type RTKError = FetchBaseQueryError | SerializedError | Record<string, unknown>;
