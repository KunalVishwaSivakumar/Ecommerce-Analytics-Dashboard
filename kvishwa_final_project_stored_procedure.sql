USE ecommerce_project;
DELIMITER //
CREATE PROCEDURE load_dim_customer()
BEGIN
  INSERT INTO dim_customer (
    customer_id, customer_age, customer_gender, customer_income, customer_loyalty_level,
    effective_date, expire_date, current_flag
  )
  SELECT c.customer_id, c.customer_age, c.customer_gender, c.customer_income, c.customer_loyalty_level,
         CURDATE(), '9999-12-31', 1
  FROM customer c
  LEFT JOIN dim_customer d ON c.customer_id = d.customer_id AND d.current_flag = 1
  WHERE d.customer_id IS NULL;

  INSERT INTO dim_customer (
    customer_id, customer_age, customer_gender, customer_income, customer_loyalty_level,
    effective_date, expire_date, current_flag
  )
  SELECT c.customer_id, c.customer_age, c.customer_gender, c.customer_income, c.customer_loyalty_level,
         CURDATE(), '9999-12-31', 1
  FROM customer c
  JOIN dim_customer d ON c.customer_id = d.customer_id AND d.current_flag = 1
  WHERE c.customer_age <> d.customer_age
     OR c.customer_gender <> d.customer_gender
     OR c.customer_income <> d.customer_income
     OR c.customer_loyalty_level <> d.customer_loyalty_level;

  UPDATE dim_customer d
  JOIN customer c ON d.customer_id = c.customer_id
  SET d.expire_date = CURDATE(), d.current_flag = 0
  WHERE d.current_flag = 1 AND (
    c.customer_age <> d.customer_age
    OR c.customer_gender <> d.customer_gender
    OR c.customer_income <> d.customer_income
    OR c.customer_loyalty_level <> d.customer_loyalty_level
  );
END //


CREATE PROCEDURE load_dim_product()
BEGIN
  INSERT INTO dim_product (product_id, product_name_2024, product_name_2025, category_id)
  SELECT p.product_id, p.product_name, NULL, p.category_id
  FROM product p
  LEFT JOIN dim_product dp ON p.product_id = dp.product_id
  WHERE dp.product_id IS NULL;

  UPDATE dim_product dp
  JOIN product p ON p.product_id = dp.product_id
  SET dp.product_name_2024 = dp.product_name_2024,
      dp.product_name_2025 = p.product_name
  WHERE dp.product_name_2024 <> p.product_name;
END //


CREATE PROCEDURE load_dim_store()
BEGIN
  INSERT INTO dim_store (store_id, store_location)
  SELECT slm.store_id, sl.store_location
  FROM store_location_map slm
  JOIN store_location sl ON slm.store_location_id = sl.store_location_id
  LEFT JOIN dim_store ds 
    ON slm.store_id = ds.store_id AND sl.store_location = ds.store_location
  WHERE ds.store_id IS NULL;
END //

CREATE PROCEDURE load_dim_promotion()
BEGIN
  INSERT INTO dim_promotion (
    promotion_id, promotion_type, promotion_applied,
    effective_date, expire_date, current_flag
  )
  SELECT p.promotion_id, p.promotion_type, p.promotion_applied,
         CURDATE(), '9999-12-31', 1
  FROM promotion p
  LEFT JOIN dim_promotion d ON p.promotion_id = d.promotion_id AND d.current_flag = 1
  WHERE d.promotion_id IS NULL;

  INSERT INTO dim_promotion (
    promotion_id, promotion_type, promotion_applied,
    effective_date, expire_date, current_flag
  )
  SELECT p.promotion_id, p.promotion_type, p.promotion_applied,
         CURDATE(), '9999-12-31', 1
  FROM promotion p
  JOIN dim_promotion d ON p.promotion_id = d.promotion_id AND d.current_flag = 1
  WHERE p.promotion_type <> d.promotion_type OR p.promotion_applied <> d.promotion_applied;

  UPDATE dim_promotion d
  JOIN promotion p ON d.promotion_id = p.promotion_id
  SET d.expire_date = CURDATE(), d.current_flag = 0
  WHERE d.current_flag = 1 AND (
    p.promotion_type <> d.promotion_type OR p.promotion_applied <> d.promotion_applied
  );
END //


CREATE PROCEDURE load_dim_payment()
BEGIN
  INSERT IGNORE INTO dim_payment (method_name)
  SELECT DISTINCT method_name FROM payment_method;
END //


CREATE PROCEDURE load_dim_weather()
BEGIN
  INSERT IGNORE INTO dim_weather (weather_conditions)
  SELECT DISTINCT weather_conditions FROM weather;
END //


CREATE PROCEDURE load_dim_date()
BEGIN
  INSERT IGNORE INTO dim_date (date_key, full_date, day, month, year, weekday)
  SELECT DISTINCT
    DATE_FORMAT(transaction_date, '%Y%m%d'),
    DATE(transaction_date),
    DAY(transaction_date),
    MONTH(transaction_date),
    YEAR(transaction_date),
    DAYNAME(transaction_date)
  FROM transaction;
END //



CALL load_dim_customer();
CALL load_dim_product();
CALL load_dim_store();
CALL load_dim_promotion();
CALL load_dim_payment();
CALL load_dim_weather();
CALL load_dim_date();





#testing SCD type 2
SELECT *
FROM dim_customer
WHERE customer_id = 1043 
ORDER BY effective_date;

SELECT * FROM CUSTOMER
WHERE customer_id = 1043 

UPDATE customer
SET customer_loyalty_level = "Platinum"
WHERE customer_id = 1043;

CALL load_dim_customer();

SELECT *
FROM dim_customer
WHERE customer_id = 1043;

#testing SCD type 2
SELECT * 
FROM dim_promotion
WHERE promotion_type="Flash Sale";

UPDATE promotion
SET promotion_type = "Black Friday Sale"
WHERE promotion_type="Flash Sale";

CALL load_dim_promotion();

SELECT * 
FROM dim_promotion
WHERE promotion_id=4;



#testing SCD type 3
SELECT *
FROM dim_product
WHERE product_id=1000;

UPDATE product
SET product_name = CONCAT('Frigidaire ',product_name)
WHERE product_id = 1000;

CALL load_dim_product();

SELECT *
FROM dim_product
WHERE product_id=1000;

SELECT * from product
WHERE product_id=1000;






DELIMITER //
CREATE PROCEDURE load_fact_sales()
BEGIN
  INSERT IGNORE INTO fact_sales (
    customer_dim_id,
    product_dim_id,
    store_dim_id,
    date_key,
    payment_dim_id,
    promotion_dim_id,
    weather_dim_id,
    quantity_sold,
    unit_price,
    forecasted_demand,
    actual_demand,
    stockout_indicator,
    holiday_indicator
  )
  SELECT
    dc.customer_dim_id,
    dp.product_dim_id,
    ds.store_dim_id,
    dd.date_key,
    dpay.payment_dim_id,
    dpromo.promotion_dim_id,
    dw.weather_dim_id,
    t.quantity_sold,
    t.unit_price,
    t.forecasted_demand,
    t.actual_demand,
    t.stockout_indicator,
    t.holiday_indicator
  FROM transaction t

  JOIN dim_customer dc ON t.customer_id = dc.customer_id AND dc.current_flag = 1
  JOIN dim_product dp ON t.product_id = dp.product_id
  JOIN store_location sl ON t.store_location_id = sl.store_location_id
  JOIN dim_store ds ON t.store_id = ds.store_id AND ds.store_location = sl.store_location
  JOIN dim_date dd ON DATE_FORMAT(t.transaction_date, '%Y%m%d') = dd.date_key
  JOIN dim_payment dpay ON t.payment_method_id = dpay.payment_dim_id
  LEFT JOIN dim_promotion dpromo ON t.promotion_id = dpromo.promotion_id AND dpromo.current_flag = 1
  JOIN dim_weather dw ON t.weather_id = dw.weather_dim_id;
END //
DELIMITER //








CALL load_fact_sales();


SELECT * FROM fact_sales LIMIT 20000;



#mytesting part

SELECT * from dim_product;

SELECT 
    dp.product_name_2025, 
    dp.product_name_2024
FROM 
    fact_sales fs
JOIN 
    dim_product dp ON fs.product_dim_id = dp.product_dim_id
WHERE 
    dp.product_dim_id = 54;


SELECT * FROM fact_sales
where customer_dim_id=8192;


SELECT * FROM dim_store;