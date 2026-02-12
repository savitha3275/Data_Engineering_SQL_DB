Star Schema Design for Analytical Reporting

Step 1: Fact vs Dimension Identification
🔹 Order Amount

Classification: Fact
Reasoning:
Numeric, measurable value
Changes per transaction
Used in aggregations (SUM, AVG)

Used in analytics:
Total revenue
Revenue by region
Revenue by product

🔹 Quantity Sold

Classification: Fact
Reasoning:
Numeric measurement
Represents volume of sales
Aggregated in reports

Used in analytics:
Units sold by product
Sales trends over time

🔹 Customer

Classification: Dimension
Reasoning:
Descriptive entity
Used for grouping and filtering
Not aggregated directly

Used in analytics:
Revenue by customer segment
Top customers

🔹 Product

Classification: Dimension
Reasoning:
Describes what is sold
Used to group sales

Used in analytics:
Revenue by category
Product performance

🔹 Date

Classification: Dimension
Reasoning:
Descriptive time attributes
Enables time-based grouping

Used in analytics:
Monthly sales
Year-over-year growth

🔹 Region

Classification: Dimension
Reasoning:
Describes geography
Used for filtering and grouping

Used in analytics:
Sales by country
Regional performance

🔎 Classification Principle

Facts:
Numeric
Measurable
Aggregated

Dimensions:
Descriptive
Used to filter/group facts

Step 2: Fact Table Design
📌 Fact Table: fact_sales
🔹 Grain Definition

One row represents:
👉 One order line item (one product in one order)

Why this grain?
Maximum analytical flexibility
Supports rollups
Prevents loss of detail

🔹 Measures
These are numeric values:
order_amount
quantity
discount_amount
profit_amount

Why measures?
Aggregated in analytics
Core business KPIs

🔹 Foreign Keys
   
customer_id → dim_customer
product_id → dim_product
date_id → dim_date
region_id → dim_region

Why needed?
Enable slicing and dicing
Connect fact to descriptive attributes

Fact Table Structure
fact_sales
- sale_id (PK, surrogate key)
- customer_id (FK → dim_customer)
- product_id (FK → dim_product)
- date_id (FK → dim_date)
- region_id (FK → dim_region)
- order_amount (measure)
- quantity (measure)
- discount_amount (measure)
- profit_amount (measure)

Explanation
sale_id is surrogate for uniqueness
Foreign keys link to dimensions
Measures are aggregated
Grain = order line

Step 3: Dimension Table Design
All dimensions use surrogate keys (best practice).


dim_customer:
- customer_id (PK, surrogate)
- customer_name
- email
- segment
- registration_date
- city
- state
- country
- effective_date
- expiry_date
- is_current

SCD Strategy

Use Type 2 Slowly Changing Dimension

When customer segment changes:
Insert new row
Expire old record

Why?
Preserves historical accuracy


dim_product
- product_id (PK, surrogate)
- product_name
- category
- subcategory
- brand
- unit_price
- unit_cost
- effective_date
- expiry_date
- is_current

SCD Strategy

Type 2 for:
Category change
Price change (if historical analysis required)

dim_date
- date_id (PK)
- full_date
- year
- quarter
- month
- month_name
- week
- day_of_week
- is_weekend
- is_holiday

Why surrogate?

Simplifies joins
Improves performance
Pre-calculated attributes

dim_region
- region_id (PK, surrogate)
- region_name
- country
- state
- city
- timezone


Purpose:

Geographic slicing
Regional performance tracking

Step 4: Star Schema Diagram

erDiagram
    FACT_SALES ||--|| DIM_CUSTOMER : "belongs to"
    FACT_SALES ||--|| DIM_PRODUCT : "contains"
    FACT_SALES ||--|| DIM_DATE : "occurs on"
    FACT_SALES ||--|| DIM_REGION : "sold in"
    
    FACT_SALES {
        int sale_id PK
        int customer_id FK
        int product_id FK
        int date_id FK
        int region_id FK
        decimal order_amount
        int quantity
        decimal discount_amount
        decimal profit_amount
    }
    
    DIM_CUSTOMER {
        int customer_id PK
        string customer_name
        string segment
        string city
        string state
    }
    
    DIM_PRODUCT {
        int product_id PK
        string product_name
        string category
        string brand
        decimal unit_price
    }
    
    DIM_DATE {
        int date_id PK
        date full_date
        int year
        int quarter
        int month
        string day_of_week
    }
    
    DIM_REGION {
        int region_id PK
        string region_name
        string country
        string state
    }

Explanation of the Diagram

Fact table is at center.
Dimensions surround it.
Foreign keys connect fact to dimensions.
No dimension-to-dimension joins.
Clean star shape.

This ensures:
Simpler queries
Faster aggregations
Easier BI integration


Why This Design Is Analytics-Friendly

✔ Clear grain
✔ Surrogate keys
✔ Conformed dimensions
✔ Aggregation-ready measures
✔ Supports rollups
✔ Prevents double counting