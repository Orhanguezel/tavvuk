-- =============================================================
-- FILE: db/seed/50.1_products_seed.sql
-- Tavvuk — Seed: PRODUCTS (poultry)
-- - Simple sample items for chicken/duck/goose/turkey
-- - Stock quantity exists but v1 does not enforce stock logic
-- =============================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- İstersen seed'i her çalıştırmada temizlemek için:
-- TRUNCATE TABLE `products`;

INSERT INTO `products`
(
  `id`,
  `title`, `slug`,
  `species`, `breed`,
  `summary`, `description`,
  `price`,
  `image_url`, `storage_asset_id`, `alt`,
  `images`, `storage_image_ids`,
  `stock_quantity`,
  `is_active`, `is_featured`,
  `tags`,
  `created_at`, `updated_at`
)
VALUES
-- ---------------- CHICKEN ----------------
(
  '11111111-1111-4111-8111-111111111111',
  'Ataks Yumurta Tavuğu', 'ataks-yumurta-tavugu',
  'chicken', 'Ataks',
  'Dayanıklı, verimli yumurtacı ırk.', 'Ataks; küçük/orta işletmeler için yaygın yumurtacı tavuk ırkı.',
  0.00,
  NULL, NULL, 'Ataks tavuğu',
  JSON_ARRAY(), JSON_ARRAY(),
  50,
  1, 1,
  JSON_ARRAY('yumurtaci','dayanikli','yerli'),
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  '22222222-2222-4222-8222-222222222222',
  'Sussex (Et & Yumurta)', 'sussex-et-yumurta',
  'chicken', 'Sussex',
  'Çift amaçlı (et+yumurta) ırk.', 'Sussex; sakin karakterli, çift amaçlı kullanıma uygun ırk.',
  0.00,
  NULL, NULL, 'Sussex tavuğu',
  JSON_ARRAY(), JSON_ARRAY(),
  30,
  1, 0,
  JSON_ARRAY('cift-amac','sakin','aile'),
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  '33333333-3333-4333-8333-333333333333',
  'Tindend / Tinted (Yumurta)', 'tinted-yumurta-tavugu',
  'chicken', 'Tinted',
  'Renkli yumurta verimiyle öne çıkar.', 'Tinted tipleri; pazarda renkli yumurta için tercih edilebilir.',
  0.00,
  NULL, NULL, 'Tinted tavuk',
  JSON_ARRAY(), JSON_ARRAY(),
  20,
  1, 0,
  JSON_ARRAY('renkli-yumurta','yumurtaci'),
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),

-- ---------------- DUCK ----------------
(
  '44444444-4444-4444-8444-444444444444',
  'Pekin Ördeği', 'pekin-ordegi',
  'duck', 'Pekin',
  'Hızlı büyüyen, yaygın et tipi ördek.', 'Pekin ördeği; et verimi için sık tercih edilir.',
  0.00,
  NULL, NULL, 'Pekin ördeği',
  JSON_ARRAY(), JSON_ARRAY(),
  15,
  1, 0,
  JSON_ARRAY('et','hizli-buyume'),
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),

-- ---------------- GOOSE ----------------
(
  '55555555-5555-4555-8555-555555555555',
  'Emden Kazı', 'emden-kazi',
  'goose', 'Emden',
  'Büyük gövdeli, klasik kaz ırkı.', 'Emden; iri yapılı kaz ırkı olarak bilinir.',
  0.00,
  NULL, NULL, 'Emden kazı',
  JSON_ARRAY(), JSON_ARRAY(),
  10,
  1, 0,
  JSON_ARRAY('kaz','iri'),
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),

-- ---------------- TURKEY ----------------
(
  '66666666-6666-4666-8666-666666666666',
  'Hindi (Bronze Tip)', 'hindi-bronze-tip',
  'turkey', 'Bronze',
  'Et odaklı hindi tipi.', 'Bronze tip hindi; et üretimi için yetiştirilebilir.',
  0.00,
  NULL, NULL, 'Bronze hindi',
  JSON_ARRAY(), JSON_ARRAY(),
  8,
  1, 0,
  JSON_ARRAY('et','hindi'),
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
);

-- Alternatif: TRUNCATE kullanmak istemiyorsan “upsert”:
-- ON DUPLICATE KEY UPDATE
--   `title`=VALUES(`title`),
--   `species`=VALUES(`species`),
--   `breed`=VALUES(`breed`),
--   `summary`=VALUES(`summary`),
--   `description`=VALUES(`description`),
--   `stock_quantity`=VALUES(`stock_quantity`),
--   `is_active`=VALUES(`is_active`),
--   `is_featured`=VALUES(`is_featured`),
--   `tags`=VALUES(`tags`),
--   `updated_at`=CURRENT_TIMESTAMP(3);

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
