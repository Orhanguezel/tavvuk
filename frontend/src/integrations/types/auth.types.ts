import { BoolLike, Role } from '@/integrations/types';


export type AuthRegisterBody = {
  email: string;
  password: string;

  full_name?: string;
  phone?: string;

  profile_image?: string;
  profile_image_asset_id?: string;
  profile_image_alt?: string;

  options?: {
    emailRedirectTo?: string;
    data?: {
      full_name?: string;
      phone?: string;

      profile_image?: string;
      profile_image_asset_id?: string;
      profile_image_alt?: string;
    };
  };
};

export type AuthLoginBody = {
  email: string;
  password: string;
};

export type AuthUpdateBody = {
  email?: string;
  password?: string;
};

export type PublicUserView = {
  id: string;
  email: string | null;
  full_name?: string | null;
  phone?: string | null;
  email_verified?: number | boolean;
  is_active?: number | boolean;
  roles: Role[];
  is_admin: boolean;
};

export type AuthTokenResponse = {
  access_token: string;
  token_type: 'bearer' | string;
  user: PublicUserView;
};

export type AuthTokenRefreshResponse = {
  access_token: string;
  token_type: 'bearer' | string;
};

export type AuthMeResponse = {
  user: {
    id: string;
    email: string | null;
    roles: Role[];
    is_admin: boolean;
  };
};

export type AuthStatusResponse =
  | { authenticated: false; is_admin: false; user?: never }
  | {
      authenticated: true;
      is_admin: boolean;
      user: { id: string; email: string | null; roles: Role[] };
    };

export type PasswordResetRequestBody = { email: string };
export type PasswordResetRequestResponse = {
  success: boolean;
  message?: string;
  token?: string; // backend token döndürüyor
};

export type PasswordResetConfirmBody = { token: string; password: string };
export type PasswordResetConfirmResponse = { success: boolean; message?: string };

