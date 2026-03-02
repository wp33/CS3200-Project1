-- Query 3
-- What It Achieves:
-- Counts the number of incidents in each zone and returns
-- only zones with at least two incidents.

SELECT
  z.zone_name,
  COUNT(*) AS incident_count
FROM Zone z
JOIN StreetSegment ss
  ON ss.zone_id = z.zone_id
JOIN Incident i
  ON i.segment_id = ss.segment_id
GROUP BY
  z.zone_id,
  z.zone_name
HAVING COUNT(*) >= 2;
