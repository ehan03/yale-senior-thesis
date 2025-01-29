CREATE TABLE IF NOT EXISTS mmadecisions_fighters (
    id INTEGER PRIMARY KEY,
    name TEXT,
    nicknames TEXT,
    date_of_birth DATE,
    birth_location TEXT,
    height_inches REAL,
    reach_inches REAL
);
CREATE TABLE IF NOT EXISTS mmadecisions_events (
    id INTEGER PRIMARY KEY,
    name TEXT,
    promotion TEXT,
    date DATE,
    venue TEXT,
    location TEXT,
    event_order INTEGER
);
CREATE TABLE IF NOT EXISTS mmadecisions_bouts (
    id INTEGER PRIMARY KEY,
    event_id INTEGER,
    bout_order INTEGER,
    fighter_1_id INTEGER,
    fighter_2_id INTEGER,
    fighter_1_weight_lbs REAL,
    fighter_2_weight_lbs REAL,
    fighter_1_fighting_out_of TEXT,
    fighter_2_fighting_out_of TEXT,
    decision_type TEXT
);
CREATE TABLE IF NOT EXISTS mmadecisions_judges (id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE IF NOT EXISTS mmadecisions_judge_scores (
    bout_id INTEGER,
    round INTEGER,
    judge_id INTEGER,
    judge_order INTEGER,
    fighter_1_score INTEGER,
    fighter_2_score INTEGER
);
CREATE TABLE IF NOT EXISTS mmadecisions_media_scores (
    bout_id INTEGER,
    person_name TEXT,
    media_name TEXT,
    fighter_1_score INTEGER,
    fighter_2_score INTEGER
);
CREATE TABLE IF NOT EXISTS mmadecisions_deductions (
    bout_id INTEGER,
    fighter_id INTEGER,
    round_number INTEGER,
    points_deducted INTEGER,
    reason TEXT
);