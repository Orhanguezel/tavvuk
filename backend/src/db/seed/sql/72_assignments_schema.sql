-- ============================================================================
-- FILE: db/seed/72_assignments_schema.sql
-- FINAL — Assignments table (audit trail)
-- - No generated columns (MariaDB compatibility)
-- - One-active-per-order is enforced in service (tx)
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `assignments`
(
  `id`            CHAR(36)      NOT NULL,

  `order_id`      CHAR(36)      NOT NULL,
  `driver_id`     CHAR(36)      NOT NULL,
  `assigned_by`   CHAR(36)      NOT NULL,

  `status`        VARCHAR(20)   NOT NULL,   -- active | cancelled
  `note`          VARCHAR(1000) NULL,

  `cancelled_by`  CHAR(36)      NULL,
  `cancelled_at`  DATETIME(3)   NULL,
  `cancel_reason` VARCHAR(255)  NULL,

  `created_at`    DATETIME(3)   NOT NULL,
  `updated_at`    DATETIME(3)   NOT NULL,

  PRIMARY KEY (`id`),

  KEY `idx_assignments_driver` (`driver_id`),
  KEY `idx_assignments_order` (`order_id`),
  KEY `idx_assignments_order_status` (`order_id`,`status`),
  KEY `idx_assignments_status` (`status`),
  KEY `idx_assignments_created_at` (`created_at`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
