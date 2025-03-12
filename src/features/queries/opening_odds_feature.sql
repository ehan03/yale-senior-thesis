WITH cte1 AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id,
            fighter_id,
            betsite
            ORDER BY timestamp
        ) AS rn
    FROM bestfightodds_moneyline_odds
    WHERE betsite != 'meanodds'
),
cte2 AS (
    SELECT event_id,
        fighter_id,
        betsite,
        CASE
            WHEN odds > 0 THEN 1 + odds / 100.0
            ELSE 1 - 100.0 / odds
        END AS decimal_odds
    FROM cte1
    WHERE rn = 1
),
cte3 AS (
    SELECT event_id,
        fighter_id,
        AVG(decimal_odds) AS mean_opening_odds
    FROM cte2
    GROUP BY event_id,
        fighter_id
),
cte4 AS (
    SELECT red_fighter_id AS fighter_id,
        id AS bout_id,
        event_id
    FROM ufcstats_bouts
    UNION
    SELECT blue_fighter_id AS fighter_id,
        id AS bout_id,
        event_id
    FROM ufcstats_bouts
),
bestfightodds_open AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t4.bout_id,
        mean_opening_odds
    FROM cte3 AS t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.bestfightodds_id
        INNER JOIN event_mapping AS t3 ON t1.event_id = t3.bestfightodds_id
        LEFT JOIN cte4 AS t4 ON t3.ufcstats_id = t4.event_id
        AND t2.ufcstats_id = t4.fighter_id
),
cte5 AS (
    SELECT t1.bout_id,
        t2.fighter_1_id,
        t2.fighter_2_id,
        t1.sportsbook_id,
        t1.fighter_1_odds_open,
        t1.fighter_2_odds_open,
        ROW_NUMBER() OVER (
            ORDER BY t1.rowid
        ) AS rn
    FROM fightoddsio_moneyline_odds AS t1
        LEFT JOIN fightoddsio_bouts AS t2 ON t1.bout_id = t2.id
    WHERE t1.fighter_1_odds_open IS NOT NULL
        AND t1.fighter_2_odds_open IS NOT NULL
),
cte6 AS (
    SELECT bout_id,
        fighter_1_id,
        fighter_2_id,
        sportsbook_id,
        fighter_1_odds_open,
        fighter_2_odds_open,
        ROW_NUMBER() OVER (
            PARTITION BY bout_id,
            sportsbook_id
            ORDER BY rn
        ) AS temp_rn
    FROM cte5
),
cte7 AS (
    SELECT bout_id,
        fighter_1_id,
        fighter_2_id,
        sportsbook_id,
        fighter_1_odds_open,
        fighter_2_odds_open
    FROM cte6
    WHERE temp_rn = 1
),
cte8 AS (
    SELECT fighter_1_id AS fighter_id,
        bout_id,
        CASE
            WHEN fighter_1_odds_open > 0 THEN 1 + fighter_1_odds_open / 100.0
            ELSE 1 - 100.0 / fighter_1_odds_open
        END AS odds_open
    FROM cte7
    UNION
    SELECT fighter_2_id AS fighter_id,
        bout_id,
        CASE
            WHEN fighter_2_odds_open > 0 THEN 1 + fighter_2_odds_open / 100.0
            ELSE 1 - 100.0 / fighter_2_odds_open
        END AS odds_open
    FROM cte7
),
fightoddsio_open AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t3.ufcstats_id AS bout_id,
        AVG(odds_open) AS mean_opening_odds
    FROM cte8 AS t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.fightoddsio_id
        INNER JOIN bout_mapping AS t3 ON t1.bout_id = t3.fightoddsio_id
    GROUP BY t2.ufcstats_id,
        t3.ufcstats_id
),
cte9 AS (
    SELECT id,
        CASE
            WHEN t3.mean_opening_odds IS NOT NULL THEN 1.0 / t3.mean_opening_odds
            ELSE 1.0 / t2.mean_opening_odds
        END AS red_mean_opening_implied_prob,
        CASE
            WHEN t5.mean_opening_odds IS NOT NULL THEN 1.0 / t5.mean_opening_odds
            ELSE 1.0 / t4.mean_opening_odds
        END AS blue_mean_opening_implied_prob,
        CASE
            WHEN red_outcome = 'W' THEN 1
            WHEN red_outcome = 'L' THEN 0
            ELSE NULL
        END AS red_win
    FROM ufcstats_bouts AS t1
        LEFT JOIN bestfightodds_open AS t2 ON t1.id = t2.bout_id
        AND t1.red_fighter_id = t2.fighter_id
        LEFT JOIN fightoddsio_open AS t3 ON t1.id = t3.bout_id
        AND t1.red_fighter_id = t3.fighter_id
        LEFT JOIN bestfightodds_open AS t4 ON t1.id = t4.bout_id
        AND t1.blue_fighter_id = t4.fighter_id
        LEFT JOIN fightoddsio_open AS t5 ON t1.id = t5.bout_id
        AND t1.blue_fighter_id = t5.fighter_id
    WHERE event_id IN (
            SELECT id
            FROM ufcstats_events
            WHERE is_ufc_event = 1
                AND date >= '2008-04-19'
        )
)
SELECT id,
    (
        red_mean_opening_implied_prob - blue_mean_opening_implied_prob
    ) / (
        red_mean_opening_implied_prob + blue_mean_opening_implied_prob
    ) AS mean_devigged_opening_implied_prob_diff,
    red_win
FROM cte9