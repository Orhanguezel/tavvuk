// src/app/(main)/auth/login/page.tsx

import Link from 'next/link';
import { Command } from 'lucide-react';
import { Suspense } from 'react';

import { LoginForm } from '../_components/login-form';

function LoginFormFallback() {
  return (
    <div className="space-y-4">
      <div className="h-10 w-full rounded-md bg-muted animate-pulse" />
      <div className="h-10 w-full rounded-md bg-muted animate-pulse" />
      <div className="h-10 w-full rounded-md bg-muted animate-pulse" />
      <div className="h-10 w-full rounded-md bg-muted animate-pulse" />
    </div>
  );
}

export default function Login() {
  return (
    <div className="flex min-h-dvh">
      {/* Sol (marka) */}
      <div className="hidden bg-primary lg:block lg:w-1/3">
        <div className="flex h-full flex-col items-center justify-center p-12 text-center">
          <div className="space-y-6">
            <Command className="mx-auto size-12 text-primary-foreground" />
            <div className="space-y-2">
              <h1 className="font-light text-5xl text-primary-foreground">Tekrar hoş geldiniz</h1>
              <p className="text-primary-foreground/80 text-xl">Devam etmek için giriş yapın</p>
            </div>
          </div>
        </div>
      </div>

      {/* Sağ (form) */}
      <div className="flex w-full items-center justify-center bg-background p-8 lg:w-2/3">
        <div className="w-full max-w-md space-y-10 py-24 lg:py-32">
          <div className="space-y-4 text-center">
            <div className="font-medium tracking-tight">Giriş Yap</div>
            <div className="mx-auto max-w-xl text-muted-foreground">
              Tavvuk yönetim paneline erişmek için e-posta adresinizi ve şifrenizi girin.
            </div>
          </div>

          <div className="space-y-4">
            {/* ✅ Next 16: useSearchParams kullanan client component Suspense ister */}
            <Suspense fallback={<LoginFormFallback />}>
              <LoginForm />
            </Suspense>

            {/* Admin-only: self-register yok */}
            <p className="text-center text-muted-foreground text-xs">
              Erişiminiz yok mu?{' '}
              <Link
                prefetch={false}
                href="/auth/login"
                className="text-primary underline-offset-4 hover:underline"
              >
                Yönetici ile iletişime geçin
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
