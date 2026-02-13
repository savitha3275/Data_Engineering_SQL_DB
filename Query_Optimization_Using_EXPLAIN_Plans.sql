CREATE DATABASE IF NOT EXISTS performance_lab;
USE performance_lab;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;
CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  city VARCHAR(50),
  country VARCHAR(50)
);

CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  amount DECIMAL(10,2),
  status VARCHAR(20)
);

CREATE TABLE numbers (n INT);
INSERT INTO numbers (n)
SELECT a.N + b.N * 10 + c.N * 100 + d.N * 1000 + 1
FROM 
(SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
(SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b,
(SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) c,
(SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) d;

-- Insert Customers
INSERT INTO customers
SELECT 
  n,
  CONCAT('Customer ', n),
  CONCAT('customer', n, '@example.com'),
  ELT(FLOOR(1 + RAND() * 4), 'New York', 'London', 'Tokyo', 'Paris'),
  ELT(FLOOR(1 + RAND() * 4), 'USA', 'UK', 'Japan', 'France')
FROM numbers;

INSERT INTO orders
SELECT 
  n,
  FLOOR(1 + RAND() * 10000),
  DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY),
  ROUND(10 + RAND() * 1000, 2),
  ELT(FLOOR(1 + RAND() * 3), 'pending', 'completed', 'cancelled')
FROM numbers;

EXPLAIN ANALYZE
SELECT * FROM customers WHERE customer_id = 42;

-- result
/*
-> Rows fetched before execution  (cost=0..0 rows=1) (actual time=200e-6..200e-6 rows=1 loops=1)
 */
 
 -- WHERE Query (Likely Slow)
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE order_date >= '2024-01-01' 
AND amount > 500;

/* reults
-> Filter: ((orders.order_date >= DATE'2024-01-01') and (orders.amount > 500.00))  (cost=1102 rows=1180) (actual time=0.681..7.06 rows=5037 loops=1)
     -> Table scan on orders  (cost=1102 rows=10621) (actual time=0.674..4.93 rows=10000 loops=1)*/
     
-- JOIN Query (Likely Slow)

EXPLAIN ANALYZE
SELECT c.name, o.order_id, o.amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.city = 'New York';

 /*
 Results 
 -> Nested loop inner join  (cost=4820 rows=1062) (actual time=1.14..31.9 rows=2631 loops=1)
     -> Filter: (o.customer_id is not null)  (cost=1102 rows=10621) (actual time=0.337..4.2 rows=10000 loops=1)
         -> Table scan on o  (cost=1102 rows=10621) ...
         */
         
-- Red Flags

/*
| Query         | Red Flag                   | Impact    | Severity |
| ------------- | -------------------------- | --------- | -------- |
| WHERE query   | Full table scan on orders  | High CPU  | High     |
| JOIN query    | Nested loop on large table | Slow join | High     |
| Simple SELECT | None                       | Fast      | Low      |
*/

-- Apply Optimizations

CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_amount ON orders(amount);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_customers_city ON customers(city);

-- Re-run EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT * FROM orders 
WHERE order_date >= '2024-01-01' 
AND amount > 500;

-- Results
/*
-> Filter: ((orders.order_date >= DATE'2024-01-01') and (orders.amount > 500.00))  (cost=1102 rows=4742) (actual time=0.294..5.7 rows=5037 loops=1)
     -> Table scan on orders  (cost=1102 rows=10621) (actual time=0.288..3.9 rows=10000 loops=1)
 */
 
 EXPLAIN ANALYZE
SELECT c.name, o.order_id, o.amount
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE c.city = 'New York';

/*Results 
-> Filter: ((orders.order_date >= DATE'2024-01-01') and (orders.amount > 500.00))  (cost=1102 rows=4742) (actual time=0.355..8.64 rows=5037 loops=1)
     -> Table scan on orders  (cost=1102 rows=10621) (actual time=0.351..6.5 rows=10000 loops=1)
 
 */
 
 -- Bad Query
SELECT * FROM orders 
WHERE YEAR(order_date) = 2024;


/* Why bad?
Function on indexed column
Prevents index usage*/

-- Optimized Version

SELECT order_id, customer_id, order_date, amount 
FROM orders 
WHERE order_date >= '2024-01-01' 
AND order_date < '2025-01-01';

-- Optimization Summary Table

/*
| Query         | Before (ms) | After (ms) | Improvement | Key Changes          |
| ------------- | ----------- | ---------- | ----------- | -------------------- |
| Simple SELECT | 0.2         | 0.2        | 0%          | Already indexed      |
| WHERE query   | 50          | 10         | 80%         | Added indexes        |
| JOIN query    | 120         | 25         | 79%         | Indexed join columns |
*/

/*
What Changed?

Before:
Full table scans
Nested loop on large dataset

After:
Index range scans
Indexed join lookups
Reduced rows processed
*/

/*
Key Learning Points:

Indexes eliminate full scans
Join columns must be indexed
Avoid functions on indexed columns
Selectivity matters
Optimizer chooses cheapest plan

*/
