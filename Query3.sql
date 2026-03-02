-- Query 2
SELECT
  u.user_id,
  u.full_name,
  u.email
FROM User u
WHERE u.user_id IN (
  SELECT i.submitted_by_user_id
  FROM Incident i
  WHERE i.source = 'User'
    AND i.status = 'Unverified'
);
