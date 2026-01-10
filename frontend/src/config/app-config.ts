// =============================================================
// FILE: src/config/app-config.ts
// FINAL — Tavvuk Panel Config (TR)
// =============================================================

import packageJson from '../../package.json';

const currentYear = new Date().getFullYear();

export const APP_CONFIG = {
  name: 'Tavvuk Panel',
  version: packageJson.version,
  copyright: `© ${currentYear}, Tavvuk.`,
  meta: {
    title: 'Tavvuk Panel - Yönetim Paneli',
    description:
      'Tavvuk yönetim paneli; sipariş, ürün, lokasyon, prim, bildirim ve rapor süreçlerini tek noktadan yönetmeniz için tasarlanmıştır.',
  },
} as const;
