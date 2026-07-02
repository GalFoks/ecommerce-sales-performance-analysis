-- ============================================
-- Tahap 4 - Persiapan: Export data untuk Python
-- ============================================
USE olist_sales_analysis;

-- ============================================
-- Export 1: Data bulanan untuk chart tren (dari Q1)
-- ============================================
SELECT
  DATE_FORMAT(co.order_purchase_timestamp, '%Y-%m') AS month,
  COUNT(DISTINCT co.order_id) AS total_orders,
  ROUND(SUM(oi.price), 2) AS total_revenue,
  ROUND(SUM(oi.price) / COUNT(DISTINCT co.order_id), 2) AS avg_order_value
FROM clean_orders co
JOIN order_items oi ON co.order_id = oi.order_id
GROUP BY month
ORDER BY month;
-- Setelah run, export hasil ini sebagai: data/processed/monthly_sales.csv

-- ============================================
-- Export 2: Data per-order untuk uji statistik Q4
-- (delay_days & review_score per order, BUKAN diagregasi)
-- Ini dibutuhkan karena uji korelasi butuh data mentah per baris,
-- bukan angka rata-rata yang sudah diringkas.
-- ============================================
SELECT
  co.order_id,
  co.delay_days,
  CASE WHEN co.delay_days > 0 THEN 1 ELSE 0 END AS is_delayed,
  r.review_score
FROM clean_orders co
JOIN order_reviews r ON co.order_id = r.order_id
WHERE r.review_score IS NOT NULL;
-- Setelah run, export hasil ini sebagai: data/processed/delay_review_raw.csv
