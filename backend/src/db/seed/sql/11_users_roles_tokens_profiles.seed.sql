-- ============================================================================
-- FILE: 011_users_roles_tokens_profiles.seed.sql
-- FINAL SEED (Tavvuk)
-- - 1 admin: orhanguzell@gmail.com (fixed)
-- - 5 sellers
-- - 5 drivers
-- - profiles created explicitly
-- NOTE:
-- - {{ADMIN_PASSWORD_HASH}} runner tarafından üretiliyor
-- ============================================================================

SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci;
SET collation_connection = 'utf8mb4_unicode_ci';
SET time_zone = '+00:00';

START TRANSACTION;

-- ============================================================================
-- ADMIN (fixed)
-- ============================================================================
INSERT INTO `users` (
  `id`, `email`, `password_hash`, `full_name`, `phone`,
  `profile_image`, `profile_image_asset_id`, `profile_image_alt`,
  `is_active`, `email_verified`, `created_at`, `updated_at`
) VALUES (
  '11111111-1111-4111-8111-111111111111',
  'orhanguzell@gmail.com',
  '{{ADMIN_PASSWORD_HASH}}',
  'Orhan Güzel',
  '+905551112233',
  'https://randomuser.me/api/portraits/men/12.jpg',
  NULL,
  'Orhan Güzel profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
);

INSERT INTO `profiles` (
  `id`, `full_name`, `phone`, `avatar_url`,
  `address_line1`, `address_line2`, `city`, `country`, `postal_code`,
  `website_url`, `instagram_url`, `facebook_url`, `x_url`, `linkedin_url`, `youtube_url`, `tiktok_url`,
  `created_at`, `updated_at`
) VALUES (
  '11111111-1111-4111-8111-111111111111',
  'Orhan Güzel',
  '+905551112233',
  'https://randomuser.me/api/portraits/men/12.jpg',
  NULL, NULL, 'Grevenbroich', 'Germany', NULL,
  'https://guezelwebdesign.com',
  'https://instagram.com/orhanguzel',
  NULL,
  'https://x.com/orhanguzel',
  'https://linkedin.com/in/orhanguzel',
  NULL,
  NULL,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
);

INSERT INTO `user_roles` (`id`, `user_id`, `role`, `created_at`)
VALUES (UUID(), '11111111-1111-4111-8111-111111111111', 'admin', CURRENT_TIMESTAMP(3));

-- ============================================================================
-- SELLERS (5)
-- ============================================================================
INSERT INTO `users` (
  `id`, `email`, `password_hash`, `full_name`, `phone`,
  `profile_image`, `profile_image_asset_id`, `profile_image_alt`,
  `is_active`, `email_verified`, `created_at`, `updated_at`
) VALUES
(
  'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
  'seller.ali.kaya@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Ali Kaya',
  '+905301111111',
  'https://randomuser.me/api/portraits/men/21.jpg',
  NULL,
  'Ali Kaya profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  'seller.mehmet.yilmaz@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Mehmet Yılmaz',
  '+905302222222',
  'https://randomuser.me/api/portraits/men/22.jpg',
  NULL,
  'Mehmet Yılmaz profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'seller.ahmet.demir@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Ahmet Demir',
  '+905303333333',
  'https://randomuser.me/api/portraits/men/23.jpg',
  NULL,
  'Ahmet Demir profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  'dddddddd-dddd-4ddd-8ddd-dddddddddddd',
  'seller.mustafa.koc@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Mustafa Koç',
  '+905304444444',
  'https://randomuser.me/api/portraits/men/24.jpg',
  NULL,
  'Mustafa Koç profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee',
  'seller.emre.sahin@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Emre Şahin',
  '+905305555555',
  'https://randomuser.me/api/portraits/men/25.jpg',
  NULL,
  'Emre Şahin profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
);

INSERT INTO `profiles` (`id`, `full_name`, `phone`, `avatar_url`, `created_at`, `updated_at`)
VALUES
('aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa','Ali Kaya','+905301111111','https://randomuser.me/api/portraits/men/21.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3)),
('bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb','Mehmet Yılmaz','+905302222222','https://randomuser.me/api/portraits/men/22.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3)),
('cccccccc-cccc-4ccc-8ccc-cccccccccccc','Ahmet Demir','+905303333333','https://randomuser.me/api/portraits/men/23.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3)),
('dddddddd-dddd-4ddd-8ddd-dddddddddddd','Mustafa Koç','+905304444444','https://randomuser.me/api/portraits/men/24.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3)),
('eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee','Emre Şahin','+905305555555','https://randomuser.me/api/portraits/men/25.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3));

INSERT INTO `user_roles` (`id`, `user_id`, `role`, `created_at`)
VALUES
(UUID(), 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', 'seller', CURRENT_TIMESTAMP(3)),
(UUID(), 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb', 'seller', CURRENT_TIMESTAMP(3)),
(UUID(), 'cccccccc-cccc-4ccc-8ccc-cccccccccccc', 'seller', CURRENT_TIMESTAMP(3)),
(UUID(), 'dddddddd-dddd-4ddd-8ddd-dddddddddddd', 'seller', CURRENT_TIMESTAMP(3)),
(UUID(), 'eeeeeeee-eeee-4eee-8eee-eeeeeeeeeeee', 'seller', CURRENT_TIMESTAMP(3));

-- ============================================================================
-- DRIVERS (5)
-- ============================================================================
INSERT INTO `users` (
  `id`, `email`, `password_hash`, `full_name`, `phone`,
  `profile_image`, `profile_image_asset_id`, `profile_image_alt`,
  `is_active`, `email_verified`, `created_at`, `updated_at`
) VALUES
(
  'ffffffff-ffff-4fff-8fff-ffffffffffff',
  'driver.ayse.demir@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Ayşe Demir',
  '+905306666666',
  'https://randomuser.me/api/portraits/women/21.jpg',
  NULL,
  'Ayşe Demir profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  '12121212-1212-4121-8121-121212121212',
  'driver.fatma.celik@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Fatma Çelik',
  '+905307777777',
  'https://randomuser.me/api/portraits/women/22.jpg',
  NULL,
  'Fatma Çelik profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  '23232323-2323-4232-8232-232323232323',
  'driver.zeynep.kaya@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Zeynep Kaya',
  '+905308888888',
  'https://randomuser.me/api/portraits/women/23.jpg',
  NULL,
  'Zeynep Kaya profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  '34343434-3434-4343-8343-343434343434',
  'driver.elif.yildiz@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Elif Yıldız',
  '+905309999999',
  'https://randomuser.me/api/portraits/women/24.jpg',
  NULL,
  'Elif Yıldız profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
),
(
  '45454545-4545-4454-8454-454545454545',
  'driver.meryem.arslan@tavvuk.local',
  '{{ADMIN_PASSWORD_HASH}}',
  'Meryem Arslan',
  '+905300000000',
  'https://randomuser.me/api/portraits/women/25.jpg',
  NULL,
  'Meryem Arslan profil fotoğrafı',
  1, 1,
  CURRENT_TIMESTAMP(3), CURRENT_TIMESTAMP(3)
);

INSERT INTO `profiles` (`id`, `full_name`, `phone`, `avatar_url`, `created_at`, `updated_at`)
VALUES
('ffffffff-ffff-4fff-8fff-ffffffffffff','Ayşe Demir','+905306666666','https://randomuser.me/api/portraits/women/21.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3)),
('12121212-1212-4121-8121-121212121212','Fatma Çelik','+905307777777','https://randomuser.me/api/portraits/women/22.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3)),
('23232323-2323-4232-8232-232323232323','Zeynep Kaya','+905308888888','https://randomuser.me/api/portraits/women/23.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3)),
('34343434-3434-4343-8343-343434343434','Elif Yıldız','+905309999999','https://randomuser.me/api/portraits/women/24.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3)),
('45454545-4545-4454-8454-454545454545','Meryem Arslan','+905300000000','https://randomuser.me/api/portraits/women/25.jpg',CURRENT_TIMESTAMP(3),CURRENT_TIMESTAMP(3));

INSERT INTO `user_roles` (`id`, `user_id`, `role`, `created_at`)
VALUES
(UUID(), 'ffffffff-ffff-4fff-8fff-ffffffffffff', 'driver', CURRENT_TIMESTAMP(3)),
(UUID(), '12121212-1212-4121-8121-121212121212', 'driver', CURRENT_TIMESTAMP(3)),
(UUID(), '23232323-2323-4232-8232-232323232323', 'driver', CURRENT_TIMESTAMP(3)),
(UUID(), '34343434-3434-4343-8343-343434343434', 'driver', CURRENT_TIMESTAMP(3)),
(UUID(), '45454545-4545-4454-8454-454545454545', 'driver', CURRENT_TIMESTAMP(3));

COMMIT;
