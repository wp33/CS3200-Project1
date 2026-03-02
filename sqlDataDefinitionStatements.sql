-- SafeRoute schema (SQLite3)
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS AlertSubscription;
DROP TABLE IF EXISTS RouteSegment;
DROP TABLE IF EXISTS GeneratedRoute;
DROP TABLE IF EXISTS RouteRequest;
DROP TABLE IF EXISTS SafetyScore;
DROP TABLE IF EXISTS Incident;
DROP TABLE IF EXISTS StreetSegment;
DROP TABLE IF EXISTS Zone;
DROP TABLE IF EXISTS User;

CREATE TABLE User (
  user_id     INTEGER PRIMARY KEY,
  full_name   TEXT NOT NULL,
  email       TEXT NOT NULL UNIQUE,
  affiliation TEXT NOT NULL CHECK (affiliation IN ('Student','Visitor','Staff'))
);

CREATE TABLE Zone (
  zone_id     INTEGER PRIMARY KEY,
  zone_name   TEXT NOT NULL UNIQUE,
  campus_area TEXT NOT NULL
);

CREATE TABLE StreetSegment (
  segment_id   INTEGER PRIMARY KEY,
  zone_id      INTEGER NOT NULL,
  street_name  TEXT NOT NULL,
  from_node    TEXT NOT NULL,
  to_node      TEXT NOT NULL,
  FOREIGN KEY (zone_id)
    REFERENCES Zone(zone_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE Incident (
  incident_id           INTEGER PRIMARY KEY,
  segment_id            INTEGER NOT NULL,
  submitted_by_user_id  INTEGER NULL,
  incident_type         TEXT NOT NULL,
  severity              INTEGER NOT NULL CHECK (severity BETWEEN 1 AND 5),
  occurred_at           TEXT NOT NULL, -- ISO8601: 'YYYY-MM-DD HH:MM:SS'
  source                TEXT NOT NULL CHECK (source IN ('Public','User')),
  status                TEXT NOT NULL CHECK (status IN ('Unverified','Verified','FalseReport')),
  FOREIGN KEY (segment_id)
    REFERENCES StreetSegment(segment_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (submitted_by_user_id)
    REFERENCES User(user_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CHECK (
    (source = 'User' AND submitted_by_user_id IS NOT NULL)
    OR (source = 'Public')
  )
);

CREATE TABLE SafetyScore (
  score_id    INTEGER PRIMARY KEY,
  segment_id  INTEGER NOT NULL,
  score_date  TEXT NOT NULL, -- 'YYYY-MM-DD'
  score_value INTEGER NOT NULL CHECK (score_value BETWEEN 0 AND 100),
  UNIQUE (segment_id, score_date),
  FOREIGN KEY (segment_id)
    REFERENCES StreetSegment(segment_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE RouteRequest (
  request_id         INTEGER PRIMARY KEY,
  user_id            INTEGER NOT NULL,
  requested_at       TEXT NOT NULL, -- ISO8601 datetime
  origin_label       TEXT NOT NULL,
  destination_label  TEXT NOT NULL,
  mode               TEXT NOT NULL CHECK (mode IN ('Safest','Balanced','Fastest')),
  FOREIGN KEY (user_id)
    REFERENCES User(user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE GeneratedRoute (
  route_id              INTEGER PRIMARY KEY,
  request_id            INTEGER NOT NULL UNIQUE,
  generated_at          TEXT NOT NULL, -- ISO8601 datetime
  total_distance_meters INTEGER NOT NULL CHECK (total_distance_meters >= 0),
  estimated_minutes     INTEGER NOT NULL CHECK (estimated_minutes >= 0),
  FOREIGN KEY (request_id)
    REFERENCES RouteRequest(request_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);

CREATE TABLE RouteSegment (
  route_id     INTEGER NOT NULL,
  segment_id   INTEGER NOT NULL,
  sequence_num INTEGER NOT NULL CHECK (sequence_num > 0),
  PRIMARY KEY (route_id, sequence_num),
  UNIQUE (route_id, segment_id),
  FOREIGN KEY (route_id)
    REFERENCES GeneratedRoute(route_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (segment_id)
    REFERENCES StreetSegment(segment_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);

CREATE TABLE AlertSubscription (
  user_id      INTEGER NOT NULL,
  zone_id      INTEGER NOT NULL,
  min_severity INTEGER NOT NULL CHECK (min_severity BETWEEN 1 AND 5),
  PRIMARY KEY (user_id, zone_id),
  FOREIGN KEY (user_id)
    REFERENCES User(user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (zone_id)
    REFERENCES Zone(zone_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);