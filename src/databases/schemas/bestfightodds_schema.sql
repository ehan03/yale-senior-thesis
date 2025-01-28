CREATE TABLE IF NOT EXISTS bestfightodds_moneyline_odds (
    event_id INTEGER,
    fighter_id INTEGER,
    betsite TEXT,
    timestamp INTEGER,
    odds INTEGER
);
CREATE TABLE IF NOT EXISTS bestfightodds_event_proposition_odds (
    event_id INTEGER,
    description TEXT,
    is_not INTEGER,
    betsite TEXT,
    odds INTEGER
);