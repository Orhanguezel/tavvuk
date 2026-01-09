// =============================================================
// FILE: src/app/layout.tsx
// FINAL — RootLayout (fix hydration mismatch)
// - ThemeBootScript runs before interactive via next/script
// - suppressHydrationWarning on html + body to tolerate extension-added attrs
// - Avoid server/client className drift on <html>
// =============================================================

import type { ReactNode } from 'react';
import type { Metadata } from 'next';
import Script from 'next/script';

import { Toaster } from '@/components/ui/sonner';
import { APP_CONFIG } from '@/config/app-config';
import { fontVars } from '@/lib/fonts/registry';
import { PREFERENCE_DEFAULTS } from '@/lib/preferences/preferences-config';

import StoreProvider from '@/stores/Provider';
import { PreferencesStoreProvider } from '@/stores/preferences/preferences-provider';

import './globals.css';

export const metadata: Metadata = {
  title: APP_CONFIG.meta.title,
  description: APP_CONFIG.meta.description,
};

function ThemeBootInlineScript() {
  const {
    theme_mode,
    theme_preset,
    content_layout,
    navbar_style,
    sidebar_variant,
    sidebar_collapsible,
    font,
  } = PREFERENCE_DEFAULTS;

  /**
   * Not:
   * - Extension’lar <body> üzerinde attribute ekleyebilir (cz-shortcut-listen gibi).
   * - Bu script, theme class’ı React hydration’dan önce oturtur.
   */
  const code = `
(function () {
  try {
    var d = document.documentElement;

    // defaults (server ile aynı snapshot)
    d.dataset.themePreset = ${JSON.stringify(theme_preset)};
    d.dataset.contentLayout = ${JSON.stringify(content_layout)};
    d.dataset.navbarStyle = ${JSON.stringify(navbar_style)};
    d.dataset.sidebarVariant = ${JSON.stringify(sidebar_variant)};
    d.dataset.sidebarCollapsible = ${JSON.stringify(sidebar_collapsible)};
    d.dataset.font = ${JSON.stringify(font)};

    // localStorage overrides (if exists)
    var lsMode = localStorage.getItem('theme_mode');
    var mode = (lsMode === 'dark' || lsMode === 'light') ? lsMode : ${JSON.stringify(theme_mode)};
    if (mode === 'dark') d.classList.add('dark');
    else d.classList.remove('dark');

  } catch (e) {}
})();
`;

  return (
    <Script id="theme-boot" strategy="beforeInteractive">
      {code}
    </Script>
  );
}

export default function RootLayout({ children }: Readonly<{ children: ReactNode }>) {
  const { theme_preset, content_layout, navbar_style, sidebar_variant, sidebar_collapsible, font } =
    PREFERENCE_DEFAULTS;

  return (
    <html
      lang="tr"
      // html/body hydration mismatch’lerini tolere et (extension + theme class)
      suppressHydrationWarning
      data-theme-preset={theme_preset}
      data-content-layout={content_layout}
      data-navbar-style={navbar_style}
      data-sidebar-variant={sidebar_variant}
      data-sidebar-collapsible={sidebar_collapsible}
      data-font={font}
    >
      <body className={`${fontVars} min-h-screen antialiased`} suppressHydrationWarning>
        <ThemeBootInlineScript />

        {/* Redux store gerekiyorsa kalsın */}
        <StoreProvider>
          {/* Preferences Zustand */}
          <PreferencesStoreProvider>
            {children}
            <Toaster />
          </PreferencesStoreProvider>
        </StoreProvider>
      </body>
    </html>
  );
}
