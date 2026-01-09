import Link from 'next/link';
import { Command } from 'lucide-react';
import { Suspense } from 'react';

import { RegisterForm } from '../_components/register-form';

function RegisterFormFallback() {
  return (
    <div className="space-y-4">
      <div className="h-10 w-full rounded-md bg-muted animate-pulse" />
      <div className="h-10 w-full rounded-md bg-muted animate-pulse" />
      <div className="h-10 w-full rounded-md bg-muted animate-pulse" />
      <div className="h-10 w-full rounded-md bg-muted animate-pulse" />
    </div>
  );
}

export default function Register() {
  return (
    <div className="flex min-h-dvh">
      {/* Sol (marka) */}
      <div className="hidden bg-primary lg:block lg:w-1/3">
        <div className="flex h-full flex-col items-center justify-center p-12 text-center">
          <div className="space-y-6">
            <Command className="mx-auto size-12 text-primary-foreground" />
            <div className="space-y-2">
              <h1 className="font-light text-5xl text-primary-foreground">Hesap oluştur</h1>
              <p className="text-primary-foreground/80 text-xl">Devam etmek için kayıt olun</p>
            </div>
          </div>
        </div>
      </div>

      {/* Sağ (form) */}
      <div className="flex w-full items-center justify-center bg-background p-8 lg:w-2/3">
        <div className="w-full max-w-md space-y-10 py-24 lg:py-32">
          <div className="space-y-4 text-center">
            <div className="font-medium tracking-tight">Kayıt Ol</div>
            <div className="mx-auto max-w-xl text-muted-foreground">
              Yeni bir hesap oluşturun. Kayıt işlemi tamamlandıktan sonra otomatik olarak giriş
              yapacaksınız.
            </div>
          </div>

          <div className="space-y-4">
            <Suspense fallback={<RegisterFormFallback />}>
              <RegisterForm />
            </Suspense>

            <p className="text-center text-muted-foreground text-xs">
              Zaten bir hesabınız var mı?{' '}
              <Link
                prefetch={false}
                href="/auth/login"
                className="text-primary underline-offset-4 hover:underline"
              >
                Giriş yap
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
