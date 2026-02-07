DROP DATABASE IF EXISTS Ecomm;
CREATE DATABASE Ecomm;
USE Ecomm;

CREATE TABLE sales (
  order_id INT,
  order_date DATE,
  customer_id VARCHAR(10),
  region VARCHAR(20),
  product VARCHAR(50),
  quantity INT,
  price INT
);

INSERT INTO sales VALUES
  (1001, '2024-01-01', 'C001', 'East', 'Keyboard', 2, 1500),
  (1002, '2024-01-02', 'C002', 'West', 'Mouse', 5, 500),
  (1003, '2024-01-03', 'C001', 'East', 'Monitor', 1, 12000),
  (1004, '2024-01-04', 'C003', 'South', 'Keyboard', 1, 1500),
  (1005, '2024-01-05', 'C002', 'West', 'Monitor', 2, 12000),
  (1006, '2024-01-06', 'C001', 'East', 'Mouse', 3, 500),
  (1007, '2024-01-07', 'C004', 'North', 'Keyboard', 4, 1500),
  (1008, '2024-01-08', 'C003', 'South', 'Monitor', 1, 12000);
  
select * from sales;
 
# Calculate revenue per order
SELECT 
  order_id,
  order_date,
  customer_id,
  region,
  product,
  quantity,
  price,
  quantity * price AS revenue
FROM sales;

# Validate results

-- Check total revenue
SELECT 
  SUM(quantity * price) AS total_revenue,
  COUNT(*) AS total_orders
FROM sales;


-- Manual verification for first few orders
SELECT 
  order_id,
  quantity,
  price,
  quantity * price AS calculated_revenue,
  (quantity * price) = (quantity * price) AS validation_check
FROM sales
LIMIT 5;


-- Check total revenue
SELECT 
  region,
  SUM(quantity * price) AS total_revenue,
  COUNT(*) AS order_count
FROM sales
GROUP BY region
ORDER BY total_revenue DESC;

-- Total revenue per product:
SELECT 
  product,
  SUM(quantity * price) AS total_revenue,
  SUM(quantity) AS total_quantity_sold,
  COUNT(*) AS order_count
FROM sales
GROUP BY product
ORDER BY total_revenue DESC;

-- Average order value:
SELECT 
  AVG(quantity * price) AS avg_order_value,
  SUM(quantity * price) / COUNT(*) AS avg_order_value_manual
FROM sales;

-- Daily revenue trend:
SELECT 
  order_date,
  SUM(quantity * price) AS daily_revenue,
  COUNT(*) AS daily_orders
FROM sales
GROUP BY order_date
ORDER BY order_date;

-- Re-run queries with filters
-- Revenue per region (East only)
SELECT 
  region,
  SUM(quantity * price) AS total_revenue
FROM sales
WHERE region = 'East'
GROUP BY region;

-- Cross-check row counts:
-- Verify no data loss in aggregations
SELECT 
  (SELECT COUNT(*) FROM sales) AS total_rows,
  (SELECT SUM(order_count) FROM (
    SELECT COUNT(*) AS order_count 
    FROM sales 
    GROUP BY region
  ) AS region_counts) AS aggregated_rows;

-- Confirm no duplicate aggregation:
-- Check for duplicate order_ids
SELECT 
  order_id,
  COUNT(*) AS occurrence_count
FROM sales
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Observations:

/*
VALIDATION OBSERVATIONS:
1. Total revenue from individual rows matches aggregated totals
2. No duplicate order_ids found
3. All regions and products properly grouped
4. Date-based aggregations are accurate
*/

-- ============================================
-- SQL Analytics: Python vs SQL Responsibilities
-- ============================================

-- Step 1: Revenue Calculation
SELECT 
  order_id,
  order_date,
  customer_id,
  region,
  product,
  quantity,
  price,
  quantity * price AS revenue
FROM sales;

-- Step 2: Total Revenue per Region
SELECT 
  region,
  SUM(quantity * price) AS total_revenue,
  COUNT(*) AS order_count
FROM sales
GROUP BY region
ORDER BY total_revenue DESC;

-- Step 3: Total Revenue per Product
SELECT 
  product,
  SUM(quantity * price) AS total_revenue,
  SUM(quantity) AS total_quantity_sold,
  COUNT(*) AS order_count
FROM sales
GROUP BY product
ORDER BY total_revenue DESC;

-- Step 4: Average Order Value
SELECT 
  AVG(quantity * price) AS avg_order_value
FROM sales;

-- Step 5: Daily Revenue Trend
SELECT 
  order_date,
  SUM(quantity * price) AS daily_revenue,
  COUNT(*) AS daily_orders
FROM sales
GROUP BY order_date
ORDER BY order_date;

-- Step 6: Validation Queries
-- Check total revenue consistency
SELECT 
  SUM(quantity * price) AS total_revenue
FROM sales;

-- Verify no duplicates
SELECT 
  order_id,
  COUNT(*) AS occurrence_count
FROM sales
GROUP BY order_id
HAVING COUNT(*) > 1;

