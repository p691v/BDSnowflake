CREATE OR REPLACE VIEW mart.v_row_count_check AS
SELECT 'source_mock_data' AS object_name, COUNT(*) AS row_count FROM public.mock_data
UNION ALL
SELECT 'fact_sales', COUNT(*) FROM mart.fact_sales
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM mart.dim_customer
UNION ALL
SELECT 'dim_seller', COUNT(*) FROM mart.dim_seller
UNION ALL
SELECT 'dim_product', COUNT(*) FROM mart.dim_product
UNION ALL
SELECT 'dim_store', COUNT(*) FROM mart.dim_store
UNION ALL
SELECT 'dim_supplier', COUNT(*) FROM mart.dim_supplier;

CREATE OR REPLACE VIEW mart.v_fact_integrity_check AS
SELECT
    COUNT(*) AS fact_rows,
    COUNT(DISTINCT source_sale_key) AS distinct_source_sales,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_fk,
    COUNT(*) FILTER (WHERE seller_id IS NULL) AS missing_seller_fk,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_fk,
    COUNT(*) FILTER (WHERE store_id IS NULL) AS missing_store_fk,
    SUM(sale_quantity) AS total_items_sold,
    SUM(sale_total_price) AS total_revenue,
    SUM(total_price_delta) AS total_source_price_delta
FROM mart.fact_sales;

CREATE OR REPLACE VIEW mart.v_sales_by_product_category AS
SELECT
    pc.product_category_name,
    COUNT(*) AS sales_count,
    SUM(f.sale_quantity) AS items_sold,
    SUM(f.sale_total_price) AS revenue
FROM mart.fact_sales f
JOIN mart.dim_product p ON p.product_id = f.product_id
JOIN mart.dim_product_category pc ON pc.product_category_id = p.product_category_id
GROUP BY pc.product_category_name
ORDER BY revenue DESC;

CREATE OR REPLACE VIEW mart.v_sales_by_country AS
SELECT
    co.country_name AS store_country,
    COUNT(*) AS sales_count,
    SUM(f.sale_quantity) AS items_sold,
    SUM(f.sale_total_price) AS revenue
FROM mart.fact_sales f
JOIN mart.dim_store st ON st.store_id = f.store_id
JOIN mart.dim_country co ON co.country_id = st.country_id
GROUP BY co.country_name
ORDER BY revenue DESC;
