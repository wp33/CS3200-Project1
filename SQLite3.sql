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
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  affiliation ENUM('Student','Visitor','Staff') NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Zone (
  zone_id INT AUTO_INCREMENT PRIMARY KEY,
  zone_name VARCHAR(100) NOT NULL UNIQUE,
  campus_area VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE StreetSegment (
  segment_id INT AUTO_INCREMENT PRIMARY KEY,
  zone_id INT NOT NULL,
  street_name VARCHAR(120) NOT NULL,
  from_node VARCHAR(80) NOT NULL,
  to_node VARCHAR(80) NOT NULL,
  CONSTRAINT fk_segment_zone
    FOREIGN KEY (zone_id)
    REFERENCES Zone(zone_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE Incident (
  incident_id INT AUTO_INCREMENT PRIMARY KEY,
  segment_id INT NOT NULL,
  submitted_by_user_id INT NULL,
  incident_type VARCHAR(120) NOT NULL,
  severity TINYINT NOT NULL,
  occurred_at DATETIME NOT NULL,
  source ENUM('Public','User') NOT NULL,
  status ENUM('Unverified','Verified','FalseReport') NOT NULL,
  CONSTRAINT fk_incident_segment
    FOREIGN KEY (segment_id)
    REFERENCES StreetSegment(segment_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_incident_user
    FOREIGN KEY (submitted_by_user_id)
    REFERENCES User(user_id)
    ON UPDATE CASCADE
    ON DELETE SET NULL,
  CONSTRAINT chk_severity CHECK (severity BETWEEN 1 AND 5),
  CONSTRAINT chk_user_source CHECK (
    (source = 'User' AND submitted_by_user_id IS NOT NULL)
    OR (source = 'Public')
  )
) ENGINE=InnoDB;

CREATE TABLE SafetyScore (
  score_id INT AUTO_INCREMENT PRIMARY KEY,
  segment_id INT NOT NULL,
  score_date DATE NOT NULL,
  score_value TINYINT NOT NULL,
  UNIQUE (segment_id, score_date),
  CONSTRAINT fk_score_segment
    FOREIGN KEY (segment_id)
    REFERENCES StreetSegment(segment_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_score CHECK (score_value BETWEEN 0 AND 100)
) ENGINE=InnoDB;

CREATE TABLE RouteRequest (
  request_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  requested_at DATETIME NOT NULL,
  origin_label VARCHAR(120) NOT NULL,
  destination_label VARCHAR(120) NOT NULL,
  mode ENUM('Safest','Balanced','Fastest') NOT NULL,
  CONSTRAINT fk_request_user
    FOREIGN KEY (user_id)
    REFERENCES User(user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE GeneratedRoute (
  route_id INT AUTO_INCREMENT PRIMARY KEY,
  request_id INT NOT NULL UNIQUE,
  generated_at DATETIME NOT NULL,
  total_distance_meters INT NOT NULL,
  estimated_minutes INT NOT NULL,
  CONSTRAINT fk_route_request
    FOREIGN KEY (request_id)
    REFERENCES RouteRequest(request_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_distance CHECK (total_distance_meters >= 0),
  CONSTRAINT chk_minutes CHECK (estimated_minutes >= 0)
) ENGINE=InnoDB;

CREATE TABLE RouteSegment (
  route_id INT NOT NULL,
  segment_id INT NOT NULL,
  sequence_num INT NOT NULL,
  PRIMARY KEY (route_id, sequence_num),
  UNIQUE (route_id, segment_id),
  CONSTRAINT fk_rs_route
    FOREIGN KEY (route_id)
    REFERENCES GeneratedRoute(route_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_rs_segment
    FOREIGN KEY (segment_id)
    REFERENCES StreetSegment(segment_id)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT chk_sequence CHECK (sequence_num > 0)
) ENGINE=InnoDB;

CREATE TABLE AlertSubscription (
  user_id INT NOT NULL,
  zone_id INT NOT NULL,
  min_severity TINYINT NOT NULL,
  PRIMARY KEY (user_id, zone_id),
  CONSTRAINT fk_as_user
    FOREIGN KEY (user_id)
    REFERENCES User(user_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT fk_as_zone
    FOREIGN KEY (zone_id)
    REFERENCES Zone(zone_id)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  CONSTRAINT chk_min_severity CHECK (min_severity BETWEEN 1 AND 5)
) ENGINE=InnoDB;