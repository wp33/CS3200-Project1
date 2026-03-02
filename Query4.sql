-- Query 4
-- What It Achieves:
-- Retrieves incidents that are either verified and high severity,
-- or user-submitted and currently unverified.

SELECT
  i.incident_id,
  i.incident_type,
  i.severity,
  i.status
FROM Incident i
WHERE
  (i.status = 'Verified' AND i.severity >= 4)
  OR
  (i.source = 'User' AND i.status = 'Unverified');
