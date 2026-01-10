-- ============================================================================
-- FILE: db/seed/71_orders_seed.batch_02.sql
-- GENERATED — Orders + Order Items (3 months spread) — Batch 02
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
  '9ecbe514-cacc-4cf2-9ce1-1674e6e02727',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-01',
  '+90 531 163 80 74',
  'Seed adres (batch 2, #1) Mah. No:26 Sokak:37',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9ecbe514-cacc-4cf2-9ce1-1674e6e02727'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9ecbe514-cacc-4cf2-9ce1-1674e6e02727'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9ecbe514-cacc-4cf2-9ce1-1674e6e02727'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9ecbe514-cacc-4cf2-9ce1-1674e6e02727'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '9ecbe514-cacc-4cf2-9ce1-1674e6e02727')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '9ecbe514-cacc-4cf2-9ce1-1674e6e02727',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9ecbe514-cacc-4cf2-9ce1-1674e6e02727'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9ecbe514-cacc-4cf2-9ce1-1674e6e02727'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '6249063f-c71a-45d9-bc24-b04c757330a1' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 15 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'ecffa27f-cff4-4d9b-b239-95bd2703018c' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 8 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '71707e4e-2df3-4be3-a523-e9a7e12282b8' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 11 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'bb7e89c4-b508-47fd-a92a-87642f5b159d',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-02',
  '+90 538 556 17 68',
  'Seed adres (batch 2, #2) Mah. No:17 Sokak:33',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bb7e89c4-b508-47fd-a92a-87642f5b159d'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bb7e89c4-b508-47fd-a92a-87642f5b159d'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bb7e89c4-b508-47fd-a92a-87642f5b159d'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  14,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bb7e89c4-b508-47fd-a92a-87642f5b159d'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bb7e89c4-b508-47fd-a92a-87642f5b159d'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'bb7e89c4-b508-47fd-a92a-87642f5b159d')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'bb7e89c4-b508-47fd-a92a-87642f5b159d',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bb7e89c4-b508-47fd-a92a-87642f5b159d'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bb7e89c4-b508-47fd-a92a-87642f5b159d'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'e11b367b-23e5-4475-aa81-35e7df524536' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '4eda21de-e046-44fd-b336-0be716468157' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '0734411a-23f3-40e8-9882-4f6c7fafd73e',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-03',
  '+90 530 863 37 84',
  'Seed adres (batch 2, #3) Mah. No:10 Sokak:3',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0734411a-23f3-40e8-9882-4f6c7fafd73e'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0734411a-23f3-40e8-9882-4f6c7fafd73e'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0734411a-23f3-40e8-9882-4f6c7fafd73e'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  8,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0734411a-23f3-40e8-9882-4f6c7fafd73e'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0734411a-23f3-40e8-9882-4f6c7fafd73e'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '0734411a-23f3-40e8-9882-4f6c7fafd73e')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '0734411a-23f3-40e8-9882-4f6c7fafd73e',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0734411a-23f3-40e8-9882-4f6c7fafd73e'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0734411a-23f3-40e8-9882-4f6c7fafd73e'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '70f9e9f7-4fa7-4d8c-b731-6bbbdcd015e9' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '6c65a177-04de-494e-9c5d-614405fa93b9' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '0f4435f0-5e26-4ebd-a8d4-568ad2876060',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-04',
  '+90 536 284 27 92',
  'Seed adres (batch 2, #4) Mah. No:94 Sokak:42',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0f4435f0-5e26-4ebd-a8d4-568ad2876060'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0f4435f0-5e26-4ebd-a8d4-568ad2876060'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0f4435f0-5e26-4ebd-a8d4-568ad2876060'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  38,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0f4435f0-5e26-4ebd-a8d4-568ad2876060'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0f4435f0-5e26-4ebd-a8d4-568ad2876060'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '0f4435f0-5e26-4ebd-a8d4-568ad2876060')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '0f4435f0-5e26-4ebd-a8d4-568ad2876060',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0f4435f0-5e26-4ebd-a8d4-568ad2876060'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0f4435f0-5e26-4ebd-a8d4-568ad2876060'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '84fba202-fa56-454f-97a0-44d82aa98be1' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 17 AS qty_ordered, 17 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'e924579d-b17f-4004-a73e-ed0cff84d89c' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'fef31a1f-c45e-4551-8763-13073463197e' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'e9a93900-fc6d-4540-9aab-f6c7ed138b17',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-05',
  '+90 535 221 32 78',
  'Seed adres (batch 2, #5) Mah. No:51 Sokak:34',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e9a93900-fc6d-4540-9aab-f6c7ed138b17'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e9a93900-fc6d-4540-9aab-f6c7ed138b17'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e9a93900-fc6d-4540-9aab-f6c7ed138b17'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  10,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e9a93900-fc6d-4540-9aab-f6c7ed138b17'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e9a93900-fc6d-4540-9aab-f6c7ed138b17'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'e9a93900-fc6d-4540-9aab-f6c7ed138b17')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'e9a93900-fc6d-4540-9aab-f6c7ed138b17',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e9a93900-fc6d-4540-9aab-f6c7ed138b17'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e9a93900-fc6d-4540-9aab-f6c7ed138b17'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '077780f4-5900-4c63-bc3f-ed499635e501' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a9448f80-282f-4851-b5a2-b5330acccd05' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '41d50ab1-fbfa-49c1-be9e-b8a2d833d730',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-06',
  '+90 536 943 39 41',
  'Seed adres (batch 2, #6) Mah. No:59 Sokak:23',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41d50ab1-fbfa-49c1-be9e-b8a2d833d730'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41d50ab1-fbfa-49c1-be9e-b8a2d833d730'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41d50ab1-fbfa-49c1-be9e-b8a2d833d730'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  29,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41d50ab1-fbfa-49c1-be9e-b8a2d833d730'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41d50ab1-fbfa-49c1-be9e-b8a2d833d730'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '41d50ab1-fbfa-49c1-be9e-b8a2d833d730')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '41d50ab1-fbfa-49c1-be9e-b8a2d833d730',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41d50ab1-fbfa-49c1-be9e-b8a2d833d730'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41d50ab1-fbfa-49c1-be9e-b8a2d833d730'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'b0d4d517-b763-4f96-97ff-cea6f7bb1e94' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '61108902-6dfc-4c0e-ac6a-bbdc75197bc6' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '7122ddf1-d603-41eb-9ca6-2d491161fe7e',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-07',
  '+90 530 346 36 18',
  'Seed adres (batch 2, #7) Mah. No:13 Sokak:39',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7122ddf1-d603-41eb-9ca6-2d491161fe7e'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7122ddf1-d603-41eb-9ca6-2d491161fe7e'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7122ddf1-d603-41eb-9ca6-2d491161fe7e'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  40,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7122ddf1-d603-41eb-9ca6-2d491161fe7e'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7122ddf1-d603-41eb-9ca6-2d491161fe7e'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '7122ddf1-d603-41eb-9ca6-2d491161fe7e')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '7122ddf1-d603-41eb-9ca6-2d491161fe7e',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7122ddf1-d603-41eb-9ca6-2d491161fe7e'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7122ddf1-d603-41eb-9ca6-2d491161fe7e'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'c7d43bee-83c3-426e-9304-24f5a90b91ee' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 26 AS qty_ordered, 26 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '9c73d892-1b51-4a70-991b-8463f3a77497' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '0745ca57-6258-41c1-94e8-af87afa12571',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-08',
  '+90 536 549 39 79',
  'Seed adres (batch 2, #8) Mah. No:28 Sokak:49',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0745ca57-6258-41c1-94e8-af87afa12571'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0745ca57-6258-41c1-94e8-af87afa12571'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0745ca57-6258-41c1-94e8-af87afa12571'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  28,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0745ca57-6258-41c1-94e8-af87afa12571'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0745ca57-6258-41c1-94e8-af87afa12571'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '0745ca57-6258-41c1-94e8-af87afa12571')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '0745ca57-6258-41c1-94e8-af87afa12571',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0745ca57-6258-41c1-94e8-af87afa12571'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0745ca57-6258-41c1-94e8-af87afa12571'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '10dfade5-a5bc-4832-96f7-0f8c32e968f3' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '812df735-ec2a-4f1e-a380-f2c28403a6cf' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'ead96add-bb7d-4145-b82e-cea6af362fe4' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '4545af54-c40b-4675-b73b-38f438312d37',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-09',
  '+90 535 342 48 28',
  'Seed adres (batch 2, #9) Mah. No:85 Sokak:34',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4545af54-c40b-4675-b73b-38f438312d37'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4545af54-c40b-4675-b73b-38f438312d37'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4545af54-c40b-4675-b73b-38f438312d37'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4545af54-c40b-4675-b73b-38f438312d37'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4545af54-c40b-4675-b73b-38f438312d37'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '4545af54-c40b-4675-b73b-38f438312d37')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '4545af54-c40b-4675-b73b-38f438312d37',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4545af54-c40b-4675-b73b-38f438312d37'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4545af54-c40b-4675-b73b-38f438312d37'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'ddfb4b11-350f-4aeb-97a7-72520a3d02b6' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '50fd10c8-46b9-4f99-a730-3e90b0435981' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '87a1cfb0-f9a5-48d7-87e9-36ef93b987d9',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-10',
  '+90 536 669 73 16',
  'Seed adres (batch 2, #10) Mah. No:45 Sokak:42',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87a1cfb0-f9a5-48d7-87e9-36ef93b987d9'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87a1cfb0-f9a5-48d7-87e9-36ef93b987d9'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87a1cfb0-f9a5-48d7-87e9-36ef93b987d9'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  25,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87a1cfb0-f9a5-48d7-87e9-36ef93b987d9'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87a1cfb0-f9a5-48d7-87e9-36ef93b987d9'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '87a1cfb0-f9a5-48d7-87e9-36ef93b987d9')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '87a1cfb0-f9a5-48d7-87e9-36ef93b987d9',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87a1cfb0-f9a5-48d7-87e9-36ef93b987d9'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('87a1cfb0-f9a5-48d7-87e9-36ef93b987d9'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '52178513-5821-4d5d-9a40-35be62b5c304' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '1e52e3f7-f680-4218-a7e0-d82f3f62ee16' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'baf2d05f-52b1-4945-8050-a7e10c9e2ef3' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '73f07d0f-97b1-4d78-a32b-9b38e822ac9a',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-11',
  '+90 538 584 40 38',
  'Seed adres (batch 2, #11) Mah. No:39 Sokak:46',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('73f07d0f-97b1-4d78-a32b-9b38e822ac9a'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('73f07d0f-97b1-4d78-a32b-9b38e822ac9a'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('73f07d0f-97b1-4d78-a32b-9b38e822ac9a'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  13,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('73f07d0f-97b1-4d78-a32b-9b38e822ac9a'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('73f07d0f-97b1-4d78-a32b-9b38e822ac9a'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '73f07d0f-97b1-4d78-a32b-9b38e822ac9a')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '73f07d0f-97b1-4d78-a32b-9b38e822ac9a',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('73f07d0f-97b1-4d78-a32b-9b38e822ac9a'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('73f07d0f-97b1-4d78-a32b-9b38e822ac9a'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'f3ab1b4b-8fbe-421c-b79b-748cb40090b8' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'bd65a855-e3ec-4ab1-b5c5-515d354d540d' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'c8a3c96c-2c94-43b9-a389-a7fd179ed46a',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-12',
  '+90 536 348 42 36',
  'Seed adres (batch 2, #12) Mah. No:43 Sokak:42',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c8a3c96c-2c94-43b9-a389-a7fd179ed46a'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c8a3c96c-2c94-43b9-a389-a7fd179ed46a'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c8a3c96c-2c94-43b9-a389-a7fd179ed46a'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  25,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c8a3c96c-2c94-43b9-a389-a7fd179ed46a'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c8a3c96c-2c94-43b9-a389-a7fd179ed46a'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'c8a3c96c-2c94-43b9-a389-a7fd179ed46a')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'c8a3c96c-2c94-43b9-a389-a7fd179ed46a',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c8a3c96c-2c94-43b9-a389-a7fd179ed46a'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c8a3c96c-2c94-43b9-a389-a7fd179ed46a'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '4f81b568-3ec1-4f7f-a398-c9910551f046' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 16 AS qty_ordered, 16 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a23e9052-fc70-4a2f-806c-4224192a509e' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '0bbc433e-11ab-427d-bf80-857eba76579a',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-13',
  '+90 539 717 15 19',
  'Seed adres (batch 2, #13) Mah. No:25 Sokak:49',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0bbc433e-11ab-427d-bf80-857eba76579a'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0bbc433e-11ab-427d-bf80-857eba76579a'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0bbc433e-11ab-427d-bf80-857eba76579a'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  44,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0bbc433e-11ab-427d-bf80-857eba76579a'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0bbc433e-11ab-427d-bf80-857eba76579a'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '0bbc433e-11ab-427d-bf80-857eba76579a')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '0bbc433e-11ab-427d-bf80-857eba76579a',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0bbc433e-11ab-427d-bf80-857eba76579a'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0bbc433e-11ab-427d-bf80-857eba76579a'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'eca1e3b9-9684-48b4-b096-c6db7bcb4755' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 22 AS qty_ordered, 22 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '4642e5c1-74bb-4c42-9a30-86996d7493a1' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'a852e796-387f-485d-aeb8-f3b286957bc1' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '4f4e5788-2e8f-43f0-97fe-a904eb9a8b13',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '23232323-2323-4232-8232-232323232323',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-14',
  '+90 530 316 34 25',
  'Seed adres (batch 2, #14) Mah. No:96 Sokak:49',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4f4e5788-2e8f-43f0-97fe-a904eb9a8b13'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4f4e5788-2e8f-43f0-97fe-a904eb9a8b13'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4f4e5788-2e8f-43f0-97fe-a904eb9a8b13'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4f4e5788-2e8f-43f0-97fe-a904eb9a8b13'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '4f4e5788-2e8f-43f0-97fe-a904eb9a8b13')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '4f4e5788-2e8f-43f0-97fe-a904eb9a8b13',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4f4e5788-2e8f-43f0-97fe-a904eb9a8b13'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4f4e5788-2e8f-43f0-97fe-a904eb9a8b13'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '4b76ac8f-1d0c-47bb-8565-9bf8cb8c3198' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 27 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'b030f9a3-12b1-46c9-976f-5d917e0581b2' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 12 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '8619df8a-b13d-4a70-ba9c-561041e05507',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '34343434-3434-4343-8343-343434343434',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-15',
  '+90 538 429 46 58',
  'Seed adres (batch 2, #15) Mah. No:60 Sokak:35',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8619df8a-b13d-4a70-ba9c-561041e05507'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8619df8a-b13d-4a70-ba9c-561041e05507'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8619df8a-b13d-4a70-ba9c-561041e05507'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8619df8a-b13d-4a70-ba9c-561041e05507'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '8619df8a-b13d-4a70-ba9c-561041e05507')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '8619df8a-b13d-4a70-ba9c-561041e05507',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8619df8a-b13d-4a70-ba9c-561041e05507'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8619df8a-b13d-4a70-ba9c-561041e05507'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '03a828af-a4cf-4521-90ce-fd4c0d511499' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 13 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '60a32e5b-7579-44bd-a4f4-79ccc2143444' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 9 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'b40b76d2-9fa1-4f79-84ca-8e713834d590' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 8 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '7f4affcd-9d23-4409-b71a-ba077add70c4',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-16',
  '+90 535 308 57 50',
  'Seed adres (batch 2, #16) Mah. No:53 Sokak:3',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f4affcd-9d23-4409-b71a-ba077add70c4'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f4affcd-9d23-4409-b71a-ba077add70c4'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f4affcd-9d23-4409-b71a-ba077add70c4'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  38,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f4affcd-9d23-4409-b71a-ba077add70c4'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f4affcd-9d23-4409-b71a-ba077add70c4'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '7f4affcd-9d23-4409-b71a-ba077add70c4')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '7f4affcd-9d23-4409-b71a-ba077add70c4',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f4affcd-9d23-4409-b71a-ba077add70c4'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7f4affcd-9d23-4409-b71a-ba077add70c4'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'bfc06835-6e66-4d97-afbb-989513f376b7' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'b690fcda-98d9-46b9-a852-75871b239ed1' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '0abf32d7-27d1-46b8-af22-45ededd502d4' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '686b3ada-ddb2-400a-a8f7-54fa6352f74c',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-17',
  '+90 534 256 35 52',
  'Seed adres (batch 2, #17) Mah. No:30 Sokak:25',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('686b3ada-ddb2-400a-a8f7-54fa6352f74c'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('686b3ada-ddb2-400a-a8f7-54fa6352f74c'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('686b3ada-ddb2-400a-a8f7-54fa6352f74c'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  37,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('686b3ada-ddb2-400a-a8f7-54fa6352f74c'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('686b3ada-ddb2-400a-a8f7-54fa6352f74c'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '686b3ada-ddb2-400a-a8f7-54fa6352f74c')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '686b3ada-ddb2-400a-a8f7-54fa6352f74c',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('686b3ada-ddb2-400a-a8f7-54fa6352f74c'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('686b3ada-ddb2-400a-a8f7-54fa6352f74c'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'efef1e43-6004-480f-bf31-0bf57b057f9a' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 20 AS qty_ordered, 20 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '02a61364-30b9-44e4-82d2-1da4020c5c3b' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '3b39f128-6bb9-43c2-b136-a453e84f17e3' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'c94b6713-ec1c-49b3-9fa5-3baf60e92e5e',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-18',
  '+90 537 571 31 55',
  'Seed adres (batch 2, #18) Mah. No:22 Sokak:9',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c94b6713-ec1c-49b3-9fa5-3baf60e92e5e'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c94b6713-ec1c-49b3-9fa5-3baf60e92e5e'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c94b6713-ec1c-49b3-9fa5-3baf60e92e5e'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c94b6713-ec1c-49b3-9fa5-3baf60e92e5e'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'c94b6713-ec1c-49b3-9fa5-3baf60e92e5e')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'c94b6713-ec1c-49b3-9fa5-3baf60e92e5e',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c94b6713-ec1c-49b3-9fa5-3baf60e92e5e'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c94b6713-ec1c-49b3-9fa5-3baf60e92e5e'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '30faac70-f4db-4452-bd20-2a044b545fcc' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 10 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'b404f9d7-3f45-4db6-b70d-05311466eeac' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 11 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '688b8955-f421-4cfb-bc81-eb2abf05c73b' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '01e09c71-0e12-4e57-8909-a595f384074c',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-19',
  '+90 530 882 10 62',
  'Seed adres (batch 2, #19) Mah. No:18 Sokak:41',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e09c71-0e12-4e57-8909-a595f384074c'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e09c71-0e12-4e57-8909-a595f384074c'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e09c71-0e12-4e57-8909-a595f384074c'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e09c71-0e12-4e57-8909-a595f384074c'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '01e09c71-0e12-4e57-8909-a595f384074c')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '01e09c71-0e12-4e57-8909-a595f384074c',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e09c71-0e12-4e57-8909-a595f384074c'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e09c71-0e12-4e57-8909-a595f384074c'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'd04a2c6c-c25d-4af4-87e4-5f5c79f9e1af' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 9 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'd980f888-e1a6-44f5-8694-7c547548512c' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 4 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'ea9634aa-21df-4a39-8b70-16a5a4e154ef',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-20',
  '+90 539 753 95 88',
  'Seed adres (batch 2, #20) Mah. No:62 Sokak:43',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ea9634aa-21df-4a39-8b70-16a5a4e154ef'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ea9634aa-21df-4a39-8b70-16a5a4e154ef'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ea9634aa-21df-4a39-8b70-16a5a4e154ef'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  29,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ea9634aa-21df-4a39-8b70-16a5a4e154ef'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ea9634aa-21df-4a39-8b70-16a5a4e154ef'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'ea9634aa-21df-4a39-8b70-16a5a4e154ef')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'ea9634aa-21df-4a39-8b70-16a5a4e154ef',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ea9634aa-21df-4a39-8b70-16a5a4e154ef'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ea9634aa-21df-4a39-8b70-16a5a4e154ef'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'ddabcf0a-2550-4b4a-ba3b-a917b20c7bf8' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 22 AS qty_ordered, 22 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '70e4a5a1-6dde-4097-b9ba-5dd9c21a5d6c' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'fd4f49d3-d381-4a50-82ed-00f8ad524f14',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-21',
  '+90 534 648 46 12',
  'Seed adres (batch 2, #21) Mah. No:65 Sokak:45',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fd4f49d3-d381-4a50-82ed-00f8ad524f14'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fd4f49d3-d381-4a50-82ed-00f8ad524f14'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fd4f49d3-d381-4a50-82ed-00f8ad524f14'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  21,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fd4f49d3-d381-4a50-82ed-00f8ad524f14'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fd4f49d3-d381-4a50-82ed-00f8ad524f14'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'fd4f49d3-d381-4a50-82ed-00f8ad524f14')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'fd4f49d3-d381-4a50-82ed-00f8ad524f14',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fd4f49d3-d381-4a50-82ed-00f8ad524f14'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fd4f49d3-d381-4a50-82ed-00f8ad524f14'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'b07d1049-f668-40bd-a045-e5a55fdc5ce2' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '081e89c7-5e9f-4b37-8912-7e5db389cd11' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '0d058471-3a97-46cc-9d32-e471cce04146' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'ef65e3c6-b805-4244-b402-2c1e029ccfda',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-22',
  '+90 535 373 60 20',
  'Seed adres (batch 2, #22) Mah. No:48 Sokak:26',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ef65e3c6-b805-4244-b402-2c1e029ccfda'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ef65e3c6-b805-4244-b402-2c1e029ccfda'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ef65e3c6-b805-4244-b402-2c1e029ccfda'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  32,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ef65e3c6-b805-4244-b402-2c1e029ccfda'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ef65e3c6-b805-4244-b402-2c1e029ccfda'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'ef65e3c6-b805-4244-b402-2c1e029ccfda')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'ef65e3c6-b805-4244-b402-2c1e029ccfda',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ef65e3c6-b805-4244-b402-2c1e029ccfda'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ef65e3c6-b805-4244-b402-2c1e029ccfda'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '47cc6363-55ff-4058-bb5b-20e468dff30b' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 27 AS qty_ordered, 27 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a32073a8-bcb2-4a5c-99fb-b5ca57c5b5c1' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '26da48b2-520c-4b87-b308-df606f1e747a',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-23',
  '+90 536 486 80 70',
  'Seed adres (batch 2, #23) Mah. No:8 Sokak:41',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('26da48b2-520c-4b87-b308-df606f1e747a'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('26da48b2-520c-4b87-b308-df606f1e747a'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('26da48b2-520c-4b87-b308-df606f1e747a'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  21,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('26da48b2-520c-4b87-b308-df606f1e747a'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('26da48b2-520c-4b87-b308-df606f1e747a'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '26da48b2-520c-4b87-b308-df606f1e747a')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '26da48b2-520c-4b87-b308-df606f1e747a',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('26da48b2-520c-4b87-b308-df606f1e747a'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('26da48b2-520c-4b87-b308-df606f1e747a'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '4e2d0efb-6cf5-4f80-849c-6190d8c1adcb' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '1878c7b8-59e3-4b85-83a1-6e8de86b8b81' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '75df0cc1-04e5-4faf-be93-578d7a9a4798',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-24',
  '+90 531 640 15 39',
  'Seed adres (batch 2, #24) Mah. No:28 Sokak:45',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('75df0cc1-04e5-4faf-be93-578d7a9a4798'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('75df0cc1-04e5-4faf-be93-578d7a9a4798'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('75df0cc1-04e5-4faf-be93-578d7a9a4798'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  39,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('75df0cc1-04e5-4faf-be93-578d7a9a4798'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('75df0cc1-04e5-4faf-be93-578d7a9a4798'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '75df0cc1-04e5-4faf-be93-578d7a9a4798')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '75df0cc1-04e5-4faf-be93-578d7a9a4798',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('75df0cc1-04e5-4faf-be93-578d7a9a4798'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('75df0cc1-04e5-4faf-be93-578d7a9a4798'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'd6c49dcd-609f-4f90-b817-a7ffe1cb2334' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '7895e3cf-7271-4830-b326-91abfdd7aa1e' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'fb984481-3971-446b-87bd-bfdb722b707d' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'b85599e0-3cdf-4a31-a070-50ed87531b9c',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 02-25',
  '+90 530 283 50 12',
  'Seed adres (batch 2, #25) Mah. No:27 Sokak:38',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b85599e0-3cdf-4a31-a070-50ed87531b9c'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b85599e0-3cdf-4a31-a070-50ed87531b9c'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b85599e0-3cdf-4a31-a070-50ed87531b9c'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b85599e0-3cdf-4a31-a070-50ed87531b9c'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b85599e0-3cdf-4a31-a070-50ed87531b9c'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'b85599e0-3cdf-4a31-a070-50ed87531b9c')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'b85599e0-3cdf-4a31-a070-50ed87531b9c',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b85599e0-3cdf-4a31-a070-50ed87531b9c'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b85599e0-3cdf-4a31-a070-50ed87531b9c'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'f0f86287-0b4a-4a51-ab0f-88896cf647b6' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 17 AS qty_ordered, 17 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'b510d541-e557-4f11-a649-b278142f51ec' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
