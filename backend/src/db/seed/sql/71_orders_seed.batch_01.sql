-- ============================================================================
-- FILE: db/seed/71_orders_seed.batch_01.sql
-- GENERATED — Orders + Order Items (3 months spread) — Batch 01
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
  '88db0991-438a-4f06-b700-8b1ab54bff88',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-01',
  '+90 535 627 81 23',
  'Seed adres (batch 1, #1) Mah. No:41 Sokak:16',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88db0991-438a-4f06-b700-8b1ab54bff88'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88db0991-438a-4f06-b700-8b1ab54bff88'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88db0991-438a-4f06-b700-8b1ab54bff88'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88db0991-438a-4f06-b700-8b1ab54bff88'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88db0991-438a-4f06-b700-8b1ab54bff88'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '88db0991-438a-4f06-b700-8b1ab54bff88')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '88db0991-438a-4f06-b700-8b1ab54bff88',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88db0991-438a-4f06-b700-8b1ab54bff88'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88db0991-438a-4f06-b700-8b1ab54bff88'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'b8ed4ef2-a72f-4483-9805-a7ba8163ada3' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 19 AS qty_ordered, 19 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'fded1a05-e062-42d4-8689-07d8e39e4d74' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '90aed336-5415-407a-b715-30bfe00524d9',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-02',
  '+90 536 984 88 63',
  'Seed adres (batch 1, #2) Mah. No:32 Sokak:11',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('90aed336-5415-407a-b715-30bfe00524d9'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('90aed336-5415-407a-b715-30bfe00524d9'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('90aed336-5415-407a-b715-30bfe00524d9'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  40,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('90aed336-5415-407a-b715-30bfe00524d9'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('90aed336-5415-407a-b715-30bfe00524d9'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '90aed336-5415-407a-b715-30bfe00524d9')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '90aed336-5415-407a-b715-30bfe00524d9',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('90aed336-5415-407a-b715-30bfe00524d9'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('90aed336-5415-407a-b715-30bfe00524d9'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '5f95b4cb-807f-43e3-9514-854efc23f52a' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '6beaa5da-090c-4686-b7c8-9b2b9946fd40' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '5e1ddd62-08ec-42f8-8cb7-f440dedda6ee' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'b2e62c45-856c-4759-9206-88d1e0492c6d',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-03',
  '+90 534 609 12 21',
  'Seed adres (batch 1, #3) Mah. No:51 Sokak:33',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b2e62c45-856c-4759-9206-88d1e0492c6d'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b2e62c45-856c-4759-9206-88d1e0492c6d'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b2e62c45-856c-4759-9206-88d1e0492c6d'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  17,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b2e62c45-856c-4759-9206-88d1e0492c6d'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b2e62c45-856c-4759-9206-88d1e0492c6d'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'b2e62c45-856c-4759-9206-88d1e0492c6d')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'b2e62c45-856c-4759-9206-88d1e0492c6d',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b2e62c45-856c-4759-9206-88d1e0492c6d'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b2e62c45-856c-4759-9206-88d1e0492c6d'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'e4e8df96-2788-4d43-a45a-d63bedaca057' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a60f8ce6-ddca-44e4-a6ed-b11bad6d8bed' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '8fcffc81-1c36-411d-aaef-c31937f6f818',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-04',
  '+90 539 963 93 96',
  'Seed adres (batch 1, #4) Mah. No:61 Sokak:19',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8fcffc81-1c36-411d-aaef-c31937f6f818'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8fcffc81-1c36-411d-aaef-c31937f6f818'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8fcffc81-1c36-411d-aaef-c31937f6f818'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  45,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8fcffc81-1c36-411d-aaef-c31937f6f818'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8fcffc81-1c36-411d-aaef-c31937f6f818'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '8fcffc81-1c36-411d-aaef-c31937f6f818')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '8fcffc81-1c36-411d-aaef-c31937f6f818',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8fcffc81-1c36-411d-aaef-c31937f6f818'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8fcffc81-1c36-411d-aaef-c31937f6f818'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'ef9ddc77-fec9-4141-bb80-6abfaa67c302' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 18 AS qty_ordered, 18 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '2a1c7a13-a462-4fc5-86ad-5704dfd80836' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'd9eb6c44-00a1-4834-a88b-830fcb155b21' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'aa2d87c7-d29c-4726-8937-c62835dce6b4',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-05',
  '+90 536 152 82 81',
  'Seed adres (batch 1, #5) Mah. No:25 Sokak:24',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('aa2d87c7-d29c-4726-8937-c62835dce6b4'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('aa2d87c7-d29c-4726-8937-c62835dce6b4'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('aa2d87c7-d29c-4726-8937-c62835dce6b4'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  30,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('aa2d87c7-d29c-4726-8937-c62835dce6b4'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('aa2d87c7-d29c-4726-8937-c62835dce6b4'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'aa2d87c7-d29c-4726-8937-c62835dce6b4')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'aa2d87c7-d29c-4726-8937-c62835dce6b4',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('aa2d87c7-d29c-4726-8937-c62835dce6b4'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('aa2d87c7-d29c-4726-8937-c62835dce6b4'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '45e80aef-5d0c-4c9a-a735-4ed2d0f6dd93' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 17 AS qty_ordered, 17 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '67f55a0b-ebb8-4cc0-ad27-5757154a8c11' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '0b0a61f7-1df2-46a4-aa81-8fd7509909de' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '9e34b3f5-268a-46b7-abb6-ccf6a9080555',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-06',
  '+90 531 503 57 53',
  'Seed adres (batch 1, #6) Mah. No:72 Sokak:24',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9e34b3f5-268a-46b7-abb6-ccf6a9080555'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9e34b3f5-268a-46b7-abb6-ccf6a9080555'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9e34b3f5-268a-46b7-abb6-ccf6a9080555'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  32,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9e34b3f5-268a-46b7-abb6-ccf6a9080555'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9e34b3f5-268a-46b7-abb6-ccf6a9080555'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '9e34b3f5-268a-46b7-abb6-ccf6a9080555')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '9e34b3f5-268a-46b7-abb6-ccf6a9080555',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9e34b3f5-268a-46b7-abb6-ccf6a9080555'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9e34b3f5-268a-46b7-abb6-ccf6a9080555'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '9ccfa7ab-e32a-4fff-ba42-6408d4ac09df' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 24 AS qty_ordered, 24 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '9ae40188-a9e1-47a9-81b1-7c7426890fc6' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '1e7c5692-5433-4b9c-87de-59394d563a61' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '3268a43b-e809-4084-8a98-e4497ae534a0',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-07',
  '+90 535 923 70 76',
  'Seed adres (batch 1, #7) Mah. No:59 Sokak:10',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3268a43b-e809-4084-8a98-e4497ae534a0'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3268a43b-e809-4084-8a98-e4497ae534a0'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3268a43b-e809-4084-8a98-e4497ae534a0'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  30,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3268a43b-e809-4084-8a98-e4497ae534a0'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3268a43b-e809-4084-8a98-e4497ae534a0'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '3268a43b-e809-4084-8a98-e4497ae534a0')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '3268a43b-e809-4084-8a98-e4497ae534a0',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3268a43b-e809-4084-8a98-e4497ae534a0'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3268a43b-e809-4084-8a98-e4497ae534a0'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '0d2ab350-05fd-49b3-babe-91c78b73e526' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '25297f7b-b59c-4454-a917-bfbf7c90087b' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '98755bb2-814c-4821-83a6-a89ee5f03036' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '4cff3fea-a79d-4c86-8967-3e85b72559fd',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '34343434-3434-4343-8343-343434343434',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-08',
  '+90 534 707 53 74',
  'Seed adres (batch 1, #8) Mah. No:66 Sokak:35',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4cff3fea-a79d-4c86-8967-3e85b72559fd'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4cff3fea-a79d-4c86-8967-3e85b72559fd'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4cff3fea-a79d-4c86-8967-3e85b72559fd'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4cff3fea-a79d-4c86-8967-3e85b72559fd'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '4cff3fea-a79d-4c86-8967-3e85b72559fd')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '4cff3fea-a79d-4c86-8967-3e85b72559fd',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4cff3fea-a79d-4c86-8967-3e85b72559fd'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4cff3fea-a79d-4c86-8967-3e85b72559fd'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '5f1df784-e081-4e72-a43b-fee0862a1f35' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 14 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'ef918036-e33d-461b-a6fd-d49f38056bce' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 14 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '19e703e3-5473-4694-8586-a7364766ffab',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-09',
  '+90 531 526 84 49',
  'Seed adres (batch 1, #9) Mah. No:93 Sokak:45',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('19e703e3-5473-4694-8586-a7364766ffab'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('19e703e3-5473-4694-8586-a7364766ffab'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('19e703e3-5473-4694-8586-a7364766ffab'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  41,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('19e703e3-5473-4694-8586-a7364766ffab'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('19e703e3-5473-4694-8586-a7364766ffab'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '19e703e3-5473-4694-8586-a7364766ffab')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '19e703e3-5473-4694-8586-a7364766ffab',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('19e703e3-5473-4694-8586-a7364766ffab'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('19e703e3-5473-4694-8586-a7364766ffab'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '04ddf14c-1e47-43e6-8ef8-b70a4665a296' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 20 AS qty_ordered, 20 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a8202fdd-baed-4f21-9323-04781952132c' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '468036b3-1d93-40d8-992a-5450e5830409' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '5b1ee821-6087-45f6-8e8c-3048b1c0acbd',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-10',
  '+90 532 636 90 89',
  'Seed adres (batch 1, #10) Mah. No:49 Sokak:10',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5b1ee821-6087-45f6-8e8c-3048b1c0acbd'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5b1ee821-6087-45f6-8e8c-3048b1c0acbd'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5b1ee821-6087-45f6-8e8c-3048b1c0acbd'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5b1ee821-6087-45f6-8e8c-3048b1c0acbd'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5b1ee821-6087-45f6-8e8c-3048b1c0acbd'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '5b1ee821-6087-45f6-8e8c-3048b1c0acbd')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '5b1ee821-6087-45f6-8e8c-3048b1c0acbd',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5b1ee821-6087-45f6-8e8c-3048b1c0acbd'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5b1ee821-6087-45f6-8e8c-3048b1c0acbd'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '38a471d3-e6b2-4759-9f82-0dcd00827c26' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '778a5f23-695d-40f7-afe5-9e2d22eec797' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'a460bb40-1c0a-4c3b-9c8f-ded6aa5caa77' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '30dbe17a-81bf-42e7-8f30-702d5f810212',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-11',
  '+90 532 522 98 36',
  'Seed adres (batch 1, #11) Mah. No:53 Sokak:33',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('30dbe17a-81bf-42e7-8f30-702d5f810212'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('30dbe17a-81bf-42e7-8f30-702d5f810212'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('30dbe17a-81bf-42e7-8f30-702d5f810212'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  32,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('30dbe17a-81bf-42e7-8f30-702d5f810212'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('30dbe17a-81bf-42e7-8f30-702d5f810212'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '30dbe17a-81bf-42e7-8f30-702d5f810212')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '30dbe17a-81bf-42e7-8f30-702d5f810212',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('30dbe17a-81bf-42e7-8f30-702d5f810212'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('30dbe17a-81bf-42e7-8f30-702d5f810212'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '13bb8e52-3916-4046-a989-48080c30fa06' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '2e263190-a48a-45a1-a6f3-ef7dc10ae47c' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'd14e3122-65a6-4c0e-8b72-3a8d7c67d70c' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-12',
  '+90 537 638 58 50',
  'Seed adres (batch 1, #12) Mah. No:23 Sokak:30',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  44,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f47a8a71-49ce-4e8b-a4e4-0ba8f9bfe973'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'ac3d123f-7725-4c74-8b53-051b99750774' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 22 AS qty_ordered, 22 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '2046abe2-4601-4ce9-b1de-e34e7e311746' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '007fa198-2415-496a-ad31-174e3caea966' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '57a2c6f6-1770-4058-a9df-986c32513599',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-13',
  '+90 533 385 81 48',
  'Seed adres (batch 1, #13) Mah. No:29 Sokak:20',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('57a2c6f6-1770-4058-a9df-986c32513599'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('57a2c6f6-1770-4058-a9df-986c32513599'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('57a2c6f6-1770-4058-a9df-986c32513599'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  29,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('57a2c6f6-1770-4058-a9df-986c32513599'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('57a2c6f6-1770-4058-a9df-986c32513599'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '57a2c6f6-1770-4058-a9df-986c32513599')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '57a2c6f6-1770-4058-a9df-986c32513599',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('57a2c6f6-1770-4058-a9df-986c32513599'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('57a2c6f6-1770-4058-a9df-986c32513599'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'f711a42a-bee4-4dba-903c-eb909792e67c' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '33e82afb-5bf3-4684-bc57-794ef365b4bf' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'd8843c79-5245-4836-9847-906ae712aa02' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'ca2def04-8a82-4cf9-9b60-a7bfc5fc684f',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-14',
  '+90 534 394 25 83',
  'Seed adres (batch 1, #14) Mah. No:87 Sokak:35',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca2def04-8a82-4cf9-9b60-a7bfc5fc684f'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca2def04-8a82-4cf9-9b60-a7bfc5fc684f'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca2def04-8a82-4cf9-9b60-a7bfc5fc684f'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  21,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca2def04-8a82-4cf9-9b60-a7bfc5fc684f'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca2def04-8a82-4cf9-9b60-a7bfc5fc684f'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'ca2def04-8a82-4cf9-9b60-a7bfc5fc684f')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'ca2def04-8a82-4cf9-9b60-a7bfc5fc684f',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca2def04-8a82-4cf9-9b60-a7bfc5fc684f'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca2def04-8a82-4cf9-9b60-a7bfc5fc684f'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '8c736da8-b092-462c-9231-11141a3c22cf' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 16 AS qty_ordered, 16 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'f5913749-9edd-4896-a70a-707c73959cd5' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '8f75bc80-8d3e-4cfb-bdfe-ed0730dd6523',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '23232323-2323-4232-8232-232323232323',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-15',
  '+90 531 454 66 93',
  'Seed adres (batch 1, #15) Mah. No:33 Sokak:48',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8f75bc80-8d3e-4cfb-bdfe-ed0730dd6523'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8f75bc80-8d3e-4cfb-bdfe-ed0730dd6523'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8f75bc80-8d3e-4cfb-bdfe-ed0730dd6523'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8f75bc80-8d3e-4cfb-bdfe-ed0730dd6523'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '8f75bc80-8d3e-4cfb-bdfe-ed0730dd6523')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '8f75bc80-8d3e-4cfb-bdfe-ed0730dd6523',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8f75bc80-8d3e-4cfb-bdfe-ed0730dd6523'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8f75bc80-8d3e-4cfb-bdfe-ed0730dd6523'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '23e54531-1283-4aa7-9001-303019773c8e' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 22 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'cb37a3a6-6503-46ab-94c0-41ab9cf273b3' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 15 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'ca0bcf9d-c4b9-4483-8eac-4343310dc557',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-16',
  '+90 539 858 85 40',
  'Seed adres (batch 1, #16) Mah. No:32 Sokak:4',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca0bcf9d-c4b9-4483-8eac-4343310dc557'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca0bcf9d-c4b9-4483-8eac-4343310dc557'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca0bcf9d-c4b9-4483-8eac-4343310dc557'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  18,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca0bcf9d-c4b9-4483-8eac-4343310dc557'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca0bcf9d-c4b9-4483-8eac-4343310dc557'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'ca0bcf9d-c4b9-4483-8eac-4343310dc557')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'ca0bcf9d-c4b9-4483-8eac-4343310dc557',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca0bcf9d-c4b9-4483-8eac-4343310dc557'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ca0bcf9d-c4b9-4483-8eac-4343310dc557'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '4b9d6bb5-e1e8-459e-b49f-e3857435dd0d' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '7a1adeb0-561a-4a18-babf-226103a41be8' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '8e0c09ec-5810-4376-98dc-3dcbdeebd376' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '27e6f660-013f-4fdd-91eb-98a1d5978088',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-17',
  '+90 531 797 27 10',
  'Seed adres (batch 1, #17) Mah. No:71 Sokak:11',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('27e6f660-013f-4fdd-91eb-98a1d5978088'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('27e6f660-013f-4fdd-91eb-98a1d5978088'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('27e6f660-013f-4fdd-91eb-98a1d5978088'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  24,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('27e6f660-013f-4fdd-91eb-98a1d5978088'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('27e6f660-013f-4fdd-91eb-98a1d5978088'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '27e6f660-013f-4fdd-91eb-98a1d5978088')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '27e6f660-013f-4fdd-91eb-98a1d5978088',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('27e6f660-013f-4fdd-91eb-98a1d5978088'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('27e6f660-013f-4fdd-91eb-98a1d5978088'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '0d7a9c43-47b5-485e-9197-445182e13e56' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 20 AS qty_ordered, 20 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'bbda03fc-aac1-4184-8df9-494401b8273f' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'ff59c9f6-f3d7-474c-af07-77285daf1a12',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-18',
  '+90 530 887 21 93',
  'Seed adres (batch 1, #18) Mah. No:74 Sokak:15',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ff59c9f6-f3d7-474c-af07-77285daf1a12'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ff59c9f6-f3d7-474c-af07-77285daf1a12'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ff59c9f6-f3d7-474c-af07-77285daf1a12'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  28,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ff59c9f6-f3d7-474c-af07-77285daf1a12'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ff59c9f6-f3d7-474c-af07-77285daf1a12'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'ff59c9f6-f3d7-474c-af07-77285daf1a12')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'ff59c9f6-f3d7-474c-af07-77285daf1a12',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ff59c9f6-f3d7-474c-af07-77285daf1a12'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ff59c9f6-f3d7-474c-af07-77285daf1a12'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '294349a4-be5a-48c6-a0b7-d4a56f83513a' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '86421292-6996-43ce-abab-ab5b18640dc9' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '2027e932-e192-4479-9aaa-af4829bcfe5e' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'e03348a1-76c4-442e-8407-89f83cf806d4',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-19',
  '+90 532 866 47 14',
  'Seed adres (batch 1, #19) Mah. No:2 Sokak:20',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e03348a1-76c4-442e-8407-89f83cf806d4'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e03348a1-76c4-442e-8407-89f83cf806d4'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e03348a1-76c4-442e-8407-89f83cf806d4'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  32,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e03348a1-76c4-442e-8407-89f83cf806d4'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e03348a1-76c4-442e-8407-89f83cf806d4'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'e03348a1-76c4-442e-8407-89f83cf806d4')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'e03348a1-76c4-442e-8407-89f83cf806d4',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e03348a1-76c4-442e-8407-89f83cf806d4'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e03348a1-76c4-442e-8407-89f83cf806d4'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'dba4aad9-77d0-4187-865b-5e2a075ed2c4' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'da15b5e0-8651-4726-a4e7-1d307b633eeb' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '1dd6f6f3-1d91-433e-9eaa-c4e830c846bd' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'c7f3dc54-daa4-4fcd-9a58-4c2effe2b581',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '34343434-3434-4343-8343-343434343434',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-20',
  '+90 532 971 74 69',
  'Seed adres (batch 1, #20) Mah. No:35 Sokak:13',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c7f3dc54-daa4-4fcd-9a58-4c2effe2b581'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c7f3dc54-daa4-4fcd-9a58-4c2effe2b581'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c7f3dc54-daa4-4fcd-9a58-4c2effe2b581'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c7f3dc54-daa4-4fcd-9a58-4c2effe2b581'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'c7f3dc54-daa4-4fcd-9a58-4c2effe2b581')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'c7f3dc54-daa4-4fcd-9a58-4c2effe2b581',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c7f3dc54-daa4-4fcd-9a58-4c2effe2b581'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c7f3dc54-daa4-4fcd-9a58-4c2effe2b581'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '6a93581b-9815-43da-b1c2-4b63c49aa28a' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 10 AS qty_ordered, 7 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'f21de905-fc60-459f-bca3-264fbb657392' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '19913c1f-738e-4578-81a4-8a95736f0726' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '4729b18d-e502-4944-b1b0-83245d5055b6',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-21',
  '+90 533 279 88 91',
  'Seed adres (batch 1, #21) Mah. No:52 Sokak:28',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4729b18d-e502-4944-b1b0-83245d5055b6'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4729b18d-e502-4944-b1b0-83245d5055b6'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4729b18d-e502-4944-b1b0-83245d5055b6'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4729b18d-e502-4944-b1b0-83245d5055b6'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4729b18d-e502-4944-b1b0-83245d5055b6'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '4729b18d-e502-4944-b1b0-83245d5055b6')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '4729b18d-e502-4944-b1b0-83245d5055b6',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4729b18d-e502-4944-b1b0-83245d5055b6'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4729b18d-e502-4944-b1b0-83245d5055b6'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'b5c71711-14f3-432c-9b23-ab34ca9664e0' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 17 AS qty_ordered, 17 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '2355fe33-5277-4064-aa9d-7b1463fff2d7' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'b2f87326-c042-4f89-9c15-49035aa07026' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '9db2f3af-0edd-46bc-9926-b34364071684',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-22',
  '+90 530 367 59 40',
  'Seed adres (batch 1, #22) Mah. No:58 Sokak:49',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9db2f3af-0edd-46bc-9926-b34364071684'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9db2f3af-0edd-46bc-9926-b34364071684'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9db2f3af-0edd-46bc-9926-b34364071684'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9db2f3af-0edd-46bc-9926-b34364071684'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '9db2f3af-0edd-46bc-9926-b34364071684')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '9db2f3af-0edd-46bc-9926-b34364071684',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9db2f3af-0edd-46bc-9926-b34364071684'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9db2f3af-0edd-46bc-9926-b34364071684'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '071736f5-ab4d-4393-9af4-d19bf13f9a1d' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 14 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '7f7b0667-79f6-436e-81c6-0dc24668d09c' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 12 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '1231f37e-430a-419e-b46d-fb94aed083ce',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-23',
  '+90 535 809 40 17',
  'Seed adres (batch 1, #23) Mah. No:86 Sokak:8',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1231f37e-430a-419e-b46d-fb94aed083ce'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1231f37e-430a-419e-b46d-fb94aed083ce'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1231f37e-430a-419e-b46d-fb94aed083ce'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  26,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1231f37e-430a-419e-b46d-fb94aed083ce'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1231f37e-430a-419e-b46d-fb94aed083ce'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '1231f37e-430a-419e-b46d-fb94aed083ce')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '1231f37e-430a-419e-b46d-fb94aed083ce',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1231f37e-430a-419e-b46d-fb94aed083ce'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1231f37e-430a-419e-b46d-fb94aed083ce'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '66c7fa55-5ac5-40db-b5e2-a6a3a45ee23b' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 17 AS qty_ordered, 17 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '747e78af-9112-420f-b0db-a6704a61e749' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'f508c70c-9144-46e5-b4a3-4df9758ef1a0',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-24',
  '+90 534 476 88 38',
  'Seed adres (batch 1, #24) Mah. No:29 Sokak:9',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f508c70c-9144-46e5-b4a3-4df9758ef1a0'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f508c70c-9144-46e5-b4a3-4df9758ef1a0'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f508c70c-9144-46e5-b4a3-4df9758ef1a0'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  34,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f508c70c-9144-46e5-b4a3-4df9758ef1a0'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f508c70c-9144-46e5-b4a3-4df9758ef1a0'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'f508c70c-9144-46e5-b4a3-4df9758ef1a0')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'f508c70c-9144-46e5-b4a3-4df9758ef1a0',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f508c70c-9144-46e5-b4a3-4df9758ef1a0'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f508c70c-9144-46e5-b4a3-4df9758ef1a0'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '5545977a-3626-43c4-8bd1-896c832a2633' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '19962d2e-49f5-4680-afba-d808c35b4f5b' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'b3e8f4c2-8113-4b25-83ad-024d87778789',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 01-25',
  '+90 538 921 95 37',
  'Seed adres (batch 1, #25) Mah. No:98 Sokak:16',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b3e8f4c2-8113-4b25-83ad-024d87778789'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b3e8f4c2-8113-4b25-83ad-024d87778789'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b3e8f4c2-8113-4b25-83ad-024d87778789'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b3e8f4c2-8113-4b25-83ad-024d87778789'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'b3e8f4c2-8113-4b25-83ad-024d87778789')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'b3e8f4c2-8113-4b25-83ad-024d87778789',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b3e8f4c2-8113-4b25-83ad-024d87778789'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b3e8f4c2-8113-4b25-83ad-024d87778789'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'dd6ae4fc-d3f1-482e-8f8a-3ea1a362ded2' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 30 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'cbb98e02-2675-49fd-b25a-12208fbd9614' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '660d638f-f175-4dfe-9512-992ca644535e' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 9 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
