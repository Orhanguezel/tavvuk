-- ============================================================================
-- FILE: db/seed/71_orders_seed.batch_03.sql
-- GENERATED — Orders + Order Items (3 months spread) — Batch 03
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
  '51f2741e-3978-4990-80c3-eb3576df6d8f',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-01',
  '+90 536 793 79 52',
  'Seed adres (batch 3, #1) Mah. No:50 Sokak:49',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('51f2741e-3978-4990-80c3-eb3576df6d8f'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('51f2741e-3978-4990-80c3-eb3576df6d8f'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('51f2741e-3978-4990-80c3-eb3576df6d8f'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  43,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('51f2741e-3978-4990-80c3-eb3576df6d8f'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('51f2741e-3978-4990-80c3-eb3576df6d8f'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '51f2741e-3978-4990-80c3-eb3576df6d8f')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '51f2741e-3978-4990-80c3-eb3576df6d8f',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('51f2741e-3978-4990-80c3-eb3576df6d8f'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('51f2741e-3978-4990-80c3-eb3576df6d8f'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '652a360b-8ef7-4a05-b319-0f8748afed64' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'ffc36a1e-b7a5-4220-8cd3-44aa53923a1d' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 9 AS qty_ordered, 9 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '26ce9954-5c7a-40c1-8aa6-880650bc77f1' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '61e8a594-5e00-4f40-959f-2699bfb2818c',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-02',
  '+90 531 448 87 88',
  'Seed adres (batch 3, #2) Mah. No:77 Sokak:26',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('61e8a594-5e00-4f40-959f-2699bfb2818c'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('61e8a594-5e00-4f40-959f-2699bfb2818c'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('61e8a594-5e00-4f40-959f-2699bfb2818c'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  18,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('61e8a594-5e00-4f40-959f-2699bfb2818c'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('61e8a594-5e00-4f40-959f-2699bfb2818c'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '61e8a594-5e00-4f40-959f-2699bfb2818c')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '61e8a594-5e00-4f40-959f-2699bfb2818c',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('61e8a594-5e00-4f40-959f-2699bfb2818c'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('61e8a594-5e00-4f40-959f-2699bfb2818c'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'c1c037d7-01fc-4c31-b1d1-813365babb5d' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '1ab5e024-154e-44fe-a067-ba8dd191823b' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'b5291b7e-15fc-4557-9eb7-e6b8b4cad793' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'a1bcb617-0d0f-442e-ac0e-fe0ef348c896',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-03',
  '+90 536 542 33 97',
  'Seed adres (batch 3, #3) Mah. No:75 Sokak:43',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a1bcb617-0d0f-442e-ac0e-fe0ef348c896'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a1bcb617-0d0f-442e-ac0e-fe0ef348c896'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a1bcb617-0d0f-442e-ac0e-fe0ef348c896'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  26,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a1bcb617-0d0f-442e-ac0e-fe0ef348c896'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a1bcb617-0d0f-442e-ac0e-fe0ef348c896'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'a1bcb617-0d0f-442e-ac0e-fe0ef348c896')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'a1bcb617-0d0f-442e-ac0e-fe0ef348c896',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a1bcb617-0d0f-442e-ac0e-fe0ef348c896'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a1bcb617-0d0f-442e-ac0e-fe0ef348c896'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '5d22d3cb-ee86-4d3e-b1a4-9332ce7d0d1e' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'c63a5335-0e50-4e97-baac-b91bbc3d134c' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '779f8732-468c-49ea-9932-a1822c0400af',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-04',
  '+90 536 828 91 29',
  'Seed adres (batch 3, #4) Mah. No:95 Sokak:25',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('779f8732-468c-49ea-9932-a1822c0400af'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('779f8732-468c-49ea-9932-a1822c0400af'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('779f8732-468c-49ea-9932-a1822c0400af'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  12,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('779f8732-468c-49ea-9932-a1822c0400af'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('779f8732-468c-49ea-9932-a1822c0400af'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '779f8732-468c-49ea-9932-a1822c0400af')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '779f8732-468c-49ea-9932-a1822c0400af',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('779f8732-468c-49ea-9932-a1822c0400af'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('779f8732-468c-49ea-9932-a1822c0400af'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '7c6160bc-02b1-471d-b6ad-578d87536b4c' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '7b10c95b-dc16-4076-a45c-cc1e773bc916' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '96159da4-179a-4be7-8082-da90c5507f3b',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-05',
  '+90 531 235 21 33',
  'Seed adres (batch 3, #5) Mah. No:56 Sokak:29',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('96159da4-179a-4be7-8082-da90c5507f3b'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('96159da4-179a-4be7-8082-da90c5507f3b'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('96159da4-179a-4be7-8082-da90c5507f3b'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  25,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('96159da4-179a-4be7-8082-da90c5507f3b'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('96159da4-179a-4be7-8082-da90c5507f3b'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '96159da4-179a-4be7-8082-da90c5507f3b')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '96159da4-179a-4be7-8082-da90c5507f3b',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('96159da4-179a-4be7-8082-da90c5507f3b'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('96159da4-179a-4be7-8082-da90c5507f3b'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '4ca074da-ade2-412f-a05a-c703e68b628f' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 18 AS qty_ordered, 18 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '15f53eb3-54cb-40af-a0b7-74ccbdc126f0' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'f9529470-11c6-430d-9153-4799157c2193' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'b72bd9dc-92fd-4138-9b60-25d97d59d84e',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-06',
  '+90 535 984 59 11',
  'Seed adres (batch 3, #6) Mah. No:38 Sokak:27',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b72bd9dc-92fd-4138-9b60-25d97d59d84e'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b72bd9dc-92fd-4138-9b60-25d97d59d84e'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b72bd9dc-92fd-4138-9b60-25d97d59d84e'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  43,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b72bd9dc-92fd-4138-9b60-25d97d59d84e'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b72bd9dc-92fd-4138-9b60-25d97d59d84e'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'b72bd9dc-92fd-4138-9b60-25d97d59d84e')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'b72bd9dc-92fd-4138-9b60-25d97d59d84e',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b72bd9dc-92fd-4138-9b60-25d97d59d84e'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('b72bd9dc-92fd-4138-9b60-25d97d59d84e'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'de8687fd-2ab5-4097-80c1-b122f09167d9' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '5309d3cd-e239-4584-b9f9-bbd0902b4d7c' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '4d3896db-6306-4544-941b-036de4ff7ebe',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-07',
  '+90 536 273 27 44',
  'Seed adres (batch 3, #7) Mah. No:39 Sokak:18',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4d3896db-6306-4544-941b-036de4ff7ebe'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4d3896db-6306-4544-941b-036de4ff7ebe'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4d3896db-6306-4544-941b-036de4ff7ebe'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  15,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4d3896db-6306-4544-941b-036de4ff7ebe'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4d3896db-6306-4544-941b-036de4ff7ebe'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '4d3896db-6306-4544-941b-036de4ff7ebe')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '4d3896db-6306-4544-941b-036de4ff7ebe',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4d3896db-6306-4544-941b-036de4ff7ebe'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('4d3896db-6306-4544-941b-036de4ff7ebe'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '373de22a-4be9-4161-b69c-062049282339' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '26ecacd8-6e5b-485b-9979-925a5b767822' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'c4c4dc7c-6176-4141-a429-46cd1222ef15',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-08',
  '+90 531 469 42 41',
  'Seed adres (batch 3, #8) Mah. No:93 Sokak:41',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c4c4dc7c-6176-4141-a429-46cd1222ef15'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c4c4dc7c-6176-4141-a429-46cd1222ef15'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c4c4dc7c-6176-4141-a429-46cd1222ef15'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  13,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c4c4dc7c-6176-4141-a429-46cd1222ef15'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c4c4dc7c-6176-4141-a429-46cd1222ef15'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'c4c4dc7c-6176-4141-a429-46cd1222ef15')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'c4c4dc7c-6176-4141-a429-46cd1222ef15',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c4c4dc7c-6176-4141-a429-46cd1222ef15'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('c4c4dc7c-6176-4141-a429-46cd1222ef15'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '59ef4c61-128f-4eb4-a733-c95511f5f179' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'dcb95988-e8e0-41cc-8714-0c90fc07651f' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '032b7849-6be5-4b32-a82a-dd4f65385ff6',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-09',
  '+90 536 440 89 58',
  'Seed adres (batch 3, #9) Mah. No:43 Sokak:29',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('032b7849-6be5-4b32-a82a-dd4f65385ff6'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('032b7849-6be5-4b32-a82a-dd4f65385ff6'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('032b7849-6be5-4b32-a82a-dd4f65385ff6'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  29,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('032b7849-6be5-4b32-a82a-dd4f65385ff6'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('032b7849-6be5-4b32-a82a-dd4f65385ff6'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '032b7849-6be5-4b32-a82a-dd4f65385ff6')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '032b7849-6be5-4b32-a82a-dd4f65385ff6',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('032b7849-6be5-4b32-a82a-dd4f65385ff6'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('032b7849-6be5-4b32-a82a-dd4f65385ff6'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'a6ee2047-560f-4b87-8e69-da506dc8e378' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 24 AS qty_ordered, 24 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '21233097-5b02-4058-8692-5216354da8ef' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '69a69a69-b7c1-410e-8c4c-9d30335fae28',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '45454545-4545-4454-8454-454545454545',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-10',
  '+90 533 590 50 32',
  'Seed adres (batch 3, #10) Mah. No:51 Sokak:21',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('69a69a69-b7c1-410e-8c4c-9d30335fae28'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('69a69a69-b7c1-410e-8c4c-9d30335fae28'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('69a69a69-b7c1-410e-8c4c-9d30335fae28'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('69a69a69-b7c1-410e-8c4c-9d30335fae28'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '69a69a69-b7c1-410e-8c4c-9d30335fae28')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '69a69a69-b7c1-410e-8c4c-9d30335fae28',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('69a69a69-b7c1-410e-8c4c-9d30335fae28'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('69a69a69-b7c1-410e-8c4c-9d30335fae28'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'a52be773-5221-4c05-b40a-fad1799c21ea' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 25 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'e04855b3-790e-4ede-8742-9bee0e516f03' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 10 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'dbc39cca-241b-4595-ac2d-90ccff83bae9',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-11',
  '+90 536 473 24 82',
  'Seed adres (batch 3, #11) Mah. No:26 Sokak:38',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dbc39cca-241b-4595-ac2d-90ccff83bae9'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dbc39cca-241b-4595-ac2d-90ccff83bae9'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dbc39cca-241b-4595-ac2d-90ccff83bae9'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  35,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dbc39cca-241b-4595-ac2d-90ccff83bae9'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dbc39cca-241b-4595-ac2d-90ccff83bae9'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'dbc39cca-241b-4595-ac2d-90ccff83bae9')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'dbc39cca-241b-4595-ac2d-90ccff83bae9',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dbc39cca-241b-4595-ac2d-90ccff83bae9'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('dbc39cca-241b-4595-ac2d-90ccff83bae9'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '70b81e02-8a3a-4599-9cf3-abdcfc0c3f7f' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 26 AS qty_ordered, 26 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '0cb79292-e80e-4679-9953-3830420430cc' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '76b261c1-1ff5-4762-a3d4-13d849e000b1' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '7fed18a6-2d24-424d-a8be-0d46b6243f32',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-12',
  '+90 531 938 62 96',
  'Seed adres (batch 3, #12) Mah. No:64 Sokak:9',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7fed18a6-2d24-424d-a8be-0d46b6243f32'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7fed18a6-2d24-424d-a8be-0d46b6243f32'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7fed18a6-2d24-424d-a8be-0d46b6243f32'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  23,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7fed18a6-2d24-424d-a8be-0d46b6243f32'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7fed18a6-2d24-424d-a8be-0d46b6243f32'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '7fed18a6-2d24-424d-a8be-0d46b6243f32')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '7fed18a6-2d24-424d-a8be-0d46b6243f32',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7fed18a6-2d24-424d-a8be-0d46b6243f32'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('7fed18a6-2d24-424d-a8be-0d46b6243f32'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'a9e98b8a-0ef5-456d-856d-193ad6102144' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '845ce2c4-c3d9-4324-83b5-85d14897bd92' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '35364112-b150-4bab-bf03-cc41819a3792' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '014fd790-7e92-4f3c-8a6c-ca0432ecb472',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-13',
  '+90 539 590 84 61',
  'Seed adres (batch 3, #13) Mah. No:69 Sokak:33',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('014fd790-7e92-4f3c-8a6c-ca0432ecb472'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('014fd790-7e92-4f3c-8a6c-ca0432ecb472'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('014fd790-7e92-4f3c-8a6c-ca0432ecb472'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  31,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('014fd790-7e92-4f3c-8a6c-ca0432ecb472'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('014fd790-7e92-4f3c-8a6c-ca0432ecb472'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '014fd790-7e92-4f3c-8a6c-ca0432ecb472')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '014fd790-7e92-4f3c-8a6c-ca0432ecb472',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('014fd790-7e92-4f3c-8a6c-ca0432ecb472'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('014fd790-7e92-4f3c-8a6c-ca0432ecb472'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '693869ce-8c5d-46aa-9c17-d28008b5d8d6' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 18 AS qty_ordered, 18 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'aac19069-3a1c-487c-a6b6-6fd9a0be6871' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 1 AS qty_ordered, 1 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'c72f6396-bcdc-456c-868a-66e05914e96c' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'e1247338-ec95-4908-a1e6-95aff0db89ad',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-14',
  '+90 531 211 41 94',
  'Seed adres (batch 3, #14) Mah. No:86 Sokak:23',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e1247338-ec95-4908-a1e6-95aff0db89ad'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e1247338-ec95-4908-a1e6-95aff0db89ad'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e1247338-ec95-4908-a1e6-95aff0db89ad'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  17,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e1247338-ec95-4908-a1e6-95aff0db89ad'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e1247338-ec95-4908-a1e6-95aff0db89ad'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'e1247338-ec95-4908-a1e6-95aff0db89ad')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'e1247338-ec95-4908-a1e6-95aff0db89ad',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e1247338-ec95-4908-a1e6-95aff0db89ad'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('e1247338-ec95-4908-a1e6-95aff0db89ad'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '0f57b9a7-8162-4273-a7fb-ed43b2fefb1b' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 6 AS qty_ordered, 6 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'edff6d76-847c-4e48-af57-b534f3549424' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'db16f4a7-400c-4eeb-ae65-467d0570e8a2',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'assigned',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-15',
  '+90 536 208 11 22',
  'Seed adres (batch 3, #15) Mah. No:34 Sokak:15',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('db16f4a7-400c-4eeb-ae65-467d0570e8a2'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('db16f4a7-400c-4eeb-ae65-467d0570e8a2'), 90) DAY) + INTERVAL 2 HOUR,
  NULL,
  NULL,
  0,
  0,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('db16f4a7-400c-4eeb-ae65-467d0570e8a2'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('db16f4a7-400c-4eeb-ae65-467d0570e8a2'), 90) DAY) + INTERVAL 2 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'db16f4a7-400c-4eeb-ae65-467d0570e8a2')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'db16f4a7-400c-4eeb-ae65-467d0570e8a2',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('db16f4a7-400c-4eeb-ae65-467d0570e8a2'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('db16f4a7-400c-4eeb-ae65-467d0570e8a2'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '0e34edef-2a0c-410c-a554-2823f3bb2e83' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 22 AS qty_ordered, 0 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '3505dbde-fcf8-482f-bed9-bea27dd6f92a' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 12 AS qty_ordered, 0 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '81b8fc2c-a9ec-4245-ac3b-65717042e555' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 4 AS qty_ordered, 0 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '9440d131-fa8e-416c-9fb7-44693f0b72aa',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-16',
  '+90 539 807 74 29',
  'Seed adres (batch 3, #16) Mah. No:45 Sokak:2',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9440d131-fa8e-416c-9fb7-44693f0b72aa'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9440d131-fa8e-416c-9fb7-44693f0b72aa'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9440d131-fa8e-416c-9fb7-44693f0b72aa'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  20,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9440d131-fa8e-416c-9fb7-44693f0b72aa'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9440d131-fa8e-416c-9fb7-44693f0b72aa'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '9440d131-fa8e-416c-9fb7-44693f0b72aa')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '9440d131-fa8e-416c-9fb7-44693f0b72aa',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9440d131-fa8e-416c-9fb7-44693f0b72aa'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('9440d131-fa8e-416c-9fb7-44693f0b72aa'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '45165a4b-1c0a-4b36-ac56-881f61e1edbd' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 18 AS qty_ordered, 18 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '1451d408-ffbc-43aa-a566-9ce45561fa8e' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '8a6ada41-d8d9-4eea-a889-3a192e2f58b6',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-17',
  '+90 537 903 36 76',
  'Seed adres (batch 3, #17) Mah. No:62 Sokak:23',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8a6ada41-d8d9-4eea-a889-3a192e2f58b6'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8a6ada41-d8d9-4eea-a889-3a192e2f58b6'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8a6ada41-d8d9-4eea-a889-3a192e2f58b6'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  36,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8a6ada41-d8d9-4eea-a889-3a192e2f58b6'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8a6ada41-d8d9-4eea-a889-3a192e2f58b6'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '8a6ada41-d8d9-4eea-a889-3a192e2f58b6')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '8a6ada41-d8d9-4eea-a889-3a192e2f58b6',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8a6ada41-d8d9-4eea-a889-3a192e2f58b6'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('8a6ada41-d8d9-4eea-a889-3a192e2f58b6'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '7024f4a6-4860-472d-958b-825bf08b4504' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 28 AS qty_ordered, 28 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'aa774da1-a9ee-4e3d-bb42-65bc2a9bf67a' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 8 AS qty_ordered, 8 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '79fabb42-3c94-488c-9527-efe891208002',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-18',
  '+90 531 123 53 92',
  'Seed adres (batch 3, #18) Mah. No:14 Sokak:44',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('79fabb42-3c94-488c-9527-efe891208002'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('79fabb42-3c94-488c-9527-efe891208002'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('79fabb42-3c94-488c-9527-efe891208002'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  18,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('79fabb42-3c94-488c-9527-efe891208002'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('79fabb42-3c94-488c-9527-efe891208002'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '79fabb42-3c94-488c-9527-efe891208002')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '79fabb42-3c94-488c-9527-efe891208002',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('79fabb42-3c94-488c-9527-efe891208002'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('79fabb42-3c94-488c-9527-efe891208002'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'eb67c724-9155-438a-9834-6af72663b20a' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '81e9d03d-d313-4403-a59c-45ce2a81aad3' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '32679afc-13d9-481a-8acf-22ce62ea065b' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '0a3336c9-059d-4615-87e7-0cdd539f6633',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-19',
  '+90 537 337 61 90',
  'Seed adres (batch 3, #19) Mah. No:24 Sokak:12',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a3336c9-059d-4615-87e7-0cdd539f6633'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a3336c9-059d-4615-87e7-0cdd539f6633'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a3336c9-059d-4615-87e7-0cdd539f6633'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  44,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a3336c9-059d-4615-87e7-0cdd539f6633'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a3336c9-059d-4615-87e7-0cdd539f6633'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '0a3336c9-059d-4615-87e7-0cdd539f6633')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '0a3336c9-059d-4615-87e7-0cdd539f6633',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a3336c9-059d-4615-87e7-0cdd539f6633'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a3336c9-059d-4615-87e7-0cdd539f6633'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '04e62d61-ea90-4412-b5e5-7645ccad9aa3' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 17 AS qty_ordered, 17 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '007db8fc-11fe-46bb-937d-cc3cd441ea9e' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 12 AS qty_ordered, 12 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '29105b92-a3fb-45d6-9b8a-9baa5226fcf6' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 15 AS qty_ordered, 15 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'bff24550-aabc-4350-8993-7632756d979f',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '34343434-3434-4343-8343-343434343434',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-20',
  '+90 536 104 37 36',
  'Seed adres (batch 3, #20) Mah. No:36 Sokak:49',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bff24550-aabc-4350-8993-7632756d979f'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bff24550-aabc-4350-8993-7632756d979f'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bff24550-aabc-4350-8993-7632756d979f'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  39,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bff24550-aabc-4350-8993-7632756d979f'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bff24550-aabc-4350-8993-7632756d979f'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'bff24550-aabc-4350-8993-7632756d979f')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'bff24550-aabc-4350-8993-7632756d979f',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bff24550-aabc-4350-8993-7632756d979f'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('bff24550-aabc-4350-8993-7632756d979f'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '2ccf8ad7-4a50-4179-99e4-27a416224c7b' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 23 AS qty_ordered, 23 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '0aa5c14b-ce83-46ac-9e00-dc5e8ec7572b' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '26edc0a5-9436-43c5-9837-75e68abab6e7' AS id, '55555555-5555-4555-8555-555555555555' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'a59aeda5-4cdb-446d-a7bd-5d67950417e1',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-21',
  '+90 531 368 95 72',
  'Seed adres (batch 3, #21) Mah. No:68 Sokak:41',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a59aeda5-4cdb-446d-a7bd-5d67950417e1'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a59aeda5-4cdb-446d-a7bd-5d67950417e1'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a59aeda5-4cdb-446d-a7bd-5d67950417e1'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  34,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a59aeda5-4cdb-446d-a7bd-5d67950417e1'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a59aeda5-4cdb-446d-a7bd-5d67950417e1'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'a59aeda5-4cdb-446d-a7bd-5d67950417e1')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'a59aeda5-4cdb-446d-a7bd-5d67950417e1',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a59aeda5-4cdb-446d-a7bd-5d67950417e1'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('a59aeda5-4cdb-446d-a7bd-5d67950417e1'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '727f06a1-6d93-4d68-a3b1-df0b0d04533f' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 24 AS qty_ordered, 24 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '32a022a8-2ed6-4944-94b9-83336d1a52a3' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 2 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '3d6cfd7f-775d-461e-854d-20863663a368',
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-22',
  '+90 537 732 32 96',
  'Seed adres (batch 3, #22) Mah. No:91 Sokak:20',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3d6cfd7f-775d-461e-854d-20863663a368'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3d6cfd7f-775d-461e-854d-20863663a368'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3d6cfd7f-775d-461e-854d-20863663a368'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  12,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3d6cfd7f-775d-461e-854d-20863663a368'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3d6cfd7f-775d-461e-854d-20863663a368'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '3d6cfd7f-775d-461e-854d-20863663a368')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '3d6cfd7f-775d-461e-854d-20863663a368',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3d6cfd7f-775d-461e-854d-20863663a368'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('3d6cfd7f-775d-461e-854d-20863663a368'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'a62b4880-8d03-469e-a264-20d24dc9ebbf' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 7 AS qty_ordered, 7 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '978098e4-7b81-4174-82f8-2d9f5e8ebcc4' AS id, '66666666-6666-4666-8666-666666666666' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '104a1ee9-aeb2-4e6a-8aaa-2dafc1c8a0f8' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 2 AS qty_ordered, 2 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  'd4c0439b-5989-4b25-a9a9-812416980957',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  '23232323-2323-4232-8232-232323232323',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-23',
  '+90 535 810 28 75',
  'Seed adres (batch 3, #23) Mah. No:50 Sokak:27',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('d4c0439b-5989-4b25-a9a9-812416980957'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('d4c0439b-5989-4b25-a9a9-812416980957'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('d4c0439b-5989-4b25-a9a9-812416980957'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  31,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('d4c0439b-5989-4b25-a9a9-812416980957'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('d4c0439b-5989-4b25-a9a9-812416980957'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = 'd4c0439b-5989-4b25-a9a9-812416980957')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  'd4c0439b-5989-4b25-a9a9-812416980957',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('d4c0439b-5989-4b25-a9a9-812416980957'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('d4c0439b-5989-4b25-a9a9-812416980957'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '04c4ba2a-dbd6-461a-999c-59911f1e7196' AS id, '33333333-3333-4333-8333-333333333333' AS product_id, 17 AS qty_ordered, 17 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '6380a71b-8f41-421c-bbe4-1f5d59c1dd7b' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT 'b783e189-68e1-4684-916a-d4caa6bb045c' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 11 AS qty_ordered, 11 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '0a5b4d2d-7e10-4345-b840-e13ce88f2df7',
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  '12121212-1212-4121-8121-121212121212',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-24',
  '+90 537 395 27 33',
  'Seed adres (batch 3, #24) Mah. No:41 Sokak:29',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a5b4d2d-7e10-4345-b840-e13ce88f2df7'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a5b4d2d-7e10-4345-b840-e13ce88f2df7'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a5b4d2d-7e10-4345-b840-e13ce88f2df7'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  22,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a5b4d2d-7e10-4345-b840-e13ce88f2df7'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a5b4d2d-7e10-4345-b840-e13ce88f2df7'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '0a5b4d2d-7e10-4345-b840-e13ce88f2df7')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '0a5b4d2d-7e10-4345-b840-e13ce88f2df7',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a5b4d2d-7e10-4345-b840-e13ce88f2df7'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('0a5b4d2d-7e10-4345-b840-e13ce88f2df7'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT 'd3dbe09e-d260-4b8b-a9ab-cc46679d5d8b' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 5 AS qty_ordered, 5 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT '46fc82a3-d919-4f6b-a783-ce1177df07ba' AS id, '44444444-4444-4444-8444-444444444444' AS product_id, 3 AS qty_ordered, 3 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '2402d493-e813-41ac-81a2-a10ce7b0f239' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 14 AS qty_ordered, 14 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

INSERT INTO `orders`
(
  `id`,`created_by`,`assigned_driver_id`,`status`,`city_id`,`district_id`,`customer_name`,`customer_phone`,`address_text`,`note_internal`,`approved_by`,`approved_at`,`assigned_by`,`assigned_at`,`delivered_at`,`delivery_note`,`delivered_qty_total`,`is_delivery_counted`,`cancel_reason`,`created_at`,`updated_at`
)
SELECT
  '88fe692d-3a07-4b30-a4db-43071790450d',
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  '45454545-4545-4454-8454-454545454545',
  'delivered',
  c.id,
  (SELECT d.id FROM districts d WHERE d.city_id = c.id ORDER BY d.created_at ASC LIMIT 1),
  'Müşteri 03-25',
  '+90 537 518 97 72',
  'Seed adres (batch 3, #25) Mah. No:54 Sokak:46',
  NULL,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88fe692d-3a07-4b30-a4db-43071790450d'), 90) DAY) + INTERVAL 1 HOUR,
  '11111111-1111-4111-8111-111111111111',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88fe692d-3a07-4b30-a4db-43071790450d'), 90) DAY) + INTERVAL 2 HOUR,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88fe692d-3a07-4b30-a4db-43071790450d'), 90) DAY) + INTERVAL 6 HOUR,
  'Teslim edildi (seed)',
  33,
  1,
  NULL,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88fe692d-3a07-4b30-a4db-43071790450d'), 90) DAY),
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88fe692d-3a07-4b30-a4db-43071790450d'), 90) DAY) + INTERVAL 6 HOUR + INTERVAL 10 MINUTE
FROM cities c
WHERE NOT EXISTS (SELECT 1 FROM `orders` o WHERE o.id = '88fe692d-3a07-4b30-a4db-43071790450d')
ORDER BY c.created_at ASC
LIMIT 1;

INSERT INTO `order_items`
(`id`,`order_id`,`product_id`,`qty_ordered`,`qty_delivered`,`created_at`,`updated_at`)
SELECT
  x.id,
  '88fe692d-3a07-4b30-a4db-43071790450d',
  x.product_id,
  x.qty_ordered,
  x.qty_delivered,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88fe692d-3a07-4b30-a4db-43071790450d'), 90) DAY) + INTERVAL 20 MINUTE,
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32('88fe692d-3a07-4b30-a4db-43071790450d'), 90) DAY) + INTERVAL 20 MINUTE
FROM (
  SELECT '32454f1a-468c-45d6-8e08-1ff66d3f0fad' AS id, '22222222-2222-4222-8222-222222222222' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 1 AS ord
  UNION ALL
  SELECT 'e8b87c28-9275-4255-9e3e-6df9735d40b2' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 10 AS qty_ordered, 10 AS qty_delivered, 2 AS ord
  UNION ALL
  SELECT '3a810dc5-0abc-4228-b327-c314a178eb9b' AS id, '11111111-1111-4111-8111-111111111111' AS product_id, 13 AS qty_ordered, 13 AS qty_delivered, 3 AS ord
) x
WHERE NOT EXISTS (SELECT 1 FROM `order_items` oi WHERE oi.id = x.id)
ORDER BY x.ord;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
