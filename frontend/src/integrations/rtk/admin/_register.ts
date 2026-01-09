// =============================================================
// FILE: src/integrations/rtk/endpoints/admin/_register.ts
// Ensotek Admin RTK Query endpoint registry (single import point)
//  - IMPORTANT: Import this file EXACTLY ONCE in admin bootstrap
// =============================================================

/**
 * Admin tarafındaki RTK Query injectEndpoints importlarını tek yerde toplar.
 * Admin component'leri endpoints/admin/*.ts dosyalarını import etmemeli.
 * Hook exportları için hooks.ts (barrel) kullanılacak.
 */

// -------------------------
// Core / Auth / Dashboard
// -------------------------
import './auth_admin.endpoints';
import './user_roles.endpoints';
import './products_admin.api';
import './locations_admin.api';
import './orders_admin.api';
import './assignments_admin.api';
import './orders_driver.api';
import './incentives_admin.api';
import './reports_admin.api';

