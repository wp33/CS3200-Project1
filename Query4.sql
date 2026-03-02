-- Query 5
SELECT
  z.zone_name,
  ss.segment_id,
  ss.street_name,
  sc.score_date,
  sc.score_value,
  RANK() OVER (
    PARTITION BY z.zone_id
    ORDER BY sc.score_value ASC
  ) AS risk_rank_in_zone
FROM SafetyScore sc
JOIN StreetSegment ss ON ss.segment_id = sc.segment_id
JOIN Zone z ON z.zone_id = ss.zone_id
WHERE sc.score_date = '2026-02-21'
ORDER BY z.zone_name, risk_rank_in_zone, ss.street_name;
