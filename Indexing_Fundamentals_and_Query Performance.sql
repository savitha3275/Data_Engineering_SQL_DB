CREATE DATABASE indexing_lab;
USE indexing_lab;

-- Create Orders Table
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  region VARCHAR(50),
  amount DECIMAL(10,2)
);

TRUNCATE TABLE orders;
CREATE TABLE numbers (n INT);
INSERT INTO numbers (n)
SELECT a.N + b.N * 10 + c.N * 100 + 1
FROM 
(SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) a,
(SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) b,
(SELECT 0 N UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 
 UNION SELECT 5 UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9) c;
 
 SELECT COUNT(*) FROM numbers;
 
 -- Step 3 — Insert 1000 Orders (Fast Bulk Insert)

INSERT INTO orders (order_id, customer_id, order_date, region, amount)
SELECT 
  n,
  FLOOR(1 + RAND() * 100),
  DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY),
  ELT(FLOOR(1 + RAND() * 4), 'North', 'South', 'East', 'West'),
  ROUND(10 + RAND() * 1000, 2)
FROM numbers;

SELECT COUNT(*) FROM orders;

-- checking baseline before indexes
EXPLAIN SELECT * FROM orders 
WHERE order_date >= '2024-01-01';

EXPLAIN SELECT * FROM orders 
WHERE region = 'North';

EXPLAIN SELECT * FROM orders 
WHERE customer_id = 42;

-- STEP 2 — Create Indexes
CREATE INDEX idx_orders_order_date 
ON orders(order_date);

CREATE INDEX idx_orders_region 
ON orders(region);

CREATE INDEX idx_orders_customer_id 
ON orders(customer_id);

SHOW INDEXES FROM orders;

-- STEP 3 — Re-run EXPLAIN (Important)
-- index type is ref
/*The index on order_date was not used for the range query 2024 date because a large percentage 
of rows satisfied the condition. However, when using an equality condition, the optimizer
 used the index (type = ref), demonstrating that index effectiveness depends on selectivity.*/
EXPLAIN SELECT * FROM orders 
WHERE order_date = '2025-01-01';

EXPLAIN SELECT * FROM orders 
WHERE region = 'North';

EXPLAIN SELECT * FROM orders 
WHERE customer_id = 42;


/*| Query       | Before | After | Improvement | Reason                          |
| ----------- | ------ | ----- | ----------- | ------------------------------- |
| order_date  | ALL    | range | Good        | Range index scan                |
| region      | ALL    | ref   | Medium      | Only 4 values (low selectivity) |
| customer_id | ALL    | ref   | High        | Highly selective                |
*/


-- STEP 4 — Index Cost Analysis (Very Important)
DROP INDEX idx_orders_order_date ON orders;
DROP INDEX idx_orders_region ON orders;
DROP INDEX idx_orders_customer_id ON orders;

INSERT INTO orders 
VALUES (999999, 888, CURDATE(), 'North', 200.00);
-- 0.031 sec

CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_region ON orders(region);
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

INSERT INTO orders 
VALUES (999998, 777, CURDATE(), 'South', 300.00);
-- 0.00 sec

/*Why Indexes Speed Up Reads?

Reduce number of rows scanned
Use B-tree search (O(log n))
Avoid full table scan*/

/*Why Indexes Slow Down Writes

During INSERT:
Insert row into table
Insert entry into each index
Rebalance B-tree
More indexes = more work*/

/*Why Too Many Indexes Are Harmful

Slower INSERT/UPDATE/DELETE
More disk usage
More memory
Slower backups
Harder optimizer decisions*/