-- ============================================================================
-- FILE: db/seed/71_orders_seed.batch_04.sql
-- GENERATED — Orders + Order Items (3 months spread) — Batch 04
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
  'e865745f-3b3b-4a9f-b1f0-dcf3114c2094',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-01',
  '+90 533 650 46 31',
  'Seed adres (batch 4, #1) Mah. No:59 Sokak:37',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e865745f-3b3b-4a9f-b1f0-dcf3114c2094'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e865745f-3b3b-4a9f-b1f0-dcf3114c2094'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e865745f-3b3b-4a9f-b1f0-dcf3114c2094'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  26,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e865745f-3b3b-4a9f-b1f0-dcf3114c2094'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e865745f-3b3b-4a9f-b1f0-dcf3114c2094'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'e865745f-3b3b-4a9f-b1f0-dcf3114c2094')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'e865745f-3b3b-4a9f-b1f0-dcf3114c2094',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e865745f-3b3b-4a9f-b1f0-dcf3114c2094'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e865745f-3b3b-4a9f-b1f0-dcf3114c2094'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'c558ec69-209a-4142-a5d6-15506b4ffb83' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 22 AS qty_ordered, 22 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '2a61abbf-6dff-436b-b5d8-0de274b288bd' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'ba8a4d3a-63c9-42f7-8e92-d4fd7942da0a' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '93323de9-731b-4c35-bf97-a1674b0a396b',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '45454545-4545-4454-8454-454545454545',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-02',
  '+90 535 655 15 66',
  'Seed adres (batch 4, #2) Mah. No:70 Sokak:14',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('93323de9-731b-4c35-bf97-a1674b0a396b'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('93323de9-731b-4c35-bf97-a1674b0a396b'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('93323de9-731b-4c35-bf97-a1674b0a396b'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('93323de9-731b-4c35-bf97-a1674b0a396b'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '93323de9-731b-4c35-bf97-a1674b0a396b')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '93323de9-731b-4c35-bf97-a1674b0a396b',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('93323de9-731b-4c35-bf97-a1674b0a396b'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('93323de9-731b-4c35-bf97-a1674b0a396b'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '00ac1b1c-5185-4fbb-9ff8-0b324c11bbc9' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 28 AS qty_ordered, 26 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '247ef2cf-54f2-44fe-8680-3554dd9dc640' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 13 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '17533f08-1c2b-4eb4-a118-5bf114c6bf94' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 14 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '8ad6917d-9d79-4b46-b0df-4ce65d1b5c04',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-03',
  '+90 531 549 25 40',
  'Seed adres (batch 4, #3) Mah. No:27 Sokak:48',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8ad6917d-9d79-4b46-b0df-4ce65d1b5c04'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8ad6917d-9d79-4b46-b0df-4ce65d1b5c04'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8ad6917d-9d79-4b46-b0df-4ce65d1b5c04'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  41,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8ad6917d-9d79-4b46-b0df-4ce65d1b5c04'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8ad6917d-9d79-4b46-b0df-4ce65d1b5c04'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '8ad6917d-9d79-4b46-b0df-4ce65d1b5c04')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '8ad6917d-9d79-4b46-b0df-4ce65d1b5c04',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8ad6917d-9d79-4b46-b0df-4ce65d1b5c04'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8ad6917d-9d79-4b46-b0df-4ce65d1b5c04'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '9a42aab9-8826-455b-83cc-c1e366944ef3' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 27 AS qty_ordered, 27 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a1442da0-f669-4f7b-b66d-a37494ea992a' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '645d1433-b434-45b7-8af6-6dd8a7fcdd2a' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'a8760fae-6d52-4faa-bb22-5837ef604b57',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-04',
  '+90 533 924 17 82',
  'Seed adres (batch 4, #4) Mah. No:45 Sokak:35',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a8760fae-6d52-4faa-bb22-5837ef604b57'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a8760fae-6d52-4faa-bb22-5837ef604b57'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a8760fae-6d52-4faa-bb22-5837ef604b57'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a8760fae-6d52-4faa-bb22-5837ef604b57'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a8760fae-6d52-4faa-bb22-5837ef604b57'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'a8760fae-6d52-4faa-bb22-5837ef604b57')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'a8760fae-6d52-4faa-bb22-5837ef604b57',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a8760fae-6d52-4faa-bb22-5837ef604b57'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a8760fae-6d52-4faa-bb22-5837ef604b57'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '930b7f4a-9bfc-4b13-bfd3-051e45fdfce1' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '89827987-7890-412e-bbc9-c4be2a4f9374' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'a3527a50-510d-4d7b-af6f-c3df78d4afc0',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-05',
  '+90 538 795 22 27',
  'Seed adres (batch 4, #5) Mah. No:97 Sokak:27',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a3527a50-510d-4d7b-af6f-c3df78d4afc0'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a3527a50-510d-4d7b-af6f-c3df78d4afc0'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a3527a50-510d-4d7b-af6f-c3df78d4afc0'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  41,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a3527a50-510d-4d7b-af6f-c3df78d4afc0'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a3527a50-510d-4d7b-af6f-c3df78d4afc0'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'a3527a50-510d-4d7b-af6f-c3df78d4afc0')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'a3527a50-510d-4d7b-af6f-c3df78d4afc0',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a3527a50-510d-4d7b-af6f-c3df78d4afc0'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a3527a50-510d-4d7b-af6f-c3df78d4afc0'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'ff2b12fb-8de0-4184-8108-af0d8e50ea6b' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 25 AS qty_ordered, 25 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '1bc59e82-53e9-4273-85ba-424f9f1e03f3' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '48c79427-621d-40cc-bc5c-52fea075b1f0' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'e57c0656-6754-4866-829e-8bd7e5c597cc',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-06',
  '+90 536 601 28 83',
  'Seed adres (batch 4, #6) Mah. No:81 Sokak:18',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e57c0656-6754-4866-829e-8bd7e5c597cc'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e57c0656-6754-4866-829e-8bd7e5c597cc'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e57c0656-6754-4866-829e-8bd7e5c597cc'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e57c0656-6754-4866-829e-8bd7e5c597cc'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'e57c0656-6754-4866-829e-8bd7e5c597cc')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'e57c0656-6754-4866-829e-8bd7e5c597cc',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e57c0656-6754-4866-829e-8bd7e5c597cc'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e57c0656-6754-4866-829e-8bd7e5c597cc'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'a1495fcb-8010-4278-9417-f462336dd7e6' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 19 AS qty_ordered, 2 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '22a5f61f-65e4-43a2-a8e1-73c8ca7b93a1' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 13 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '308b2365-02a9-4d6a-a254-e13cd50beb8b' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 7 AS qty_ordered, 4 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '3a8b6594-c66b-473b-8f4a-aeb5a285a182',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-07',
  '+90 535 695 10 21',
  'Seed adres (batch 4, #7) Mah. No:94 Sokak:30',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3a8b6594-c66b-473b-8f4a-aeb5a285a182'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3a8b6594-c66b-473b-8f4a-aeb5a285a182'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3a8b6594-c66b-473b-8f4a-aeb5a285a182'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3a8b6594-c66b-473b-8f4a-aeb5a285a182'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '3a8b6594-c66b-473b-8f4a-aeb5a285a182')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '3a8b6594-c66b-473b-8f4a-aeb5a285a182',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3a8b6594-c66b-473b-8f4a-aeb5a285a182'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3a8b6594-c66b-473b-8f4a-aeb5a285a182'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'd091b381-c2cf-4faa-b9df-64f75744d9c4' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 16 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '4fe57db1-30c3-4952-ab26-e92627fd52c5' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 13 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'f978b9c5-6179-4422-a8b1-d1262f77b222' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 7 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '1cb900f4-c8be-4537-b0e7-a286be52ab3a',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '34343434-3434-4343-8343-343434343434',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-08',
  '+90 537 374 51 46',
  'Seed adres (batch 4, #8) Mah. No:44 Sokak:36',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1cb900f4-c8be-4537-b0e7-a286be52ab3a'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1cb900f4-c8be-4537-b0e7-a286be52ab3a'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1cb900f4-c8be-4537-b0e7-a286be52ab3a'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1cb900f4-c8be-4537-b0e7-a286be52ab3a'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '1cb900f4-c8be-4537-b0e7-a286be52ab3a')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '1cb900f4-c8be-4537-b0e7-a286be52ab3a',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1cb900f4-c8be-4537-b0e7-a286be52ab3a'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1cb900f4-c8be-4537-b0e7-a286be52ab3a'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '4be1a7ed-b1d5-4a62-96f8-3a1cb400e092' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 20 AS qty_ordered, 10 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a51f0caa-d4ee-4ce6-b0d1-c34a4471b3ac' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 13 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '7a7252e5-ade7-491a-92f7-fc3ab863e070' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '41071ca6-12fb-4200-930c-35ab3b2664f2',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-09',
  '+90 532 551 68 10',
  'Seed adres (batch 4, #9) Mah. No:55 Sokak:13',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41071ca6-12fb-4200-930c-35ab3b2664f2'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41071ca6-12fb-4200-930c-35ab3b2664f2'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41071ca6-12fb-4200-930c-35ab3b2664f2'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  30,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41071ca6-12fb-4200-930c-35ab3b2664f2'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41071ca6-12fb-4200-930c-35ab3b2664f2'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '41071ca6-12fb-4200-930c-35ab3b2664f2')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '41071ca6-12fb-4200-930c-35ab3b2664f2',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41071ca6-12fb-4200-930c-35ab3b2664f2'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('41071ca6-12fb-4200-930c-35ab3b2664f2'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'd18b13c0-66fb-4841-b531-3da688c8ccbe' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 25 AS qty_ordered, 25 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'ee798fc1-2c41-48fc-9287-80172edfc94f' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '81345892-2fb2-40b4-a994-69f83ad580ef' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '067d7129-9eca-42af-9ca8-ac9b08377509',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-10',
  '+90 532 153 60 90',
  'Seed adres (batch 4, #10) Mah. No:40 Sokak:47',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('067d7129-9eca-42af-9ca8-ac9b08377509'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('067d7129-9eca-42af-9ca8-ac9b08377509'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('067d7129-9eca-42af-9ca8-ac9b08377509'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('067d7129-9eca-42af-9ca8-ac9b08377509'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('067d7129-9eca-42af-9ca8-ac9b08377509'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '067d7129-9eca-42af-9ca8-ac9b08377509')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '067d7129-9eca-42af-9ca8-ac9b08377509',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('067d7129-9eca-42af-9ca8-ac9b08377509'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('067d7129-9eca-42af-9ca8-ac9b08377509'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'c7083027-136e-43dc-b458-780395db7e38' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 18 AS qty_ordered, 18 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '22eec0dd-169b-4089-8607-0e5be91484ac' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '544a0bce-0760-45ad-ba4e-dd10cc2fb787' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-11',
  '+90 532 707 38 76',
  'Seed adres (batch 4, #11) Mah. No:88 Sokak:29',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  29,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('fc775cb4-ab6a-47bf-85f0-5a1d6ac351e1'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '07acd692-7e5c-4fb2-906e-a9504a425564' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '7c524b04-19dc-46a0-a03c-f47dcd7e89f9' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '7d4f3b71-3789-4638-8f80-121d767f3658',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-12',
  '+90 533 492 21 23',
  'Seed adres (batch 4, #12) Mah. No:14 Sokak:21',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7d4f3b71-3789-4638-8f80-121d767f3658'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7d4f3b71-3789-4638-8f80-121d767f3658'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7d4f3b71-3789-4638-8f80-121d767f3658'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7d4f3b71-3789-4638-8f80-121d767f3658'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7d4f3b71-3789-4638-8f80-121d767f3658'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '7d4f3b71-3789-4638-8f80-121d767f3658')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '7d4f3b71-3789-4638-8f80-121d767f3658',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7d4f3b71-3789-4638-8f80-121d767f3658'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7d4f3b71-3789-4638-8f80-121d767f3658'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'ad22a1e7-435d-4587-b7a8-8aa7df523aae' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '76c02571-bb14-4ca3-9c85-5b52aaeb674a' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'e731ce17-9113-45fe-9825-c32b9dbac2c3',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-13',
  '+90 539 108 88 93',
  'Seed adres (batch 4, #13) Mah. No:22 Sokak:29',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e731ce17-9113-45fe-9825-c32b9dbac2c3'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e731ce17-9113-45fe-9825-c32b9dbac2c3'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e731ce17-9113-45fe-9825-c32b9dbac2c3'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  28,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e731ce17-9113-45fe-9825-c32b9dbac2c3'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e731ce17-9113-45fe-9825-c32b9dbac2c3'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'e731ce17-9113-45fe-9825-c32b9dbac2c3')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'e731ce17-9113-45fe-9825-c32b9dbac2c3',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e731ce17-9113-45fe-9825-c32b9dbac2c3'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e731ce17-9113-45fe-9825-c32b9dbac2c3'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '2882b8d0-d164-44b5-b065-8e43d91cd247' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 25 AS qty_ordered, 25 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '74062620-5e26-4679-92ba-230a37e31613' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '0e446475-d398-4617-b62e-ec88c4bb096d',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-14',
  '+90 533 188 22 27',
  'Seed adres (batch 4, #14) Mah. No:97 Sokak:8',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0e446475-d398-4617-b62e-ec88c4bb096d'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0e446475-d398-4617-b62e-ec88c4bb096d'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0e446475-d398-4617-b62e-ec88c4bb096d'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  26,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0e446475-d398-4617-b62e-ec88c4bb096d'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0e446475-d398-4617-b62e-ec88c4bb096d'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '0e446475-d398-4617-b62e-ec88c4bb096d')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '0e446475-d398-4617-b62e-ec88c4bb096d',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0e446475-d398-4617-b62e-ec88c4bb096d'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0e446475-d398-4617-b62e-ec88c4bb096d'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'edbbe60d-9781-467c-bc09-eea29ebc461b' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 16 AS qty_ordered, 16 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'd3c53163-ea33-43a4-b13b-6203207b3e6c' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '41f207a9-a16d-400a-afc8-00397658d9f3' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-15',
  '+90 539 714 87 46',
  'Seed adres (batch 4, #15) Mah. No:89 Sokak:2',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  32,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('ba6c9ab6-5f56-49f8-ac3c-ee06ad0030e9'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'ed75859d-5c07-4314-a04c-5e4cdb14e097' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '8ff00e06-9562-4e14-a4c9-a9523a5716b1' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '68d6e68d-f843-4f9c-a3ef-2ce14f3dce56' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'c791fb84-5d69-4c29-9ab7-a125eef8904f',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-16',
  '+90 530 902 40 73',
  'Seed adres (batch 4, #16) Mah. No:50 Sokak:8',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c791fb84-5d69-4c29-9ab7-a125eef8904f'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c791fb84-5d69-4c29-9ab7-a125eef8904f'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c791fb84-5d69-4c29-9ab7-a125eef8904f'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  33,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c791fb84-5d69-4c29-9ab7-a125eef8904f'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c791fb84-5d69-4c29-9ab7-a125eef8904f'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'c791fb84-5d69-4c29-9ab7-a125eef8904f')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'c791fb84-5d69-4c29-9ab7-a125eef8904f',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c791fb84-5d69-4c29-9ab7-a125eef8904f'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c791fb84-5d69-4c29-9ab7-a125eef8904f'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '522730d6-5bbd-4010-acfb-7436836e3767' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 24 AS qty_ordered, 24 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '50c76a53-e442-42c3-a15e-9eb88646ef48' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '861e5803-c517-433a-925f-01b3ec65dbef',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '23232323-2323-4232-8232-232323232323',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-17',
  '+90 532 496 82 63',
  'Seed adres (batch 4, #17) Mah. No:47 Sokak:35',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('861e5803-c517-433a-925f-01b3ec65dbef'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('861e5803-c517-433a-925f-01b3ec65dbef'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('861e5803-c517-433a-925f-01b3ec65dbef'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('861e5803-c517-433a-925f-01b3ec65dbef'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '861e5803-c517-433a-925f-01b3ec65dbef')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '861e5803-c517-433a-925f-01b3ec65dbef',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('861e5803-c517-433a-925f-01b3ec65dbef'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('861e5803-c517-433a-925f-01b3ec65dbef'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'e6dccf47-142d-44af-b1a6-c4cd0ae39d8d' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 29 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '4e7255c4-6b4b-4bc9-bb6c-df37504ef84e' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 1 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'e4737573-f843-4a23-bf9f-9590803c8335' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 2 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '2bf3d1b4-3ec6-44c0-8944-13c3744204e4',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-18',
  '+90 530 908 60 74',
  'Seed adres (batch 4, #18) Mah. No:37 Sokak:41',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bf3d1b4-3ec6-44c0-8944-13c3744204e4'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bf3d1b4-3ec6-44c0-8944-13c3744204e4'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bf3d1b4-3ec6-44c0-8944-13c3744204e4'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  36,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bf3d1b4-3ec6-44c0-8944-13c3744204e4'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bf3d1b4-3ec6-44c0-8944-13c3744204e4'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '2bf3d1b4-3ec6-44c0-8944-13c3744204e4')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '2bf3d1b4-3ec6-44c0-8944-13c3744204e4',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bf3d1b4-3ec6-44c0-8944-13c3744204e4'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bf3d1b4-3ec6-44c0-8944-13c3744204e4'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '16c63c46-66f6-47d4-b570-5400ea71fa51' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 18 AS qty_ordered, 18 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'b0ce976e-7732-43f7-88aa-4c86ad5ffc40' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '4972e866-cb61-4168-88e9-b232d461141e' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'e3755406-d845-483f-8654-c17e0ed53c42',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-19',
  '+90 534 185 49 20',
  'Seed adres (batch 4, #19) Mah. No:66 Sokak:14',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e3755406-d845-483f-8654-c17e0ed53c42'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e3755406-d845-483f-8654-c17e0ed53c42'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e3755406-d845-483f-8654-c17e0ed53c42'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  40,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e3755406-d845-483f-8654-c17e0ed53c42'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e3755406-d845-483f-8654-c17e0ed53c42'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'e3755406-d845-483f-8654-c17e0ed53c42')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'e3755406-d845-483f-8654-c17e0ed53c42',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e3755406-d845-483f-8654-c17e0ed53c42'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e3755406-d845-483f-8654-c17e0ed53c42'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'fad00e09-2e19-4070-8ca6-f818b516db8f' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 22 AS qty_ordered, 22 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '26aee316-750b-442a-b520-d49fb089c6bd' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '4906eb45-dbc1-441c-bc1a-01d8808936bf' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'e07b5199-16a9-462e-9d5d-e1a159f55290',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-20',
  '+90 533 159 41 21',
  'Seed adres (batch 4, #20) Mah. No:56 Sokak:8',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e07b5199-16a9-462e-9d5d-e1a159f55290'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e07b5199-16a9-462e-9d5d-e1a159f55290'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e07b5199-16a9-462e-9d5d-e1a159f55290'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  17,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e07b5199-16a9-462e-9d5d-e1a159f55290'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e07b5199-16a9-462e-9d5d-e1a159f55290'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'e07b5199-16a9-462e-9d5d-e1a159f55290')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'e07b5199-16a9-462e-9d5d-e1a159f55290',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e07b5199-16a9-462e-9d5d-e1a159f55290'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e07b5199-16a9-462e-9d5d-e1a159f55290'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'd14e9272-e4b0-4d60-a61b-7d1b45fd83bf' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a476ee80-0551-4390-9966-5d0278a3b5f3' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '85a18b29-7000-48f7-9629-6c236a4683a4',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-21',
  '+90 532 818 11 30',
  'Seed adres (batch 4, #21) Mah. No:64 Sokak:23',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('85a18b29-7000-48f7-9629-6c236a4683a4'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('85a18b29-7000-48f7-9629-6c236a4683a4'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('85a18b29-7000-48f7-9629-6c236a4683a4'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  31,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('85a18b29-7000-48f7-9629-6c236a4683a4'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('85a18b29-7000-48f7-9629-6c236a4683a4'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '85a18b29-7000-48f7-9629-6c236a4683a4')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '85a18b29-7000-48f7-9629-6c236a4683a4',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('85a18b29-7000-48f7-9629-6c236a4683a4'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('85a18b29-7000-48f7-9629-6c236a4683a4'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'cab070ce-51d7-4e2b-b308-43eaf961530b' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '57e207f8-7ff3-4e61-8e05-3a08c4f33d7f' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '6c132343-2dd5-4d77-bcab-a85a36dc0831' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-22',
  '+90 530 443 64 44',
  'Seed adres (batch 4, #22) Mah. No:68 Sokak:5',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  33,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4c70b9fb-3a0d-4d5b-ae3f-9ef7ed71f87e'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'a458e3e8-30b0-4351-85c9-f89c10148166' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 25 AS qty_ordered, 25 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a97ce4d3-7b21-4abd-a4c4-6e770c8a9929' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'f24c48d7-f657-4dd1-b414-b25ce90254ff',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-23',
  '+90 537 979 82 31',
  'Seed adres (batch 4, #23) Mah. No:48 Sokak:11',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f24c48d7-f657-4dd1-b414-b25ce90254ff'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f24c48d7-f657-4dd1-b414-b25ce90254ff'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f24c48d7-f657-4dd1-b414-b25ce90254ff'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  35,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f24c48d7-f657-4dd1-b414-b25ce90254ff'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f24c48d7-f657-4dd1-b414-b25ce90254ff'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'f24c48d7-f657-4dd1-b414-b25ce90254ff')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'f24c48d7-f657-4dd1-b414-b25ce90254ff',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f24c48d7-f657-4dd1-b414-b25ce90254ff'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f24c48d7-f657-4dd1-b414-b25ce90254ff'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'ce00e3c8-4dbd-4b1a-8464-e968eedcb106' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 23 AS qty_ordered, 23 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '119cdf25-8155-4994-acf4-29527146f414' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '01e96300-6f59-4679-9519-182b54fa4696',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-24',
  '+90 530 145 11 41',
  'Seed adres (batch 4, #24) Mah. No:6 Sokak:31',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e96300-6f59-4679-9519-182b54fa4696'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e96300-6f59-4679-9519-182b54fa4696'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e96300-6f59-4679-9519-182b54fa4696'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  19,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e96300-6f59-4679-9519-182b54fa4696'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e96300-6f59-4679-9519-182b54fa4696'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '01e96300-6f59-4679-9519-182b54fa4696')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '01e96300-6f59-4679-9519-182b54fa4696',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e96300-6f59-4679-9519-182b54fa4696'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('01e96300-6f59-4679-9519-182b54fa4696'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '830a0bba-88b3-45d7-aa11-3fb92eb3c115' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'ae9d8b6f-bfd2-487a-a9c8-4bec5fa96636' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '1c0d9099-7094-4aa4-b873-3a6f70ab766a',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 04-25',
  '+90 536 837 50 44',
  'Seed adres (batch 4, #25) Mah. No:10 Sokak:37',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c0d9099-7094-4aa4-b873-3a6f70ab766a'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c0d9099-7094-4aa4-b873-3a6f70ab766a'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c0d9099-7094-4aa4-b873-3a6f70ab766a'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  29,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c0d9099-7094-4aa4-b873-3a6f70ab766a'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c0d9099-7094-4aa4-b873-3a6f70ab766a'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '1c0d9099-7094-4aa4-b873-3a6f70ab766a')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '1c0d9099-7094-4aa4-b873-3a6f70ab766a',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c0d9099-7094-4aa4-b873-3a6f70ab766a'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1c0d9099-7094-4aa4-b873-3a6f70ab766a'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'f04188bf-5f24-4433-99ae-5f69fa36886d' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 26 AS qty_ordered, 26 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'fe9a2012-997b-4c61-9a56-1a64670192a9' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
