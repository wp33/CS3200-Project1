-- Query 4
SELECT
  i.incident_id,
  i.incident_type,
  i.severity,
  i.occurred_at,
  i.source,
  i.status,
  ss.street_name,
  z.zone_name
FROM Incident i
JOIN StreetSegment ss ON ss.segment_id = i.segment_id
JOIN Zone z ON z.zone_id = ss.zone_id
WHERE
  (i.status = 'Verified' AND i.severity >= 4)
  OR
  (i.source = 'User' AND i.status = 'Unverified'
   AND i.occurred_at >= NOW() - INTERVAL 7 DAY)
ORDER BY i.occurred_at DESC;
