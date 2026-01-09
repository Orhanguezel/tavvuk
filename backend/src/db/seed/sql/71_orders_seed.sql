-- ============================================================================
-- FILE: db/seed/71_orders_seed.sql
-- FINAL — Tavvuk Seed: ORDERS + ORDER_ITEMS + DRIVER_ROUTES
-- - src/modules/orders/schema.ts ile bire bir uyumlu
-- - NO SET variables
-- - Idempotent inserts (WHERE NOT EXISTS)
-- - Compatible with MariaDB/MySQL
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- Optional cleanup (uncomment if needed)
-- DELETE FROM `order_items`;
-- DELETE FROM `orders`;
-- DELETE FROM `driver_routes`;

-- ============================================================================
-- ORDER A1 — Seller Ali creates, approved+assigned to Driver Ayse, status=assigned
-- ============================================================================
INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,
  `city_id`,`district_id`,
  `customer_name`,`customer_phone`,`address_text`,
  `note_internal`,
  `approved_by`,`approved_at`,
  `assigned_by`,`assigned_at`,
  `delivered_at`,`delivery_note`,
  `delivered_qty_total`,`is_delivery_counted`,
  `cancel_reason`,
  `created_at`,`updated_at`
)
SELECT
  '90000000-0000-4000-8000-000000000101',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Test Müşteri (Ali) ASSIGNED #1',
  '+90 533 100 00 01',
  'Test adres: Ali -> Ayşe (assigned)',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  NULL, NULL,
  0, 0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000000101')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000000101',
  x.product_id,
  x.qty,
  0,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT
    '91000000-0000-4000-8000-000000000101' AS id,
    COALESCE(
      (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1),
      (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)
    ) AS product_id,
    10 AS qty,
    1 AS ord
  UNION ALL
  SELECT
    '91000000-0000-4000-8000-000000000102' AS id,
    COALESCE(
      (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1,1),
      (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)
    ) AS product_id,
    5 AS qty,
    2 AS ord
) x
WHERE x.product_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM `order_items` oi
    WHERE oi.id IN (
      '91000000-0000-4000-8000-000000000101',
      '91000000-0000-4000-8000-000000000102'
    )
  )
ORDER BY x.ord;

-- ============================================================================
-- ORDER A2 — Seller Ali creates, approved but NOT assigned, status=approved
-- ============================================================================
INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,
  `city_id`,`district_id`,
  `customer_name`,`customer_phone`,`address_text`,
  `note_internal`,
  `approved_by`,`approved_at`,
  `assigned_by`,`assigned_at`,
  `delivered_at`,`delivery_note`,
  `delivered_qty_total`,`is_delivery_counted`,
  `cancel_reason`,
  `created_at`,`updated_at`
)
SELECT
  '90000000-0000-4000-8000-000000000102',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  NULL,
  'approved',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Test Müşteri (Ali) APPROVED #2',
  '+90 533 100 00 02',
  'Test adres: Ali (approved, not assigned)',
  'Onaylandı, şoför atanacak.',
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  NULL, NULL,
  NULL, NULL,
  0, 0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000000102')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  '91000000-0000-4000-8000-000000000111',
  '90000000-0000-4000-8000-000000000102',
  COALESCE(
    (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1),
    (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)
  ),
  12, 0,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = '91000000-0000-4000-8000-000000000111');

-- ============================================================================
-- ORDER M1 — Seller Mehmet creates, approved+assigned to Driver Fatma, status=on_delivery
-- ============================================================================
INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,
  `city_id`,`district_id`,
  `customer_name`,`customer_phone`,`address_text`,
  `note_internal`,
  `approved_by`,`approved_at`,
  `assigned_by`,`assigned_at`,
  `delivered_at`,`delivery_note`,
  `delivered_qty_total`,`is_delivery_counted`,
  `cancel_reason`,
  `created_at`,`updated_at`
)
SELECT
  '90000000-0000-4000-8000-000000000201',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '12121212-1212-4121-8121-121212121212',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Test Müşteri (Mehmet) ON_DELIVERY #1',
  '+90 533 200 00 01',
  'Test adres: Mehmet -> Fatma (on_delivery)',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  NULL, NULL,
  0, 0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000000201')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000000201',
  x.product_id,
  x.qty,
  0,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT
    '91000000-0000-4000-8000-000000000201' AS id,
    COALESCE(
      (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1),
      (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)
    ) AS product_id,
    7 AS qty,
    1 AS ord
  UNION ALL
  SELECT
    '91000000-0000-4000-8000-000000000202' AS id,
    COALESCE(
      (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 2,1),
      (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)
    ) AS product_id,
    4 AS qty,
    2 AS ord
) x
WHERE x.product_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM `order_items` oi
    WHERE oi.id IN (
      '91000000-0000-4000-8000-000000000201',
      '91000000-0000-4000-8000-000000000202'
    )
  )
ORDER BY x.ord;

-- ============================================================================
-- ORDER M2 — Seller Mehmet creates, CANCELLED
-- ============================================================================
INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,
  `city_id`,`district_id`,
  `customer_name`,`customer_phone`,`address_text`,
  `note_internal`,
  `approved_by`,`approved_at`,
  `assigned_by`,`assigned_at`,
  `delivered_at`,`delivery_note`,
  `delivered_qty_total`,`is_delivery_counted`,
  `cancel_reason`,
  `created_at`,`updated_at`
)
SELECT
  '90000000-0000-4000-8000-000000000202',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  NULL,
  'cancelled',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Test Müşteri (Mehmet) CANCELLED #2',
  '+90 533 200 00 02',
  'Test adres: Mehmet (cancelled)',
  'Müşteri iptal istedi.',
  NULL, NULL,
  NULL, NULL,
  NULL, NULL,
  0, 0,
  'customer_cancelled',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000000202')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  '91000000-0000-4000-8000-000000000211',
  '90000000-0000-4000-8000-000000000202',
  COALESCE(
    (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1),
    (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)
  ),
  3, 0,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = '91000000-0000-4000-8000-000000000211');

-- ============================================================================
-- ORDER H1 — Seller Ahmet creates, approved+assigned, DELIVERED
-- ============================================================================
INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,
  `city_id`,`district_id`,
  `customer_name`,`customer_phone`,`address_text`,
  `note_internal`,
  `approved_by`,`approved_at`,
  `assigned_by`,`assigned_at`,
  `delivered_at`,`delivery_note`,
  `delivered_qty_total`,`is_delivery_counted`,
  `cancel_reason`,
  `created_at`,`updated_at`
)
SELECT
  '90000000-0000-4000-8000-000000000301',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Test Müşteri (Ahmet) DELIVERED #1',
  '+90 533 300 00 01',
  'Test adres: Ahmet -> Zeynep (delivered)',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (seed).',
  12,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000000301')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000000301',
  x.product_id,
  x.qo,
  x.qd,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT
    '91000000-0000-4000-8000-000000000301' AS id,
    COALESCE((SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1),
             (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)) AS product_id,
    8 AS qo,
    8 AS qd,
    1 AS ord
  UNION ALL
  SELECT
    '91000000-0000-4000-8000-000000000302' AS id,
    COALESCE((SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1,1),
             (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)) AS product_id,
    4 AS qo,
    4 AS qd,
    2 AS ord
) x
WHERE x.product_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM `order_items` oi
    WHERE oi.id IN (
      '91000000-0000-4000-8000-000000000301',
      '91000000-0000-4000-8000-000000000302'
    )
  )
ORDER BY x.ord;

-- ============================================================================
-- ORDER MU1 — Seller Mustafa creates, SUBMITTED
-- ============================================================================
INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,
  `city_id`,`district_id`,
  `customer_name`,`customer_phone`,`address_text`,
  `note_internal`,
  `approved_by`,`approved_at`,
  `assigned_by`,`assigned_at`,
  `delivered_at`,`delivery_note`,
  `delivered_qty_total`,`is_delivery_counted`,
  `cancel_reason`,
  `created_at`,`updated_at`
)
SELECT
  '90000000-0000-4000-8000-000000000401',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  NULL,
  'submitted',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Test Müşteri (Mustafa) SUBMITTED #1',
  '+90 533 400 00 01',
  'Test adres: Mustafa (submitted)',
  NULL,
  NULL, NULL,
  NULL, NULL,
  NULL, NULL,
  0, 0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000000401')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  '91000000-0000-4000-8000-000000000411',
  '90000000-0000-4000-8000-000000000401',
  COALESCE((SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1),
           (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)),
  9, 0,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = '91000000-0000-4000-8000-000000000411');

-- ============================================================================
-- ORDER E1 — Seller Emre creates, approved+assigned, 3 items
-- ============================================================================
INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,
  `city_id`,`district_id`,
  `customer_name`,`customer_phone`,`address_text`,
  `note_internal`,
  `approved_by`,`approved_at`,
  `assigned_by`,`assigned_at`,
  `delivered_at`,`delivery_note`,
  `delivered_qty_total`,`is_delivery_counted`,
  `cancel_reason`,
  `created_at`,`updated_at`
)
SELECT
  '90000000-0000-4000-8000-000000000501',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '45454545-4545-4454-8454-454545454545',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Test Müşteri (Emre) ASSIGNED #1',
  '+90 533 500 00 01',
  'Test adres: Emre -> Meryem (assigned)',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  NULL, NULL,
  0, 0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000000501')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000000501',
  x.product_id,
  x.qty,
  0,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT
    '91000000-0000-4000-8000-000000000501' AS id,
    COALESCE((SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1),
             (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)) AS product_id,
    8 AS qty,
    1 AS ord
  UNION ALL
  SELECT
    '91000000-0000-4000-8000-000000000502' AS id,
    COALESCE((SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1,1),
             (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)) AS product_id,
    4 AS qty,
    2 AS ord
  UNION ALL
  SELECT
    '91000000-0000-4000-8000-000000000503' AS id,
    COALESCE((SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 2,1),
             (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)) AS product_id,
    2 AS qty,
    3 AS ord
) x
WHERE x.product_id IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM `order_items` oi
    WHERE oi.id IN (
      '91000000-0000-4000-8000-000000000501',
      '91000000-0000-4000-8000-000000000502',
      '91000000-0000-4000-8000-000000000503'
    )
  )
ORDER BY x.ord;

-- ============================================================================
-- ORDER D1 — Driver Ayse creates her own order (created_by=driver), submitted
-- ============================================================================
INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,
  `city_id`,`district_id`,
  `customer_name`,`customer_phone`,`address_text`,
  `note_internal`,
  `approved_by`,`approved_at`,
  `assigned_by`,`assigned_at`,
  `delivered_at`,`delivery_note`,
  `delivered_qty_total`,`is_delivery_counted`,
  `cancel_reason`,
  `created_at`,`updated_at`
)
SELECT
  '90000000-0000-4000-8000-000000000901',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  NULL,
  'submitted',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Test Müşteri (Driver Ayşe) OWN_ORDER',
  '+90 533 900 00 01',
  'Test adres: Driver kendi siparişi (created_by=driver)',
  'Driver açtı (seed örneği).',
  NULL, NULL,
  NULL, NULL,
  NULL, NULL,
  0, 0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000000901')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  '91000000-0000-4000-8000-000000000901',
  '90000000-0000-4000-8000-000000000901',
  COALESCE((SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1),
           (SELECT p.id FROM products p ORDER BY p.created_at ASC LIMIT 1)),
  2, 0,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = '91000000-0000-4000-8000-000000000901');

-- ============================================================================
-- DRIVER ROUTES — one route per driver for the first city and its first district
-- IMPORTANT: driver_routes şemasında updated_at yok (Drizzle ile birebir)
-- ============================================================================
INSERT INTO `driver_routes` (`id`,`driver_id`,`city_id`,`district_id`,`created_at`)
SELECT
  x.id,
  x.driver_id,
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '92000000-0000-4000-8000-000000000001' AS id, 'ffffffff-ffff-4fff-8fff-ffffffffffff' AS driver_id
  UNION ALL SELECT '92000000-0000-4000-8000-000000000002', '12121212-1212-4121-8121-121212121212'
  UNION ALL SELECT '92000000-0000-4000-8000-000000000003', '23232323-2323-4232-8232-232323232323'
  UNION ALL SELECT '92000000-0000-4000-8000-000000000004', '34343434-3434-4343-8343-343434343434'
  UNION ALL SELECT '92000000-0000-4000-8000-000000000005', '45454545-4545-4454-8454-454545454545'
) x
JOIN (SELECT id FROM cities ORDER BY created_at ASC LIMIT 1) c
WHERE NOT EXISTS (SELECT 1 FROM `driver_routes` dr WHERE dr.id = x.id);

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
