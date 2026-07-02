"""
Load Olist Brazilian E-Commerce CSVs into MySQL database.

Prasyarat:
- MySQL server sudah jalan
- Database `olist_sales_analysis` sudah dibuat (CREATE DATABASE olist_sales_analysis;)
- Semua file CSV asli Kaggle ada di folder data/raw/

Install dependency:
    pip install pandas sqlalchemy pymysql
"""

import pandas as pd
from sqlalchemy import create_engine
import os

# ====== KONFIGURASI — SESUAIKAN DENGAN SETUP KAMU ======
DB_USER = "root"
DB_PASSWORD = "rogue377"
DB_HOST = "localhost"
DB_PORT = "3306"
DB_NAME = "olist_sales_analysis"

RAW_DATA_DIR = "data/raw"
# =========================================================

# Mapping nama file CSV Kaggle -> nama tabel MySQL yang lebih rapi
FILE_TABLE_MAP = {
    "olist_orders_dataset.csv": "orders",
    "olist_order_items_dataset.csv": "order_items",
    "olist_customers_dataset.csv": "customers",
    "olist_products_dataset.csv": "products",
    "olist_order_payments_dataset.csv": "order_payments",
    "olist_order_reviews_dataset.csv": "order_reviews",
    "olist_sellers_dataset.csv": "sellers",
    "olist_geolocation_dataset.csv": "geolocation",
    "product_category_name_translation.csv": "product_category_translation",
}

def main():
    engine = create_engine(
        f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )

    for filename, table_name in FILE_TABLE_MAP.items():
        filepath = os.path.join(RAW_DATA_DIR, filename)
        if not os.path.exists(filepath):
            print(f"[SKIP] {filename} tidak ditemukan di {RAW_DATA_DIR}")
            continue

        print(f"[LOADING] {filename} -> table `{table_name}` ...")
        df = pd.read_csv(filepath)

        # Load ke MySQL, replace kalau tabel sudah ada (biar bisa re-run script ini)
        df.to_sql(table_name, con=engine, if_exists="replace", index=False, chunksize=5000)

        print(f"[DONE] {table_name}: {len(df):,} baris berhasil di-load.")

    print("\nSemua tabel selesai di-load. Lanjut ke verifikasi jumlah baris di SQL.")

if __name__ == "__main__":
    main()
