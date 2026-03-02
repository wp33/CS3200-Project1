# Q6 — Query Documentation

---

## Query 1 — Multi-Table JOIN (Routes and Ordered Segments)

### Purpose
This query displays complete route information, including:
- The user who requested the route
- The time it was requested
- The routing mode
- The ordered street segments that make up the route
- The zone each segment belongs to

It demonstrates how SafeRoute builds a route from multiple street segments across zones.

### Tables Used
User → RouteRequest → GeneratedRoute → RouteSegment → StreetSegment → Zone

### Example Output

| request_id | full_name       | requested_at           | mode    | route_id | sequence_num | street_name   | zone_name           |
|------------|----------------|------------------------|---------|----------|--------------|---------------|---------------------|
| 1          | Wallace Peng   | 2026-02-22 19:50:00    | Safest  | 1        | 1            | College Ave   | Campus Core         |
| 1          | Wallace Peng   | 2026-02-22 19:50:00    | Safest  | 1        | 2            | Quad Walk     | Campus Core         |
| 2          | Avery Chen     | 2026-02-21 21:55:00    | Balanced| 2        | 1            | Market St     | Downtown Corridor   |

---

## Query 2 — Subquery (Users with Unverified Reports)

### Purpose
This query identifies users who have submitted at least one incident report that is:
- User-submitted
- Still unverified

This supports moderation and safety monitoring workflows.

### Tables Used
User + Incident (subquery)

### Example Output

| user_id | full_name       | email                    |
|---------|----------------|--------------------------|
| 1       | Wallace Peng   | wallace@student.edu      |

---

## Query 3 — GROUP BY with HAVING (High-Risk Zones)

### Purpose
This query finds zones that have more than 2 incidents with severity ≥ 4.
It helps identify areas with consistently high-risk activity.

### Tables Used
Zone → StreetSegment → Incident

### Example Output

| zone_name          | severe_incident_count |
|-------------------|----------------------|
| Downtown Corridor | 4                    |
| North Neighborhood| 3                    |

---

## Query 4 — Complex Search Condition

### Purpose
This query returns incidents that meet either of these criteria:

1. Verified AND severity ≥ 4  
OR  
2. User-submitted AND unverified AND occurred within the last 7 days  

This helps display both confirmed dangerous incidents and recent suspicious activity.

### Tables Used
Incident → StreetSegment → Zone

### Example Output

| incident_id | incident_type     | severity | occurred_at           | source | status     | street_name | zone_name          |
|-------------|------------------|----------|-----------------------|--------|------------|------------|-------------------|
| 12          | Assault          | 5        | 2026-02-21 22:10:00   | Public | Verified   | Market St   | Downtown Corridor |
| 18          | Suspicious Person| 3        | 2026-02-22 20:05:00   | User   | Unverified | Quad Walk   | Campus Core       |

---

## Query 5 — Window Function (Ranking Risk per Zone)

### Purpose
This query ranks street segments within each zone based on safety score (lowest score = highest risk) using:

RANK() OVER (PARTITION BY zone ORDER BY score_value ASC)

This enables SafeRoute to prioritize safer routing by identifying the most dangerous segments per area.

### Tables Used
SafetyScore → StreetSegment → Zone

### Example Output

| zone_name          | segment_id | street_name | score_date  | score_value | risk_rank_in_zone |
|-------------------|------------|------------|------------|------------|------------------|
| Downtown Corridor | 4          | Market St   | 2026-02-21 | 40         | 1                |
| Downtown Corridor | 7          | River Rd    | 2026-02-21 | 55         | 2                |
| Campus Core       | 2          | Quad Walk   | 2026-02-21 | 78         | 1                |
| Campus Core       | 1          | College Ave | 2026-02-21 | 90         | 2                |