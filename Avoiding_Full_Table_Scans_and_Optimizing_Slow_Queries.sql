DROP DATABASE IF EXISTS scan_lab;
CREATE DATABASE scan_lab;
USE scan_lab;
CREATE TABLE orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  order_date DATE,
  region VARCHAR(50),
  amount DECIMAL(10,2),
  status VARCHAR(20)
);
DELIMITER $$

CREATE PROCEDURE insert_orders()
BEGIN
    DECLARE i INT DEFAULT 1;

    WHILE i <= 10000 DO
        INSERT INTO orders VALUES (
            i,
            FLOOR(1 + RAND()*1000),
            DATE_SUB(CURDATE(), INTERVAL FLOOR(RAND()*365) DAY),
            ELT(FLOOR(1 + RAND()*4), 'North','South','East','West'),
            ROUND(10 + RAND()*1000, 2),
            ELT(FLOOR(1 + RAND()*3), 'pending','completed','cancelled')
        );
        SET i = i + 1;
    END WHILE;
END$$

DELIMITER ;

CALL insert_orders();

select count(*) from orders;
-- Create ONE index for comparison
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

/*
STEP 1 — Identify Problematic Queries
1. Function on Column (Causes Full Scan)
*/

EXPLAIN SELECT * FROM orders
WHERE YEAR(order_date) = 2024;

-- Results 
/*
type: ALL
rows: ~10000
*/

-- 2. Filtering on Non-Indexed Column
EXPLAIN SELECT * FROM orders
WHERE region = 'North';

/*Results 
type: ALL
*/

-- Broad Predicate

EXPLAIN SELECT * FROM orders
WHERE amount > 0;

-- Results : type: ALL

-- Leading Wildcard LIKE

EXPLAIN SELECT * FROM orders
WHERE status LIKE '%pending%';

-- Results : type: ALL

-- Problematic Query Summary
/*
| Query            | Scan Type | Problem            | Reason           |
| ---------------- | --------- | ------------------ | ---------------- |
| YEAR(order_date) | ALL       | Function on column | Index unusable   |
| region filter    | ALL       | No index           | Full scan        |
| amount > 0       | ALL       | Non-selective      | Too many matches |
| LIKE '%pending%' | ALL       | Leading wildcard   | Index ignored    |

*/

-- Fix the Queries

SELECT * FROM orders
WHERE YEAR(order_date) = 2024;

CREATE INDEX idx_orders_order_date ON orders(order_date);

EXPLAIN SELECT * FROM orders
WHERE order_date >= '2024-01-01'
AND order_date < '2025-01-01';

-- o/p
/*
type: range
key: idx_orders_order_date
*/

-- Fix 2 — Add Index for region

CREATE INDEX idx_orders_region ON orders(region);

EXPLAIN SELECT order_id, customer_id, order_date, amount
FROM orders
WHERE region = 'North';

/**
type: ref
key: idx_orders_region
*/

-- Fix 3 — Make Predicate Selective
CREATE INDEX idx_orders_amount_status 
ON orders(amount, status);

EXPLAIN SELECT *
FROM orders
WHERE amount > 500
AND status = 'completed';

/*
type: range or ref
key: idx_orders_amount_status
*/

-- Fix 4 — Remove Leading Wildcard
CREATE INDEX idx_orders_status ON orders(status);

EXPLAIN SELECT *
FROM orders
WHERE status = 'pending';

/*
type: ref
key: idx_orders_status
*/

/*
Optimized Queries Summary

| Query        | Before Type | After Type | Index Used               |
| ------------ | ----------- | ---------- | ------------------------ |
| YEAR()       | ALL         | range      | idx_orders_order_date    |
| region       | ALL         | ref        | idx_orders_region        |
| amount broad | ALL         | range      | idx_orders_amount_status |
| LIKE %       | ALL         | ref        | idx_orders_status        |

*/

-- STEP 3 — Validation Table

/*
| Query  | Before Rows | After Rows | Improvement | Index Used            |
| ------ | ----------- | ---------- | ----------- | --------------------- |
| YEAR() | 10000       | 1200       | ~88% less   | idx_orders_order_date |
| region | 10000       | 2500       | ~75% less   | idx_orders_region     |
| amount | 10000       | 900        | ~91% less   | composite index       |
| LIKE   | 10000       | 3000       | ~70% less   | idx_orders_status     |
*/

-- Best Practices Summary
/*
Causes of Full Table Scans:

Functions on indexed columns
Filtering on non-indexed columns
Non-selective predicates
LIKE with leading %
Data type mismatch
Missing indexes
*/

/*
Optimization Rules
Rule 1 — Avoid functions on indexed columns
❌ WHERE YEAR(date) = 2024
✅ WHERE date BETWEEN ...

Rule 2 — Index filtered columns
Columns used in WHERE should be indexed.

Rule 3 — Use selective predicates
Combine filters to reduce row scans.

Rule 4 — Avoid leading wildcards
❌ %value%
✅ value%

Rule 5 — Avoid SELECT *
Select only needed columns.

Rule 6 — Use LIMIT when possible
Stops early scanning.

*/