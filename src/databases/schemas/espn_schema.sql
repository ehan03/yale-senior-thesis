CREATE TABLE IF NOT EXISTS espn_fighters (
    id INTEGER PRIMARY KEY,
    name TEXT,
    nickname TEXT,
    date_of_birth DATE,
    reach_inches REAL,
    height_inches INTEGER,
    stance TEXT,
    team_id INTEGER,
    nationality TEXT,
    fighting_style TEXT
);
CREATE TABLE IF NOT EXISTS espn_fighter_histories (
    fighter_id INTEGER,
    order INTEGER,
    bout_id INTEGER,
    event_id INTEGER,
    event_name TEXT,
    date DATE,
    hour_utc INTEGER,
    opponent_id INTEGER,
    outcome TEXT,
    outcome_method TEXT,
    end_round INTEGER,
    end_round_time_seconds INTEGER,
    total_time_seconds INTEGER,
    is_title_bout INTEGER
);
CREATE TABLE IF NOT EXISTS espn_events (
    id INTEGER PRIMARY KEY,
    name TEXT,
    date DATE,
    hour_utc INTEGER,
    venue_id INTEGER,
    event_order INTEGER
);
CREATE TABLE IF NOT EXISTS espn_bouts (
    id INTEGER PRIMARY KEY,
    event_id INTEGER,
    bout_order INTEGER,
    red_fighter_id INTEGER,
    blue_fighter_id INTEGER,
    winner_id INTEGER,
    card_segment TEXT
);
CREATE TABLE IF NOT EXISTS espn_bout_stats (
    bout_id INTEGER,
    fighter_id INTEGER,
    knockdowns_scored INTEGER,
    total_strikes_landed INTEGER,
    total_strikes_attempted INTEGER,
    takedowns_landed INTEGER,
    takedowns_slams_landed INTEGER,
    takedowns_attempted INTEGER,
    reversals_scored INTEGER,
    significant_strikes_distance_head_landed INTEGER,
    significant_strikes_distance_head_attempted INTEGER,
    significant_strikes_distance_body_landed INTEGER,
    significant_strikes_distance_body_attempted INTEGER,
    significant_strikes_distance_leg_landed INTEGER,
    significant_strikes_distance_leg_attempted INTEGER,
    significant_strikes_clinch_head_landed INTEGER,
    significant_strikes_clinch_head_attempted INTEGER,
    significant_strikes_clinch_body_landed INTEGER,
    significant_strikes_clinch_body_attempted INTEGER,
    significant_strikes_clinch_leg_landed INTEGER,
    significant_strikes_clinch_leg_attempted INTEGER,
    significant_strikes_ground_head_landed INTEGER,
    significant_strikes_ground_head_attempted INTEGER,
    significant_strikes_ground_body_landed INTEGER,
    significant_strikes_ground_body_attempted INTEGER,
    significant_strikes_ground_leg_landed INTEGER,
    significant_strikes_ground_leg_attempted INTEGER,
    advances INTEGER,
    advances_to_back INTEGER,
    advances_to_half_guard INTEGER,
    advances_to_mount INTEGER,
    advances_to_side INTEGER,
    submissions_attempted INTEGER
);
CREATE TABLE IF NOT EXISTS espn_teams (id INTEGER PRIMARY KEY, name TEXT);
CREATE TABLE IF NOT EXISTS espn_venues (
    id INTEGER PRIMARY KEY,
    name TEXT,
    city TEXT,
    state TEXT,
    country TEXT,
    is_indoor INTEGER
);