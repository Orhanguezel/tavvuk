-- ============================================================================
-- FILE: db/seed/71_orders_seed.batch_05.sql
-- GENERATED — Orders + Order Items (3 months spread) — Batch 05
-- - Delivered-heavy dataset for analytics
-- - Seller/Driver users from 11_users_roles_tokens_profiles.seed.sql
-- - Products (species/breed) from 50.1_products_seed.sql
-- - Timestamps deterministically spread over last ~90 days via CRC32(order_id)
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'dc8c9cd0-55a4-4511-a5ab-9b73325696ca',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '45454545-4545-4454-8454-454545454545',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-01',
  '+90 536 170 69 46',
  'Seed adres (batch 5, #1) Mah. No:40 Sokak:21',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dc8c9cd0-55a4-4511-a5ab-9b73325696ca'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dc8c9cd0-55a4-4511-a5ab-9b73325696ca'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dc8c9cd0-55a4-4511-a5ab-9b73325696ca'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dc8c9cd0-55a4-4511-a5ab-9b73325696ca'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'dc8c9cd0-55a4-4511-a5ab-9b73325696ca')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'dc8c9cd0-55a4-4511-a5ab-9b73325696ca',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dc8c9cd0-55a4-4511-a5ab-9b73325696ca'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dc8c9cd0-55a4-4511-a5ab-9b73325696ca'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'b9d77eb3-9f62-4c2b-81b1-e3ed5bc1a832' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 5 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '5fcdbb5e-4866-44e6-bf02-339af9c54bf4' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 4 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'a132cd16-7ed4-4d3b-b819-36f6cca1d4ae',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-02',
  '+90 539 348 69 57',
  'Seed adres (batch 5, #2) Mah. No:76 Sokak:32',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a132cd16-7ed4-4d3b-b819-36f6cca1d4ae'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a132cd16-7ed4-4d3b-b819-36f6cca1d4ae'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a132cd16-7ed4-4d3b-b819-36f6cca1d4ae'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  44,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a132cd16-7ed4-4d3b-b819-36f6cca1d4ae'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a132cd16-7ed4-4d3b-b819-36f6cca1d4ae'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'a132cd16-7ed4-4d3b-b819-36f6cca1d4ae')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'a132cd16-7ed4-4d3b-b819-36f6cca1d4ae',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a132cd16-7ed4-4d3b-b819-36f6cca1d4ae'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a132cd16-7ed4-4d3b-b819-36f6cca1d4ae'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '7dd5af97-033d-44e3-936d-8b790795515a' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '846bea6a-3334-446f-b3a7-d3a1d138f44f' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '958dcdab-5bdd-41c4-bb7d-ae2ce073340f' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '6e159605-d4d6-40c7-b0bb-41bc3e287d87',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-03',
  '+90 538 454 91 98',
  'Seed adres (batch 5, #3) Mah. No:2 Sokak:22',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6e159605-d4d6-40c7-b0bb-41bc3e287d87'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6e159605-d4d6-40c7-b0bb-41bc3e287d87'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6e159605-d4d6-40c7-b0bb-41bc3e287d87'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  29,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6e159605-d4d6-40c7-b0bb-41bc3e287d87'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6e159605-d4d6-40c7-b0bb-41bc3e287d87'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '6e159605-d4d6-40c7-b0bb-41bc3e287d87')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '6e159605-d4d6-40c7-b0bb-41bc3e287d87',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6e159605-d4d6-40c7-b0bb-41bc3e287d87'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6e159605-d4d6-40c7-b0bb-41bc3e287d87'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '4cb3187a-6820-4be7-896f-c1e298345cd2' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 17 AS qty_ordered, 17 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'e93f05e7-3d2e-40ae-869b-c739fdad213a' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '50361b3e-431c-494d-acb4-f87bd1dbbee5',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-04',
  '+90 533 529 72 17',
  'Seed adres (batch 5, #4) Mah. No:19 Sokak:46',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50361b3e-431c-494d-acb4-f87bd1dbbee5'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50361b3e-431c-494d-acb4-f87bd1dbbee5'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50361b3e-431c-494d-acb4-f87bd1dbbee5'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  19,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50361b3e-431c-494d-acb4-f87bd1dbbee5'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50361b3e-431c-494d-acb4-f87bd1dbbee5'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '50361b3e-431c-494d-acb4-f87bd1dbbee5')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '50361b3e-431c-494d-acb4-f87bd1dbbee5',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50361b3e-431c-494d-acb4-f87bd1dbbee5'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50361b3e-431c-494d-acb4-f87bd1dbbee5'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '0bcc260f-22f0-4295-9065-123459220399' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '849e357a-cd96-45ea-b32c-506663a3ccc9' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '253834d4-6d29-4c03-b9b1-2aa314c5d57f',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-05',
  '+90 531 694 22 74',
  'Seed adres (batch 5, #5) Mah. No:18 Sokak:41',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('253834d4-6d29-4c03-b9b1-2aa314c5d57f'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('253834d4-6d29-4c03-b9b1-2aa314c5d57f'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('253834d4-6d29-4c03-b9b1-2aa314c5d57f'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('253834d4-6d29-4c03-b9b1-2aa314c5d57f'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '253834d4-6d29-4c03-b9b1-2aa314c5d57f')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '253834d4-6d29-4c03-b9b1-2aa314c5d57f',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('253834d4-6d29-4c03-b9b1-2aa314c5d57f'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('253834d4-6d29-4c03-b9b1-2aa314c5d57f'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '63d637a1-bc4c-4c73-835a-b9444db1eeb5' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 23 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '0ff0ee90-3021-4be1-adfa-252757acb012' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 1 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'f5ff03ee-e973-4ada-a166-ddb7cb6d5e3a' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 11 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'ad6ac863-ddc9-434e-834d-511341a72e8e',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-06',
  '+90 535 920 60 99',
  'Seed adres (batch 5, #6) Mah. No:95 Sokak:21',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ad6ac863-ddc9-434e-834d-511341a72e8e'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ad6ac863-ddc9-434e-834d-511341a72e8e'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ad6ac863-ddc9-434e-834d-511341a72e8e'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  16,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ad6ac863-ddc9-434e-834d-511341a72e8e'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ad6ac863-ddc9-434e-834d-511341a72e8e'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'ad6ac863-ddc9-434e-834d-511341a72e8e')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'ad6ac863-ddc9-434e-834d-511341a72e8e',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ad6ac863-ddc9-434e-834d-511341a72e8e'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ad6ac863-ddc9-434e-834d-511341a72e8e'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '095f01e1-4bed-4e6e-ab7d-53f5d81cbc97' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'ea9c76d0-7712-4900-a37f-23286b67698e' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '2650f089-4c67-4524-917e-d2ba9a2a67d6',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-07',
  '+90 531 268 67 69',
  'Seed adres (batch 5, #7) Mah. No:41 Sokak:27',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2650f089-4c67-4524-917e-d2ba9a2a67d6'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2650f089-4c67-4524-917e-d2ba9a2a67d6'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2650f089-4c67-4524-917e-d2ba9a2a67d6'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  37,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2650f089-4c67-4524-917e-d2ba9a2a67d6'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2650f089-4c67-4524-917e-d2ba9a2a67d6'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '2650f089-4c67-4524-917e-d2ba9a2a67d6')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '2650f089-4c67-4524-917e-d2ba9a2a67d6',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2650f089-4c67-4524-917e-d2ba9a2a67d6'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2650f089-4c67-4524-917e-d2ba9a2a67d6'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'eac4b767-ea43-4553-a0ae-56e2a0efa696' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 29 AS qty_ordered, 29 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'ca3f4e37-324e-409e-88d2-b80e6bc0d97e' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '97daf5bf-5758-45d3-9c87-c3884f436153',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-08',
  '+90 531 192 30 97',
  'Seed adres (batch 5, #8) Mah. No:39 Sokak:46',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('97daf5bf-5758-45d3-9c87-c3884f436153'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('97daf5bf-5758-45d3-9c87-c3884f436153'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('97daf5bf-5758-45d3-9c87-c3884f436153'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  26,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('97daf5bf-5758-45d3-9c87-c3884f436153'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('97daf5bf-5758-45d3-9c87-c3884f436153'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '97daf5bf-5758-45d3-9c87-c3884f436153')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '97daf5bf-5758-45d3-9c87-c3884f436153',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('97daf5bf-5758-45d3-9c87-c3884f436153'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('97daf5bf-5758-45d3-9c87-c3884f436153'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '4b8364fb-7552-4131-a00c-432d3e667438' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '7d7aec13-a158-4143-8d6e-2533f005aae7' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'aef54579-7dec-40da-a458-27ddb442b2b5' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '1202a4bd-0eba-46da-86d9-b64a239133d7',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-09',
  '+90 530 793 48 43',
  'Seed adres (batch 5, #9) Mah. No:23 Sokak:2',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1202a4bd-0eba-46da-86d9-b64a239133d7'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1202a4bd-0eba-46da-86d9-b64a239133d7'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1202a4bd-0eba-46da-86d9-b64a239133d7'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  33,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1202a4bd-0eba-46da-86d9-b64a239133d7'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1202a4bd-0eba-46da-86d9-b64a239133d7'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '1202a4bd-0eba-46da-86d9-b64a239133d7')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '1202a4bd-0eba-46da-86d9-b64a239133d7',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1202a4bd-0eba-46da-86d9-b64a239133d7'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1202a4bd-0eba-46da-86d9-b64a239133d7'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '6fdbfcfe-6a58-4eb8-9804-72e92c2b1f83' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 22 AS qty_ordered, 22 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'e0262fc4-ccf4-4a4d-9804-7917b41b8e68' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '1f054cd3-4132-4b22-9ccb-6a0d5eb07f7a' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '6c730bfb-8a95-4254-b55b-8ed1caafc011',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-10',
  '+90 532 224 11 17',
  'Seed adres (batch 5, #10) Mah. No:29 Sokak:9',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6c730bfb-8a95-4254-b55b-8ed1caafc011'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6c730bfb-8a95-4254-b55b-8ed1caafc011'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6c730bfb-8a95-4254-b55b-8ed1caafc011'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6c730bfb-8a95-4254-b55b-8ed1caafc011'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '6c730bfb-8a95-4254-b55b-8ed1caafc011')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '6c730bfb-8a95-4254-b55b-8ed1caafc011',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6c730bfb-8a95-4254-b55b-8ed1caafc011'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('6c730bfb-8a95-4254-b55b-8ed1caafc011'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'f1958a04-63a4-4101-97df-362b19c8f14c' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 16 AS qty_ordered, 2 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '4dda71c0-8bc8-44f3-97bd-dcc2cc672fa3' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 10 AS qty_ordered, 4 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'e11b99ec-152a-4d60-a87f-2e1d20e6588b',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-11',
  '+90 533 761 66 26',
  'Seed adres (batch 5, #11) Mah. No:12 Sokak:22',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e11b99ec-152a-4d60-a87f-2e1d20e6588b'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e11b99ec-152a-4d60-a87f-2e1d20e6588b'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e11b99ec-152a-4d60-a87f-2e1d20e6588b'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e11b99ec-152a-4d60-a87f-2e1d20e6588b'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'e11b99ec-152a-4d60-a87f-2e1d20e6588b')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'e11b99ec-152a-4d60-a87f-2e1d20e6588b',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e11b99ec-152a-4d60-a87f-2e1d20e6588b'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e11b99ec-152a-4d60-a87f-2e1d20e6588b'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '81f666b0-f915-44fc-9499-7f499c0bb88e' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 6 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '243a17b1-d45e-4e1b-a4f0-8c9adc1b3e8f' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 15 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'a0587da7-c341-4498-bb22-491f09e91326',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '34343434-3434-4343-8343-343434343434',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-12',
  '+90 536 608 13 58',
  'Seed adres (batch 5, #12) Mah. No:88 Sokak:28',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a0587da7-c341-4498-bb22-491f09e91326'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a0587da7-c341-4498-bb22-491f09e91326'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a0587da7-c341-4498-bb22-491f09e91326'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a0587da7-c341-4498-bb22-491f09e91326'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'a0587da7-c341-4498-bb22-491f09e91326')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'a0587da7-c341-4498-bb22-491f09e91326',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a0587da7-c341-4498-bb22-491f09e91326'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a0587da7-c341-4498-bb22-491f09e91326'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'ed415a35-cf0b-49c6-bc15-332fdc93d126' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 10 AS qty_ordered, 4 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '1f84a894-b00f-4e26-9f35-13277b37a0fd' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 8 AS qty_ordered, 2 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '9daf1a92-8359-4efe-8010-13285484086f',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-13',
  '+90 533 762 47 73',
  'Seed adres (batch 5, #13) Mah. No:53 Sokak:36',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9daf1a92-8359-4efe-8010-13285484086f'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9daf1a92-8359-4efe-8010-13285484086f'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9daf1a92-8359-4efe-8010-13285484086f'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  16,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9daf1a92-8359-4efe-8010-13285484086f'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9daf1a92-8359-4efe-8010-13285484086f'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '9daf1a92-8359-4efe-8010-13285484086f')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '9daf1a92-8359-4efe-8010-13285484086f',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9daf1a92-8359-4efe-8010-13285484086f'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9daf1a92-8359-4efe-8010-13285484086f'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '176abeff-6e04-4177-b029-01d13a2fc9c1' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '7c1b28e9-2678-475a-8bee-f19c397ef304' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'f483bd3a-d2fa-4eeb-a870-219920ce4d7b',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-14',
  '+90 538 355 90 79',
  'Seed adres (batch 5, #14) Mah. No:3 Sokak:25',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f483bd3a-d2fa-4eeb-a870-219920ce4d7b'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f483bd3a-d2fa-4eeb-a870-219920ce4d7b'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f483bd3a-d2fa-4eeb-a870-219920ce4d7b'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  39,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f483bd3a-d2fa-4eeb-a870-219920ce4d7b'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f483bd3a-d2fa-4eeb-a870-219920ce4d7b'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'f483bd3a-d2fa-4eeb-a870-219920ce4d7b')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'f483bd3a-d2fa-4eeb-a870-219920ce4d7b',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f483bd3a-d2fa-4eeb-a870-219920ce4d7b'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f483bd3a-d2fa-4eeb-a870-219920ce4d7b'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'c2b8222e-7bd1-4cbe-aa46-d6f202510050' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 20 AS qty_ordered, 20 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '1424094b-ba53-468d-980d-7308d59ce33f' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '4dd70ca0-7a65-465c-8da1-ff9be538aba4' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '59ac1525-7211-4771-8e72-2dc1bf17a271',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-15',
  '+90 534 284 13 50',
  'Seed adres (batch 5, #15) Mah. No:77 Sokak:15',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('59ac1525-7211-4771-8e72-2dc1bf17a271'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('59ac1525-7211-4771-8e72-2dc1bf17a271'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('59ac1525-7211-4771-8e72-2dc1bf17a271'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  15,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('59ac1525-7211-4771-8e72-2dc1bf17a271'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('59ac1525-7211-4771-8e72-2dc1bf17a271'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '59ac1525-7211-4771-8e72-2dc1bf17a271')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '59ac1525-7211-4771-8e72-2dc1bf17a271',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('59ac1525-7211-4771-8e72-2dc1bf17a271'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('59ac1525-7211-4771-8e72-2dc1bf17a271'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'e0734e72-cce7-4f76-bee3-55cead5aeb16' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '76ebf984-3ab3-4503-a4ea-371dfeba2eef' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '87141cac-ff76-4d00-ac25-72bf2fd7d5ae',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '45454545-4545-4454-8454-454545454545',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-16',
  '+90 532 202 41 94',
  'Seed adres (batch 5, #16) Mah. No:31 Sokak:18',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87141cac-ff76-4d00-ac25-72bf2fd7d5ae'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87141cac-ff76-4d00-ac25-72bf2fd7d5ae'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87141cac-ff76-4d00-ac25-72bf2fd7d5ae'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87141cac-ff76-4d00-ac25-72bf2fd7d5ae'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '87141cac-ff76-4d00-ac25-72bf2fd7d5ae')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '87141cac-ff76-4d00-ac25-72bf2fd7d5ae',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87141cac-ff76-4d00-ac25-72bf2fd7d5ae'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87141cac-ff76-4d00-ac25-72bf2fd7d5ae'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '681f2966-af16-45b7-9893-ca1b2a732142' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 6 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'aa690f4d-1a50-4eee-8e65-0dcacf616b7f' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 10 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '882c7a29-78e2-4ff4-a4e6-b07de27bc739' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 6 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '1c48e517-4856-4ed9-bc99-708579c326a9',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-17',
  '+90 535 925 99 55',
  'Seed adres (batch 5, #17) Mah. No:76 Sokak:2',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c48e517-4856-4ed9-bc99-708579c326a9'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c48e517-4856-4ed9-bc99-708579c326a9'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c48e517-4856-4ed9-bc99-708579c326a9'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  30,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c48e517-4856-4ed9-bc99-708579c326a9'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c48e517-4856-4ed9-bc99-708579c326a9'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '1c48e517-4856-4ed9-bc99-708579c326a9')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '1c48e517-4856-4ed9-bc99-708579c326a9',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c48e517-4856-4ed9-bc99-708579c326a9'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c48e517-4856-4ed9-bc99-708579c326a9'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '199c0045-a440-4137-89d5-0f4666784a89' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 23 AS qty_ordered, 23 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'ac5ffe0b-59ed-4e2b-ab8d-ce0ab3553375' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '185b72bd-9138-45b8-949f-4d1f94f50a14' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'c9161cd9-792c-4968-974e-0c13cd4fd8fe',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-18',
  '+90 537 138 21 17',
  'Seed adres (batch 5, #18) Mah. No:30 Sokak:39',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c9161cd9-792c-4968-974e-0c13cd4fd8fe'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c9161cd9-792c-4968-974e-0c13cd4fd8fe'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c9161cd9-792c-4968-974e-0c13cd4fd8fe'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  26,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c9161cd9-792c-4968-974e-0c13cd4fd8fe'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c9161cd9-792c-4968-974e-0c13cd4fd8fe'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'c9161cd9-792c-4968-974e-0c13cd4fd8fe')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'c9161cd9-792c-4968-974e-0c13cd4fd8fe',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c9161cd9-792c-4968-974e-0c13cd4fd8fe'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c9161cd9-792c-4968-974e-0c13cd4fd8fe'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '457954cf-c62f-4c0f-8179-f16f7150d5cc' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 20 AS qty_ordered, 20 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'bb9bcc61-f7f4-444c-8744-0e46574ab9de' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'b951959e-85b2-45cc-b9ad-aec6e07f600f',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '12121212-1212-4121-8121-121212121212',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-19',
  '+90 535 834 32 51',
  'Seed adres (batch 5, #19) Mah. No:8 Sokak:2',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b951959e-85b2-45cc-b9ad-aec6e07f600f'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b951959e-85b2-45cc-b9ad-aec6e07f600f'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b951959e-85b2-45cc-b9ad-aec6e07f600f'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b951959e-85b2-45cc-b9ad-aec6e07f600f'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'b951959e-85b2-45cc-b9ad-aec6e07f600f')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'b951959e-85b2-45cc-b9ad-aec6e07f600f',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b951959e-85b2-45cc-b9ad-aec6e07f600f'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b951959e-85b2-45cc-b9ad-aec6e07f600f'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '05215f87-d75f-4c94-a022-c6b8333c1b77' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 9 AS qty_ordered, 1 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '2fe08dc4-fec9-4833-97d7-36448b30dad2' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 14 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '50641a20-5f1a-4765-9f9e-a2c6d839d25e',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-20',
  '+90 536 700 22 53',
  'Seed adres (batch 5, #20) Mah. No:39 Sokak:21',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50641a20-5f1a-4765-9f9e-a2c6d839d25e'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50641a20-5f1a-4765-9f9e-a2c6d839d25e'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50641a20-5f1a-4765-9f9e-a2c6d839d25e'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  41,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50641a20-5f1a-4765-9f9e-a2c6d839d25e'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50641a20-5f1a-4765-9f9e-a2c6d839d25e'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '50641a20-5f1a-4765-9f9e-a2c6d839d25e')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '50641a20-5f1a-4765-9f9e-a2c6d839d25e',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50641a20-5f1a-4765-9f9e-a2c6d839d25e'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('50641a20-5f1a-4765-9f9e-a2c6d839d25e'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'a9c1b30e-03eb-4eee-9587-74b8204a820d' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'bac95a0c-aaec-4935-b3c5-563fa53776c3' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'ed1a48d1-71e7-4c43-9089-9b006417eae2',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-21',
  '+90 538 810 88 55',
  'Seed adres (batch 5, #21) Mah. No:29 Sokak:43',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ed1a48d1-71e7-4c43-9089-9b006417eae2'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ed1a48d1-71e7-4c43-9089-9b006417eae2'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ed1a48d1-71e7-4c43-9089-9b006417eae2'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  34,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ed1a48d1-71e7-4c43-9089-9b006417eae2'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ed1a48d1-71e7-4c43-9089-9b006417eae2'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'ed1a48d1-71e7-4c43-9089-9b006417eae2')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'ed1a48d1-71e7-4c43-9089-9b006417eae2',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ed1a48d1-71e7-4c43-9089-9b006417eae2'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ed1a48d1-71e7-4c43-9089-9b006417eae2'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '21272cef-ea9b-4fc4-8bc1-75fe34ee7073' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 17 AS qty_ordered, 17 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'c60d108f-608c-4b6d-90e2-1ccb1bed1326' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'd7117842-ca80-4fb1-8768-9927bdf93623' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '32478b7a-069f-4d99-bf36-b17f6b8a5b2b',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-22',
  '+90 539 500 82 14',
  'Seed adres (batch 5, #22) Mah. No:24 Sokak:39',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('32478b7a-069f-4d99-bf36-b17f6b8a5b2b'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('32478b7a-069f-4d99-bf36-b17f6b8a5b2b'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('32478b7a-069f-4d99-bf36-b17f6b8a5b2b'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('32478b7a-069f-4d99-bf36-b17f6b8a5b2b'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('32478b7a-069f-4d99-bf36-b17f6b8a5b2b'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '32478b7a-069f-4d99-bf36-b17f6b8a5b2b')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '32478b7a-069f-4d99-bf36-b17f6b8a5b2b',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('32478b7a-069f-4d99-bf36-b17f6b8a5b2b'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('32478b7a-069f-4d99-bf36-b17f6b8a5b2b'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '14d9cb54-b0db-4402-99c7-619ddb28026e' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'ad5db08f-574f-4373-98b9-976bee973224' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'c734d587-d539-4816-bdbd-f4f9f59c4afe',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-23',
  '+90 531 343 54 50',
  'Seed adres (batch 5, #23) Mah. No:22 Sokak:41',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c734d587-d539-4816-bdbd-f4f9f59c4afe'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c734d587-d539-4816-bdbd-f4f9f59c4afe'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c734d587-d539-4816-bdbd-f4f9f59c4afe'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  53,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c734d587-d539-4816-bdbd-f4f9f59c4afe'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c734d587-d539-4816-bdbd-f4f9f59c4afe'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'c734d587-d539-4816-bdbd-f4f9f59c4afe')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'c734d587-d539-4816-bdbd-f4f9f59c4afe',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c734d587-d539-4816-bdbd-f4f9f59c4afe'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c734d587-d539-4816-bdbd-f4f9f59c4afe'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'b35b8e0f-2060-496b-b9b3-787002dc3b60' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 27 AS qty_ordered, 27 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'e5065594-89b9-44be-a484-9f53ff2a7e26' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '69e0043e-8d35-4f3b-a0d5-6c6ee16a1163' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '7f8aa5e5-d06b-4be9-9926-3828acfc303c',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-24',
  '+90 533 355 98 18',
  'Seed adres (batch 5, #24) Mah. No:45 Sokak:17',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f8aa5e5-d06b-4be9-9926-3828acfc303c'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f8aa5e5-d06b-4be9-9926-3828acfc303c'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f8aa5e5-d06b-4be9-9926-3828acfc303c'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  24,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f8aa5e5-d06b-4be9-9926-3828acfc303c'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f8aa5e5-d06b-4be9-9926-3828acfc303c'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '7f8aa5e5-d06b-4be9-9926-3828acfc303c')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '7f8aa5e5-d06b-4be9-9926-3828acfc303c',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f8aa5e5-d06b-4be9-9926-3828acfc303c'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f8aa5e5-d06b-4be9-9926-3828acfc303c'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'bef38dcf-51be-40f5-991f-fdb45a92fba4' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '21c926d9-02ac-4d7f-9df2-d05dad8881ed' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '9485aa29-2f84-41ee-9083-a85f48cf37f1' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '877241dd-00af-4d40-8b69-b13074ccc4d8',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '12121212-1212-4121-8121-121212121212',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 05-25',
  '+90 537 487 54 79',
  'Seed adres (batch 5, #25) Mah. No:49 Sokak:7',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('877241dd-00af-4d40-8b69-b13074ccc4d8'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('877241dd-00af-4d40-8b69-b13074ccc4d8'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('877241dd-00af-4d40-8b69-b13074ccc4d8'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('877241dd-00af-4d40-8b69-b13074ccc4d8'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '877241dd-00af-4d40-8b69-b13074ccc4d8')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '877241dd-00af-4d40-8b69-b13074ccc4d8',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('877241dd-00af-4d40-8b69-b13074ccc4d8'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('877241dd-00af-4d40-8b69-b13074ccc4d8'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'efb22992-ba9a-4303-8e99-77b8e00c619f' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 25 AS qty_ordered, 24 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '7bf706e7-a992-4aa5-8987-765d9d6ca40f' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 4 AS qty_ordered, 1 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'c9100729-0939-4e69-b493-c00e3f1a7cca' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 2 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
