CREATE TABLE IF NOT EXISTS wikipedia_events (
    id INTEGER PRIMARY KEY,
    date DATE,
    name TEXT,
    venue_id INTEGER,
    location TEXT,
    attendance INTEGER
);
CREATE TABLE IF NOT EXISTS wikipedia_venues (
    id INTEGER PRIMARY KEY,
    name TEXT,
    latitude REAL,
    longitude REAL,
    elevation_meters REAL,
    capacity INTEGER
);