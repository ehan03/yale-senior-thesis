CREATE TABLE IF NOT EXISTS fightoddsio_fighters (
    id TEXT PRIMARY KEY,
    pk INTEGER,
    slug TEXT,
    name TEXT,
    nickname TEXT,
    date_of_birth DATE,
    height_centimeters REAL,
    reach_inches REAL,
    leg_reach_inches INTEGER,
    fighting_style TEXT,
    stance TEXT,
    nationality TEXT
);
CREATE TABLE IF NOT EXISTS fightoddsio_events (
    id TEXT PRIMARY KEY,
    pk INTEGER,
    slug TEXT,
    name TEXT,
    date DATE,
    location TEXT,
    venue TEXT,
    event_order INTEGER
);
CREATE TABLE IF NOT EXISTS fightoddsio_bouts (
    id TEXT PRIMARY KEY,
    pk INTEGER,
    slug TEXT,
    event_id TEXT,
    fighter_1_id TEXT,
    fighter_2_id TEXT,
    winner_id TEXT,
    bout_type TEXT,
    weight_class TEXT,
    weight_lbs INTEGER,
    outcome_method TEXT,
    outcome_method_details TEXT,
    end_round INTEGER,
    end_round_time TEXT,
    fighter_1_odds INTEGER,
    fighter_2_odds INTEGER
);
CREATE TABLE IF NOT EXISTS fightoddsio_sportsbooks (
    id TEXT PRIMARY KEY,
    slug TEXT,
    short_name TEXT,
    full_name TEXT,
    website_url TEXT
);
CREATE TABLE IF NOT EXISTS fightoddsio_moneyline_odds (
    id TEXT PRIMARY KEY,
    bout_id TEXT,
    sportsbook_id TEXT,
    outcome_1_id TEXT,
    fighter_1_odds_open INTEGER,
    fighter_1_odds_worst INTEGER,
    fighter_1_odds_current INTEGER,
    fighter_1_odds_best INTEGER,
    outcome_2_id TEXT,
    fighter_2_odds_open INTEGER,
    fighter_2_odds_worst INTEGER,
    fighter_2_odds_current INTEGER,
    fighter_2_odds_best INTEGER
);
CREATE TABLE IF NOT EXISTS fightoddsio_proposition_odds (
    bout_id TEXT,
    offer_type_id TEXT,
    is_not INTEGER,
    average_odds INTEGER,
    fighter_pk INTEGER,
    description TEXT,
    not_description TEXT
);