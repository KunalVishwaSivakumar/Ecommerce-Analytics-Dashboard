USE ecommerce_project;

#SCD TYPE 2
CREATE TABLE dim_customer (
    customer_dim_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    customer_age INT,
    customer_gender VARCHAR(10),
    customer_income FLOAT,
    customer_loyalty_level VARCHAR(20),
    effective_date DATE,
    expire_date DATE,
    current_flag BOOLEAN
);

#SCD TYPE 3
CREATE TABLE dim_product (
    product_dim_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    product_name_2024 VARCHAR(100),
    product_name_2025 VARCHAR(100),
    category_id INT
);

#SCD TYPE 1
CREATE TABLE dim_store (
  store_dim_id INT AUTO_INCREMENT PRIMARY KEY,
  store_id INT,
  store_location VARCHAR(100),
  UNIQUE (store_id, store_location)
);


#SCD TYPE 0
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,  -- format YYYYMMDD
    full_date DATE,
    day INT,
    month INT,
    year INT,
    weekday VARCHAR(15)
);

#SCD TYPE 1
CREATE TABLE dim_payment (
    payment_dim_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50) UNIQUE
);

#SCD TYPE 2
CREATE TABLE dim_promotion (
    promotion_dim_id INT AUTO_INCREMENT PRIMARY KEY,
    promotion_id INT,
    promotion_type VARCHAR(50),
    promotion_applied BOOLEAN,
    effective_date DATE,
    expire_date DATE,
    current_flag BOOLEAN
);

#SCD TYPE 1
CREATE TABLE dim_weather (
    weather_dim_id INT AUTO_INCREMENT PRIMARY KEY,
    weather_conditions VARCHAR(50) UNIQUE
);


CREATE TABLE fact_sales (
  customer_dim_id INT,
  product_dim_id INT,
  store_dim_id INT,
  date_key INT,
  payment_dim_id INT,
  promotion_dim_id INT,
  weather_dim_id INT,
  quantity_sold INT,
  unit_price FLOAT,
  forecasted_demand INT,
  actual_demand INT,
  stockout_indicator BOOLEAN,
  holiday_indicator BOOLEAN,
  PRIMARY KEY (
    customer_dim_id,
    product_dim_id,
    store_dim_id,
    date_key,
    payment_dim_id,
    promotion_dim_id,
    weather_dim_id
  ),
  FOREIGN KEY (customer_dim_id) REFERENCES dim_customer(customer_dim_id),
  FOREIGN KEY (product_dim_id) REFERENCES dim_product(product_dim_id),
  FOREIGN KEY (store_dim_id) REFERENCES dim_store(store_dim_id),
  FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
  FOREIGN KEY (payment_dim_id) REFERENCES dim_payment(payment_dim_id),
  FOREIGN KEY (promotion_dim_id) REFERENCES dim_promotion(promotion_dim_id),
  FOREIGN KEY (weather_dim_id) REFERENCES dim_weather(weather_dim_id)
);


SELECT * from fact_sales LIMIT 50000;
SELECT * FROM dim_product LIMIT 20000;
SELECT * FROM dim_store
where store_id=1;

