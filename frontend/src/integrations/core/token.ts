// =============================================================
// FILE: src/integrations/core/token.ts
// FINAL — SSR-safe access_token depolama yardımcıları
// =============================================================

const TOKEN_KEY = 'access_token';

const isBrowser = typeof window !== 'undefined' && typeof window.localStorage !== 'undefined';

export const tokenStore = {
  get(): string {
    if (!isBrowser) return '';
    try {
      return (window.localStorage.getItem(TOKEN_KEY) || '').trim();
    } catch {
      return '';
    }
  },

  set(token?: string | null) {
    if (!isBrowser) return;
    try {
      const t = (token || '').trim();
      if (!t) window.localStorage.removeItem(TOKEN_KEY);
      else window.localStorage.setItem(TOKEN_KEY, t);
    } catch {
      // localStorage disabled vs. — sessizce geç
    }
  },
};
