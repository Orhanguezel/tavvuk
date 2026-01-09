-- ============================================================================
-- FILE: db/seed/70_orders.schema.sql
-- FINAL — Tavvuk Orders (orders + order_items + driver_routes)
-- - src/modules/orders/schema.ts ile bire bir uyumlu
-- - MariaDB/MySQL
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- -----------------------------
-- orders
-- -----------------------------
CREATE TABLE IF NOT EXISTS `orders` (
  `id`                 CHAR(36)      NOT NULL,

  `created_by`         CHAR(36)      NOT NULL,

  `assigned_driver_id` CHAR(36)      NULL,
  `status`             ENUM('submitted','approved','assigned','on_delivery','delivered','cancelled')
                                   NOT NULL DEFAULT 'submitted',

  `city_id`            CHAR(36)      NOT NULL,
  `district_id`        CHAR(36)      NULL,

  `customer_name`      VARCHAR(255)  NOT NULL,
  `customer_phone`     VARCHAR(50)   NOT NULL,
  `address_text`       TEXT          NOT NULL,

  `note_internal`      TEXT          NULL,

  `approved_by`        CHAR(36)      NULL,
  `approved_at`        DATETIME(3)   NULL,

  `assigned_by`        CHAR(36)      NULL,
  `assigned_at`        DATETIME(3)   NULL,

  `delivered_at`       DATETIME(3)   NULL,
  `delivery_note`      TEXT          NULL,

  `delivered_qty_total` INT          NOT NULL DEFAULT 0,
  `is_delivery_counted` TINYINT(1)   NOT NULL DEFAULT 0,

  `cancel_reason`      VARCHAR(255)  NULL,

  `created_at`         DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at`         DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

  PRIMARY KEY (`id`),

  KEY `orders_status_created_at_idx` (`status`, `created_at`),
  KEY `orders_city_district_created_at_idx` (`city_id`, `district_id`, `created_at`),
  KEY `orders_created_by_created_at_idx` (`created_by`, `created_at`),
  KEY `orders_assigned_driver_created_at_idx` (`assigned_driver_id`, `created_at`),
  KEY `orders_customer_phone_idx` (`customer_phone`),
  KEY `orders_customer_name_idx` (`customer_name`),

  KEY `orders_status_delivered_at_idx` (`status`, `delivered_at`),
  KEY `orders_created_by_delivered_at_idx` (`created_by`, `delivered_at`),
  KEY `orders_assigned_driver_delivered_at_idx` (`assigned_driver_id`, `delivered_at`),
  KEY `orders_city_delivered_at_idx` (`city_id`, `delivered_at`),
  KEY `orders_district_delivered_at_idx` (`district_id`, `delivered_at`),

  CONSTRAINT `fk_orders_created_by` FOREIGN KEY (`created_by`) REFERENCES `users`(`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_assigned_driver` FOREIGN KEY (`assigned_driver_id`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users`(`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_orders_district` FOREIGN KEY (`district_id`) REFERENCES `districts`(`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

-- -----------------------------
-- order_items
-- -----------------------------
CREATE TABLE IF NOT EXISTS `order_items` (
  `id`           CHAR(36)    NOT NULL,
  `order_id`     CHAR(36)    NOT NULL,
  `product_id`   CHAR(36)    NOT NULL,

  `qty_ordered`  INT         NOT NULL,
  `qty_delivered` INT        NOT NULL DEFAULT 0,

  `created_at`   DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at`   DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

  PRIMARY KEY (`id`),

  KEY `order_items_order_id_idx` (`order_id`),
  KEY `order_items_product_id_idx` (`product_id`),
  KEY `order_items_order_product_idx` (`order_id`, `product_id`),

  CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_order_items_product` FOREIGN KEY (`product_id`) REFERENCES `products`(`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

-- -----------------------------
-- driver_routes
-- -----------------------------
CREATE TABLE IF NOT EXISTS `driver_routes` (
  `id`          CHAR(36)    NOT NULL,
  `driver_id`   CHAR(36)    NOT NULL,
  `city_id`     CHAR(36)    NOT NULL,
  `district_id` CHAR(36)    NULL,

  `created_at`  DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

  PRIMARY KEY (`id`),

  KEY `driver_routes_driver_idx` (`driver_id`),
  KEY `driver_routes_city_district_idx` (`city_id`, `district_id`),

  CONSTRAINT `fk_driver_routes_driver` FOREIGN KEY (`driver_id`) REFERENCES `users`(`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_driver_routes_city` FOREIGN KEY (`city_id`) REFERENCES `cities`(`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_driver_routes_district` FOREIGN KEY (`district_id`) REFERENCES `districts`(`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
