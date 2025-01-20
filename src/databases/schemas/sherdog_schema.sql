CREATE TABLE IF NOT EXISTS sherdog_fighters (
    id INTEGER PRIMARY KEY,
    name TEXT,
    nickname TEXT,
    height_inches INTEGER,
    date_of_birth DATE,
    nationality TEXT,
    pro_debut_date DATE
);
CREATE TABLE IF NOT EXISTS sherdog_fighter_histories (
    fighter_id INTEGER,
    order INTEGER,
    event_id INTEGER,
    date DATE,
    opponent_id INTEGER,
    outcome TEXT,
    outcome_method TEXT,
    outcome_method_broad TEXT,
    end_round INTEGER,
    end_round_time TEXT,
    end_round_time_seconds INTEGER,
    total_time_seconds INTEGER
);
CREATE TABLE if NOT EXISTS sherdog_events (
    id INTEGER PRIMARY KEY,
    name TEXT,
    date DATE,
    location TEXT,
    country TEXT,
    is_ufc_event INTEGER,
    event_order INTEGER
);