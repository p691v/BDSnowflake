DROP SCHEMA IF EXISTS mart CASCADE;
CREATE SCHEMA mart;

CREATE TABLE mart.dim_country (
    country_id bigserial PRIMARY KEY,
    country_name text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_city (
    city_id bigserial PRIMARY KEY,
    country_id bigint NOT NULL REFERENCES mart.dim_country(country_id),
    city_name text NOT NULL,
    UNIQUE (country_id, city_name)
);

CREATE TABLE mart.dim_pet_type (
    pet_type_id bigserial PRIMARY KEY,
    pet_type_name text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_pet_breed (
    pet_breed_id bigserial PRIMARY KEY,
    pet_breed_name text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_product_category (
    product_category_id bigserial PRIMARY KEY,
    product_category_name text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_pet_category (
    pet_category_id bigserial PRIMARY KEY,
    pet_category_name text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_product_brand (
    product_brand_id bigserial PRIMARY KEY,
    product_brand_name text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_product_material (
    product_material_id bigserial PRIMARY KEY,
    product_material_name text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_product_color (
    product_color_id bigserial PRIMARY KEY,
    product_color_name text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_product_size (
    product_size_id bigserial PRIMARY KEY,
    product_size_name text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_date (
    date_id integer PRIMARY KEY,
    full_date date NOT NULL UNIQUE,
    year smallint NOT NULL,
    quarter smallint NOT NULL,
    month smallint NOT NULL,
    day smallint NOT NULL,
    iso_day_of_week smallint NOT NULL
);

CREATE TABLE mart.dim_customer (
    customer_id bigserial PRIMARY KEY,
    source_customer_key text NOT NULL UNIQUE,
    first_name text NOT NULL,
    last_name text NOT NULL,
    age integer,
    email text NOT NULL UNIQUE,
    country_id bigint REFERENCES mart.dim_country(country_id),
    postal_code text,
    pet_type_id bigint REFERENCES mart.dim_pet_type(pet_type_id),
    pet_name text,
    pet_breed_id bigint REFERENCES mart.dim_pet_breed(pet_breed_id)
);

CREATE TABLE mart.dim_seller (
    seller_id bigserial PRIMARY KEY,
    source_seller_key text NOT NULL UNIQUE,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL UNIQUE,
    country_id bigint REFERENCES mart.dim_country(country_id),
    postal_code text
);

CREATE TABLE mart.dim_store (
    store_id bigserial PRIMARY KEY,
    source_store_key text NOT NULL UNIQUE,
    store_name text NOT NULL,
    address_line text,
    city_id bigint REFERENCES mart.dim_city(city_id),
    state_name text,
    country_id bigint REFERENCES mart.dim_country(country_id),
    phone text,
    email text NOT NULL UNIQUE
);

CREATE TABLE mart.dim_supplier (
    supplier_id bigserial PRIMARY KEY,
    source_supplier_key text NOT NULL UNIQUE,
    supplier_name text NOT NULL,
    contact_name text,
    email text NOT NULL UNIQUE,
    phone text,
    address_line text,
    city_id bigint REFERENCES mart.dim_city(city_id),
    country_id bigint REFERENCES mart.dim_country(country_id)
);

CREATE TABLE mart.dim_product (
    product_id bigserial PRIMARY KEY,
    source_product_key text NOT NULL UNIQUE,
    product_name text NOT NULL,
    product_category_id bigint REFERENCES mart.dim_product_category(product_category_id),
    pet_category_id bigint REFERENCES mart.dim_pet_category(pet_category_id),
    product_brand_id bigint REFERENCES mart.dim_product_brand(product_brand_id),
    product_material_id bigint REFERENCES mart.dim_product_material(product_material_id),
    product_color_id bigint REFERENCES mart.dim_product_color(product_color_id),
    product_size_id bigint REFERENCES mart.dim_product_size(product_size_id),
    supplier_id bigint REFERENCES mart.dim_supplier(supplier_id),
    weight numeric(12, 2),
    description text,
    rating numeric(3, 1),
    reviews integer,
    release_date_id integer REFERENCES mart.dim_date(date_id),
    expiry_date_id integer REFERENCES mart.dim_date(date_id)
);

CREATE TABLE mart.fact_sales (
    sale_id bigserial PRIMARY KEY,
    source_sale_key text NOT NULL UNIQUE,
    sale_date_id integer NOT NULL REFERENCES mart.dim_date(date_id),
    customer_id bigint NOT NULL REFERENCES mart.dim_customer(customer_id),
    seller_id bigint NOT NULL REFERENCES mart.dim_seller(seller_id),
    store_id bigint NOT NULL REFERENCES mart.dim_store(store_id),
    product_id bigint NOT NULL REFERENCES mart.dim_product(product_id),
    sale_quantity integer NOT NULL CHECK (sale_quantity > 0),
    sale_total_price numeric(12, 2) NOT NULL,
    unit_product_price numeric(12, 2) NOT NULL,
    source_product_quantity integer,
    computed_total_price numeric(12, 2) GENERATED ALWAYS AS (unit_product_price * sale_quantity) STORED,
    total_price_delta numeric(12, 2) GENERATED ALWAYS AS (sale_total_price - unit_product_price * sale_quantity) STORED
);

CREATE INDEX ix_dim_city_country ON mart.dim_city(country_id);
CREATE INDEX ix_dim_customer_country ON mart.dim_customer(country_id);
CREATE INDEX ix_dim_seller_country ON mart.dim_seller(country_id);
CREATE INDEX ix_dim_store_city ON mart.dim_store(city_id);
CREATE INDEX ix_dim_supplier_city ON mart.dim_supplier(city_id);
CREATE INDEX ix_dim_product_supplier ON mart.dim_product(supplier_id);
CREATE INDEX ix_fact_sales_date ON mart.fact_sales(sale_date_id);
CREATE INDEX ix_fact_sales_customer ON mart.fact_sales(customer_id);
CREATE INDEX ix_fact_sales_product ON mart.fact_sales(product_id);
