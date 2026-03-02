-- Query 5
-- What It Achieves:
-- Ranks street segments within each zone based on safety score,
-- allowing comparison of relative risk levels inside each zone.

SELECT
  z.zone_name,
  ss.segment_id,
  sc.score_value,
  RANK() OVER (
    PARTITION BY z.zone_id
    ORDER BY sc.score_value ASC
  ) AS risk_rank_in_zone
FROM SafetyScore sc
JOIN StreetSegment ss
  ON ss.segment_id = sc.segment_id
JOIN Zone z
  ON z.zone_id = ss.zone_id;
