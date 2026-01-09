// =============================================================
// FILE: src/integrations/rtk/baseApi.ts
// Panel Next.js + Fastify backend için RTK base
// FINAL (HARDENED):
//  - Cookie auth: credentials: 'include' (kritik)
//  - Authorization header cookie auth'u bozmasın diye /auth/* için kesin bypass
//  - 401 -> refresh (tek refresh in-flight) -> retry (sonsuz loop engelli)
//  - FormData body varsa Content-Type ASLA set edilmez (boundary bozulmasın)
//  - JSON-like body varsa Content-Type set edilir
//  - Headers: object | Headers iki türü de güvenli yönetilir
// =============================================================

import { createApi, fetchBaseQuery } from '@reduxjs/toolkit/query/react';
import type {
  BaseQueryFn,
  FetchArgs,
  FetchBaseQueryError,
  FetchBaseQueryMeta,
} from '@reduxjs/toolkit/query';

import { tags } from './tags';
import { BASE_URL as CONFIG_BASE_URL } from '@/integrations/rtk/constants';

/* ---------------------------------- baseUrl ---------------------------------- */

function trimSlash(x: string) {
  return String(x || '').replace(/\/+$/, '');
}

/**
 * Panel için dev tahmini:
 * - UI:      http://localhost:3000
 * - Backend: http://localhost:8045/api
 */
function guessDevBackend(): string {
  try {
    if (typeof window !== 'undefined') {
      const { protocol, hostname } = window.location;
      const host = hostname || 'localhost';
      return `${protocol}//${host}:8045/api`;
    }
  } catch {
    // noop
  }
  return 'http://localhost:8045/api';
}

// Öncelik: constants.ts -> env -> dev guess
const BASE_URL = trimSlash(
  CONFIG_BASE_URL ||
    process.env.NEXT_PUBLIC_PANEL_API_BASE ||
    (process.env.NODE_ENV !== 'production' ? guessDevBackend() : '/api'),
);

/* ---------------------------------- helpers ---------------------------------- */

function isRecord(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null && !Array.isArray(v);
}

function isFormDataBody(b: unknown): boolean {
  return typeof FormData !== 'undefined' && b instanceof FormData;
}

function isJsonLikeBody(b: unknown): b is Record<string, unknown> {
  if (!b) return false;
  if (isFormDataBody(b)) return false;
  if (typeof Blob !== 'undefined' && b instanceof Blob) return false;
  if (typeof ArrayBuffer !== 'undefined' && b instanceof ArrayBuffer) return false;
  return isRecord(b);
}

function toPath(u: string): string {
  const s = String(u || '');
  if (!s) return '/';

  // absolute url -> pathname
  if (/^https?:\/\//i.test(s)) {
    try {
      return new URL(s).pathname || '/';
    } catch {
      return s.startsWith('/') ? s : `/${s}`;
    }
  }

  return s.startsWith('/') ? s : `/${s}`;
}

function normalizeCleanPath(u: string): string {
  const p = toPath(u).replace(/\/+$/, '');
  return p || '/';
}

/* --------------------------- header utils (robust) --------------------------- */

function isHeaders(h: any): h is Headers {
  return typeof Headers !== 'undefined' && h instanceof Headers;
}

function headerHas(h: any, key: string): boolean {
  if (!h) return false;
  if (isHeaders(h)) return h.has(key);
  const k = key.toLowerCase();
  return Object.keys(h).some((x) => x.toLowerCase() === k);
}

function headerSet(h: any, key: string, value: string): any {
  if (isHeaders(h)) {
    h.set(key, value);
    return h;
  }
  return { ...(h || {}), [key]: value };
}

function headerDel(h: any, key: string): any {
  if (!h) return h;
  if (isHeaders(h)) {
    h.delete(key);
    return h;
  }
  const k = key.toLowerCase();
  const next: Record<string, any> = { ...(h || {}) };
  for (const kk of Object.keys(next)) {
    if (kk.toLowerCase() === k) delete next[kk];
  }
  return next;
}

/* ------------------------------- auth behavior ------------------------------ */

/**
 * Cookie-auth ortamında Authorization header çoğu zaman sıkıntı çıkarır:
 * - Backend, Authorization gördüğünde cookie'yi ignore edebilir.
 * Bu yüzden /auth/* altında Authorization kesinlikle EKLENMEZ / VARSA SİLİNİR.
 */
const AUTH_HEADER_BYPASS_PREFIXES = ['/auth/'] as const;

function shouldBypassAuthHeader(path: string): boolean {
  const p = normalizeCleanPath(path);
  return AUTH_HEADER_BYPASS_PREFIXES.some((pref) => p === pref || p.startsWith(pref));
}

/**
 * Refresh denemesi YAPMAYACAĞIMIZ path'ler (sonsuz loop önler).
 */
const AUTH_SKIP_REAUTH = new Set<string>([
  '/auth/login',
  '/auth/logout',
  '/auth/token/refresh',
  '/auth/me',
  '/auth/status',
]);

/**
 * ✅ JSON body: Content-Type application/json set edilir
 * ✅ FormData body: Content-Type ASLA set edilmez; varsa kaldırılır
 */
function ensureContentType(a: FetchArgs): FetchArgs {
  const next: FetchArgs = { ...a };

  // FormData => boundary bozulmasın
  if (typeof next.body !== 'undefined' && isFormDataBody(next.body)) {
    next.headers = headerDel(headerDel(next.headers, 'content-type'), 'Content-Type');
    return next;
  }

  // JSON-like body => Content-Type set
  if (typeof next.body !== 'undefined' && isJsonLikeBody(next.body)) {
    // tek casing ile set etmek yeterli (Headers case-insensitive)
    next.headers = headerSet(next.headers, 'content-type', 'application/json');
  }

  return next;
}

function stripAuthorizationIfNeeded(a: FetchArgs, cleanPath: string): FetchArgs {
  if (!shouldBypassAuthHeader(cleanPath)) return a;

  const next: FetchArgs = { ...a };
  next.headers = headerDel(headerDel(next.headers, 'authorization'), 'Authorization');
  return next;
}

/* -------------------------------- base query -------------------------------- */

type RBQ = BaseQueryFn<
  string | FetchArgs,
  unknown,
  FetchBaseQueryError,
  unknown,
  FetchBaseQueryMeta
>;

const DEFAULT_LOCALE = (process.env.NEXT_PUBLIC_DEFAULT_LOCALE as string | undefined) || 'de';

const rawBaseQuery: RBQ = fetchBaseQuery({
  baseUrl: BASE_URL,
  credentials: 'include', // ✅ Cookie set/forward için KRİTİK
  prepareHeaders: (headers) => {
    if (!headers.has('accept')) headers.set('accept', 'application/json');
    if (!headers.has('accept-language')) headers.set('accept-language', DEFAULT_LOCALE);

    // Cookie-auth esas: Authorization'ı burada default eklemiyoruz.
    return headers;
  },
  responseHandler: async (response) => {
    const ct = response.headers.get('content-type') || '';
    if (ct.includes('application/json')) return response.json();
    if (ct.includes('text/')) return response.text();
    try {
      const t = await response.text();
      return t || null;
    } catch {
      return null;
    }
  },
  validateStatus: (res) => res.ok,
}) as RBQ;

/* -------------------------- 401 -> refresh -> retry -------------------------- */

type RawResult = Awaited<ReturnType<typeof rawBaseQuery>>;

// ✅ refresh concurrency
let refreshInFlight: Promise<RawResult> | null = null;

async function runRefresh(api: any, extra: any): Promise<RawResult> {
  // refresh endpoint cookie ile çalışacak; Authorization istemiyoruz
  const r = await rawBaseQuery(
    {
      url: '/auth/token/refresh',
      method: 'POST',
      // JSON body yoksa content-type set etmiyoruz (backend body bekliyorsa ekleyebilirsin)
      headers: {
        accept: 'application/json',
      } as any,
    },
    api,
    extra,
  );

  return r as RawResult;
}

const baseQueryWithReauth: RBQ = async (args, api, extra) => {
  // ---- build request
  let req: string | FetchArgs = args;
  const urlPath = typeof req === 'string' ? req : req.url || '';
  const cleanPath = normalizeCleanPath(urlPath);

  if (typeof req !== 'string') {
    req = stripAuthorizationIfNeeded(req, cleanPath);
    req = ensureContentType(req);
  }

  // ---- first attempt
  let result: RawResult = (await rawBaseQuery(req, api, extra)) as RawResult;

  // ---- 401 -> refresh? (skip list dışında)
  if (result.error?.status === 401 && !AUTH_SKIP_REAUTH.has(cleanPath)) {
    if (!refreshInFlight) {
      refreshInFlight = (async () => {
        try {
          return await runRefresh(api, extra);
        } finally {
          refreshInFlight = null;
        }
      })();
    }

    const refreshRes = await refreshInFlight;

    if (!refreshRes.error) {
      // retry original
      let retry: string | FetchArgs = args;
      const retryPath = typeof retry === 'string' ? retry : retry.url || '';
      const retryCleanPath = normalizeCleanPath(retryPath);

      if (typeof retry !== 'string') {
        retry = stripAuthorizationIfNeeded(retry, retryCleanPath);
        retry = ensureContentType(retry);
      }

      result = (await rawBaseQuery(retry, api, extra)) as RawResult;
    }
  }

  return result;
};

export const baseApi = createApi({
  reducerPath: 'tavvukApi',
  baseQuery: baseQueryWithReauth,
  endpoints: () => ({}),
  tagTypes: tags,
});

export { rawBaseQuery, BASE_URL };
