-- Query 1
SELECT
  rr.request_id,
  u.full_name,
  rr.requested_at,
  rr.mode,
  gr.route_id,
  rs.sequence_num,
  ss.street_name,
  z.zone_name
FROM RouteRequest rr
JOIN User u ON u.user_id = rr.user_id
JOIN GeneratedRoute gr ON gr.request_id = rr.request_id
JOIN RouteSegment rs ON rs.route_id = gr.route_id
JOIN StreetSegment ss ON ss.segment_id = rs.segment_id
JOIN Zone z ON z.zone_id = ss.zone_id
ORDER BY rr.request_id, rs.sequence_num;
