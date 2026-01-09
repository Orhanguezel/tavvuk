-- =============================================================
-- FILE: db/schema/50_products.schema.sql
-- Tavvuk — PRODUCTS (poultry)
-- - chicken/duck/goose/turkey/quail/other
-- - stock_quantity exists (v1 informational)
-- =============================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';

CREATE TABLE IF NOT EXISTS `products` (
  `id` CHAR(36) NOT NULL,

  `title` VARCHAR(255) NOT NULL,
  `slug`  VARCHAR(255) NOT NULL,

  `species` ENUM('chicken','duck','goose','turkey','quail','other') NOT NULL DEFAULT 'chicken',
  `breed` VARCHAR(255) NULL,
  `summary` VARCHAR(500) NULL,
  `description` TEXT NULL,

  `price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,

  `image_url` LONGTEXT NULL,
  `storage_asset_id` CHAR(36) NULL,
  `alt` VARCHAR(255) NULL,

  `images` JSON NOT NULL DEFAULT (JSON_ARRAY()),
  `storage_image_ids` JSON NOT NULL DEFAULT (JSON_ARRAY()),

  `stock_quantity` INT NOT NULL DEFAULT 0,

  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `is_featured` TINYINT(1) NOT NULL DEFAULT 0,

  `tags` JSON NOT NULL DEFAULT (JSON_ARRAY()),

  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

  PRIMARY KEY (`id`),
  UNIQUE KEY `products_slug_uq` (`slug`),

  KEY `products_species_idx` (`species`),
  KEY `products_breed_idx` (`breed`),
  KEY `products_active_idx` (`is_active`),
  KEY `products_featured_idx` (`is_featured`),
  KEY `products_asset_idx` (`storage_asset_id`),
  KEY `products_created_at_idx` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
