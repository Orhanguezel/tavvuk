-- =============================================================
-- FILE: 60_site_settings_schema.sql  (GZL Temizlik)  [FINAL - FIXED + TR MENU]
-- - Booking/Mail integration keys added:
--   site_title, footer_company_name, footer_company_email,
--   contact_receiver_email, booking_admin_email, booking_admin_user_id
-- =============================================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';

SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

DROP TABLE IF EXISTS `site_settings`;

CREATE TABLE `site_settings` (
  `id` CHAR(36) NOT NULL,
  `key` VARCHAR(100) NOT NULL,
  `value` MEDIUMTEXT NOT NULL,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `site_settings_key_uq` (`key`),
  KEY `site_settings_key_idx` (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================
-- BRAND / UI
-- =============================================================

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'brand_name', 'GZL Temizlik', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'brand_tagline', 'Gemlik’te profesyonel temizlik hizmetleri', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- ✅ Booking controller getSiteName() uses this first
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'site_title', 'GZL Temizlik', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- JSON text (string değil)
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'ui_theme', '{"color":"slate","primaryHex":"#1e293b","darkMode":false,"navbarHeight":96}', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'site_version', '1.0.0', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- CONTACT
-- =============================================================

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'contact_phone_display', '+90 000 000 00 00', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'contact_phone_tel', '+900000000000', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'contact_email', 'info@tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- (legacy/alias) bazı projelerde contact_to_email kullanılıyor
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'contact_to_email', 'info@tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- ✅ Booking controller getAdminBookingEmail() fallback uses this
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'contact_receiver_email', 'info@tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'contact_address', 'Gemlik / Bursa', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'contact_whatsapp_link', 'https://wa.me/900000000000', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- BOOKING (admin recipients)
-- =============================================================

-- ✅ Booking controller getAdminBookingEmail() checks this FIRST
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'booking_admin_email', 'info@tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- ✅ Booking controller notifications target (36-char UUID)
-- value boş: admin user oluşturunca güncelleyeceksin.
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'booking_admin_user_id', '', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- STORAGE / UPLOAD CONFIG
-- =============================================================

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'storage_driver', 'local', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'storage_local_root', '/www/wwwroot/tavvuk/uploads', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'storage_local_base_url', 'http://localhost:8071/uploads', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- ✅ tek kez
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'storage_cdn_public_base', 'https://cdn.tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'storage_public_api_base', 'https://tavvuk.com/api', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- Cloudinary placeholders
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'cloudinary_cloud_name', '', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'cloudinary_api_key', '', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'cloudinary_api_secret', '__SET_IN_ENV__', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'cloudinary_folder', 'uploads', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'cloudinary_unsigned_preset', '', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- SMTP / MAIL CONFIG
-- =============================================================

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'smtp_host', 'smtp.example.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'smtp_port', '587', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'smtp_username', 'info@tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'smtp_password', '__SET_IN_ENV__', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'smtp_from_email', 'info@tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'smtp_from_name', 'GZL Temizlik', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'smtp_ssl', 'false', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- HEADER TEXT (PLAIN)
-- =============================================================

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'header_info_text', '• Profesyonel ekip  • Zamanında hizmet  • Şeffaf fiyatlandırma  • Çevre dostu ürünler', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'header_cta_label', 'TEKLİF AL', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- HEADER MENU (JSON array) — TR
-- =============================================================

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(
  UUID(),
  'header_menu',
  '[{"title":"Ana Sayfa","path":"/","pageKey":"home","type":"link"},
    {"title":"Kurumsal","path":"/about-us","pageKey":"pages","type":"dropdown","itemsKey":"menu_pages"},
    {"title":"Hizmetler","path":"/services","pageKey":"services","type":"dropdown","itemsKey":"menu_services"},
    {"title":"Blog","path":"/blog","pageKey":"blog","type":"dropdown","itemsKey":"menu_blog"},
    {"title":"İletişim","path":"/contact-us","pageKey":"contact","type":"link"}]',
  NOW(3),
  NOW(3)
)
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'header_menu_right', '[]', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- MENU (dropdown contents) — TR
-- =============================================================

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(
  UUID(),
  'menu_pages',
  '[{"title":"Hakkımızda","path":"/about-us","pageKey":"about"},
    {"title":"Ekibimiz","path":"/team","pageKey":"team"},
    {"title":"S.S.S.","path":"/faq","pageKey":"faq"},
    {"title":"Giriş","path":"/login","pageKey":"login"},
    {"title":"Kayıt Ol","path":"/register","pageKey":"register"}]',
  NOW(3),
  NOW(3)
)
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(
  UUID(),
  'menu_services',
  '[{"title":"Ev Temizliği","path":"/services/ev-temizligi","pageKey":"service_home"},
    {"title":"Apartman / Merdiven","path":"/services/apartman-merdiven-temizligi","pageKey":"service_stairs"},
    {"title":"İnşaat Sonrası Temizlik","path":"/services/insaat-sonrasi-temizlik","pageKey":"service_after_construction"},
    {"title":"Ofis Temizliği","path":"/services/ofis-temizligi","pageKey":"service_office"},
    {"title":"Havuz Temizliği","path":"/services/havuz-temizligi","pageKey":"service_pool"},
    {"title":"Çim Biçme","path":"/services/cim-bicme","pageKey":"service_grass"}]',
  NOW(3),
  NOW(3)
)
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(
  UUID(),
  'menu_blog',
  '[{"title":"Tüm Yazılar","path":"/blog","pageKey":"blog_list"}]',
  NOW(3),
  NOW(3)
)
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- FOOTER
-- =============================================================

-- ✅ Booking controller getSiteName() fallback uses this
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'footer_company_name', 'GZL Temizlik', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- ✅ Booking controller getAdminBookingEmail() fallback uses this
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'footer_company_email', 'info@tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'footer_keywords', '["temizlik","ev temizliği","ofis temizliği","inşaat sonrası temizlik","profesyonel temizlik","Gemlik temizlik","GZL Temizlik"]', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'footer_services', '["Ev Temizliği","Apartman / Merdiven","Depo Temizliği","Havuz Temizliği","Çim Biçme"]', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(
  UUID(),
  'footer_services_links',
  '[{"title":"Ev Temizliği","path":"/services/ev-temizligi","pageKey":"svc_home"},
    {"title":"Ofis Temizliği","path":"/services/ofis-temizligi","pageKey":"svc_office"},
    {"title":"Apartman / Merdiven","path":"/services/apartman-merdiven-temizligi","pageKey":"svc_stairs"},
    {"title":"İnşaat Sonrası Temizlik","path":"/services/insaat-sonrasi-temizlik","pageKey":"svc_after"},
    {"title":"Havuz Temizliği","path":"/services/havuz-temizligi","pageKey":"svc_pool"},
    {"title":"Çim Biçme","path":"/services/cim-bicme","pageKey":"svc_grass"}]',
  NOW(3),
  NOW(3)
)
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- OFFERS (admin recipients) — GZL (single-locale)
-- =============================================================

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'offers_admin_email', 'info@tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- JSON array string (önerilen format)
-- örn: ["uuid1","uuid2"]  (şimdilik boş bırakılabilir)
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'offers_admin_user_ids', '[]', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- URL BASES (Offer PDF absolute links + storage relative base)
-- =============================================================

-- Offer/service tarafında ABSOLUTE link üretimi için kullanılır
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'public_base_url', 'https://tavvuk.com', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- ✅ DÜZELTME: storage_local_base_url PATH olmalı (örn: /uploads)
-- Eski değer: http://localhost:8071/uploads  (bu, path helper ile çakışır)
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(UUID(), 'storage_local_base_url', '/uploads', NOW(3), NOW(3))
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- COMPANY BRAND (Offer PDF header)
-- =============================================================

-- company_brand JSON (string değil, JSON text)
-- logo.url alanına istersen CDN ya da /uploads/... koyabilirsin
INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(
  UUID(),
  'company_brand',
  '{
    "name":"GZL Temizlik",
    "shortName":"GZL",
    "website":"https://tavvuk.com",
    "logo": { "url": null, "width": 160, "height": 60 }
  }',
  NOW(3),
  NOW(3)
)
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);

-- =============================================================
-- OFFER PDF LABELS (optional) — single-language TR
-- =============================================================

INSERT INTO `site_settings` (`id`,`key`,`value`,`created_at`,`updated_at`) VALUES
(
  UUID(),
  'offer_pdf_labels',
  '{
    "title":"Teklif",
    "quoteNo":"Teklif No",
    "date":"Tarih",
    "validity":"Geçerlilik",
    "status":"Durum",

    "customerInfo":"Müşteri Bilgileri",
    "name":"Ad Soyad",
    "company":"Firma",
    "email":"E-posta",
    "phone":"Telefon",
    "country":"İl/İlçe",
    "formLanguage":"Form dili",
    "service":"Hizmet",

    "summary":"Teklif Özeti",
    "subject":"Konu",
    "noMessage":"Müşteri mesajı bulunmamaktadır.",

    "pricing":"Fiyatlandırma",
    "net":"Net Tutar",
    "vat":"KDV",
    "shipping":"Ulaşım",
    "total":"Genel Toplam",
    "pricingEmpty":"Fiyatlandırma henüz eklenmemiştir; bu belge ön teklif niteliğindedir.",

    "notes":"Notlar",
    "notesLegalTemplate":"Bu belge bilgilendirme amaçlıdır. Nihai fiyat ve koşullar GZL Temizlik tarafından yazılı olarak onaylandığında geçerli olacaktır.",
    "validUntilPartTemplate":"Bu teklif {validUntil} tarihine kadar geçerlidir.",
    "internalNotes":"İdari not (dahili kullanım)",

    "footerLeftTemplate":"{siteName} – Otomatik Teklif Sistemi",
    "footerRight":"Bu PDF sistem tarafından oluşturulmuştur, imza gerektirmez."
  }',
  NOW(3),
  NOW(3)
)
ON DUPLICATE KEY UPDATE `value`=VALUES(`value`), `updated_at`=CURRENT_TIMESTAMP(3);


COMMIT;

SET FOREIGN_KEY_CHECKS = 1;
