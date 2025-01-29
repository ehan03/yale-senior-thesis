CREATE TABLE IF NOT EXISTS betmma_fighters (
    id INTEGER PRIMARY KEY,
    ufcstats_id TEXT,
    sherdog_id INTEGER,
    name TEXT,
    height_inches REAL,
    reach_inches REAL,
    stance TEXT,
    nationality TEXT
);
CREATE TABLE IF NOT EXISTS betmma_fighter_histories (
    fighter_id INTEGER,
    order INTEGER,
    bout_id INTEGER,
    opponent_id INTEGER,
    outcome TEXT,
    outcome_method TEXT,
    end_round INTEGER,
    end_round_time_seconds INTEGER,
    total_time_seconds INTEGER,
    odds INTEGER
);
CREATE TABLE IF NOT EXISTS betmma_events (
    id INTEGER PRIMARY KEY,
    name TEXT,
    date DATE,
    location TEXT,
    is_ufc_event INTEGER,
    event_order INTEGER
);
CREATE TABLE IF NOT EXISTS betmma_bouts (
    id INTEGER PRIMARY KEY,
    event_id INTEGER,
    bout_order INTEGER,
    fighter_1_id INTEGER,
    fighter_2_id INTEGER
);
CREATE TABLE IF NOT EXISTS betmma_late_replacements (
    fighter_id INTEGER,
    bout_id INTEGER,
    notice_time_days INTEGER
);
CREATE TABLE IF NOT EXISTS betmma_missed_weights (
    fighter_id INTEGER,
    bout_id INTEGER,
    weight_lbs REAL
);