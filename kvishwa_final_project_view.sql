USE ecommerce_project;
#What are the monthly total sales and quantity sold per store location?
CREATE OR REPLACE VIEW vw_monthly_sales_by_store AS
SELECT 
    dd.year,
    dd.month,
    ds.store_location,
    SUM(fs.quantity_sold) AS total_quantity,
    ROUND(SUM(fs.quantity_sold * fs.unit_price), 2) AS total_sales
FROM fact_sales fs
JOIN dim_date dd ON fs.date_key = dd.date_key
JOIN dim_store ds ON fs.store_dim_id = ds.store_dim_id
GROUP BY dd.year, dd.month, ds.store_location;

SELECT * FROM vw_monthly_sales_by_store;

#How effective were promotions in increasing total sales volume?
CREATE OR REPLACE VIEW vw_promotion_effectiveness AS
SELECT 
    CASE 
        WHEN dpromo.promotion_applied = 1 THEN 'With Promotion'
        ELSE 'No Promotion'
    END AS promotion_status,
    SUM(fs.quantity_sold) AS total_quantity,
    ROUND(SUM(fs.quantity_sold * fs.unit_price), 2) AS total_sales
FROM fact_sales fs
LEFT JOIN dim_promotion dpromo ON fs.promotion_dim_id = dpromo.promotion_dim_id
GROUP BY promotion_status;

SELECT * FROM vw_promotion_effectiveness;


#What are the top 10 best-selling products based on total quantity sold?
CREATE OR REPLACE VIEW vw_top_selling_products AS
SELECT 
    dp.product_name_2025 AS product_name,
    SUM(fs.quantity_sold) AS total_quantity_sold,
    ROUND(SUM(fs.quantity_sold * fs.unit_price), 2) AS total_revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_dim_id = dp.product_dim_id
GROUP BY dp.product_name_2025
ORDER BY total_quantity_sold DESC
LIMIT 10;
SELECT * FROM vw_top_selling_products;

#Which store had the highest sales during a specific month?
CREATE OR REPLACE VIEW vw_monthly_top_store_sales AS
SELECT 
    dd.year,
    dd.month,
    ds.store_location,
    ROUND(SUM(fs.quantity_sold * fs.unit_price), 2) AS total_sales
FROM fact_sales fs
JOIN dim_date dd ON fs.date_key = dd.date_key
JOIN dim_store ds ON fs.store_dim_id = ds.store_dim_id
GROUP BY dd.year, dd.month, ds.store_location;


SELECT * 
FROM vw_monthly_top_store_sales
WHERE year = 2024 AND month = 8
ORDER BY total_sales DESC
LIMIT 1;


SELECT * FROM TRANSACTION WHERE product_id=1004;
#indexing
CREATE INDEX idx_product_name ON transaction(product_id);
SELECT * FROM TRANSACTION WHERE product_id=1004;

DROP INDEX idx_product_name ON TRANSACTION;

