-- ============================================
-- Perbaikan Tipe Data: TEXT -> DATETIME
-- ============================================
-- Kolom tanggal ter-import sebagai TEXT, perlu diubah
-- ke DATETIME supaya bisa dipakai DATEDIFF, DATE_FORMAT, dll.

USE olist_sales_analysis;

SET SQL_SAFE_UPDATES = 0;

-- Langkah 1: Ubah string kosong '' menjadi NULL dulu (kalau ada)
-- Ini jaga-jaga, karena kadang pandas menyimpan nilai kosong sebagai '' bukan NULL
UPDATE orders SET order_purchase_timestamp = NULL WHERE order_purchase_timestamp = '';
UPDATE orders SET order_approved_at = NULL WHERE order_approved_at = '';
UPDATE orders SET order_delivered_carrier_date = NULL WHERE order_delivered_carrier_date = '';
UPDATE orders SET order_delivered_customer_date = NULL WHERE order_delivered_customer_date = '';
UPDATE orders SET order_estimated_delivery_date = NULL WHERE order_estimated_delivery_date = '';

-- Langkah 2: Ubah tipe kolom dari TEXT menjadi DATETIME
ALTER TABLE orders MODIFY COLUMN order_purchase_timestamp DATETIME;
ALTER TABLE orders MODIFY COLUMN order_approved_at DATETIME;
ALTER TABLE orders MODIFY COLUMN order_delivered_carrier_date DATETIME;
ALTER TABLE orders MODIFY COLUMN order_delivered_customer_date DATETIME;
ALTER TABLE orders MODIFY COLUMN order_estimated_delivery_date DATETIME;

-- Langkah 3: Verifikasi ulang - cek tipe data sudah benar
DESCRIBE orders;

-- Langkah 4: Tes cepat - coba hitung selisih hari, harus jalan tanpa error
SELECT
  order_id,
  order_purchase_timestamp,
  order_delivered_customer_date,
  DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS delivery_days
FROM orders
WHERE order_delivered_customer_date IS NOT NULL
LIMIT 5;
