-- Query 3
SELECT
  z.zone_name,
  COUNT(*) AS severe_incident_count
FROM Zone z
JOIN StreetSegment ss ON ss.zone_id = z.zone_id
JOIN Incident i ON i.segment_id = ss.segment_id
WHERE i.severity >= 4
GROUP BY z.zone_id, z.zone_name
HAVING COUNT(*) > 2
ORDER BY severe_incident_count DESC, z.zone_name;
