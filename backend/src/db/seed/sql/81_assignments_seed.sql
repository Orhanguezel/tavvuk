-- ============================================================================
-- FILE: db/seed/73_assignments_seed.sql
-- FINAL — Seed: ASSIGNMENTS (pairs with 71_orders_seed.sql)
-- - Uses status (active|cancelled)
-- - No is_active column (schema compatible)
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- Optional cleanup
-- DELETE FROM `assignments`;

-- ----------------------------------------------------------------------------
-- A1: assigned -> active
-- order_id: 90000000-0000-4000-8000-000000000101
-- driver : ffffffff-ffff-4fff-8fff-ffffffffffff
-- ----------------------------------------------------------------------------
INSERT INTO `assignments`
(
  `id`,`order_id`,`driver_id`,`assigned_by`,
  `status`,`note`,
  `cancelled_by`,`cancelled_at`,`cancel_reason`,
  `created_at`,`updated_at`
)
VALUES
(
  '91000000-0000-4000-8000-000000000101',
  '90000000-0000-4000-8000-000000000101',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  '11111111-1111-4111-8111-111111111111',
  'active',
  'Seed: Ali -> Ayşe assignment (assigned)',
  NULL,NULL,NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

-- ----------------------------------------------------------------------------
-- M1: on_delivery -> active
-- order_id: 90000000-0000-4000-8000-000000000201
-- driver : 12121212-1212-4121-8121-121212121212
-- ----------------------------------------------------------------------------
INSERT INTO `assignments`
(
  `id`,`order_id`,`driver_id`,`assigned_by`,
  `status`,`note`,
  `cancelled_by`,`cancelled_at`,`cancel_reason`,
  `created_at`,`updated_at`
)
VALUES
(
  '91000000-0000-4000-8000-000000000201',
  '90000000-0000-4000-8000-000000000201',
  '12121212-1212-4121-8121-121212121212',
  '11111111-1111-4111-8111-111111111111',
  'active',
  'Seed: Mehmet -> Fatma assignment (on_delivery)',
  NULL,NULL,NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

-- ----------------------------------------------------------------------------
-- H1: delivered -> cancelled (closed after delivery)
-- order_id: 90000000-0000-4000-8000-000000000301
-- driver : 23232323-2323-4232-8232-232323232323
-- ----------------------------------------------------------------------------
INSERT INTO `assignments`
(
  `id`,`order_id`,`driver_id`,`assigned_by`,
  `status`,`note`,
  `cancelled_by`,`cancelled_at`,`cancel_reason`,
  `created_at`,`updated_at`
)
VALUES
(
  '91000000-0000-4000-8000-000000000301',
  '90000000-0000-4000-8000-000000000301',
  '23232323-2323-4232-8232-232323232323',
  '11111111-1111-4111-8111-111111111111',
  'cancelled',
  'Seed: Ahmet -> Zeynep assignment (closed after delivery)',
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  'delivered_closed',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

-- ----------------------------------------------------------------------------
-- E1: assigned -> active
-- order_id: 90000000-0000-4000-8000-000000000501
-- driver : 45454545-4545-4454-8454-454545454545
-- ----------------------------------------------------------------------------
INSERT INTO `assignments`
(
  `id`,`order_id`,`driver_id`,`assigned_by`,
  `status`,`note`,
  `cancelled_by`,`cancelled_at`,`cancel_reason`,
  `created_at`,`updated_at`
)
VALUES
(
  '91000000-0000-4000-8000-000000000501',
  '90000000-0000-4000-8000-000000000501',
  '45454545-4545-4454-8454-454545454545',
  '11111111-1111-4111-8111-111111111111',
  'active',
  'Seed: Emre -> Meryem assignment (assigned)',
  NULL,NULL,NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
);

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
