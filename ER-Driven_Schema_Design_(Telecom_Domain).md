1. Entity Identification
1. Subscriber

Purpose:
Represents a telecom customer (can be caller or receiver).

Attributes:
subscriber_id
phone_number
name
registration_date
status (active/inactive)

Candidate Keys:
subscriber_id (surrogate)
phone_number (natural, unique)

2.Call

Purpose:
Represents one call record between two subscribers.

Attributes:
call_id
caller_id
receiver_id
start_time
end_time
duration
call_type_id
tower_id

Candidate Keys:
call_id
CallType

Purpose:
Represents call categories (Local, STD, ISD).

Attributes:
call_type_id
call_type_name

description
base_rate_per_minute

Candidate Keys:
call_type_id
call_type_name (unique)

2️. Key Design & Relationships

Primary Keys

| Entity     | Primary Key   | Justification                                 |
| ---------- | ------------- | --------------------------------------------- |
| Subscriber | subscriber_id | Surrogate, stable, avoids phone change issues |
| Call       | call_id       | Unique per call record                        |
| CallType   | call_type_id  | Small lookup table                            |
| Tower      | tower_id      | Unique infrastructure identifier              |

Foreign Keys & Relationships:

Subscriber → Call (Caller)

FK: Call.caller_id → Subscriber.subscriber_id
Cardinality: 1 : Many
Required: Yes
One subscriber can make many calls.

Subscriber → Call (Receiver)

FK: Call.receiver_id → Subscriber.subscriber_id
Cardinality: 1 : Many
Required: Yes
One subscriber can receive many calls.

CallType → Call

FK: Call.call_type_id → CallType.call_type_id
Cardinality: 1 : Many
Required: Yes
One call type used in many calls.

Tower → Call

FK: Call.tower_id → Tower.tower_id
Cardinality: 1 : Many
Required: Yes (assuming every call connects to tower)

3. Normalized Schema (3NF)

subscribers:
subscriber_id (PK)
phone_number (UK)
name
registration_date
status

call_types:
call_type_id (PK)
call_type_name (UK)
description
base_rate_per_minute

towers:
tower_id (PK)
tower_name
city
latitude
longitude

calls:
call_id (PK)
caller_id (FK → subscribers.subscriber_id)
receiver_id (FK → subscribers.subscriber_id)
start_time
end_time
duration
call_type_id (FK → call_types.call_type_id)
tower_id (FK → towers.tower_id)

Normalization Verification:

1NF
All attributes atomic
No repeating groups

2NF
No composite PKs
All attributes fully depend on primary key

3NF
No transitive dependencies
CallType details not stored in calls
Subscriber details not repeated in calls
Tower details not repeated in calls

Now schema is fully in 3NF.

ER Diagram (Mermaid)

erDiagram
    SUBSCRIBER ||--o{ CALL : "makes (caller)"
    SUBSCRIBER ||--o{ CALL : "receives (receiver)"
    CALL_TYPE ||--o{ CALL : "categorized as"
    TOWER ||--o{ CALL : "handled by"

    SUBSCRIBER {
        int subscriber_id PK
        string phone_number UK
        string name
        date registration_date
        string status
    }

    CALL {
        int call_id PK
        int caller_id FK
        int receiver_id FK
        datetime start_time
        datetime end_time
        int duration
        int call_type_id FK
        int tower_id FK
    }

    CALL_TYPE {
        int call_type_id PK
        string call_type_name UK
        string description
        decimal base_rate_per_minute
    }

    TOWER {
        int tower_id PK
        string tower_name
        string city
        decimal latitude
        decimal longitude
    }


Schema Justification:

Why This Schema is Normalized

Data Integrity
Subscriber info stored once
Call type info stored once
Tower info stored once

Prevents Anomalies
Update anomaly avoided (changing tower location updates once)
Insert anomaly avoided (can create subscriber without call)
Delete anomaly avoided (deleting call doesn't delete subscriber)

Why 3NF is Appropriate

CDR systems:

High write volume
Need accurate billing
Regulatory compliance required

Normalization ensures:
No inconsistent billing
Accurate subscriber relationships
Clean separation of concerns


Where Denormalization Might Be Added Later

For analytics:
Possible Additions:
Materialized view with:

subscriber name
call type name
tower city
Pre-aggregated daily call summary table

Example analytics query:
Total minutes per city per day
Revenue by call type

Denormalized views improve:
Reporting speed
BI performance
But core OLTP remains normalized.