CREATE TABLE IF NOT EXISTS tapology_fighters (
    id TEXT PRIMARY KEY,
    ufcstats_id TEXT,
    sherdog_id INTEGER,
    bestfightodds_id INTEGER,
    ufc_id TEXT,
    wikipedia_url TEXT,
    name TEXT,
    nickname TEXT,
    date_of_birth DATE,
    height_inches INTEGER,
    reach_inches REAL,
    nationality TEXT,
    birth_location TEXT
);
CREATE TABLE IF NOT EXISTS tapology_fighter_histories (
    fighter_id TEXT,
    order INTEGER,
    bout_id TEXT,
    bout_id_integer INTEGER,
    event_id TEXT,
    event_name TEXT,
    opponent_id TEXT,
    billing TEXT,
    round_time_format TEXT,
    weight_class TEXT,
    weight_class_lbs REAL,
    outcome TEXT,
    outcome_method TEXT,
    outcome_method_details TEXT,
    end_round INTEGER,
    end_round_time_seconds INTEGER,
    fighter_record TEXT,
    opponent_record TEXT,
    weigh_in_result_lbs REAL,
    odds INTEGER,
    pick_em_percent INTEGER
);
CREATE TABLE IF NOT EXISTS tapology_fighter_gyms_by_bout (
    fighter_id TEXT,
    bout_id TEXT,
    gym_id TEXT,
    gym_purpose TEXT
);
CREATE TABLE IF NOT EXISTS tapology_events (
    id TEXT PRIMARY KEY,
    ufcstats_id TEXT,
    sherdog_id INTEGER,
    bestfightodds_id INTEGER,
    ufc_id TEXT,
    name TEXT,
    event_order INTEGER
);
CREATE TABLE IF NOT EXISTS tapology_bouts (
    id TEXT PRIMARY KEY,
    ufcstats_id TEXT,
    event_id TEXT,
    bout_order INTEGER,
    fighter_1_id TEXT,
    fighter_2_id TEXT,
    billing TEXT,
    weight_class_final_weight_lbs INTEGER,
    weight_class_original_weight_lbs INTEGER,
    outcome_method TEXT,
    outcome_method_details TEXT,
    fighter_1_odds INTEGER,
    fighter_2_odds INTEGER,
    fighter_1_weight_lbs REAL,
    fighter_2_weight_lbs REAL
);
CREATE TABLE IF NOT EXISTS tapology_community_picks (
    bout_id TEXT,
    fighter_id TEXT,
    ko_tko_percentage REAL,
    submission_percentage REAL,
    decision_percentage REAL,
    overall_percentage INTEGER,
    num_picks INTEGER
);
CREATE TABLE IF NOT EXISTS tapology_gyms (
    id TEXT PRIMARY KEY,
    name TEXT,
    name_alternative TEXT,
    location TEXT,
    parent_id TEXT
);
CREATE TABLE IF NOT EXISTS tapology_rehydration_weights (
    bout_id TEXT,
    fighter_id TEXT,
    weigh_in_result_lbs REAL,
    fight_night_weight_lbs REAL,
    weight_gain_lbs REAL
);