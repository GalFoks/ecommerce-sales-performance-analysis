-- ============================================
-- Tahap 3: 6 Business Questions
-- ============================================
USE olist_sales_analysis;

-- ============================================
-- Q1: Tren Penjualan Bulanan
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

-- ============================================
-- Q2: Kategori Produk Terbaik & Terburuk
-- ============================================
SELECT
  p.product_category_name,
  ROUND(SUM(oi.price), 2) AS total_revenue,
  COUNT(DISTINCT oi.order_id) AS total_orders,
  RANK() OVER (ORDER BY SUM(oi.price) DESC) AS revenue_rank
FROM clean_orders co
JOIN order_items oi ON co.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY total_revenue DESC;

-- Kategori dengan revenue terendah (10 terbawah)
SELECT
  p.product_category_name,
  ROUND(SUM(oi.price), 2) AS total_revenue,
  COUNT(DISTINCT oi.order_id) AS total_orders
FROM clean_orders co
JOIN order_items oi ON co.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE p.product_category_name IS NOT NULL
GROUP BY p.product_category_name
ORDER BY total_revenue ASC
LIMIT 10;

-- ============================================
-- Q3: Performa per Wilayah (State)
-- ============================================
SELECT
  c.customer_state,
  COUNT(DISTINCT co.order_id) AS total_orders,
  ROUND(AVG(co.delivery_days), 1) AS avg_delivery_days,
  ROUND(SUM(oi.price), 2) AS total_revenue
FROM clean_orders co
JOIN customers c ON co.customer_id = c.customer_id
JOIN order_items oi ON co.order_id = oi.order_id
GROUP BY c.customer_state
ORDER BY total_revenue DESC;

-- ============================================
-- Q4: Korelasi Keterlambatan vs Review Score
-- ============================================
SELECT
  CASE
    WHEN co.delay_days > 0 THEN 'Terlambat'
    ELSE 'Tepat Waktu / Lebih Cepat'
  END AS delivery_status,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  COUNT(*) AS total_orders
FROM clean_orders co
JOIN order_reviews r ON co.order_id = r.order_id
GROUP BY delivery_status;

-- ============================================
-- Q5: Metode Pembayaran
-- ============================================
SELECT
  op.payment_type,
  COUNT(DISTINCT op.order_id) AS total_orders,
  ROUND(AVG(op.payment_value), 2) AS avg_payment_value,
  ROUND(SUM(op.payment_value), 2) AS total_payment_value
FROM clean_orders co
JOIN order_payments op ON co.order_id = op.order_id
GROUP BY op.payment_type
ORDER BY total_orders DESC;

-- ============================================
-- Q6: Pareto Analysis - Top 20% Customer
-- ============================================
WITH customer_revenue AS (
  SELECT
    co.customer_id,
    SUM(oi.price) AS total_spent
  FROM clean_orders co
  JOIN order_items oi ON co.order_id = oi.order_id
  GROUP BY co.customer_id
),
ranked AS (
  SELECT *,
    PERCENT_RANK() OVER (ORDER BY total_spent DESC) AS pct_rank
  FROM customer_revenue
)
SELECT
  CASE WHEN pct_rank <= 0.2 THEN 'Top 20%' ELSE 'Bottom 80%' END AS customer_tier,
  COUNT(*) AS num_customers,
  ROUND(SUM(total_spent), 2) AS total_revenue,
  ROUND(SUM(total_spent) * 100.0 / (SELECT SUM(total_spent) FROM customer_revenue), 1) AS pct_of_total_revenue
FROM ranked
GROUP BY customer_tier;
