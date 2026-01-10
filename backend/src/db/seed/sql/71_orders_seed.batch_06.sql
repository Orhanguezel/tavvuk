-- ============================================================================
-- FILE: db/seed/71_orders_seed.batch_06.sql
-- GENERATED — Orders + Order Items (3 months spread) — Batch 06
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
  'c754cd85-b6e3-49d1-8fd5-730165a2d2bc',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-01',
  '+90 531 175 53 31',
  'Seed adres (batch 6, #1) Mah. No:49 Sokak:11',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c754cd85-b6e3-49d1-8fd5-730165a2d2bc'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c754cd85-b6e3-49d1-8fd5-730165a2d2bc'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c754cd85-b6e3-49d1-8fd5-730165a2d2bc'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  32,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c754cd85-b6e3-49d1-8fd5-730165a2d2bc'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c754cd85-b6e3-49d1-8fd5-730165a2d2bc'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'c754cd85-b6e3-49d1-8fd5-730165a2d2bc')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'c754cd85-b6e3-49d1-8fd5-730165a2d2bc',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c754cd85-b6e3-49d1-8fd5-730165a2d2bc'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c754cd85-b6e3-49d1-8fd5-730165a2d2bc'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '35bdbfb7-1ac2-456a-b1d3-15d7c7c9b8ef' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'aa371e37-4d40-4d3b-8e09-f490b894dfdf' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '2842c2c4-bc55-4342-95e5-2363b9dd711a' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '950f776e-2db3-479b-88f1-0ff7b740dd24',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-02',
  '+90 532 721 65 30',
  'Seed adres (batch 6, #2) Mah. No:7 Sokak:7',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('950f776e-2db3-479b-88f1-0ff7b740dd24'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('950f776e-2db3-479b-88f1-0ff7b740dd24'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('950f776e-2db3-479b-88f1-0ff7b740dd24'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  27,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('950f776e-2db3-479b-88f1-0ff7b740dd24'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('950f776e-2db3-479b-88f1-0ff7b740dd24'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '950f776e-2db3-479b-88f1-0ff7b740dd24')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '950f776e-2db3-479b-88f1-0ff7b740dd24',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('950f776e-2db3-479b-88f1-0ff7b740dd24'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('950f776e-2db3-479b-88f1-0ff7b740dd24'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '423cb061-ee67-4340-88d0-9ec502b196b7' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 18 AS qty_ordered, 18 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '2ae64991-ba8c-4637-8729-527a62c7c402' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '3bf5d34b-12d5-4fa4-8a12-a975f7653ce5',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-03',
  '+90 534 343 22 16',
  'Seed adres (batch 6, #3) Mah. No:51 Sokak:37',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3bf5d34b-12d5-4fa4-8a12-a975f7653ce5'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3bf5d34b-12d5-4fa4-8a12-a975f7653ce5'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3bf5d34b-12d5-4fa4-8a12-a975f7653ce5'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3bf5d34b-12d5-4fa4-8a12-a975f7653ce5'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3bf5d34b-12d5-4fa4-8a12-a975f7653ce5'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '3bf5d34b-12d5-4fa4-8a12-a975f7653ce5')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '3bf5d34b-12d5-4fa4-8a12-a975f7653ce5',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3bf5d34b-12d5-4fa4-8a12-a975f7653ce5'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3bf5d34b-12d5-4fa4-8a12-a975f7653ce5'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'b28564fe-e649-4cfb-a9d7-8195519cc977' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a23bdc99-74be-4b58-a8b4-be0f1aeaa09a' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '46400124-81c4-4481-bb37-48f37976bd3f' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '4fc04ca0-055a-482f-984f-80114d4c8bb7',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '23232323-2323-4232-8232-232323232323',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-04',
  '+90 539 591 35 22',
  'Seed adres (batch 6, #4) Mah. No:4 Sokak:14',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4fc04ca0-055a-482f-984f-80114d4c8bb7'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4fc04ca0-055a-482f-984f-80114d4c8bb7'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4fc04ca0-055a-482f-984f-80114d4c8bb7'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4fc04ca0-055a-482f-984f-80114d4c8bb7'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '4fc04ca0-055a-482f-984f-80114d4c8bb7')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '4fc04ca0-055a-482f-984f-80114d4c8bb7',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4fc04ca0-055a-482f-984f-80114d4c8bb7'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4fc04ca0-055a-482f-984f-80114d4c8bb7'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '037d77d1-3c06-4a89-8b93-25f3db9d62fe' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '63d88931-9ce4-41bc-819d-8640f28a0688' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 5 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '2bb6e833-3f8c-4d02-a57f-9062da05d104',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '34343434-3434-4343-8343-343434343434',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-05',
  '+90 534 193 92 79',
  'Seed adres (batch 6, #5) Mah. No:50 Sokak:12',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bb6e833-3f8c-4d02-a57f-9062da05d104'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bb6e833-3f8c-4d02-a57f-9062da05d104'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bb6e833-3f8c-4d02-a57f-9062da05d104'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bb6e833-3f8c-4d02-a57f-9062da05d104'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '2bb6e833-3f8c-4d02-a57f-9062da05d104')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '2bb6e833-3f8c-4d02-a57f-9062da05d104',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bb6e833-3f8c-4d02-a57f-9062da05d104'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bb6e833-3f8c-4d02-a57f-9062da05d104'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'a613a638-939e-440d-91b2-351fef7c86eb' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 16 AS qty_ordered, 5 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '805db2a2-f79f-4b7e-a859-7033eca007ae' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '25946fbe-dec4-42d8-bf7e-17e436415ba0',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-06',
  '+90 534 677 17 29',
  'Seed adres (batch 6, #6) Mah. No:97 Sokak:45',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('25946fbe-dec4-42d8-bf7e-17e436415ba0'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('25946fbe-dec4-42d8-bf7e-17e436415ba0'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('25946fbe-dec4-42d8-bf7e-17e436415ba0'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  46,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('25946fbe-dec4-42d8-bf7e-17e436415ba0'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('25946fbe-dec4-42d8-bf7e-17e436415ba0'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '25946fbe-dec4-42d8-bf7e-17e436415ba0')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '25946fbe-dec4-42d8-bf7e-17e436415ba0',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('25946fbe-dec4-42d8-bf7e-17e436415ba0'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('25946fbe-dec4-42d8-bf7e-17e436415ba0'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'e1b97352-3617-4996-a1f5-092e597adc2d' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 26 AS qty_ordered, 26 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '67d4a7a9-4f40-4544-a550-41c58bd13972' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'eaccf827-a5b3-4dd5-803c-341271d3ae5a' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-07',
  '+90 536 938 76 63',
  'Seed adres (batch 6, #7) Mah. No:69 Sokak:44',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  33,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a7d5f44b-a817-4e5f-b66a-1c5f540b7ec0'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'c9ac8224-cab6-4863-a2ab-ac5053105591' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 23 AS qty_ordered, 23 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '0906331b-3646-436e-9275-ef9e36f89ed2' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '20e1e9aa-fe03-49f1-86ef-9257485ff1bc' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '53e0f091-770c-4c8c-89ea-333a46d6d86b',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-08',
  '+90 538 919 83 96',
  'Seed adres (batch 6, #8) Mah. No:80 Sokak:10',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('53e0f091-770c-4c8c-89ea-333a46d6d86b'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('53e0f091-770c-4c8c-89ea-333a46d6d86b'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('53e0f091-770c-4c8c-89ea-333a46d6d86b'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  14,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('53e0f091-770c-4c8c-89ea-333a46d6d86b'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('53e0f091-770c-4c8c-89ea-333a46d6d86b'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '53e0f091-770c-4c8c-89ea-333a46d6d86b')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '53e0f091-770c-4c8c-89ea-333a46d6d86b',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('53e0f091-770c-4c8c-89ea-333a46d6d86b'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('53e0f091-770c-4c8c-89ea-333a46d6d86b'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '48e06136-91e0-4998-9099-0c23fd09989a' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '6197c7d1-0570-4f8b-bce4-c839d269dc6c' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-09',
  '+90 531 799 65 35',
  'Seed adres (batch 6, #9) Mah. No:81 Sokak:10',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  32,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('486cf4c5-8bc2-4925-9d7f-b5fb7631a1a1'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '994928ce-add5-4c91-a556-bfcec85bbaf1' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '6c298911-75fc-4a21-80c4-835f72134868' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '855d5a38-2f25-4d0c-98de-3434de031302' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'a57e3525-9d08-409a-90b8-fd78d7c3cd53',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-10',
  '+90 535 977 45 76',
  'Seed adres (batch 6, #10) Mah. No:59 Sokak:1',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a57e3525-9d08-409a-90b8-fd78d7c3cd53'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a57e3525-9d08-409a-90b8-fd78d7c3cd53'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a57e3525-9d08-409a-90b8-fd78d7c3cd53'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  38,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a57e3525-9d08-409a-90b8-fd78d7c3cd53'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a57e3525-9d08-409a-90b8-fd78d7c3cd53'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'a57e3525-9d08-409a-90b8-fd78d7c3cd53')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'a57e3525-9d08-409a-90b8-fd78d7c3cd53',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a57e3525-9d08-409a-90b8-fd78d7c3cd53'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a57e3525-9d08-409a-90b8-fd78d7c3cd53'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '2422161c-40db-4544-82f8-4cd63afe0886' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 23 AS qty_ordered, 23 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '1a531284-588d-4ae1-a95c-65c14c4f78da' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'c16c7be9-f87b-4189-aaa4-ad2e2b01f7d3' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '76ca368e-c266-476e-9d38-3f605481a1a8',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-11',
  '+90 539 696 22 23',
  'Seed adres (batch 6, #11) Mah. No:73 Sokak:50',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('76ca368e-c266-476e-9d38-3f605481a1a8'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('76ca368e-c266-476e-9d38-3f605481a1a8'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('76ca368e-c266-476e-9d38-3f605481a1a8'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  37,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('76ca368e-c266-476e-9d38-3f605481a1a8'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('76ca368e-c266-476e-9d38-3f605481a1a8'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '76ca368e-c266-476e-9d38-3f605481a1a8')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '76ca368e-c266-476e-9d38-3f605481a1a8',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('76ca368e-c266-476e-9d38-3f605481a1a8'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('76ca368e-c266-476e-9d38-3f605481a1a8'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '2b951dd0-2326-4bff-807d-35bf9915b460' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 22 AS qty_ordered, 22 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'd86b493c-e54e-4f5b-a316-7563d872dfbc' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'adcd85f0-988c-499c-9b00-78599639671e',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-12',
  '+90 537 685 87 70',
  'Seed adres (batch 6, #12) Mah. No:5 Sokak:12',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('adcd85f0-988c-499c-9b00-78599639671e'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('adcd85f0-988c-499c-9b00-78599639671e'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('adcd85f0-988c-499c-9b00-78599639671e'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  35,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('adcd85f0-988c-499c-9b00-78599639671e'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('adcd85f0-988c-499c-9b00-78599639671e'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'adcd85f0-988c-499c-9b00-78599639671e')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'adcd85f0-988c-499c-9b00-78599639671e',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('adcd85f0-988c-499c-9b00-78599639671e'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('adcd85f0-988c-499c-9b00-78599639671e'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'c78e66df-2bc4-4e92-b3bc-077640e82dbc' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 24 AS qty_ordered, 24 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '9ff44e01-d990-4274-b8c1-d057f3456adb' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '1001f45b-243f-4f9d-a88b-a0cc8dc722a2',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-13',
  '+90 535 807 40 16',
  'Seed adres (batch 6, #13) Mah. No:96 Sokak:31',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1001f45b-243f-4f9d-a88b-a0cc8dc722a2'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1001f45b-243f-4f9d-a88b-a0cc8dc722a2'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1001f45b-243f-4f9d-a88b-a0cc8dc722a2'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  24,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1001f45b-243f-4f9d-a88b-a0cc8dc722a2'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1001f45b-243f-4f9d-a88b-a0cc8dc722a2'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '1001f45b-243f-4f9d-a88b-a0cc8dc722a2')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '1001f45b-243f-4f9d-a88b-a0cc8dc722a2',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1001f45b-243f-4f9d-a88b-a0cc8dc722a2'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1001f45b-243f-4f9d-a88b-a0cc8dc722a2'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '6ba61e5e-b2a5-42af-9077-aed9a48c7d4b' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '43eb5c78-60d5-4db5-91e5-a92354262e51' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '902efbf2-02a1-4000-a8b6-50f5b8a985bf' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'da1fadb6-91f7-4510-bc67-4f3283ea8d6a',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-14',
  '+90 531 989 39 27',
  'Seed adres (batch 6, #14) Mah. No:39 Sokak:48',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('da1fadb6-91f7-4510-bc67-4f3283ea8d6a'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('da1fadb6-91f7-4510-bc67-4f3283ea8d6a'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('da1fadb6-91f7-4510-bc67-4f3283ea8d6a'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('da1fadb6-91f7-4510-bc67-4f3283ea8d6a'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'da1fadb6-91f7-4510-bc67-4f3283ea8d6a')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'da1fadb6-91f7-4510-bc67-4f3283ea8d6a',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('da1fadb6-91f7-4510-bc67-4f3283ea8d6a'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('da1fadb6-91f7-4510-bc67-4f3283ea8d6a'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '3e743e88-5f00-4b4a-adff-4bfca6fd27a8' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 13 AS qty_ordered, 11 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'bd649cac-f1c4-48cc-83a7-72fce27c6dd6' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '2bfd6a2a-4b4f-404c-adf6-14ff2409d85a',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-15',
  '+90 536 858 72 76',
  'Seed adres (batch 6, #15) Mah. No:48 Sokak:4',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bfd6a2a-4b4f-404c-adf6-14ff2409d85a'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bfd6a2a-4b4f-404c-adf6-14ff2409d85a'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bfd6a2a-4b4f-404c-adf6-14ff2409d85a'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  26,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bfd6a2a-4b4f-404c-adf6-14ff2409d85a'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bfd6a2a-4b4f-404c-adf6-14ff2409d85a'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '2bfd6a2a-4b4f-404c-adf6-14ff2409d85a')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '2bfd6a2a-4b4f-404c-adf6-14ff2409d85a',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bfd6a2a-4b4f-404c-adf6-14ff2409d85a'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('2bfd6a2a-4b4f-404c-adf6-14ff2409d85a'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '5da1d022-9040-47f3-8e63-32bdf8f5adbc' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '812dcac7-47a0-4734-a834-b31380ef4361' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '49f06ce1-7a17-4b92-98e9-fd5bca76c625' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'b4155089-4fc3-4ecc-8e76-bbbbe0b7fb24',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '45454545-4545-4454-8454-454545454545',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-16',
  '+90 530 277 34 35',
  'Seed adres (batch 6, #16) Mah. No:8 Sokak:16',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b4155089-4fc3-4ecc-8e76-bbbbe0b7fb24'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b4155089-4fc3-4ecc-8e76-bbbbe0b7fb24'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b4155089-4fc3-4ecc-8e76-bbbbe0b7fb24'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b4155089-4fc3-4ecc-8e76-bbbbe0b7fb24'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'b4155089-4fc3-4ecc-8e76-bbbbe0b7fb24')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'b4155089-4fc3-4ecc-8e76-bbbbe0b7fb24',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b4155089-4fc3-4ecc-8e76-bbbbe0b7fb24'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b4155089-4fc3-4ecc-8e76-bbbbe0b7fb24'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'fb77b820-1fba-43bf-bfe6-0fc697efa71f' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 16 AS qty_ordered, 6 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'a643ffe3-1114-4a18-8c53-20127473622e' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '28039144-cbce-429d-b5a3-b7d43f9270b4',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-17',
  '+90 531 797 13 40',
  'Seed adres (batch 6, #17) Mah. No:48 Sokak:32',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('28039144-cbce-429d-b5a3-b7d43f9270b4'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('28039144-cbce-429d-b5a3-b7d43f9270b4'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('28039144-cbce-429d-b5a3-b7d43f9270b4'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  35,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('28039144-cbce-429d-b5a3-b7d43f9270b4'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('28039144-cbce-429d-b5a3-b7d43f9270b4'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '28039144-cbce-429d-b5a3-b7d43f9270b4')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '28039144-cbce-429d-b5a3-b7d43f9270b4',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('28039144-cbce-429d-b5a3-b7d43f9270b4'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('28039144-cbce-429d-b5a3-b7d43f9270b4'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '04a2bcec-a454-4218-af60-319d0b566a1d' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 20 AS qty_ordered, 20 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '436e10f7-dc43-4477-b682-424fa4faf39c' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'b118f8e2-3840-4e44-a016-98f44796efee' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'f49e19ca-de45-442f-a28f-a057e7c9333b',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-18',
  '+90 531 391 13 59',
  'Seed adres (batch 6, #18) Mah. No:7 Sokak:11',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f49e19ca-de45-442f-a28f-a057e7c9333b'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f49e19ca-de45-442f-a28f-a057e7c9333b'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f49e19ca-de45-442f-a28f-a057e7c9333b'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  20,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f49e19ca-de45-442f-a28f-a057e7c9333b'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f49e19ca-de45-442f-a28f-a057e7c9333b'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'f49e19ca-de45-442f-a28f-a057e7c9333b')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'f49e19ca-de45-442f-a28f-a057e7c9333b',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f49e19ca-de45-442f-a28f-a057e7c9333b'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('f49e19ca-de45-442f-a28f-a057e7c9333b'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '19e20e46-71f9-4bc4-a08b-5b06adbb196a' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '546d0ee3-1dc2-4bc4-8f19-9e96b206c299' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '458f9b6b-673d-4599-8997-b22a85430ebb' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 4 AS qty_ordered, 4 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '315dbee7-13e5-4daf-90ff-3f42a3e87619',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-19',
  '+90 530 585 26 92',
  'Seed adres (batch 6, #19) Mah. No:23 Sokak:39',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('315dbee7-13e5-4daf-90ff-3f42a3e87619'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('315dbee7-13e5-4daf-90ff-3f42a3e87619'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('315dbee7-13e5-4daf-90ff-3f42a3e87619'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  38,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('315dbee7-13e5-4daf-90ff-3f42a3e87619'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('315dbee7-13e5-4daf-90ff-3f42a3e87619'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '315dbee7-13e5-4daf-90ff-3f42a3e87619')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '315dbee7-13e5-4daf-90ff-3f42a3e87619',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('315dbee7-13e5-4daf-90ff-3f42a3e87619'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('315dbee7-13e5-4daf-90ff-3f42a3e87619'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '6a54d179-0c57-4acf-95ee-baacb11953d8' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '0ec64e3e-bb4d-47a0-b49d-b3df7e73b92b' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '57648305-64d6-44eb-83e3-edd9ab54ad31' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '5952fd8b-0644-48d5-b788-59177da61e9f',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '34343434-3434-4343-8343-343434343434',
  'on_delivery',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-20',
  '+90 535 570 42 37',
  'Seed adres (batch 6, #20) Mah. No:60 Sokak:20',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5952fd8b-0644-48d5-b788-59177da61e9f'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5952fd8b-0644-48d5-b788-59177da61e9f'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5952fd8b-0644-48d5-b788-59177da61e9f'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5952fd8b-0644-48d5-b788-59177da61e9f'), 90) DAY) + INTERVAL 4 HOUR
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '5952fd8b-0644-48d5-b788-59177da61e9f')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '5952fd8b-0644-48d5-b788-59177da61e9f',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5952fd8b-0644-48d5-b788-59177da61e9f'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5952fd8b-0644-48d5-b788-59177da61e9f'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '54db0737-f941-4a6b-b91c-857cd7a945c0' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 17 AS qty_ordered, 3 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '5429c745-871a-4345-aa37-bea05dae3008' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '55306c1f-06eb-4c31-acc2-8de15ccc2c23' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 11 AS qty_ordered, 9 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '0ba7eeef-8e8b-4ce3-a377-3e89a42126d7',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-21',
  '+90 531 593 18 53',
  'Seed adres (batch 6, #21) Mah. No:36 Sokak:41',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0ba7eeef-8e8b-4ce3-a377-3e89a42126d7'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0ba7eeef-8e8b-4ce3-a377-3e89a42126d7'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0ba7eeef-8e8b-4ce3-a377-3e89a42126d7'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  25,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0ba7eeef-8e8b-4ce3-a377-3e89a42126d7'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0ba7eeef-8e8b-4ce3-a377-3e89a42126d7'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '0ba7eeef-8e8b-4ce3-a377-3e89a42126d7')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '0ba7eeef-8e8b-4ce3-a377-3e89a42126d7',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0ba7eeef-8e8b-4ce3-a377-3e89a42126d7'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0ba7eeef-8e8b-4ce3-a377-3e89a42126d7'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '64d12d4f-de7a-4263-a29d-1ca428cccf1f' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '92a96bf0-2f2d-4cdd-9bae-f8fa28c99771' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '5cba6dd3-0f94-4245-93f3-fa621563c530',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-22',
  '+90 533 158 86 61',
  'Seed adres (batch 6, #22) Mah. No:85 Sokak:21',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5cba6dd3-0f94-4245-93f3-fa621563c530'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5cba6dd3-0f94-4245-93f3-fa621563c530'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5cba6dd3-0f94-4245-93f3-fa621563c530'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  18,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5cba6dd3-0f94-4245-93f3-fa621563c530'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5cba6dd3-0f94-4245-93f3-fa621563c530'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '5cba6dd3-0f94-4245-93f3-fa621563c530')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '5cba6dd3-0f94-4245-93f3-fa621563c530',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5cba6dd3-0f94-4245-93f3-fa621563c530'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('5cba6dd3-0f94-4245-93f3-fa621563c530'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '1cf4095c-38dc-49a7-b72e-eea832ced3be' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'c26daefc-902a-4591-b2ba-0e3b8e3edf57' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'f8d8a4b8-67f0-4eba-b2b1-62032d7c2e2d' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '9fbcc250-1e20-4d15-834e-b234eb2eacf0',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-23',
  '+90 530 697 83 34',
  'Seed adres (batch 6, #23) Mah. No:44 Sokak:47',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9fbcc250-1e20-4d15-834e-b234eb2eacf0'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9fbcc250-1e20-4d15-834e-b234eb2eacf0'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9fbcc250-1e20-4d15-834e-b234eb2eacf0'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  50,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9fbcc250-1e20-4d15-834e-b234eb2eacf0'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9fbcc250-1e20-4d15-834e-b234eb2eacf0'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '9fbcc250-1e20-4d15-834e-b234eb2eacf0')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '9fbcc250-1e20-4d15-834e-b234eb2eacf0',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9fbcc250-1e20-4d15-834e-b234eb2eacf0'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9fbcc250-1e20-4d15-834e-b234eb2eacf0'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '39eb91ff-f3d6-438d-812f-903ae58a04a2' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 22 AS qty_ordered, 22 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '54ba4902-dd59-4070-b7bf-94841a44083c' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'f5dc76ec-993f-4a02-8f6e-6b1f0e69093f' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '1b540587-3dcd-4ee6-87f2-cf07f008b7a8',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-24',
  '+90 532 960 94 81',
  'Seed adres (batch 6, #24) Mah. No:24 Sokak:19',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1b540587-3dcd-4ee6-87f2-cf07f008b7a8'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1b540587-3dcd-4ee6-87f2-cf07f008b7a8'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1b540587-3dcd-4ee6-87f2-cf07f008b7a8'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  40,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1b540587-3dcd-4ee6-87f2-cf07f008b7a8'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1b540587-3dcd-4ee6-87f2-cf07f008b7a8'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '1b540587-3dcd-4ee6-87f2-cf07f008b7a8')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '1b540587-3dcd-4ee6-87f2-cf07f008b7a8',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1b540587-3dcd-4ee6-87f2-cf07f008b7a8'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('1b540587-3dcd-4ee6-87f2-cf07f008b7a8'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '36485ddd-6053-4013-9f3c-1e6aa80439a9' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '15f73ef0-3c3b-445b-b7f3-0862e680974f' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '4350693b-a8f2-4d67-b6d0-a9f03a4fa049',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '12121212-1212-4121-8121-121212121212',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 06-25',
  '+90 535 770 21 38',
  'Seed adres (batch 6, #25) Mah. No:46 Sokak:15',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4350693b-a8f2-4d67-b6d0-a9f03a4fa049'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4350693b-a8f2-4d67-b6d0-a9f03a4fa049'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4350693b-a8f2-4d67-b6d0-a9f03a4fa049'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4350693b-a8f2-4d67-b6d0-a9f03a4fa049'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '4350693b-a8f2-4d67-b6d0-a9f03a4fa049')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '4350693b-a8f2-4d67-b6d0-a9f03a4fa049',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4350693b-a8f2-4d67-b6d0-a9f03a4fa049'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4350693b-a8f2-4d67-b6d0-a9f03a4fa049'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'fc1971ad-8b0b-485b-b2d6-907ae3443cb9' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 18 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'dd3c084b-0a64-486b-a3d4-22b9889d9b25' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 6 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'b1651966-2c21-47e6-8875-54bca6ff5f95' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 10 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
