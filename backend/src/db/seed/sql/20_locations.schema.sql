-- ============================================================================
-- FILE: 20_locations.schema.sql
-- FINAL — Tavvuk Locations (cities + districts)
-- ============================================================================
SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `cities` (
  `id`         CHAR(36)      NOT NULL,
  `code`       INT           NOT NULL,
  `name`       VARCHAR(128)  NOT NULL,
  `is_active`  TINYINT(1)    NOT NULL DEFAULT 1,
  `created_at` DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `cities_code_uq` (`code`),
  UNIQUE KEY `cities_name_uq` (`name`),
  KEY `cities_active_idx` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `districts` (
  `id`         CHAR(36)      NOT NULL,
  `city_id`    CHAR(36)      NOT NULL,
  `code`       INT           NOT NULL DEFAULT 0,
  `name`       VARCHAR(128)  NOT NULL,
  `is_active`  TINYINT(1)    NOT NULL DEFAULT 1,
  `created_at` DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `districts_city_name_uq` (`city_id`, `name`),
  KEY `districts_city_id_idx` (`city_id`),
  KEY `districts_active_idx` (`is_active`),
  KEY `districts_code_idx` (`code`),
  CONSTRAINT `fk_districts_city`
    FOREIGN KEY (`city_id`) REFERENCES `cities` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
