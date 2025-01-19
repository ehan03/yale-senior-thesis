CREATE TABLE IF NOT EXISTS ufcstats_fighters (
    id TEXT PRIMARY KEY,
    name TEXT,
    height_inches INTEGER,
    reach_inches INTEGER,
    stance TEXT,
    date_of_birth DATE
);
CREATE TABLE IF NOT EXISTS ufcstats_fighter_histories (
    fighter_id TEXT,
    order INTEGER,
    bout_id TEXT,
    opponent_id TEXT
);
CREATE TABLE IF NOT EXISTS ufcstats_events (
    id = TEXT PRIMARY KEY,
    name TEXT,
    date DATE,
    location TEXT,
    is_ufc_event INTEGER,
    order INTEGER
);
CREATE TABLE IF NOT EXISTS ufcstats_bouts (
    id TEXT PRIMARY KEY,
    event_id TEXT,
    bout_order INTEGER,
    red_fighter_id TEXT,
    blue_fighter_id TEXT,
    red_outcome TEXT,
    blue_outcome TEXT,
    weight_class TEXT,
    type_verbose TEXT,
    performance_bonus INTEGER,
    outcome_method TEXT,
    outcome_method_details TEXT,
    end_round INTEGER,
    end_round_time_seconds INTEGER,
    round_time_format TEXT,
    total_time_seconds INTEGER
);
CREATE TABLE IF NOT EXISTS ufcstats_round_stats (
    bout_id TEXT,
    round_number INTEGER,
    fighter_id TEXT,
    round_time_seconds INTEGER,
    knockdowns_scored INTEGER,
    total_strikes_landed INTEGER,
    total_strikes_attempted INTEGER,
    takedowns_landed INTEGER,
    takedowns_attempted INTEGER,
    submissions_attempted INTEGER,
    reversals_scored INTEGER,
    control_time_seconds INTEGER,
    significant_strikes_landed INTEGER,
    significant_strikes_attempted INTEGER,
    significant_strikes_head_landed INTEGER,
    significant_strikes_head_attempted INTEGER,
    significant_strikes_body_landed INTEGER,
    significant_strikes_body_attempted INTEGER,
    significant_strikes_leg_landed INTEGER,
    significant_strikes_leg_attempted INTEGER,
    significant_strikes_distance_landed INTEGER,
    significant_strikes_distance_attempted INTEGER,
    significant_strikes_clinch_landed INTEGER,
    significant_strikes_clinch_attempted INTEGER,
    significant_strikes_ground_landed INTEGER,
    significant_strikes_ground_attempted INTEGER
);