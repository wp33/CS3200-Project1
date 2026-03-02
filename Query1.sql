-- Query 1
-- What It Achieves:
-- Retrieves route requests along with the user who made the request
-- and the zones included in the generated route.

SELECT
  rr.request_id,
  u.full_name,
  z.zone_name
FROM RouteRequest rr
JOIN User u
  ON u.user_id = rr.user_id
JOIN GeneratedRoute gr
  ON gr.request_id = rr.request_id
JOIN RouteSegment rs
  ON rs.route_id = gr.route_id
JOIN StreetSegment ss
  ON ss.segment_id = rs.segment_id
JOIN Zone z
  ON z.zone_id = ss.zone_id
ORDER BY
  rr.request_id;
