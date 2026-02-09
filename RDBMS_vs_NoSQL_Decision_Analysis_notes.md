1. NoSQL Overview (By Category)
1. Document Stores

What they are:
Store data as JSON-like documents
Each document can have a flexible structure

Key characteristics:
Schema-less or schema-flexible
Nested data supported
Easy to evolve data models
Good read/write performance

Use cases:
User profiles
Content management systems
Product catalogs
Event data

Examples:
MongoDB
CouchDB

Takeaway:
“Best when data structure varies and evolves frequently.”

2. Key-Value Stores

What they are:
Store data as key → value pairs
Value is opaque to the database

Key characteristics:
Extremely fast lookups
Simple data model
Limited querying capability
Highly scalable

Use cases:
Caching
Session management
Feature flags
Real-time counters

Examples:
Redis
Amazon DynamoDB

Takeaway:
“Best for speed and scalability, not complex queries.”

3. Wide-Column Databases

What they are:
Store data in rows with dynamic columns
Optimized for large-scale distributed data

Key characteristics:
High write throughput
Horizontally scalable
Columns grouped into families
Tunable consistency

Use cases:
Time-series data
Logs and metrics
IoT data
Telecom records

Examples:
Apache Cassandra
HBase

Takeaway:
“Designed for massive datasets and high write volumes.”

4. Graph Databases

What they are:
Store data as nodes and relationships
Relationships are first-class citizens

Key characteristics:
Optimized for relationship traversal
Complex relationship queries are fast
Not ideal for large aggregations

Use cases:
Social networks
Fraud detection
Recommendation engines
Network analysis

Examples:
Neo4j
Amazon Neptune

Takeaway:
“When relationships matter more than records.”

2. ACID vs BASE
ACID Properties (Relational Databases)
Atomicity -
All or nothing
Example: Bank transfer succeeds fully or rolls back

Consistency
Database moves from one valid state to another
Example: Account balance never goes negative

Isolation
Transactions don’t interfere with each other
Example: Two withdrawals don’t corrupt balance

Durability
Once committed, data survives crashes
Example: Payment remains recorded after system restart

When ACID is critical:
Banking
Payments
Financial systems
Inventory management

BASE Properties (Many NoSQL Systems)
Basically Available
System always responds, even during failures
Example: Social media feed still loads

Soft State
Data may change over time without input
Example: Cached data expiring

Eventual Consistency
Data becomes consistent over time
Example: Like count updates after a delay

Why BASE Is Acceptable
Eventual consistency is fine when:
Slight delays are acceptable
Data correctness is not life-critical
High availability is more important than accuracy

Examples of BASE systems:
Cassandra
DynamoDB
CouchDB

Trade-off summary:
ACID → correctness first
BASE → availability & scalability first

| Aspect            | RDBMS               | NoSQL                  | Trade-off                |
| ----------------- | ------------------- | ---------------------- | ------------------------ |
| Consistency       | Strong (ACID)       | Eventual (BASE)        | Accuracy vs availability |
| Scalability       | Vertical (scale-up) | Horizontal (scale-out) | Cost vs complexity       |
| Query flexibility | Rich SQL, joins     | Limited or specialized | Power vs simplicity      |
| Schema            | Fixed schema        | Flexible schema        | Stability vs agility     |


4. Scenario-Based Storage Decisions
1. Banking System

Recommended storage:
RDBMS

Justification:
Highly structured data
Strong consistency required
Complex transactions
Strict integrity rules

Why not NoSQL?
Eventual consistency is unacceptable
Financial errors are costly

2. E-commerce Platform
Recommended storage:
Hybrid approach

RDBMS for:
Orders
Payments
Inventory

NoSQL (Document / Key-Value) for:
Product catalog
User sessions
Recommendations

Justification:
Mix of structured and semi-structured data
High read traffic
Need for scalability

3. Telecom Call Data Records (CDR)

Recommended storage:
Wide-column NoSQL (Cassandra / HBase)

Justification:
Massive data volume
High write throughput
Time-series access patterns
Eventual consistency acceptable

Why not RDBMS?
Vertical scaling limits
Performance bottlenecks at scale

5. One-Line Summaries

NoSQL: “Optimized for scale, availability, and flexible data models.”
ACID: “Correctness and reliability first.”
BASE: “Availability and scalability over strict consistency.”
RDBMS vs NoSQL: “Structure vs scale.