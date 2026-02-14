Row-Based vs Columnar File Formats

1️⃣ How Row-Based Storage (CSV) Stores Data
🔹 Structure
Row-based formats store data row by row.
Each row contains all column values together.

Example table:
| order_id | region | amount | date       |
| -------- | ------ | ------ | ---------- |
| 1        | North  | 100    | 2024-01-01 |
| 2        | South  | 200    | 2024-01-02 |

CSV Physical Layout (On Disk)
1,North,100,2024-01-01
2,South,200,2024-01-02

Each line = one complete row.
All column values for a record are stored together.

Disk Layout Concept
[Row1: order_id, region, amount, date]
[Row2: order_id, region, amount, date]
[Row3: order_id, region, amount, date]

Data is stored sequentially by row.

2️⃣ How Columnar Formats (Parquet, ORC) Store Data:

Columnar formats store data column by column.
Using same table:
Instead of row storage:

order_id column → [1, 2]
region column   → [North, South]
amount column   → [100, 200]
date column     → [2024-01-01, 2024-01-02]

🔹 Disk Layout Concept
[order_id: 1, 2, 3, 4...]
[region: North, South, East...]
[amount: 100, 200, 150...]
[date: 2024-01-01, ...]

Each column stored contiguously.

3️⃣ Why Row-Based Works Well for Transactions (OLTP)
Access Pattern

Transactions usually retrieve complete records:

SELECT * FROM orders WHERE order_id = 42;
We need the entire row.

Row-based layout:
One disk read
All data already together

Efficient For:
Inserts
Updates
Point lookups
Small queries

Example Use Cases:
Banking systems
Order placement
Login systems
Real-time applications

Write Performance:
Appending a row = write one line.
Very simple and fast.

4️⃣ Why Columnar Works Well for Analytics (OLAP)

Analytics typically reads specific columns, not whole rows.

Example:
SELECT SUM(amount) FROM orders;
We only need amount column.

Columnar format:
Reads only that column
Ignores others
Massive I/O reduction

Compression Benefits:

Since values in a column are similar:

Example:
region column:
North
North
North
North
South
South

This compresses extremely well using:
Run-length encoding
Dictionary encoding
Bit packing

5️⃣ Visual Comparison Table:

| Aspect                | Row-Based (CSV) | Columnar (Parquet)       |
| --------------------- | --------------- | ------------------------ |
| Storage Layout        | Row by row      | Column by column         |
| Read Pattern          | Full row        | Selected columns         |
| Write Pattern         | Fast append     | Slower (batch optimized) |
| Compression           | Low             | High                     |
| Analytics Performance | Poor            | Excellent                |


✅ STEP 2 — Access Pattern Analysis
Query 1: Full Row Retrieval
SELECT * FROM orders WHERE order_id = 42;

Better Format: ✅ Row-Based
Why:
Reads one full row
Data already contiguous
Minimal overhead

I/O Pattern:
Single sequential row read
Very efficient

Query 2: Single-Column Aggregation
SELECT SUM(amount) FROM orders;

Better Format: ✅ Columnar
Why:
Only reads amount column
Skips all other columns

I/O Pattern:
Reads only one column block
Massive I/O reduction

Query 3: Multi-Column Filtering
SELECT order_id, amount
FROM orders
WHERE order_date >= '2024-01-01'
AND region = 'North';

Better Format: ✅ Columnar
Why:

Only reads 3 columns:
order_id
amount
order_date
region

Row-based would read entire rows.
I/O Pattern:
Column pruning
Predicate pushdown

Query 4: Wide Analytical Scan
SELECT 
  region,
  DATE_TRUNC('month', order_date),
  SUM(amount),
  COUNT(*)
FROM orders
WHERE order_date >= '2024-01-01'
GROUP BY region, DATE_TRUNC('month', order_date);

Better Format: ✅ Columnar (by far)
Why:

Heavy aggregation
Scans specific columns

Benefits from compression
Vectorized execution

Access Pattern Table:
| Query Type                | Better Format | Reasoning           | I/O Pattern            |
| ------------------------- | ------------- | ------------------- | ---------------------- |
| Full row retrieval        | Row-based     | Whole row needed    | Row read               |
| Single-column aggregation | Columnar      | Reads 1 column only | Column scan            |
| Multi-column filtering    | Columnar      | Reads few columns   | Column pruning         |
| Wide analytical scans     | Columnar      | Aggregation heavy   | Compressed column scan |

✅ STEP 3 — Performance Expectations
1️⃣ Which Format Reads Less Data for Analytics?

Columnar.

Example:
Table:
100 columns
Query needs 3 columns

Row-based:
→ Reads 100 columns per row.
Columnar:
→ Reads only 3 columns.

If each column = 8 bytes:

Row-based:
100 × 8 = 800 bytes per row
Columnar:
3 × 8 = 24 bytes per row
📉 ~97% less data read.

2️⃣ Which Format Compresses Better?
Columnar.
Why?
Same-type values stored together:
100, 101, 102, 103

Much more compressible than:

1,North,100,2024-01-01
2,South,200,2024-01-02

Typical compression:
Format	Compression Ratio
CSV	1–2x
Parquet	5–10x

3️⃣ Schema Evolution
Row-Based (CSV)
Adding column breaks structure
No schema metadata
Hard to manage
Columnar (Parquet)
Self-describing schema
Supports adding columns
Backward/forward compatible
Winner: ✅ Columnar

Performance Comparison Table:
| Metric            | Row-Based | Columnar | Winner    | Reason                 |
| ----------------- | --------- | -------- | --------- | ---------------------- |
| Analytics Read    | High I/O  | Low I/O  | Columnar  | Column pruning         |
| Compression       | Low       | High     | Columnar  | Similar values grouped |
| Schema Evolution  | Weak      | Strong   | Columnar  | Embedded schema        |
| Write Performance | Very Fast | Moderate | Row-based | Simple append          |
| OLTP Queries      | Excellent | Poor     | Row-based | Full row access        |

✅ STEP 4 — Summary Notes
Row-Based Formats (CSV, JSON) are preferred when:
 High write frequency (OLTP systems)
 Real-time transactions
 Full row retrieval is common
 Small to medium datasets
 Simplicity required

Examples:
Banking apps
E-commerce checkout
User profile updates

Columnar Formats (Parquet, ORC) are preferred when:
 Analytical workloads
 Large datasets (TB+)
 Aggregations and reporting
 Data warehouse environments
 Big data platforms (Spark, Hive)

Examples:
Data lakes
BI dashboards
Financial reporting
Machine learning pipelines

Decision Framework
1️⃣ What is the primary access pattern?
Full rows → Row-based
Specific columns → Columnar

2️⃣ What is the query pattern?
Transactions → Row-based
Aggregations → Columnar

3️⃣ What is data volume?
Small → Either
Large (TB+) → Columnar preferred

4️⃣ Performance requirement?
Low latency OLTP → Row-based
High throughput analytics → Columnar

🎯 Final Takeaway

Row-based = optimized for transactions
Columnar = optimized for analytics

They solve different problems.
Modern architectures use both:
OLTP database (row-based)
Data warehouse (columnar)