Read-Heavy vs Write-Heavy Systems

A. Transactional Systems (OLTP)
Primary Operation
Frequent INSERT / UPDATE / DELETE
Short, row-level queries

Read vs Write?
Write-heavy (or balanced but integrity-focused)

Preferred Schema
Highly Normalized (3NF or higher)

Why?
Avoid duplication
Strong consistency
Enforced foreign keys
ACID compliance

Example
Bank transactions, order processing, payments.
Goal: Data integrity over query speed.

B. Reporting Systems

Primary Operation
Aggregations
Complex joins
Read-only analytics

Read vs Write?
Read-heavy

Preferred Schema
Partially Denormalized

Why?
Reduce join complexity
Faster dashboard queries
Accept minor duplication

Example
Monthly revenue dashboard.
Goal: Faster reads over strict normalization

C.Data Warehouses

Primary Operation:
Large scans
Aggregations
Historical analysis

Read vs Write?
Extremely read-heavy
Batch writes

Preferred Schema
Denormalized (Star/Snowflake Schema)

Why?
Fewer joins
Faster aggregations
Optimized for analytics engines

Example
Sales fact table joined with dimension tables.
Goal: Query performance at scale.

2. Performance vs Duplication:

Why Joins Hurt Performance

When you join multiple tables:
Multiple index lookups
Data shuffling
Network transfer (in distributed systems)
Memory usage increases

Example:

SELECT *
FROM orders o
JOIN customers c
JOIN products p
JOIN shipments s


In distributed systems:
Data may move across nodes
Causes shuffle cost (Spark, MPP systems)
More joins = more CPU + IO + latency

Why Duplication Risks Inconsistency

Example:
Product price stored in 5 tables.
If price changes:
Must update 5 places
If one fails → inconsistent data

Problems:
Update anomalies
Sync complexity
Data drift
Increased maintenance

The Trade-Off:

| If You Optimize For | You Sacrifice    |
| ------------------- | ---------------- |
| Performance         | Some duplication |
| Consistency         | Query speed      |

Balance Strategy:

Normalize write layer
Denormalize read layer
Use ETL to sync

3. Case Study Evaluation

Case 1: Core Banking Transactions
Recommended: Normalized
Why?

Integrity Requirements:
Extremely high
No duplicate balances
Regulatory compliance

Query Pattern:
Short, transactional

Consistency:
Non-negotiable

Performance:
Correctness > speed

Denormalization here could cause financial corruption.

Case 2: Product Catalog API
Recommended: Hybrid (Mostly Denormalized)
Why?

Read Frequency:
Very high (millions of product views)

Write Frequency:
Low (price updates occasional)

Performance
API must respond in milliseconds

Approach:
Store product document with embedded category info
Sync from normalized backend DB
Optimize for fast reads.

Daily Sales Reporting
Recommended: Denormalized (Star Schema)
Why?

Read-heavy:
Complex aggregations

Write Pattern:
Batch loads

Performance:
Dashboard speed critical

Use:
Fact_sales table
Dimension tables (date, product, region)

Analytics systems benefit from denormalization.


Design Reflection
Where Normalization is Mandatory
Scenarios

Banking systems
Payment systems
Inventory control
Healthcare records

Why?
Data accuracy critical
Regulatory compliance
High write concurrency

Risk of Denormalization:
Double spending
Inconsistent balances
Legal exposure

Where Denormalization is Acceptable
Scenarios

Data warehouses
Read-heavy APIs
Caching layers
Search indexes

Why?

Performance prioritized
Writes controlled via pipelines

Safeguards:
Single source of truth
ETL refresh jobs
CDC (Change Data Capture)

Decision Principles (Data Engineering Lens)

What is the primary workload? (Read vs Write)
How critical is consistency?
What is acceptable latency?
Is this system operational or analytical?
Can duplication be controlled via pipelines?

Golden Rule

Normalize for integrity.
Denormalize for performance.

Final Summary:
| System Type    | Schema Style | Why                     |
| -------------- | ------------ | ----------------------- |
| OLTP           | Normalized   | Integrity & consistency |
| Reporting      | Hybrid       | Balanced                |
| Data Warehouse | Denormalized | Query performance       |
