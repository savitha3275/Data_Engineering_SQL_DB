1. Problems in Unnormalized Table

Repeated Attributes
customer_name, customer_city repeated for same customer
Example: John Smith, New York appears in multiple rows

product_name, product_price repeated for same product
Example: Laptop – 1200.00 appears multiple times

Partial Dependencies
Implied composite key: (order_id, product_name)
customer_name, customer_city depend only on order_id
product_price depends only on product_name

Transitive Dependencies
customer_city depends on customer_name, not the key

Anomalies
Update: Change John Smith’s city → update multiple rows
Insert: Cannot add a customer without an order
Delete: Deleting last order removes customer info
Duplication: Same customer & product data stored repeatedly

2. First Normal Form (1NF)

What was wrong?

Repeating product rows per order
Mixed entity data in one table

How 1NF fixes it
One row = one product per order

All values are atomic

1NF Schema
orders_1nf
- order_id
- customer_name
- customer_city
- product_name
- product_price
- quantity

Key Point

1NF removes repeating groups but does NOT remove redundancy

3. Second Normal Form (2NF)

Composite Key Identified
(order_id, product_name)

Partial Dependencies Removed
customer_name, customer_city → depend only on order
product_price → depend only on product

2NF Tables
customers
- customer_id (PK)
- customer_name
- customer_city

products
- product_id (PK)
- product_name
- product_price

orders
- order_id (PK)
- customer_id (FK)

order_items
- order_id (PK, FK)
- product_id (PK, FK)
- quantity

Key Point

2NF removes partial dependencies, but transitive ones may still exist

4. Third Normal Form (3NF)

Transitive Dependency Removed
customer_city → moved to reference table

3NF Tables
customers
- customer_id (PK)
- customer_name
- city_id (FK)

cities
- city_id (PK)
- city_name

products
- product_id (PK)
- product_name
- product_price

orders
- order_id (PK)
- customer_id (FK)

order_items
- order_id (PK, FK)
- product_id (PK, FK)
- quantity
- unit_price

Improvements

No non-key attribute depends on another non-key
Better data integrity
Cities reusable across customers

note:
If customer_city is just a label with no extra attributes, 2NF may already be 3NF.

5. Final Schema Review

Tables & Purpose

| Table       | Purpose                      |
| ----------- | ---------------------------- |
| customers   | Stores unique customer data  |
| cities      | Reference data for locations |
| products    | Stores product catalog       |
| orders      | Stores order-level data      |
| order_items | Line items per order         |

Keys

Primary Keys:
customers.customer_id
cities.city_id
products.product_id
orders.order_id
(order_items.order_id, product_items.product_id)

Foreign Keys
orders.customer_id → customers.customer_id
customers.city_id → cities.city_id
order_items.order_id → orders.order_id
order_items.product_id → products.product_id

Anomalies Resolved

Update anomalies removed
Insert anomalies resolved
Delete anomalies avoided
No duplicated customer/product data