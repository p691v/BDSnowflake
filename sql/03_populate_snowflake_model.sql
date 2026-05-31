INSERT INTO mart.dim_country (country_name)
SELECT DISTINCT country_name
FROM (
    SELECT NULLIF(BTRIM(customer_country), '') AS country_name FROM public.mock_data
    UNION
    SELECT NULLIF(BTRIM(seller_country), '') FROM public.mock_data
    UNION
    SELECT NULLIF(BTRIM(store_country), '') FROM public.mock_data
    UNION
    SELECT NULLIF(BTRIM(supplier_country), '') FROM public.mock_data
) src
WHERE country_name IS NOT NULL
ON CONFLICT (country_name) DO NOTHING;

INSERT INTO mart.dim_city (country_id, city_name)
SELECT DISTINCT c.country_id, src.city_name
FROM (
    SELECT NULLIF(BTRIM(store_city), '') AS city_name, NULLIF(BTRIM(store_country), '') AS country_name FROM public.mock_data
    UNION
    SELECT NULLIF(BTRIM(supplier_city), ''), NULLIF(BTRIM(supplier_country), '') FROM public.mock_data
) src
JOIN mart.dim_country c ON c.country_name = src.country_name
WHERE src.city_name IS NOT NULL
ON CONFLICT (country_id, city_name) DO NOTHING;

INSERT INTO mart.dim_pet_type (pet_type_name)
SELECT DISTINCT NULLIF(BTRIM(customer_pet_type), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(customer_pet_type), '') IS NOT NULL
ON CONFLICT (pet_type_name) DO NOTHING;

INSERT INTO mart.dim_pet_breed (pet_breed_name)
SELECT DISTINCT NULLIF(BTRIM(customer_pet_breed), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(customer_pet_breed), '') IS NOT NULL
ON CONFLICT (pet_breed_name) DO NOTHING;

INSERT INTO mart.dim_product_category (product_category_name)
SELECT DISTINCT NULLIF(BTRIM(product_category), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(product_category), '') IS NOT NULL
ON CONFLICT (product_category_name) DO NOTHING;

INSERT INTO mart.dim_pet_category (pet_category_name)
SELECT DISTINCT NULLIF(BTRIM(pet_category), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(pet_category), '') IS NOT NULL
ON CONFLICT (pet_category_name) DO NOTHING;

INSERT INTO mart.dim_product_brand (product_brand_name)
SELECT DISTINCT NULLIF(BTRIM(product_brand), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(product_brand), '') IS NOT NULL
ON CONFLICT (product_brand_name) DO NOTHING;

INSERT INTO mart.dim_product_material (product_material_name)
SELECT DISTINCT NULLIF(BTRIM(product_material), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(product_material), '') IS NOT NULL
ON CONFLICT (product_material_name) DO NOTHING;

INSERT INTO mart.dim_product_color (product_color_name)
SELECT DISTINCT NULLIF(BTRIM(product_color), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(product_color), '') IS NOT NULL
ON CONFLICT (product_color_name) DO NOTHING;

INSERT INTO mart.dim_product_size (product_size_name)
SELECT DISTINCT NULLIF(BTRIM(product_size), '')
FROM public.mock_data
WHERE NULLIF(BTRIM(product_size), '') IS NOT NULL
ON CONFLICT (product_size_name) DO NOTHING;

INSERT INTO mart.dim_date (date_id, full_date, year, quarter, month, day, iso_day_of_week)
SELECT DISTINCT
    TO_CHAR(full_date, 'YYYYMMDD')::integer AS date_id,
    full_date,
    EXTRACT(YEAR FROM full_date)::smallint,
    EXTRACT(QUARTER FROM full_date)::smallint,
    EXTRACT(MONTH FROM full_date)::smallint,
    EXTRACT(DAY FROM full_date)::smallint,
    EXTRACT(ISODOW FROM full_date)::smallint
FROM (
    SELECT TO_DATE(sale_date, 'MM/DD/YYYY') AS full_date FROM public.mock_data
    UNION
    SELECT TO_DATE(product_release_date, 'MM/DD/YYYY') FROM public.mock_data
    UNION
    SELECT TO_DATE(product_expiry_date, 'MM/DD/YYYY') FROM public.mock_data
) src
WHERE full_date IS NOT NULL
ON CONFLICT (date_id) DO NOTHING;

INSERT INTO mart.dim_customer (
    source_customer_key,
    first_name,
    last_name,
    age,
    email,
    country_id,
    postal_code,
    pet_type_id,
    pet_name,
    pet_breed_id
)
SELECT DISTINCT
    m.source_file || ':' || m.sale_customer_id AS source_customer_key,
    m.customer_first_name,
    m.customer_last_name,
    m.customer_age,
    m.customer_email,
    c.country_id,
    NULLIF(BTRIM(m.customer_postal_code), ''),
    pt.pet_type_id,
    NULLIF(BTRIM(m.customer_pet_name), ''),
    pb.pet_breed_id
FROM public.mock_data m
LEFT JOIN mart.dim_country c ON c.country_name = NULLIF(BTRIM(m.customer_country), '')
LEFT JOIN mart.dim_pet_type pt ON pt.pet_type_name = NULLIF(BTRIM(m.customer_pet_type), '')
LEFT JOIN mart.dim_pet_breed pb ON pb.pet_breed_name = NULLIF(BTRIM(m.customer_pet_breed), '')
ON CONFLICT (source_customer_key) DO NOTHING;

INSERT INTO mart.dim_seller (
    source_seller_key,
    first_name,
    last_name,
    email,
    country_id,
    postal_code
)
SELECT DISTINCT
    m.source_file || ':' || m.sale_seller_id AS source_seller_key,
    m.seller_first_name,
    m.seller_last_name,
    m.seller_email,
    c.country_id,
    NULLIF(BTRIM(m.seller_postal_code), '')
FROM public.mock_data m
LEFT JOIN mart.dim_country c ON c.country_name = NULLIF(BTRIM(m.seller_country), '')
ON CONFLICT (source_seller_key) DO NOTHING;

INSERT INTO mart.dim_store (
    source_store_key,
    store_name,
    address_line,
    city_id,
    state_name,
    country_id,
    phone,
    email
)
SELECT DISTINCT
    m.source_file || ':' || m.id AS source_store_key,
    m.store_name,
    NULLIF(BTRIM(m.store_location), ''),
    city.city_id,
    NULLIF(BTRIM(m.store_state), ''),
    c.country_id,
    NULLIF(BTRIM(m.store_phone), ''),
    m.store_email
FROM public.mock_data m
LEFT JOIN mart.dim_country c ON c.country_name = NULLIF(BTRIM(m.store_country), '')
LEFT JOIN mart.dim_city city
    ON city.country_id = c.country_id
    AND city.city_name = NULLIF(BTRIM(m.store_city), '')
ON CONFLICT (source_store_key) DO NOTHING;

INSERT INTO mart.dim_supplier (
    source_supplier_key,
    supplier_name,
    contact_name,
    email,
    phone,
    address_line,
    city_id,
    country_id
)
SELECT DISTINCT
    m.source_file || ':' || m.id AS source_supplier_key,
    m.supplier_name,
    NULLIF(BTRIM(m.supplier_contact), ''),
    m.supplier_email,
    NULLIF(BTRIM(m.supplier_phone), ''),
    NULLIF(BTRIM(m.supplier_address), ''),
    city.city_id,
    c.country_id
FROM public.mock_data m
LEFT JOIN mart.dim_country c ON c.country_name = NULLIF(BTRIM(m.supplier_country), '')
LEFT JOIN mart.dim_city city
    ON city.country_id = c.country_id
    AND city.city_name = NULLIF(BTRIM(m.supplier_city), '')
ON CONFLICT (source_supplier_key) DO NOTHING;

INSERT INTO mart.dim_product (
    source_product_key,
    product_name,
    product_category_id,
    pet_category_id,
    product_brand_id,
    product_material_id,
    product_color_id,
    product_size_id,
    supplier_id,
    weight,
    description,
    rating,
    reviews,
    release_date_id,
    expiry_date_id
)
SELECT DISTINCT
    m.source_file || ':' || m.sale_product_id AS source_product_key,
    m.product_name,
    pc.product_category_id,
    petc.pet_category_id,
    b.product_brand_id,
    mat.product_material_id,
    col.product_color_id,
    sz.product_size_id,
    sup.supplier_id,
    m.product_weight,
    m.product_description,
    m.product_rating,
    m.product_reviews,
    TO_CHAR(TO_DATE(m.product_release_date, 'MM/DD/YYYY'), 'YYYYMMDD')::integer,
    TO_CHAR(TO_DATE(m.product_expiry_date, 'MM/DD/YYYY'), 'YYYYMMDD')::integer
FROM public.mock_data m
LEFT JOIN mart.dim_product_category pc ON pc.product_category_name = NULLIF(BTRIM(m.product_category), '')
LEFT JOIN mart.dim_pet_category petc ON petc.pet_category_name = NULLIF(BTRIM(m.pet_category), '')
LEFT JOIN mart.dim_product_brand b ON b.product_brand_name = NULLIF(BTRIM(m.product_brand), '')
LEFT JOIN mart.dim_product_material mat ON mat.product_material_name = NULLIF(BTRIM(m.product_material), '')
LEFT JOIN mart.dim_product_color col ON col.product_color_name = NULLIF(BTRIM(m.product_color), '')
LEFT JOIN mart.dim_product_size sz ON sz.product_size_name = NULLIF(BTRIM(m.product_size), '')
LEFT JOIN mart.dim_supplier sup ON sup.source_supplier_key = m.source_file || ':' || m.id
ON CONFLICT (source_product_key) DO NOTHING;

INSERT INTO mart.fact_sales (
    source_sale_key,
    sale_date_id,
    customer_id,
    seller_id,
    store_id,
    product_id,
    sale_quantity,
    sale_total_price,
    unit_product_price,
    source_product_quantity
)
SELECT
    m.source_file || ':' || m.id AS source_sale_key,
    TO_CHAR(TO_DATE(m.sale_date, 'MM/DD/YYYY'), 'YYYYMMDD')::integer AS sale_date_id,
    c.customer_id,
    s.seller_id,
    st.store_id,
    p.product_id,
    m.sale_quantity,
    m.sale_total_price,
    m.product_price,
    m.product_quantity
FROM public.mock_data m
JOIN mart.dim_customer c ON c.source_customer_key = m.source_file || ':' || m.sale_customer_id
JOIN mart.dim_seller s ON s.source_seller_key = m.source_file || ':' || m.sale_seller_id
JOIN mart.dim_store st ON st.source_store_key = m.source_file || ':' || m.id
JOIN mart.dim_product p ON p.source_product_key = m.source_file || ':' || m.sale_product_id
ON CONFLICT (source_sale_key) DO NOTHING;
