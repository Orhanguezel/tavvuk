// =============================================================
// FILE: src/integrations/rtk/hooks.ts
// Barrel exports for RTK Query hooks
// =============================================================
// =============================================================
// Admin – Ensotek
// Buradan sonrası sadece admin RTK endpoint hook’ları
// =============================================================

// Core / Auth / Dashboard
export * from './admin/dashboard_admin.endpoints';
export * from './admin/db_admin.endpoints';
export * from './admin/auth_admin.endpoints';
export * from './admin/user_roles.endpoints';
export * from './admin/products_admin.api';
export * from './admin/locations_admin.api';
export * from './admin/orders_admin.api';
export * from './admin/orders_driver.api';
export * from './admin/assignments_admin.api';
export * from './admin/incentives_admin.api';
export * from './admin/reports_admin.api';

// =============================================================
// Public
// Buradan sonrası sadece public RTK endpoint hook’ları
// =============================================================

// Modules
export * from './public/auth_public.endpoints';
export * from './public/profiles.endpoints';
export * from './public/products_public.api';
export * from './public/locations_public.api';
export * from './public/orders_public.api';
export * from './public/assignments_public.api';
export * from './public/incentives_public.api';
export * from './public/notifications.api';

