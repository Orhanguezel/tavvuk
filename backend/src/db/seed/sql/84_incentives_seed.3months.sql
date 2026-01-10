-- ============================================================================
-- FILE: db/seed/84_incentives_seed.sql
-- FINAL — Seed: Incentive plan + rules + ledger (idempotent) — FIXED to match
--        db/seed/82_incentives_schema.sql
--
-- Fixes:
--  - incentive_ledger does NOT have `rule_type`, `amount`, `qty_base`, `total_amount`
--  - Instead it has: deliveries_count, chickens_count, amount_total
--
-- Behavior:
--  - Creates plan + rules (same as 83) using ON DUPLICATE KEY UPDATE
--  - Generates ONE ledger row per (order_id, user_id, role_context)
--    for delivered + is_delivery_counted=1 orders
--  - creator payout: 10.00 per delivery + 0.50 per chicken (delivered_qty_total)
--  - driver  payout: 12.00 per delivery + 0.60 per chicken (delivered_qty_total)
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- ---------------------------------------------------------------------------
-- (Optional) Schema safety net (matches 82_incentives_schema.sql exactly)
-- Uncomment if your schema runner may skip 82_incentives_schema.sql
-- ---------------------------------------------------------------------------
/*
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
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `incentive_rules`
(
  `id`           CHAR(36)      NOT NULL,
  `plan_id`      CHAR(36)      NOT NULL,
  `role_context` VARCHAR(20)   NOT NULL,
  `rule_type`    VARCHAR(20)   NOT NULL,
  `amount`       DECIMAL(12,2) NOT NULL,
  `product_id`   CHAR(36)      NULL,
  `is_active`    TINYINT(1)    NOT NULL DEFAULT 1,
  `created_at`   DATETIME(3)   NOT NULL,
  `updated_at`   DATETIME(3)   NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_incentive_rules_plan` (`plan_id`),
  KEY `idx_incentive_rules_plan_role` (`plan_id`, `role_context`),
  KEY `idx_incentive_rules_plan_active` (`plan_id`, `is_active`)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `incentive_ledger`
(
  `id`              CHAR(36)      NOT NULL,
  `order_id`        CHAR(36)      NOT NULL,
  `user_id`         CHAR(36)      NOT NULL,
  `role_context`    VARCHAR(20)   NOT NULL,
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
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
*/

-- ---------------------------------------------------------------------------
-- Plan
-- ---------------------------------------------------------------------------

INSERT INTO `incentive_plans`
(`id`,`name`,`is_active`,`effective_from`,`created_by`,`created_at`,`updated_at`)
VALUES
(
  'a1000000-0000-4000-8000-000000000001',
  'Default Plan (MVP)',
  1,
  CURRENT_DATE(),
  '11111111-1111-4111-8111-111111111111',
  CURRENT_TIMESTAMP(3),
  CURRENT_TIMESTAMP(3)
)
ON DUPLICATE KEY UPDATE
  `name`=VALUES(`name`),
  `is_active`=VALUES(`is_active`),
  `effective_from`=VALUES(`effective_from`),
  `updated_at`=VALUES(`updated_at`);

-- ---------------------------------------------------------------------------
-- Rules (stable IDs; reruns are clean)
-- ---------------------------------------------------------------------------

INSERT INTO `incentive_rules`
(`id`,`plan_id`,`role_context`,`rule_type`,`amount`,`product_id`,`is_active`,`created_at`,`updated_at`)
VALUES
('a2000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'creator', 'per_delivery', 10.00, NULL, 1, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)),
('a2000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000001', 'creator', 'per_chicken',  0.50, NULL, 1, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)),
('a2000000-0000-4000-8000-000000000003', 'a1000000-0000-4000-8000-000000000001', 'driver',  'per_delivery', 12.00, NULL, 1, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)),
('a2000000-0000-4000-8000-000000000004', 'a1000000-0000-4000-8000-000000000001', 'driver',  'per_chicken',  0.60, NULL, 1, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3))
ON DUPLICATE KEY UPDATE
  `amount`=VALUES(`amount`),
  `is_active`=VALUES(`is_active`),
  `updated_at`=VALUES(`updated_at`);

-- ---------------------------------------------------------------------------
-- Ledger generation (ONE row per order per role)
-- Eligibility:
--   orders.status='delivered' AND orders.is_delivery_counted=1
--
-- chickens_count base:
--   orders.delivered_qty_total   (MVP simplification; aligns with your orders seed)
-- ---------------------------------------------------------------------------

-- creator rows
INSERT IGNORE INTO `incentive_ledger`
(`id`,`order_id`,`user_id`,`role_context`,`deliveries_count`,`chickens_count`,`amount_total`,`plan_id`,`calculated_at`)
SELECT
  UUID(),
  o.id,
  o.created_by,
  'creator',
  1,
  CAST(o.delivered_qty_total AS DECIMAL(12,2)),
  ROUND(10.00 + (CAST(o.delivered_qty_total AS DECIMAL(12,2)) * 0.50), 2),
  'a1000000-0000-4000-8000-000000000001',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32(o.id), 90) DAY)
FROM `orders` o
WHERE o.status = 'delivered' AND o.is_delivery_counted = 1;

-- driver rows (skip if no assigned driver)
INSERT IGNORE INTO `incentive_ledger`
(`id`,`order_id`,`user_id`,`role_context`,`deliveries_count`,`chickens_count`,`amount_total`,`plan_id`,`calculated_at`)
SELECT
  UUID(),
  o.id,
  o.assigned_driver_id,
  'driver',
  1,
  CAST(o.delivered_qty_total AS DECIMAL(12,2)),
  ROUND(12.00 + (CAST(o.delivered_qty_total AS DECIMAL(12,2)) * 0.60), 2),
  'a1000000-0000-4000-8000-000000000001',
  DATE_SUB(CURRENT_TIMESTAMP(3), INTERVAL MOD(CRC32(o.id), 90) DAY)
FROM `orders` o
WHERE o.status = 'delivered'
  AND o.is_delivery_counted = 1
  AND o.assigned_driver_id IS NOT NULL;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
