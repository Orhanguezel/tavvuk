'use client';

import { z } from 'zod';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { toast } from 'sonner';
import { useRouter, useSearchParams } from 'next/navigation';

import { Button } from '@/components/ui/button';
import { Checkbox } from '@/components/ui/checkbox';
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form';
import { Input } from '@/components/ui/input';

import { useAuthRegisterMutation } from '@/integrations/rtk/hooks';

const FormSchema = z
  .object({
    full_name: z.string().trim().min(2).max(100).optional(),
    phone: z.string().trim().min(6).max(50).optional(),

    email: z.string().email({ message: 'Please enter a valid email address.' }),
    password: z.string().min(6, { message: 'Password must be at least 6 characters.' }),
    confirm_password: z.string().min(6),

    accept_terms: z.boolean().refine((v) => v === true, {
      message: 'You must accept the terms to continue.',
    }),
  })
  .refine((v) => v.password === v.confirm_password, {
    message: 'Passwords do not match.',
    path: ['confirm_password'],
  });

type FormValues = z.infer<typeof FormSchema>;

function safeNext(next: string | null | undefined, fallback: string): string {
  const v = String(next ?? '').trim();
  if (!v || !v.startsWith('/')) return fallback;
  if (v.startsWith('//')) return fallback;
  return v;
}

function getErrMessage(err: unknown): string {
  const anyErr = err as any;

  const m1 = anyErr?.data?.error?.message;
  if (typeof m1 === 'string' && m1.trim()) return m1;

  const m1b = anyErr?.data?.error;
  if (typeof m1b === 'string' && m1b.trim()) return m1b;

  const m2 = anyErr?.data?.message;
  if (typeof m2 === 'string' && m2.trim()) return m2;

  const m3 = anyErr?.error;
  if (typeof m3 === 'string' && m3.trim()) return m3;

  return 'Registration failed. Please check your details and try again.';
}

export function RegisterForm() {
  const router = useRouter();
  const sp = useSearchParams();

  const [register, registerState] = useAuthRegisterMutation();

  const form = useForm<FormValues>({
    resolver: zodResolver(FormSchema),
    defaultValues: {
      full_name: '',
      phone: '',
      email: '',
      password: '',
      confirm_password: '',
      accept_terms: false,
    },
    mode: 'onSubmit',
  });

  const onSubmit = async (values: FormValues) => {
    try {
      await register({
        email: values.email.trim().toLowerCase(),
        password: values.password,
        full_name: values.full_name?.trim() || undefined,
        phone: values.phone?.trim() || undefined,
      }).unwrap();

      toast.success('Account created and signed in.');

      const next = safeNext(sp?.get('next'), '/dashboard');
      router.replace(next);
      router.refresh();
    } catch (err) {
      toast.error(getErrMessage(err));
    }
  };

  const isBusy = registerState.isLoading;

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
        {/* Optional profile fields */}
        <FormField
          control={form.control}
          name="full_name"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Full name (optional)</FormLabel>
              <FormControl>
                <Input
                  id="full_name"
                  placeholder="Your name"
                  autoComplete="name"
                  disabled={isBusy}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="phone"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Phone (optional)</FormLabel>
              <FormControl>
                <Input
                  id="phone"
                  placeholder="+90 5xx xxx xx xx"
                  autoComplete="tel"
                  disabled={isBusy}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        {/* Required auth fields */}
        <FormField
          control={form.control}
          name="email"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Email Address</FormLabel>
              <FormControl>
                <Input
                  id="email"
                  type="email"
                  placeholder="you@example.com"
                  autoComplete="email"
                  disabled={isBusy}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Password</FormLabel>
              <FormControl>
                <Input
                  id="password"
                  type="password"
                  placeholder="••••••••"
                  autoComplete="new-password"
                  disabled={isBusy}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        <FormField
          control={form.control}
          name="confirm_password"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Confirm password</FormLabel>
              <FormControl>
                <Input
                  id="confirm_password"
                  type="password"
                  placeholder="••••••••"
                  autoComplete="new-password"
                  disabled={isBusy}
                  {...field}
                />
              </FormControl>
              <FormMessage />
            </FormItem>
          )}
        />

        {/* Terms */}
        <FormField
          control={form.control}
          name="accept_terms"
          render={({ field }) => (
            <FormItem className="flex flex-row items-center">
              <FormControl>
                <Checkbox
                  id="accept_terms"
                  checked={!!field.value}
                  onCheckedChange={(v) => field.onChange(!!v)}
                  disabled={isBusy}
                  className="size-4"
                />
              </FormControl>
              <FormLabel
                htmlFor="accept_terms"
                className="ml-1 font-medium text-muted-foreground text-sm"
              >
                I accept the terms and conditions
              </FormLabel>
              <FormMessage />
            </FormItem>
          )}
        />

        <Button className="w-full" type="submit" disabled={isBusy}>
          {isBusy ? 'Creating account...' : 'Register'}
        </Button>
      </form>
    </Form>
  );
}
