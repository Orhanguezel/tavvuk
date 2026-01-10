-- ============================================================================
-- FILE: db/seed/83_incentives_seed.sql
-- FINAL — Seed: Incentive plan + rules (simple MVP)
-- - 1 active plan effective today
-- - creator: per_delivery 10.00, per_chicken 0.50
-- - driver : per_delivery 12.00, per_chicken 0.60
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- Optional cleanup
-- DELETE FROM `incentive_ledger`;
-- DELETE FROM `incentive_rules`;
-- DELETE FROM `incentive_plans`;

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
);

-- creator rules
INSERT INTO `incentive_rules`
(`id`,`plan_id`,`role_context`,`rule_type`,`amount`,`product_id`,`is_active`,`created_at`,`updated_at`)
VALUES
(UUID(), 'a1000000-0000-4000-8000-000000000001', 'creator', 'per_delivery', 10.00, NULL, 1, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)),
(UUID(), 'a1000000-0000-4000-8000-000000000001', 'creator', 'per_chicken', 0.50, NULL, 1, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3));

-- driver rules
INSERT INTO `incentive_rules`
(`id`,`plan_id`,`role_context`,`rule_type`,`amount`,`product_id`,`is_active`,`created_at`,`updated_at`)
VALUES
(UUID(), 'a1000000-0000-4000-8000-000000000001', 'driver', 'per_delivery', 12.00, NULL, 1, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)),
(UUID(), 'a1000000-0000-4000-8000-000000000001', 'driver', 'per_chicken', 0.60, NULL, 1, CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3));

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
