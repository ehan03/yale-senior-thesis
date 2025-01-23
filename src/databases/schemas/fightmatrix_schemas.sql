CREATE TABLE IF NOT EXISTS fightmatrix_fighters (
    id INTEGER PRIMARY KEY,
    sherdog_id INTEGER,
    tapology_id TEXT,
    name TEXT,
    pro_debut_date DATE,
    ufc_debut_date DATE
);
CREATE TABLE IF NOT EXISTS fightmatrix_fighter_histories (
    fighter_id INTEGER,
    order INTEGER,
    event_id INTEGER,
    date DATE,
    opponent_id INTEGER,
    outcome TEXT,
    outcome_method TEXT,
    end_round INTEGER,
    fighter_elo_k170_pre INTEGER,
    fighter_elo_k170_post INTEGER,
    fighter_elo_modified_pre INTEGER,
    fighter_elo_modified_post INTEGER,
    fighter_glicko_1_pre INTEGER,
    fighter_glicko_1_post INTEGER,
    opponent_elo_k170_pre INTEGER,
    opponent_elo_k170_post INTEGER,
    opponent_elo_modified_pre INTEGER,
    opponent_elo_modified_post INTEGER,
    opponent_glicko_1_pre INTEGER,
    opponent_glicko_1_post INTEGER
);
CREATE TABLE IF NOT EXISTS fightmatrix_events (
    id INTEGER PRIMARY KEY,
    name TEXT,
    promotion TEXT,
    date DATE,
    country TEXT,
    is_ufc_event INTEGER,
    event_order INTEGER
);
CREATE TABLE IF NOT EXISTS fightmatrix_bouts (
    event_id INTEGER,
    bout_order INTEGER,
    fighter_1_id INTEGER,
    fighter_2_id INTEGER,
    fighter_1_outcome TEXT,
    fighter_2_outcome TEXT,
    fighter_1_elo_k170_pre INTEGER,
    fighter_1_elo_k170_post INTEGER,
    fighter_1_elo_modified_pre INTEGER,
    fighter_1_elo_modified_post INTEGER,
    fighter_1_glicko_1_pre INTEGER,
    fighter_1_glicko_1_post INTEGER,
    fighter_2_elo_k170_pre INTEGER,
    fighter_2_elo_k170_post INTEGER,
    fighter_2_elo_modified_pre INTEGER,
    fighter_2_elo_modified_post INTEGER,
    fighter_2_glicko_1_pre INTEGER,
    fighter_2_glicko_1_post INTEGER,
    weight_class TEXT,
    outcome_method TEXT,
    end_round INTEGER
);
CREATE TABLE IF NOT EXISTS fightmatrix_rankings (
    issue_date DATE,
    weight_class TEXT,
    fighter_id INTEGER,
    rank INTEGER,
    points INTEGER
);