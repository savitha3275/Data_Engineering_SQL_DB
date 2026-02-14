-- STEP 1 — Sharding Concepts Review

-- Horizontal vs Vertical Partitioning
/*

Definition:
Split rows of a table across multiple databases/servers.

Example:

Shard 1 → users 1–1M
Shard 2 → users 1M–2M
Shard 3 → users 2M–3M

Each shard has the same schema, different rows.
When appropriate:
Massive datasets
High write throughput
Horizontal scalability needed

Scalability:
Scales horizontally (add more servers)
Distributes load
*/

/*

Vertical Partitioning

Definition:
Split columns across multiple tables or databases.

Example:
users_core (id, username, email)
users_profile (bio, avatar, preferences)

When appropriate:
Large row width
Frequently accessed vs rarely accessed columns

Scalability:
Reduces I/O
Does NOT distribute write load
*/

/*
2. Sharding vs Indexing

| Sharding                    | Indexing                          |
| --------------------------- | --------------------------------- |
| Splits data across machines | Organizes data within one machine |
| Solves scale limits         | Solves lookup performance         |
| Adds operational complexity | Simple to maintain                |

*/

/*

When indexing is sufficient:
Data fits on single machine
CPU/disk not saturated
Mostly read optimization needed

When sharding is necessary:
Dataset too large for one server
Write throughput exceeds single node capacity
Storage limits reached

You can use both together (common in real systems).
*/

/*
3.Key Sharding Considerations

Data distribution (avoid hot shards)
Query routing complexity
Scalability
Operational complexity
Cross-shard joins
Consistency guarantees

*/

/*
STEP 2 — Shard Key Selection

Dataset 1: User Accounts

users (
  user_id INT PRIMARY KEY,
  email VARCHAR(100),
  username VARCHAR(50),
  country VARCHAR(50),
  created_at TIMESTAMP
)

Proposed Shard Key: user_id
Strategy: Hash-based sharding
shard_id = hash(user_id) % N

Justification:
Very high cardinality
Even distribution
Write load evenly spread
Most queries use user_id

Trade-offs:
Queries by email require lookup service
Cross-shard analytics harder

Dataset 2: Transaction Records

transactions (
  transaction_id BIGINT PRIMARY KEY,
  user_id INT,
  amount DECIMAL,
  transaction_date TIMESTAMP,
  merchant_id INT
)

Proposed Shard Key: user_id
Strategy: Hash-based

Why NOT transaction_id?
Append-only pattern → time-based clustering
But user-based queries common
Users generate transactions repeatedly

Justification:
Queries by user_id are frequent
User and transactions co-located
Reduces cross-shard joins

Trade-offs:
High-activity users → potential hot shard
Date-based analytics require scatter-gather


Dataset 3: IoT Sensor Data

sensor_readings (
  reading_id BIGINT PRIMARY KEY,
  device_id INT,
  sensor_type VARCHAR,
  value DECIMAL,
  timestamp TIMESTAMP,
  location VARCHAR
)

Proposed Shard Key: (device_id, time_bucket)
Strategy: Composite (Hash + Time Range)

Example:
shard = hash(device_id) % N
Partition by month internally

Justification:
High write volume
Devices generate continuous data
Queries mostly by device_id + time range

Trade-offs:
Cross-device analytics are expensive
Requires good routing logic


Dataset 4: Orders by Region

orders (
  order_id BIGINT PRIMARY KEY,
  customer_id INT,
  region VARCHAR,
  order_date DATE,
  amount DECIMAL,
  status VARCHAR
)

Proposed Shard Key: region
Strategy: Geographic (Range-based)

Example:

Shard US
Shard Europe
Shard Asia

Justification:
Natural geographic distribution
Most queries are regional
Regulatory compliance (data locality)

Trade-offs:
Uneven traffic (US > others)
Region rebalancing complex
Alternative: hash(customer_id) for better balance.

*/

/*
STEP 3 — Risk Analysis

| Dataset      | Hot Shards Risk      | Rebalancing Risk | Query Routing Risk | Data Skew Risk | Mitigation          |
| ------------ | -------------------- | ---------------- | ------------------ | -------------- | ------------------- |
| Users        | Medium               | Medium           | Low                | Low            | Consistent hashing  |
| Transactions | High (heavy users)   | Medium           | Medium             | Medium         | Rate limiting       |
| IoT          | High (large devices) | High             | Medium             | High           | Time partitioning   |
| Orders       | High (US region)     | High             | Low                | High           | Split heavy regions |

*/

/*

Common Risks
Hot Shards

Cause:
Celebrity users
Large devices
Popular region

Mitigation:
Consistent hashing
Dynamic shard splitting
Write throttling
Rebalancing
Moving TBs of data expensive
Requires online migration

Mitigation:
Use consistent hashing ring
Add virtual nodes

Cross-Shard Queries
Aggregations expensive
Joins complex

Mitigation:
Pre-aggregation
Data duplication
CQRS architecture

*/

/*
STEP 4 — Final Design Summary

When is Sharding Necessary?
Data > single server capacity
Write throughput too high
Storage limit reached
Replication insufficient

When Indexing Is Enough?
Data < 500GB (depending on infra)
Mostly read workload
Moderate growth

*/

/*Trade-Offs

| Trade-off                  | Explanation                          |
| -------------------------- | ------------------------------------ |
| Performance vs Complexity  | Sharding increases ops complexity    |
| Scalability vs Consistency | Cross-shard ACID is hard             |
| Flexibility vs Simplicity  | Simple keys reduce query flexibility |

*/

/*
Decision Matrix

| Dataset      | Shard Key        | Strategy  | Primary Benefit      | Main Risk                | Mitigation        |
| ------------ | ---------------- | --------- | -------------------- | ------------------------ | ----------------- |
| Users        | user_id          | Hash      | Even distribution    | Cross-shard email search | Global index      |
| Transactions | user_id          | Hash      | Co-located user data | Heavy users              | Rate limiting     |
| IoT          | device_id + time | Composite | Write scalability    | Data skew                | Time partitions   |
| Orders       | region           | Range     | Geo optimization     | Region imbalance         | Split hot regions |


*/

/*
Key Design Principles:

High-cardinality shard keys
Align shard key with query pattern
Avoid sequential keys (cause hot shards)
Use consistent hashing
Monitor shard utilization

*/