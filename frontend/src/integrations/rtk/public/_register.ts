// =============================================================
// FILE: src/integrations/rtk/public/_register.ts
// Ensotek Admin RTK Query endpoint registry (single import point)
//  - IMPORTANT: Import this file EXACTLY ONCE in admin bootstrap
// =============================================================

// -------------------------
// Core / Auth / Dashboard
// -------------------------
import './auth_public.endpoints';
import './profiles.endpoints';
import './products_public.api';
import './locations_public.api';
import './orders_public.api';
import './assignments_public.api';
import './incentives_public.api';
import './notifications_admin.api';
