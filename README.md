
E-commerce Analytics Dashboard
==============================

📊 End-to-End Analytics Pipeline using MySQL, Python & Tableau

Author: Kunal Vishwa Sivakumar  
Course: MET CS 779 – Advanced Database Management  
Dataset: Walmart Retail Transactions (10,000+ records)

-------------------------------------------------------------------------------

Project Overview
----------------
This project simulates a real-world retail analytics system by transforming raw Walmart transaction data into actionable business insights.

It includes:
- Data ingestion and ETL using Python
- Normalization into a BCNF-compliant OLTP schema
- Star schema creation with SCD types
- Performance tuning using indexing
- SQL views for business queries
- Tableau dashboards for visualization

-------------------------------------------------------------------------------

Repository Structure
--------------------
- connector.py                           → Python ETL script for inserting data into normalized schema
- kvishwa_final_project_normalise.sql    → OLTP schema (15 normalized tables)
- kvishwa_final_project_star.sql         → OLAP schema (Star Schema with SCD Types 1, 2, 3)
- kvishwa_final_project_stored_procedure.sql → Stored procedures to populate dimensions and fact table
- kvishwa_final_project_view.sql         → SQL views for Tableau analytics
- Walmart_final_customer_updated.csv     → Cleaned transactional dataset
- Dashboard.pdf                          → Tableau dashboard visualizations
- project.drawio                         → ERD for OLTP & OLAP schemas
- SivakumarKunalVishwa_DeltaReport.pdf  → Full technical report
- README.txt                             → This file

-------------------------------------------------------------------------------

OLTP Schema (Normalized Design)
-------------------------------
- 15 relational tables based on BCNF
- Separate entities for product, customer, store, supplier, payment, weather, etc.
- Many-to-many relationships handled with bridge tables (e.g., store_location_map)
- Referential integrity maintained via primary/foreign keys

-------------------------------------------------------------------------------

OLAP Schema (Star Schema)
-------------------------
- Fact Table: fact_sales (measurable transactions)
- Dimension Tables:
  • dim_customer – SCD Type 2
  • dim_product – SCD Type 3
  • dim_store – SCD Type 1
  • dim_date – SCD Type 0
  • dim_promotion – SCD Type 2
  • dim_payment – SCD Type 1
  • dim_weather – SCD Type 1

-------------------------------------------------------------------------------

Stored Procedures
-----------------
Automated transformation from OLTP to OLAP using:
- load_dim_customer()
- load_dim_product()
- load_dim_store()
- load_dim_promotion()
- load_dim_payment()
- load_dim_weather()
- load_dim_date()
- load_fact_sales()

-------------------------------------------------------------------------------

Python ETL
----------
- File: connector.py
- Reads and cleans CSV data
- Inserts values into OLTP schema
- Handles category, supplier, promotion, and foreign key mappings

-------------------------------------------------------------------------------

SQL Views & Tableau Dashboards
------------------------------
Views created for reporting:
- vw_monthly_sales_by_store
- vw_promotion_effectiveness
- vw_top_selling_products
- vw_monthly_top_store_sales

These views are connected to Tableau to build interactive dashboards for:
- Monthly sales per store
- Promotion vs. sales effectiveness
- Top 10 best-selling products
- Store performance comparison

-------------------------------------------------------------------------------

📌 Tableau Dashboard  
The project includes interactive visualizations answering key business questions:
- Monthly total quantity per store
- Sales trends with vs without promotions
- Top 10 products by quantity sold
- Monthly sales per store location

![image](https://github.com/user-attachments/assets/92b9db91-e55f-4c29-a621-a7f5255bdfc4)


-------------------------------------------------------------------------------

Features Implemented
---------------------
✅ Fully normalized OLTP schema (BCNF)  
✅ Star schema design for OLAP  
✅ Support for SCD Types 1, 2, and 3  
✅ Python ETL pipeline  
✅ Indexing and query optimization  
✅ Stored procedures for automation  
✅ SQL views for analytics  
✅ Tableau dashboard for insights  

-------------------------------------------------------------------------------

How to Run the Project
----------------------
1. Execute kvishwa_final_project_normalise.sql to create OLTP schema in MySQL
2. Run connector.py to load data into MySQL
3. Execute kvishwa_final_project_star.sql to create the star schema
4. Run kvishwa_final_project_stored_procedure.sql to populate dimensions and fact table
5. Use Tableau and connect to views from kvishwa_final_project_view.sql

-------------------------------------------------------------------------------

Final Report
------------
- SivakumarKunalVishwa_DeltaReport.pdf  
  → Contains methodology, ER diagrams, optimizations, and analysis

-------------------------------------------------------------------------------

Contact
-------
Kunal Vishwa Sivakumar  
Email: kvishwa@bu.edu  
Program: MS in Applied Data Analytics, Boston University

-------------------------------------------------------------------------------
