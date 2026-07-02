-- ============================================
-- Tahap 2: Data Cleaning - View clean_orders
-- ============================================
-- Hanya order berstatus 'delivered' yang dipakai untuk analisis,
-- karena order yang belum sampai/dibatalkan tidak relevan untuk
-- mengukur performa penjualan & pengiriman.

USE olist_sales_analysis;

DROP VIEW IF EXISTS clean_orders;

CREATE VIEW clean_orders AS
SELECT
  o.order_id,
  o.customer_id,
  o.order_purchase_timestamp,
  o.order_delivered_customer_date,
  o.order_estimated_delivery_date,
  DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp) AS delivery_days,
  DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delay_days
FROM orders o
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL;

-- ============================================
-- Verifikasi: cek jumlah baris di view ini
-- ============================================
SELECT COUNT(*) AS total_clean_orders FROM clean_orders;

-- ============================================
-- Verifikasi: lihat contoh datanya
-- ============================================
SELECT * FROM clean_orders LIMIT 10;

-- ============================================
-- Verifikasi: cek delivery_days & delay_days masuk akal
-- (tidak ada angka negatif ekstrem/aneh)
-- ============================================
SELECT
  MIN(delivery_days) AS min_delivery_days,
  MAX(delivery_days) AS max_delivery_days,
  AVG(delivery_days) AS avg_delivery_days,
  MIN(delay_days) AS min_delay_days,
  MAX(delay_days) AS max_delay_days,
  AVG(delay_days) AS avg_delay_days
FROM clean_orders;
