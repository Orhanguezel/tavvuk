// =============================================================
// FILE: src/integrations/rtk/constants.ts
// FINAL — same-origin API base
// =============================================================

function trimSlash(x: string) {
  return String(x || '').replace(/\/+$/, '');
}

// Cookie-auth için en stabil yaklaşım: same-origin "/api"
const envBase = (process.env.NEXT_PUBLIC_API_URL as string | undefined) || '';

export const BASE_URL = '/api';
export const EDGE_URL = BASE_URL;
export const APP_URL = BASE_URL;

