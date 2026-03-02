-- Query 2
-- What It Achieves:
-- Returns users who have submitted at least one unverified incident report.

SELECT
  u.user_id,
  u.full_name
FROM User u
WHERE u.user_id IN (
  SELECT
    i.submitted_by_user_id
  FROM Incident i
  WHERE i.status = 'Unverified'
);
