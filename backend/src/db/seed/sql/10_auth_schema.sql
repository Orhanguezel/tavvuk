-- ============================================================================
-- FILE: 010_users_roles_tokens_profiles.schema.sql
-- FINAL (Tavvuk)
-- - users: drizzle schema ile bire bir uyumlu (legacy alanlar dahil)
-- - user_roles: ENUM('admin','seller','driver')
-- - refresh_tokens
-- - profiles: address + social links (optional)
-- - RESET (drop & recreate) - no ALTER
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';

START TRANSACTION;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `refresh_tokens`;
DROP TABLE IF EXISTS `user_roles`;
DROP TABLE IF EXISTS `profiles`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================================
-- TABLE: users
-- (Drizzle: src/modules/auth/schema.ts ile uyumlu)
-- ============================================================================
CREATE TABLE `users` (
  `id`                     CHAR(36)       NOT NULL,
  `email`                  VARCHAR(255)   NOT NULL,
  `password_hash`          VARCHAR(255)   NOT NULL,
  `full_name`              VARCHAR(255)   DEFAULT NULL,
  `phone`                  VARCHAR(50)    DEFAULT NULL,

  -- ✅ optional profile image on users
  `profile_image`          VARCHAR(500)   DEFAULT NULL,
  `profile_image_asset_id` CHAR(36)       DEFAULT NULL,
  `profile_image_alt`      VARCHAR(255)   DEFAULT NULL,

  -- ✅ legacy / shared image fields (projede kalsın denilenler)
  `featured_image`         VARCHAR(500)   DEFAULT NULL,
  `featured_image_asset_id` CHAR(36)      DEFAULT NULL,
  `image_url`              LONGTEXT       DEFAULT NULL,
  `storage_asset_id`       CHAR(36)       DEFAULT NULL,
  `alt`                    VARCHAR(255)   DEFAULT NULL,

  `is_active`              TINYINT(1)     NOT NULL DEFAULT 1,
  `email_verified`         TINYINT(1)     NOT NULL DEFAULT 0,

  `reset_token`            VARCHAR(255)   DEFAULT NULL,
  `reset_token_expires`    DATETIME(3)    DEFAULT NULL,

  `created_at`             DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at`             DATETIME(3)    NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `last_sign_in_at`        DATETIME(3)    DEFAULT NULL,

  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  KEY `users_is_active_idx` (`is_active`),
  KEY `users_created_at_idx` (`created_at`),
  KEY `users_last_sign_in_at_idx` (`last_sign_in_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE: profiles  (address + social links)
-- id = users.id
-- ============================================================================
CREATE TABLE `profiles` (
  `id`             CHAR(36)      NOT NULL,

  `full_name`      TEXT          DEFAULT NULL,
  `phone`          VARCHAR(64)   DEFAULT NULL,
  `avatar_url`     TEXT          DEFAULT NULL, -- legacy/profile keep (optional)

  `address_line1`  VARCHAR(255)  DEFAULT NULL,
  `address_line2`  VARCHAR(255)  DEFAULT NULL,
  `city`           VARCHAR(128)  DEFAULT NULL,
  `country`        VARCHAR(128)  DEFAULT NULL,
  `postal_code`    VARCHAR(32)   DEFAULT NULL,

  -- ✅ social (optional)
  `website_url`    VARCHAR(2048) DEFAULT NULL,
  `instagram_url`  VARCHAR(2048) DEFAULT NULL,
  `facebook_url`   VARCHAR(2048) DEFAULT NULL,
  `x_url`          VARCHAR(2048) DEFAULT NULL,
  `linkedin_url`   VARCHAR(2048) DEFAULT NULL,
  `youtube_url`    VARCHAR(2048) DEFAULT NULL,
  `tiktok_url`     VARCHAR(2048) DEFAULT NULL,

  `created_at`     DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at`     DATETIME(3)   NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),

  PRIMARY KEY (`id`),

  CONSTRAINT `fk_profiles_id_users_id`
    FOREIGN KEY (`id`) REFERENCES `users` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE: user_roles
-- ============================================================================
CREATE TABLE `user_roles` (
  `id`          CHAR(36)     NOT NULL,
  `user_id`     CHAR(36)     NOT NULL,
  `role`        ENUM('admin','seller','driver') NOT NULL,
  `created_at`  DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

  PRIMARY KEY (`id`),
  UNIQUE KEY `user_roles_user_id_role_unique` (`user_id`, `role`),
  KEY `user_roles_user_id_idx` (`user_id`),

  CONSTRAINT `fk_user_roles_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- TABLE: refresh_tokens
-- ============================================================================
CREATE TABLE `refresh_tokens` (
  `id`           CHAR(36)     NOT NULL,
  `user_id`      CHAR(36)     NOT NULL,
  `token_hash`   VARCHAR(255) NOT NULL,

  `created_at`   DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `expires_at`   DATETIME(3)  NOT NULL,
  `revoked_at`   DATETIME(3)  DEFAULT NULL,
  `replaced_by`  CHAR(36)     DEFAULT NULL,

  PRIMARY KEY (`id`),
  KEY `refresh_tokens_user_id_idx` (`user_id`),
  KEY `refresh_tokens_expires_at_idx` (`expires_at`),

  CONSTRAINT `fk_refresh_tokens_user`
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

COMMIT;
