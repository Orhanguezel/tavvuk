-- ============================================================================
-- FILE: db/seed/82_incentives_schema.sql
-- FINAL — Incentive plans + rules + ledger (MariaDB/MySQL)
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

CREATE TABLE IF NOT EXISTS `incentive_plans`
(
  `id`            CHAR(36)     NOT NULL,
  `name`          VARCHAR(120) NOT NULL,
  `is_active`     TINYINT(1)   NOT NULL DEFAULT 1,
  `effective_from` DATE        NOT NULL,

  `created_by`    CHAR(36)     NOT NULL,

  `created_at`    DATETIME(3)  NOT NULL,
  `updated_at`    DATETIME(3)  NOT NULL,

  PRIMARY KEY (`id`),
  KEY `idx_incentive_plans_active_from` (`is_active`, `effective_from`),
  KEY `idx_incentive_plans_created_at` (`created_at`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `incentive_rules`
(
  `id`           CHAR(36)     NOT NULL,
  `plan_id`      CHAR(36)     NOT NULL,

  `role_context` VARCHAR(20)  NOT NULL,  -- creator | driver
  `rule_type`    VARCHAR(20)  NOT NULL,  -- per_delivery | per_chicken
  `amount`       DECIMAL(12,2) NOT NULL,

  `product_id`   CHAR(36)     NULL,
  `is_active`    TINYINT(1)   NOT NULL DEFAULT 1,

  `created_at`   DATETIME(3)  NOT NULL,
  `updated_at`   DATETIME(3)  NOT NULL,

  PRIMARY KEY (`id`),

  KEY `idx_incentive_rules_plan` (`plan_id`),
  KEY `idx_incentive_rules_plan_role` (`plan_id`, `role_context`),
  KEY `idx_incentive_rules_plan_active` (`plan_id`, `is_active`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `incentive_ledger`
(
  `id`             CHAR(36)      NOT NULL,

  `order_id`        CHAR(36)      NOT NULL,
  `user_id`         CHAR(36)      NOT NULL,
  `role_context`    VARCHAR(20)   NOT NULL,  -- creator | driver

  `deliveries_count` TINYINT(1)   NOT NULL,
  `chickens_count`   DECIMAL(12,2) NOT NULL,

  `amount_total`    DECIMAL(12,2) NOT NULL,

  `plan_id`         CHAR(36)      NOT NULL,
  `calculated_at`   DATETIME(3)   NOT NULL,

  PRIMARY KEY (`id`),

  UNIQUE KEY `uq_incentive_ledger_order_user_role` (`order_id`,`user_id`,`role_context`),

  KEY `idx_incentive_ledger_user` (`user_id`),
  KEY `idx_incentive_ledger_order` (`order_id`),
  KEY `idx_incentive_ledger_plan` (`plan_id`),
  KEY `idx_incentive_ledger_calculated_at` (`calculated_at`),
  KEY `idx_incentive_ledger_role` (`role_context`)
)
ENGINE=InnoDB
DEFAULT CHARSET=utf8mb4
COLLATE=utf8mb4_unicode_ci;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
