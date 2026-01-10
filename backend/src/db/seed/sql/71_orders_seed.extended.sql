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
  'Müşteri (Ali)',
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
  'Müşteri (Ali)',
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
  'Müşteri 12',
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
  'Müşteri (Mehmet) #2',
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
  'Müşteri 1111',
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
  'Müşteri (Ali) #1',
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
  'Müşteri (Ali)',
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
  'Müşteri 11',
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



-- =============================================================================
-- EXTENDED: ANALYTICS-RICH ORDERS (MORE DELIVERED, REAL SELLERS/DRIVERS, BREEDS)
-- =============================================================================

-- ============================================================================
-- ORDER X1001 — Emre Şahin creates, assigned to Driver Fatma Çelik
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
  '90000000-0000-4000-8000-000000001001',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '12121212-1212-4121-8121-121212121212',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1001 (Emre)',
  '+90 533 1001 93 99',
  'Hürriyet Mah., Mimar Sinan Cd. No:57/15 (Seed) — Emre Şahin -> Fatma Çelik',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  NULL,
  NULL,
  0,
  0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001001')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001001',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010011' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 18 AS qty, 0 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010012' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 15 AS qty, 0 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010013' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 12 AS qty, 0 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001001');

-- ============================================================================
-- ORDER X1002 — Mehmet Yılmaz creates, delivered to Driver Fatma Çelik
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
  '90000000-0000-4000-8000-000000001002',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1002 (Mehmet)',
  '+90 533 1002 53 23',
  'Yeni Mah., Mimar Sinan Cd. No:25/12 (Seed) — Mehmet Yılmaz -> Fatma Çelik',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  25,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001002')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001002',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010021' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 5 AS qty, 5 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010022' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 20 AS qty, 20 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001002');

-- ============================================================================
-- ORDER X1003 — Emre Şahin creates, delivered to Driver Ayşe Demir
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
  '90000000-0000-4000-8000-000000001003',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1003 (Emre)',
  '+90 533 1003 58 20',
  'Hürriyet Mah., Barbaros Cd. No:93/19 (Seed) — Emre Şahin -> Ayşe Demir',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  15,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001003')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001003',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010031' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 5 AS qty, 5 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010032' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 10 AS qty, 10 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001003');

-- ============================================================================
-- ORDER X1004 — Ahmet Demir creates, delivered to Driver Ayşe Demir
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
  '90000000-0000-4000-8000-000000001004',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1004 (Ahmet)',
  '+90 533 1004 39 22',
  'Yenimahalle Mah., Barbaros Cd. No:117/21 (Seed) — Ahmet Demir -> Ayşe Demir',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  25,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001004')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001004',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010041' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 15 AS qty, 15 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010042' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 10 AS qty, 10 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001004');

-- ============================================================================
-- ORDER X1005 — Ahmet Demir creates, delivered to Driver Ayşe Demir
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
  '90000000-0000-4000-8000-000000001005',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1005 (Ahmet)',
  '+90 533 1005 87 91',
  'Bahçelievler Mah., Gazi Cd. No:63/6 (Seed) — Ahmet Demir -> Ayşe Demir',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  25,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001005')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001005',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010051' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 10 AS qty, 10 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010052' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 15 AS qty, 15 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001005');

-- ============================================================================
-- ORDER X1006 — Ali Kaya creates, delivered to Driver Fatma Çelik
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
  '90000000-0000-4000-8000-000000001006',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1006 (Ali)',
  '+90 533 1006 14 50',
  'Yenimahalle Mah., Barbaros Cd. No:17/7 (Seed) — Ali Kaya -> Fatma Çelik',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  58,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001006')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001006',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010061' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 20 AS qty, 20 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010062' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 18 AS qty, 18 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010063' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 20 AS qty, 20 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001006');

-- ============================================================================
-- ORDER X1007 — Mehmet Yılmaz creates, delivered to Driver Zeynep Kaya
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
  '90000000-0000-4000-8000-000000001007',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1007 (Mehmet)',
  '+90 533 1007 27 41',
  'Hürriyet Mah., Gazi Cd. No:68/24 (Seed) — Mehmet Yılmaz -> Zeynep Kaya',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  33,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001007')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001007',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010071' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 15 AS qty, 15 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010072' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 10 AS qty, 10 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010073' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 8 AS qty, 8 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001007');

-- ============================================================================
-- ORDER X1008 — Emre Şahin creates, assigned to Driver Elif Yıldız
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
  '90000000-0000-4000-8000-000000001008',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '34343434-3434-4343-8343-343434343434',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1008 (Emre)',
  '+90 533 1008 21 16',
  'Yeni Mah., İnönü Cd. No:41/26 (Seed) — Emre Şahin -> Elif Yıldız',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  NULL,
  NULL,
  0,
  0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001008')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001008',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010081' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 18 AS qty, 0 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010082' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 18 AS qty, 0 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010083' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 20 AS qty, 0 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001008');

-- ============================================================================
-- ORDER X1009 — Emre Şahin creates, delivered to Driver Zeynep Kaya
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
  '90000000-0000-4000-8000-000000001009',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1009 (Emre)',
  '+90 533 1009 80 11',
  'Yeni Mah., Gazi Cd. No:69/25 (Seed) — Emre Şahin -> Zeynep Kaya',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  46,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001009')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001009',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010091' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 18 AS qty, 18 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010092' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 8 AS qty, 8 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010093' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 20 AS qty, 20 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001009');

-- ============================================================================
-- ORDER X1010 — Ali Kaya creates, delivered to Driver Zeynep Kaya
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
  '90000000-0000-4000-8000-000000001010',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1010 (Ali)',
  '+90 533 1010 74 32',
  'Hürriyet Mah., Cumhuriyet Cd. No:77/27 (Seed) — Ali Kaya -> Zeynep Kaya',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  31,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001010')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001010',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010101' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 8 AS qty, 8 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010102' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 15 AS qty, 15 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010103' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 8 AS qty, 8 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001010');

-- ============================================================================
-- ORDER X1011 — Emre Şahin creates, on_delivery to Driver Meryem Arslan
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
  '90000000-0000-4000-8000-000000001011',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '45454545-4545-4454-8454-454545454545',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1011 (Emre)',
  '+90 533 1011 10 86',
  'Zafer Mah., Mevlana Cd. No:5/4 (Seed) — Emre Şahin -> Meryem Arslan',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  NULL,
  NULL,
  0,
  0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001011')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001011',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010111' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 5 AS qty, 0 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010112' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 6 AS qty, 0 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001011');

-- ============================================================================
-- ORDER X1012 — Emre Şahin creates, delivered to Driver Fatma Çelik
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
  '90000000-0000-4000-8000-000000001012',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1012 (Emre)',
  '+90 533 1012 26 94',
  'İstasyon Mah., Gazi Cd. No:43/9 (Seed) — Emre Şahin -> Fatma Çelik',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  40,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001012')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001012',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010121' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 10 AS qty, 10 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010122' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 12 AS qty, 12 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010123' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 18 AS qty, 18 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001012');

-- ============================================================================
-- ORDER X1013 — Ahmet Demir creates, delivered to Driver Elif Yıldız
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
  '90000000-0000-4000-8000-000000001013',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1013 (Ahmet)',
  '+90 533 1013 76 67',
  'Yeni Mah., Fatih Cd. No:58/3 (Seed) — Ahmet Demir -> Elif Yıldız',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  20,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001013')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001013',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010131' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 10 AS qty, 10 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010132' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 10 AS qty, 10 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001013');

-- ============================================================================
-- ORDER X1014 — Ali Kaya creates, delivered to Driver Ayşe Demir
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
  '90000000-0000-4000-8000-000000001014',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1014 (Ali)',
  '+90 533 1014 90 17',
  'Çamlıca Mah., Cumhuriyet Cd. No:9/28 (Seed) — Ali Kaya -> Ayşe Demir',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  22,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001014')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001014',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010141' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 10 AS qty, 10 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010142' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 12 AS qty, 12 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001014');

-- ============================================================================
-- ORDER X1015 — Mustafa Koç creates, delivered to Driver Fatma Çelik
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
  '90000000-0000-4000-8000-000000001015',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1015 (Mustafa)',
  '+90 533 1015 79 26',
  'Aydınlıkevler Mah., Şehitler Cd. No:122/8 (Seed) — Mustafa Koç -> Fatma Çelik',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  12,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001015')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001015',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010151' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 6 AS qty, 6 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010152' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 6 AS qty, 6 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001015');

-- ============================================================================
-- ORDER X1016 — Mustafa Koç creates, on_delivery to Driver Zeynep Kaya
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
  '90000000-0000-4000-8000-000000001016',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1016 (Mustafa)',
  '+90 533 1016 64 62',
  'İstasyon Mah., Atatürk Cd. No:26/2 (Seed) — Mustafa Koç -> Zeynep Kaya',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  NULL,
  NULL,
  0,
  0,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001016')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001016',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010161' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 6 AS qty, 0 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010162' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 10 AS qty, 0 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001016');

-- ============================================================================
-- ORDER X1017 — Mustafa Koç creates, delivered to Driver Fatma Çelik
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
  '90000000-0000-4000-8000-000000001017',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1017 (Mustafa)',
  '+90 533 1017 45 69',
  'Çamlıca Mah., Cumhuriyet Cd. No:114/26 (Seed) — Mustafa Koç -> Fatma Çelik',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  24,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001017')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001017',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010171' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 6 AS qty, 6 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010172' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 10 AS qty, 10 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010173' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 8 AS qty, 8 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001017');

-- ============================================================================
-- ORDER X1018 — Mustafa Koç creates, delivered to Driver Elif Yıldız
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
  '90000000-0000-4000-8000-000000001018',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1018 (Mustafa)',
  '+90 533 1018 71 37',
  'Yenimahalle Mah., Atatürk Cd. No:43/13 (Seed) — Mustafa Koç -> Elif Yıldız',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  32,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001018')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001018',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010181' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 20 AS qty, 20 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010182' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty, 12 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001018');

-- ============================================================================
-- ORDER X1019 — Mustafa Koç creates, delivered to Driver Meryem Arslan
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
  '90000000-0000-4000-8000-000000001019',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1019 (Mustafa)',
  '+90 533 1019 94 72',
  'Bahçelievler Mah., Fatih Cd. No:76/7 (Seed) — Mustafa Koç -> Meryem Arslan',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  20,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001019')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001019',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010191' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 5 AS qty, 5 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010192' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 15 AS qty, 15 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001019');

-- ============================================================================
-- ORDER X1020 — Ali Kaya creates, delivered to Driver Ayşe Demir
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
  '90000000-0000-4000-8000-000000001020',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 1020 (Ali)',
  '+90 533 1020 84 71',
  'Hürriyet Mah., Gazi Cd. No:41/2 (Seed) — Ali Kaya -> Ayşe Demir',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3),
  'Teslim edildi (extended seed).',
  34,
  1,
  NULL,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90000000-0000-4000-8000-000000001020')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90000000-0000-4000-8000-000000001020',
  x.product_id,
  x.qty,
  x.qty_del,
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
FROM (
  SELECT '91000000-0000-4000-8000-000000010201' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 6 AS qty, 6 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010202' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 10 AS qty, 10 AS qty_del
  UNION ALL
  SELECT '91000000-0000-4000-8000-000000010203' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 18 AS qty, 18 AS qty_del
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.order_id = '90000000-0000-4000-8000-000000001020');


COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
