drop database ecommerce_project;
CREATE DATABASE ecommerce_project;
USE ecommerce_project;


CREATE TABLE customer (
    customer_id INT PRIMARY KEY,
    customer_age INT,
    customer_gender VARCHAR(10),
    customer_income FLOAT,
    customer_loyalty_level VARCHAR(20)
);


CREATE TABLE category (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) UNIQUE
);


CREATE TABLE product (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    FOREIGN KEY (category_id) REFERENCES category(category_id)
);


CREATE TABLE store (
    store_id INT PRIMARY KEY
);


CREATE TABLE store_location (
    store_location_id INT AUTO_INCREMENT PRIMARY KEY,
    store_location VARCHAR(100) UNIQUE
);


CREATE TABLE store_location_map (
    store_id INT,
    store_location_id INT,
    PRIMARY KEY (store_id, store_location_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id),
    FOREIGN KEY (store_location_id) REFERENCES store_location(store_location_id)
);


CREATE TABLE supplier (
    supplier_id INT PRIMARY KEY
);




CREATE TABLE product_supplier_map (
    product_id INT,
    supplier_id INT,
    supplier_lead_time INT,
    PRIMARY KEY (product_id, supplier_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (supplier_id) REFERENCES supplier(supplier_id)
);


CREATE TABLE payment_method (
    payment_method_id INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50) UNIQUE
);


CREATE TABLE promotion (
    promotion_id INT AUTO_INCREMENT PRIMARY KEY,
    promotion_type VARCHAR(50),
    promotion_applied BOOLEAN
);


CREATE TABLE weather (
    weather_id INT AUTO_INCREMENT PRIMARY KEY,
    weather_conditions VARCHAR(50) UNIQUE
);


CREATE TABLE product_store_inventory_map (
    product_id INT,
    store_id INT,
    inventory_level INT,
    reorder_point INT,
    reorder_quantity INT,
    PRIMARY KEY (product_id, store_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (store_id) REFERENCES store(store_id)
);


CREATE TABLE transaction (
    transaction_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    store_id INT,
    store_location_id INT,  
    transaction_date DATETIME,
    quantity_sold INT,
    unit_price FLOAT,
    payment_method_id INT,
    promotion_id INT,
    weather_id INT,
    holiday_indicator BOOLEAN,
    weekday VARCHAR(15),
    forecasted_demand INT,
    actual_demand INT,
    stockout_indicator BOOLEAN,
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (product_id) REFERENCES product(product_id),
    FOREIGN KEY (store_id, store_location_id) REFERENCES store_location_map(store_id, store_location_id),
    FOREIGN KEY (payment_method_id) REFERENCES payment_method(payment_method_id),
    FOREIGN KEY (promotion_id) REFERENCES promotion(promotion_id),
    FOREIGN KEY (weather_id) REFERENCES weather(weather_id)
);    




Select * from product_supplier_map LIMIT 20000;
SELECT * FROM supplier;
SELECT * FROM PRODUCT ;
SELECT * FROM TRANSACTION WHERE product_id=1004;
SELECT * FROM TRANSACTION WHERE transaction_date = '2024-03-31 21:46:00';
SELECT * FROM TRANSACTION LIMIT 10000;
SELECT * FROM CUSTOMER limit 10000;


SELECT * FROM product;
SELECT * FROM store_location;