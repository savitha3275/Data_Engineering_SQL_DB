Online Retail System – Keys & Relationships Design
1. Entities & Attributes

Customer:
Attributes: customer_id, name, email, phone, address, created_at
Candidate identifiers: customer_id, email
Notes: Email is unique but may change → not ideal as PK

Order
Attributes: order_id, order_date, customer_id, order_status, total_amount
Candidate identifiers: order_id, (customer_id + order_date)
Notes: Business may change order numbering rules

Product
Attributes: product_id, sku, name, description, price, category, is_active
Candidate identifiers: product_id, sku
Notes: SKU is a business identifier but may change across regions

OrderItem
Attributes: order_id, product_id, quantity, unit_price
Candidate identifiers: (order_id, product_id)


2. Primary Key Selection & Justification
| Entity    | Primary Key             | Justification                                     |
| --------- | ----------------------- | ------------------------------------------------- |
| Customer  | customer_id (surrogate) | Stable, immutable, avoids exposing PII like email |
| Order     | order_id (surrogate)    | Simple joins, order numbers can change            |
| Product   | product_id (surrogate)  | SKU may change, surrogate ensures stability       |
| OrderItem | (order_id, product_id)  | Uniquely identifies a product within an order     |


Natural vs Surrogate Key Logic
Natural keys: Email, SKU → business-controlled, may change
Surrogate keys: Integer IDs → stable, efficient joins, safer
Composite key: Used when uniqueness depends on multiple attributes

3. Relationships & Foreign Keys

Customer → Order
Type: One-to-Many
FK: Order.customer_id → Customer.customer_id
Required: Yes
Reason: Every order must belong to a customer

Order → OrderItem
Type: One-to-Many
FK: OrderItem.order_id → Order.order_id
Required: Yes
Reason: Order items cannot exist without an order

Product → OrderItem
Type: One-to-Many
FK: OrderItem.product_id → Product.product_id
Required: Yes
Reason: Each order item references exactly one product

4. Composite Key Analysis (OrderItem)

Why (order_id + product_id)?
A product can appear only once per order
Quantity handles multiple units of the same product

What breaks with a single column?
Only order_id
Cannot distinguish multiple products in the same order

Only product_id
Cannot distinguish same product across different orders

Takeaway:
The composite key enforces the business rule:
One row per product per order

5. ER Diagram (Mermaid)

erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ ORDERITEM : contains
    PRODUCT ||--o{ ORDERITEM : appears_in

    CUSTOMER {
        int customer_id PK
        string name
        string email
        string phone
    }

    ORDER {
        int order_id PK
        date order_date
        int customer_id FK
        decimal total_amount
    }

    PRODUCT {
        int product_id PK
        string sku
        string name
        decimal price
    }

    ORDERITEM {
        int order_id PK, FK
        int product_id PK, FK
        int quantity
        decimal unit_price
    }