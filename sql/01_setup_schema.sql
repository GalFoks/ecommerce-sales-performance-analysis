-- ============================================
-- Tahap 0: Setup Database
-- ============================================
-- Jalankan ini dulu sebelum menjalankan load_data_to_mysql.py

CREATE DATABASE IF NOT EXISTS olist_sales_analysis
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE olist_sales_analysis;

-- Setelah load_data_to_mysql.py dijalankan, tabel-tabel berikut
-- seharusnya sudah ada:
--   orders, order_items, customers, products,
--   order_payments, order_reviews, sellers,
--   geolocation, product_category_translation

-- ============================================
-- Verifikasi: cek jumlah baris tiap tabel
-- ============================================
SELECT 'orders' AS table_name, COUNT(*) AS total_rows FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL
SELECT 'customers', COUNT(*) FROM customers
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL
SELECT 'order_reviews', COUNT(*) FROM order_reviews
UNION ALL
SELECT 'sellers', COUNT(*) FROM sellers;

-- ============================================
-- Cek struktur tabel orders (pastikan nama kolom sesuai)
-- ============================================
DESCRIBE orders;

-- ============================================
-- Cek missing values di kolom kunci tabel orders
-- ============================================
SELECT
  COUNT(*) AS total_orders,
  SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS missing_delivery,
  SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS missing_approved,
  SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS status_delivered_count
FROM orders;
