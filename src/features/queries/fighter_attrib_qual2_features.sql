WITH cte1 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.event_id,
        t1.opponent_id,
        ROW_NUMBER() OVER (
            PARTITION BY t1.fighter_id,
            t1.event_id,
            t1.opponent_id
            ORDER BY t1.'order'
        ) AS temp_rn,
        CASE
            WHEN t1.outcome = 'W' THEN 1
            ELSE 0
        END AS win,
        CASE
            WHEN t1.outcome = 'L' THEN 1
            ELSE 0
        END AS lose,
        CASE
            WHEN t2.country LIKE '% USA%' THEN 'united states'
            ELSE LOWER(t2.country)
        END AS country,
        CASE
            WHEN t3.nationality = 'USA' THEN 'united states'
            ELSE LOWER(t3.nationality)
        END AS nationality,
        CASE
            WHEN t4.nationality = 'USA' THEN 'united states'
            ELSE LOWER(t4.nationality)
        END AS opp_nationality
    FROM sherdog_fighter_histories t1
        LEFT JOIN sherdog_events t2 ON t1.event_id = t2.id
        LEFT JOIN sherdog_fighters t3 ON t1.fighter_id = t3.id
        LEFT JOIN sherdog_fighters t4 ON t1.opponent_id = t4.id
),
cte2 AS (
    SELECT event_id,
        bout_order,
        fighter_1_id AS fighter_id,
        fighter_2_id AS opponent_id,
        is_title_bout,
        weight_class
    FROM sherdog_bouts
    UNION
    SELECT event_id,
        bout_order,
        fighter_2_id AS fighter_id,
        fighter_1_id AS opponent_id,
        is_title_bout,
        weight_class
    FROM sherdog_bouts
),
cte3 AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY event_id,
            fighter_id,
            opponent_id
            ORDER BY bout_order
        ) AS temp_rn
    FROM cte2
),
cte4 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.event_id,
        t1.opponent_id,
        t1.temp_rn,
        t1.win,
        t1.lose,
        t1.country,
        t1.opp_nationality,
        CASE
            WHEN t1.nationality = t1.country THEN 1
            ELSE 0
        END AS is_home_country,
        CASE
            WHEN t1.opp_nationality = t1.country THEN 1
            ELSE 0
        END AS opp_is_home_country,
        t2.is_title_bout,
        t2.weight_class
    FROM cte1 t1
        LEFT JOIN cte3 t2 ON t1.event_id = t2.event_id
        AND t1.fighter_id = t2.fighter_id
        AND t1.opponent_id = t2.opponent_id
        AND t1.temp_rn = t2.temp_rn
    ORDER BY t1.fighter_id,
        t1.'order'
),
cte5 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        opponent_id,
        t1.temp_rn,
        SUM(win) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins,
        SUM(lose) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses,
        AVG(win) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct,
        AVG(lose) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS lose_pct,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_by_country,
        SUM(lose) OVER (
            PARTITION BY fighter_id,
            country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_by_country,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_by_country,
        AVG(lose) OVER (
            PARTITION BY fighter_id,
            country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS lose_pct_by_country,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            opp_nationality
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_against_opp_nationality,
        SUM(lose) OVER (
            PARTITION BY fighter_id,
            opp_nationality
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_against_opp_nationality,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            opp_nationality
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_against_opp_nationality,
        AVG(lose) OVER (
            PARTITION BY fighter_id,
            opp_nationality
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS lose_pct_against_opp_nationality,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_by_is_home_country,
        SUM(lose) OVER (
            PARTITION BY fighter_id,
            is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_by_is_home_country,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_by_is_home_country,
        AVG(lose) OVER (
            PARTITION BY fighter_id,
            is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS lose_pct_by_is_home_country,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            opp_is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_by_opp_is_home_country,
        SUM(lose) OVER (
            PARTITION BY fighter_id,
            opp_is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_by_opp_is_home_country,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            opp_is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_by_opp_is_home_country,
        AVG(lose) OVER (
            PARTITION BY fighter_id,
            opp_is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS lose_pct_by_opp_is_home_country,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            is_home_country,
            opp_is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_by_is_home_country_and_opp_is_home_country,
        SUM(lose) OVER (
            PARTITION BY fighter_id,
            is_home_country,
            opp_is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_by_is_home_country_and_opp_is_home_country,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            is_home_country,
            opp_is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_by_is_home_country_and_opp_is_home_country,
        AVG(lose) OVER (
            PARTITION BY fighter_id,
            is_home_country,
            opp_is_home_country
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS lose_pct_by_is_home_country_and_opp_is_home_country,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            is_title_bout
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_by_is_title_bout,
        SUM(lose) OVER (
            PARTITION BY fighter_id,
            is_title_bout
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_by_is_title_bout,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            is_title_bout
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_by_is_title_bout,
        AVG(lose) OVER (
            PARTITION BY fighter_id,
            is_title_bout
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS lose_pct_by_is_title_bout,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            weight_class
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_by_weight_class,
        SUM(lose) OVER (
            PARTITION BY fighter_id,
            weight_class
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_by_weight_class,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            weight_class
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_by_weight_class,
        AVG(lose) OVER (
            PARTITION BY fighter_id,
            weight_class
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS lose_pct_by_weight_class
    FROM cte4 t1
    ORDER BY t1.fighter_id,
        t1.'order'
),
cte6 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        opponent_id,
        t1.temp_rn,
        CASE
            WHEN wins IS NULL THEN 0
            ELSE wins
        END AS wins,
        CASE
            WHEN losses IS NULL THEN 0
            ELSE losses
        END AS losses,
        win_pct,
        lose_pct,
        CASE
            WHEN wins_by_country IS NULL THEN 0
            ELSE wins_by_country
        END AS wins_by_country,
        CASE
            WHEN losses_by_country IS NULL THEN 0
            ELSE losses_by_country
        END AS losses_by_country,
        CASE
            WHEN win_pct_by_country IS NULL THEN win_pct
            ELSE win_pct_by_country
        END AS win_pct_by_country,
        CASE
            WHEN lose_pct_by_country IS NULL THEN lose_pct
            ELSE lose_pct_by_country
        END AS lose_pct_by_country,
        CASE
            WHEN wins_against_opp_nationality IS NULL THEN 0
            ELSE wins_against_opp_nationality
        END AS wins_against_opp_nationality,
        CASE
            WHEN losses_against_opp_nationality IS NULL THEN 0
            ELSE losses_against_opp_nationality
        END AS losses_against_opp_nationality,
        CASE
            WHEN win_pct_against_opp_nationality IS NULL THEN win_pct
            ELSE win_pct_against_opp_nationality
        END AS win_pct_against_opp_nationality,
        CASE
            WHEN lose_pct_against_opp_nationality IS NULL THEN lose_pct
            ELSE lose_pct_against_opp_nationality
        END AS lose_pct_against_opp_nationality,
        CASE
            WHEN wins_by_is_home_country IS NULL THEN 0
            ELSE wins_by_is_home_country
        END AS wins_by_is_home_country,
        CASE
            WHEN losses_by_is_home_country IS NULL THEN 0
            ELSE losses_by_is_home_country
        END AS losses_by_is_home_country,
        CASE
            WHEN win_pct_by_is_home_country IS NULL THEN win_pct
            ELSE win_pct_by_is_home_country
        END AS win_pct_by_is_home_country,
        CASE
            WHEN lose_pct_by_is_home_country IS NULL THEN lose_pct
            ELSE lose_pct_by_is_home_country
        END AS lose_pct_by_is_home_country,
        CASE
            WHEN wins_by_opp_is_home_country IS NULL THEN 0
            ELSE wins_by_opp_is_home_country
        END AS wins_by_opp_is_home_country,
        CASE
            WHEN losses_by_opp_is_home_country IS NULL THEN 0
            ELSE losses_by_opp_is_home_country
        END AS losses_by_opp_is_home_country,
        CASE
            WHEN win_pct_by_opp_is_home_country IS NULL THEN win_pct
            ELSE win_pct_by_opp_is_home_country
        END AS win_pct_by_opp_is_home_country,
        CASE
            WHEN lose_pct_by_opp_is_home_country IS NULL THEN lose_pct
            ELSE lose_pct_by_opp_is_home_country
        END AS lose_pct_by_opp_is_home_country,
        CASE
            WHEN wins_by_is_home_country_and_opp_is_home_country IS NULL THEN 0
            ELSE wins_by_is_home_country_and_opp_is_home_country
        END AS wins_by_is_home_country_and_opp_is_home_country,
        CASE
            WHEN losses_by_is_home_country_and_opp_is_home_country IS NULL THEN 0
            ELSE losses_by_is_home_country_and_opp_is_home_country
        END AS losses_by_is_home_country_and_opp_is_home_country,
        CASE
            WHEN win_pct_by_is_home_country_and_opp_is_home_country IS NULL THEN win_pct
            ELSE win_pct_by_is_home_country_and_opp_is_home_country
        END AS win_pct_by_is_home_country_and_opp_is_home_country,
        CASE
            WHEN lose_pct_by_is_home_country_and_opp_is_home_country IS NULL THEN lose_pct
            ELSE lose_pct_by_is_home_country_and_opp_is_home_country
        END AS lose_pct_by_is_home_country_and_opp_is_home_country,
        CASE
            WHEN wins_by_is_title_bout IS NULL THEN 0
            ELSE wins_by_is_title_bout
        END AS wins_by_is_title_bout,
        CASE
            WHEN losses_by_is_title_bout IS NULL THEN 0
            ELSE losses_by_is_title_bout
        END AS losses_by_is_title_bout,
        CASE
            WHEN win_pct_by_is_title_bout IS NULL THEN win_pct
            ELSE win_pct_by_is_title_bout
        END AS win_pct_by_is_title_bout,
        CASE
            WHEN lose_pct_by_is_title_bout IS NULL THEN lose_pct
            ELSE lose_pct_by_is_title_bout
        END AS lose_pct_by_is_title_bout,
        CASE
            WHEN wins_by_weight_class IS NULL THEN 0
            ELSE wins_by_weight_class
        END AS wins_by_weight_class,
        CASE
            WHEN losses_by_weight_class IS NULL THEN 0
            ELSE losses_by_weight_class
        END AS losses_by_weight_class,
        CASE
            WHEN win_pct_by_weight_class IS NULL THEN win_pct
            ELSE win_pct_by_weight_class
        END AS win_pct_by_weight_class,
        CASE
            WHEN lose_pct_by_weight_class IS NULL THEN lose_pct
            ELSE lose_pct_by_weight_class
        END AS lose_pct_by_weight_class
    FROM cte5 t1
),
cte7 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.event_id,
        t1.opponent_id,
        t1.wins_by_country,
        t1.losses_by_country,
        t1.win_pct_by_country,
        t1.lose_pct_by_country,
        t1.wins_against_opp_nationality,
        t1.losses_against_opp_nationality,
        t1.win_pct_against_opp_nationality,
        t1.lose_pct_against_opp_nationality,
        t1.wins_by_is_home_country,
        t1.losses_by_is_home_country,
        t1.win_pct_by_is_home_country,
        t1.lose_pct_by_is_home_country,
        t1.wins_by_opp_is_home_country,
        t1.losses_by_opp_is_home_country,
        t1.win_pct_by_opp_is_home_country,
        t1.lose_pct_by_opp_is_home_country,
        t1.wins_by_is_home_country_and_opp_is_home_country,
        t1.losses_by_is_home_country_and_opp_is_home_country,
        t1.win_pct_by_is_home_country_and_opp_is_home_country,
        t1.lose_pct_by_is_home_country_and_opp_is_home_country,
        t1.wins_by_is_title_bout,
        t1.losses_by_is_title_bout,
        t1.win_pct_by_is_title_bout,
        t1.lose_pct_by_is_title_bout,
        t1.wins_by_weight_class,
        t1.losses_by_weight_class,
        t1.win_pct_by_weight_class,
        t1.lose_pct_by_weight_class,
        AVG(t2.wins_by_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_country,
        AVG(t1.wins_by_country - t2.wins_by_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_country_diff,
        AVG(t2.losses_by_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_country,
        AVG(t1.losses_by_country - t2.losses_by_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_country_diff,
        AVG(t2.win_pct_by_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_country,
        AVG(t1.win_pct_by_country - t2.win_pct_by_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_country_diff,
        AVG(t2.lose_pct_by_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_country,
        AVG(t1.lose_pct_by_country - t2.lose_pct_by_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_country_diff,
        AVG(t2.wins_against_opp_nationality) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_against_opp_nationality,
        AVG(
            t1.wins_against_opp_nationality - t2.wins_against_opp_nationality
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_against_opp_nationality_diff,
        AVG(t2.losses_against_opp_nationality) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_against_opp_nationality,
        AVG(
            t1.losses_against_opp_nationality - t2.losses_against_opp_nationality
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_against_opp_nationality_diff,
        AVG(t2.win_pct_against_opp_nationality) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_against_opp_nationality,
        AVG(
            t1.win_pct_against_opp_nationality - t2.win_pct_against_opp_nationality
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_against_opp_nationality_diff,
        AVG(t2.lose_pct_against_opp_nationality) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_against_opp_nationality,
        AVG(
            t1.lose_pct_against_opp_nationality - t2.lose_pct_against_opp_nationality
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_against_opp_nationality_diff,
        AVG(t2.wins_by_is_home_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_is_home_country,
        AVG(
            t1.wins_by_is_home_country - t2.wins_by_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_is_home_country_diff,
        AVG(t2.losses_by_is_home_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_is_home_country,
        AVG(
            t1.losses_by_is_home_country - t2.losses_by_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_is_home_country_diff,
        AVG(t2.win_pct_by_is_home_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_is_home_country,
        AVG(
            t1.win_pct_by_is_home_country - t2.win_pct_by_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_is_home_country_diff,
        AVG(t2.lose_pct_by_is_home_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_is_home_country,
        AVG(
            t1.lose_pct_by_is_home_country - t2.lose_pct_by_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_is_home_country_diff,
        AVG(t2.wins_by_opp_is_home_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_opp_is_home_country,
        AVG(
            t1.wins_by_opp_is_home_country - t2.wins_by_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_opp_is_home_country_diff,
        AVG(t2.losses_by_opp_is_home_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_opp_is_home_country,
        AVG(
            t1.losses_by_opp_is_home_country - t2.losses_by_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_opp_is_home_country_diff,
        AVG(t2.win_pct_by_opp_is_home_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_opp_is_home_country,
        AVG(
            t1.win_pct_by_opp_is_home_country - t2.win_pct_by_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_opp_is_home_country_diff,
        AVG(t2.lose_pct_by_opp_is_home_country) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_opp_is_home_country,
        AVG(
            t1.lose_pct_by_opp_is_home_country - t2.lose_pct_by_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_opp_is_home_country_diff,
        AVG(
            t2.wins_by_is_home_country_and_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_is_home_country_and_opp_is_home_country,
        AVG(
            t1.wins_by_is_home_country_and_opp_is_home_country - t2.wins_by_is_home_country_and_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff,
        AVG(
            t2.losses_by_is_home_country_and_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_is_home_country_and_opp_is_home_country,
        AVG(
            t1.losses_by_is_home_country_and_opp_is_home_country - t2.losses_by_is_home_country_and_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff,
        AVG(
            t2.win_pct_by_is_home_country_and_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_is_home_country_and_opp_is_home_country,
        AVG(
            t1.win_pct_by_is_home_country_and_opp_is_home_country - t2.win_pct_by_is_home_country_and_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff,
        AVG(
            t2.lose_pct_by_is_home_country_and_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country,
        AVG(
            t1.lose_pct_by_is_home_country_and_opp_is_home_country - t2.lose_pct_by_is_home_country_and_opp_is_home_country
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff,
        AVG(t2.wins_by_is_title_bout) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_is_title_bout,
        AVG(
            t1.wins_by_is_title_bout - t2.wins_by_is_title_bout
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_is_title_bout_diff,
        AVG(t2.losses_by_is_title_bout) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_is_title_bout,
        AVG(
            t1.losses_by_is_title_bout - t2.losses_by_is_title_bout
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_is_title_bout_diff,
        AVG(t2.win_pct_by_is_title_bout) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_is_title_bout,
        AVG(
            t1.win_pct_by_is_title_bout - t2.win_pct_by_is_title_bout
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_is_title_bout_diff,
        AVG(t2.lose_pct_by_is_title_bout) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_is_title_bout,
        AVG(
            t1.lose_pct_by_is_title_bout - t2.lose_pct_by_is_title_bout
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_is_title_bout_diff,
        AVG(t2.wins_by_weight_class) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_weight_class,
        AVG(
            t1.wins_by_weight_class - t2.wins_by_weight_class
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_weight_class_diff,
        AVG(t2.losses_by_weight_class) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_weight_class,
        AVG(
            t1.losses_by_weight_class - t2.losses_by_weight_class
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_weight_class_diff,
        AVG(t2.win_pct_by_weight_class) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_weight_class,
        AVG(
            t1.win_pct_by_weight_class - t2.win_pct_by_weight_class
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_by_weight_class_diff,
        AVG(t2.lose_pct_by_weight_class) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_weight_class,
        AVG(
            t1.lose_pct_by_weight_class - t2.lose_pct_by_weight_class
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_lose_pct_by_weight_class_diff
    FROM cte6 t1
        LEFT JOIN cte6 t2 ON t1.fighter_id = t2.opponent_id
        AND t1.event_id = t2.event_id
        AND t1.opponent_id = t2.fighter_id
        AND t1.temp_rn = t2.temp_rn
),
cte8 AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t1.'order',
        t4.ufcstats_id AS event_id,
        t3.ufcstats_id AS opponent_id,
        t1.wins_by_country,
        t1.losses_by_country,
        t1.win_pct_by_country,
        t1.lose_pct_by_country,
        t1.wins_against_opp_nationality,
        t1.losses_against_opp_nationality,
        t1.win_pct_against_opp_nationality,
        t1.lose_pct_against_opp_nationality,
        t1.wins_by_is_home_country,
        t1.losses_by_is_home_country,
        t1.win_pct_by_is_home_country,
        t1.lose_pct_by_is_home_country,
        t1.wins_by_opp_is_home_country,
        t1.losses_by_opp_is_home_country,
        t1.win_pct_by_opp_is_home_country,
        t1.lose_pct_by_opp_is_home_country,
        t1.wins_by_is_home_country_and_opp_is_home_country,
        t1.losses_by_is_home_country_and_opp_is_home_country,
        t1.win_pct_by_is_home_country_and_opp_is_home_country,
        t1.lose_pct_by_is_home_country_and_opp_is_home_country,
        t1.wins_by_is_title_bout,
        t1.losses_by_is_title_bout,
        t1.win_pct_by_is_title_bout,
        t1.lose_pct_by_is_title_bout,
        t1.wins_by_weight_class,
        t1.losses_by_weight_class,
        t1.win_pct_by_weight_class,
        t1.lose_pct_by_weight_class,
        t1.avg_opp_wins_by_country,
        t1.avg_opp_wins_by_country_diff,
        t1.avg_opp_losses_by_country,
        t1.avg_opp_losses_by_country_diff,
        t1.avg_opp_win_pct_by_country,
        t1.avg_opp_win_pct_by_country_diff,
        t1.avg_opp_lose_pct_by_country,
        t1.avg_opp_lose_pct_by_country_diff,
        t1.avg_opp_wins_against_opp_nationality,
        t1.avg_opp_wins_against_opp_nationality_diff,
        t1.avg_opp_losses_against_opp_nationality,
        t1.avg_opp_losses_against_opp_nationality_diff,
        t1.avg_opp_win_pct_against_opp_nationality,
        t1.avg_opp_win_pct_against_opp_nationality_diff,
        t1.avg_opp_lose_pct_against_opp_nationality,
        t1.avg_opp_lose_pct_against_opp_nationality_diff,
        t1.avg_opp_wins_by_is_home_country,
        t1.avg_opp_wins_by_is_home_country_diff,
        t1.avg_opp_losses_by_is_home_country,
        t1.avg_opp_losses_by_is_home_country_diff,
        t1.avg_opp_win_pct_by_is_home_country,
        t1.avg_opp_win_pct_by_is_home_country_diff,
        t1.avg_opp_lose_pct_by_is_home_country,
        t1.avg_opp_lose_pct_by_is_home_country_diff,
        t1.avg_opp_wins_by_opp_is_home_country,
        t1.avg_opp_wins_by_opp_is_home_country_diff,
        t1.avg_opp_losses_by_opp_is_home_country,
        t1.avg_opp_losses_by_opp_is_home_country_diff,
        t1.avg_opp_win_pct_by_opp_is_home_country,
        t1.avg_opp_win_pct_by_opp_is_home_country_diff,
        t1.avg_opp_lose_pct_by_opp_is_home_country,
        t1.avg_opp_lose_pct_by_opp_is_home_country_diff,
        t1.avg_opp_wins_by_is_home_country_and_opp_is_home_country,
        t1.avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff,
        t1.avg_opp_losses_by_is_home_country_and_opp_is_home_country,
        t1.avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff,
        t1.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country,
        t1.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff,
        t1.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country,
        t1.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff,
        t1.avg_opp_wins_by_is_title_bout,
        t1.avg_opp_wins_by_is_title_bout_diff,
        t1.avg_opp_losses_by_is_title_bout,
        t1.avg_opp_losses_by_is_title_bout_diff,
        t1.avg_opp_win_pct_by_is_title_bout,
        t1.avg_opp_win_pct_by_is_title_bout_diff,
        t1.avg_opp_lose_pct_by_is_title_bout,
        t1.avg_opp_lose_pct_by_is_title_bout_diff,
        t1.avg_opp_wins_by_weight_class,
        t1.avg_opp_wins_by_weight_class_diff,
        t1.avg_opp_losses_by_weight_class,
        t1.avg_opp_losses_by_weight_class_diff,
        t1.avg_opp_win_pct_by_weight_class,
        t1.avg_opp_win_pct_by_weight_class_diff,
        t1.avg_opp_lose_pct_by_weight_class,
        t1.avg_opp_lose_pct_by_weight_class_diff
    FROM cte7 t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.sherdog_id
        INNER JOIN fighter_mapping AS t3 ON t1.opponent_id = t3.sherdog_id
        INNER JOIN event_mapping AS t4 ON t1.event_id = t4.sherdog_id
),
cte9 AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        event_id,
        opponent_id,
        wins_by_country,
        losses_by_country,
        win_pct_by_country,
        lose_pct_by_country,
        wins_against_opp_nationality,
        losses_against_opp_nationality,
        win_pct_against_opp_nationality,
        lose_pct_against_opp_nationality,
        wins_by_is_home_country,
        losses_by_is_home_country,
        win_pct_by_is_home_country,
        lose_pct_by_is_home_country,
        wins_by_opp_is_home_country,
        losses_by_opp_is_home_country,
        win_pct_by_opp_is_home_country,
        lose_pct_by_opp_is_home_country,
        wins_by_is_home_country_and_opp_is_home_country,
        losses_by_is_home_country_and_opp_is_home_country,
        win_pct_by_is_home_country_and_opp_is_home_country,
        lose_pct_by_is_home_country_and_opp_is_home_country,
        wins_by_is_title_bout,
        losses_by_is_title_bout,
        win_pct_by_is_title_bout,
        lose_pct_by_is_title_bout,
        wins_by_weight_class,
        losses_by_weight_class,
        win_pct_by_weight_class,
        lose_pct_by_weight_class,
        avg_opp_wins_by_country,
        avg_opp_wins_by_country_diff,
        avg_opp_losses_by_country,
        avg_opp_losses_by_country_diff,
        avg_opp_win_pct_by_country,
        avg_opp_win_pct_by_country_diff,
        avg_opp_lose_pct_by_country,
        avg_opp_lose_pct_by_country_diff,
        avg_opp_wins_against_opp_nationality,
        avg_opp_wins_against_opp_nationality_diff,
        avg_opp_losses_against_opp_nationality,
        avg_opp_losses_against_opp_nationality_diff,
        avg_opp_win_pct_against_opp_nationality,
        avg_opp_win_pct_against_opp_nationality_diff,
        avg_opp_lose_pct_against_opp_nationality,
        avg_opp_lose_pct_against_opp_nationality_diff,
        avg_opp_wins_by_is_home_country,
        avg_opp_wins_by_is_home_country_diff,
        avg_opp_losses_by_is_home_country,
        avg_opp_losses_by_is_home_country_diff,
        avg_opp_win_pct_by_is_home_country,
        avg_opp_win_pct_by_is_home_country_diff,
        avg_opp_lose_pct_by_is_home_country,
        avg_opp_lose_pct_by_is_home_country_diff,
        avg_opp_wins_by_opp_is_home_country,
        avg_opp_wins_by_opp_is_home_country_diff,
        avg_opp_losses_by_opp_is_home_country,
        avg_opp_losses_by_opp_is_home_country_diff,
        avg_opp_win_pct_by_opp_is_home_country,
        avg_opp_win_pct_by_opp_is_home_country_diff,
        avg_opp_lose_pct_by_opp_is_home_country,
        avg_opp_lose_pct_by_opp_is_home_country_diff,
        avg_opp_wins_by_is_home_country_and_opp_is_home_country,
        avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff,
        avg_opp_losses_by_is_home_country_and_opp_is_home_country,
        avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff,
        avg_opp_win_pct_by_is_home_country_and_opp_is_home_country,
        avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff,
        avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country,
        avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff,
        avg_opp_wins_by_is_title_bout,
        avg_opp_wins_by_is_title_bout_diff,
        avg_opp_losses_by_is_title_bout,
        avg_opp_losses_by_is_title_bout_diff,
        avg_opp_win_pct_by_is_title_bout,
        avg_opp_win_pct_by_is_title_bout_diff,
        avg_opp_lose_pct_by_is_title_bout,
        avg_opp_lose_pct_by_is_title_bout_diff,
        avg_opp_wins_by_weight_class,
        avg_opp_wins_by_weight_class_diff,
        avg_opp_losses_by_weight_class,
        avg_opp_losses_by_weight_class_diff,
        avg_opp_win_pct_by_weight_class,
        avg_opp_win_pct_by_weight_class_diff,
        avg_opp_lose_pct_by_weight_class,
        avg_opp_lose_pct_by_weight_class_diff
    FROM cte8 t1
),
cte10 AS (
    SELECT t1.*
    FROM ufcstats_fighter_histories AS t1
        LEFT JOIN ufcstats_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN ufcstats_events AS t3 ON t2.event_id = t3.id
    WHERE t3.is_ufc_event = 1
),
cte11 AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        bout_id,
        opponent_id
    FROM cte10 t1
),
cte12 AS (
    SELECT t1.fighter_id,
        t1.bout_id,
        t2.wins_by_country,
        t2.losses_by_country,
        t2.win_pct_by_country,
        t2.lose_pct_by_country,
        t2.wins_against_opp_nationality,
        t2.losses_against_opp_nationality,
        t2.win_pct_against_opp_nationality,
        t2.lose_pct_against_opp_nationality,
        t2.wins_by_is_home_country,
        t2.losses_by_is_home_country,
        t2.win_pct_by_is_home_country,
        t2.lose_pct_by_is_home_country,
        t2.wins_by_opp_is_home_country,
        t2.losses_by_opp_is_home_country,
        t2.win_pct_by_opp_is_home_country,
        t2.lose_pct_by_opp_is_home_country,
        t2.wins_by_is_home_country_and_opp_is_home_country,
        t2.losses_by_is_home_country_and_opp_is_home_country,
        t2.win_pct_by_is_home_country_and_opp_is_home_country,
        t2.lose_pct_by_is_home_country_and_opp_is_home_country,
        t2.wins_by_is_title_bout,
        t2.losses_by_is_title_bout,
        t2.win_pct_by_is_title_bout,
        t2.lose_pct_by_is_title_bout,
        t2.wins_by_weight_class,
        t2.losses_by_weight_class,
        t2.win_pct_by_weight_class,
        t2.lose_pct_by_weight_class,
        t2.avg_opp_wins_by_country,
        t2.avg_opp_wins_by_country_diff,
        t2.avg_opp_losses_by_country,
        t2.avg_opp_losses_by_country_diff,
        t2.avg_opp_win_pct_by_country,
        t2.avg_opp_win_pct_by_country_diff,
        t2.avg_opp_lose_pct_by_country,
        t2.avg_opp_lose_pct_by_country_diff,
        t2.avg_opp_wins_against_opp_nationality,
        t2.avg_opp_wins_against_opp_nationality_diff,
        t2.avg_opp_losses_against_opp_nationality,
        t2.avg_opp_losses_against_opp_nationality_diff,
        t2.avg_opp_win_pct_against_opp_nationality,
        t2.avg_opp_win_pct_against_opp_nationality_diff,
        t2.avg_opp_lose_pct_against_opp_nationality,
        t2.avg_opp_lose_pct_against_opp_nationality_diff,
        t2.avg_opp_wins_by_is_home_country,
        t2.avg_opp_wins_by_is_home_country_diff,
        t2.avg_opp_losses_by_is_home_country,
        t2.avg_opp_losses_by_is_home_country_diff,
        t2.avg_opp_win_pct_by_is_home_country,
        t2.avg_opp_win_pct_by_is_home_country_diff,
        t2.avg_opp_lose_pct_by_is_home_country,
        t2.avg_opp_lose_pct_by_is_home_country_diff,
        t2.avg_opp_wins_by_opp_is_home_country,
        t2.avg_opp_wins_by_opp_is_home_country_diff,
        t2.avg_opp_losses_by_opp_is_home_country,
        t2.avg_opp_losses_by_opp_is_home_country_diff,
        t2.avg_opp_win_pct_by_opp_is_home_country,
        t2.avg_opp_win_pct_by_opp_is_home_country_diff,
        t2.avg_opp_lose_pct_by_opp_is_home_country,
        t2.avg_opp_lose_pct_by_opp_is_home_country_diff,
        t2.avg_opp_wins_by_is_home_country_and_opp_is_home_country,
        t2.avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff,
        t2.avg_opp_losses_by_is_home_country_and_opp_is_home_country,
        t2.avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff,
        t2.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country,
        t2.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff,
        t2.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country,
        t2.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff,
        t2.avg_opp_wins_by_is_title_bout,
        t2.avg_opp_wins_by_is_title_bout_diff,
        t2.avg_opp_losses_by_is_title_bout,
        t2.avg_opp_losses_by_is_title_bout_diff,
        t2.avg_opp_win_pct_by_is_title_bout,
        t2.avg_opp_win_pct_by_is_title_bout_diff,
        t2.avg_opp_lose_pct_by_is_title_bout,
        t2.avg_opp_lose_pct_by_is_title_bout_diff,
        t2.avg_opp_wins_by_weight_class,
        t2.avg_opp_wins_by_weight_class_diff,
        t2.avg_opp_losses_by_weight_class,
        t2.avg_opp_losses_by_weight_class_diff,
        t2.avg_opp_win_pct_by_weight_class,
        t2.avg_opp_win_pct_by_weight_class_diff,
        t2.avg_opp_lose_pct_by_weight_class,
        t2.avg_opp_lose_pct_by_weight_class_diff
    FROM cte11 t1
        INNER JOIN cte9 t2 ON t1.fighter_id = t2.fighter_id
        AND t1.opponent_id = t2.opponent_id
        AND t1.ufc_order = t2.ufc_order
)
SELECT id,
    t2.wins_by_country - t3.wins_by_country AS wins_by_country_diff,
    1.0 * t2.wins_by_country / t3.wins_by_country AS wins_by_country_ratio,
    t2.losses_by_country - t3.losses_by_country AS losses_by_country_diff,
    1.0 * t2.losses_by_country / t3.losses_by_country AS losses_by_country_ratio,
    t2.win_pct_by_country - t3.win_pct_by_country AS win_pct_by_country_diff,
    1.0 * t2.win_pct_by_country / t3.win_pct_by_country AS win_pct_by_country_ratio,
    t2.lose_pct_by_country - t3.lose_pct_by_country AS lose_pct_by_country_diff,
    1.0 * t2.lose_pct_by_country / t3.lose_pct_by_country AS lose_pct_by_country_ratio,
    t2.wins_against_opp_nationality - t3.wins_against_opp_nationality AS wins_against_opp_nationality_diff,
    1.0 * t2.wins_against_opp_nationality / t3.wins_against_opp_nationality AS wins_against_opp_nationality_ratio,
    t2.losses_against_opp_nationality - t3.losses_against_opp_nationality AS losses_against_opp_nationality_diff,
    1.0 * t2.losses_against_opp_nationality / t3.losses_against_opp_nationality AS losses_against_opp_nationality_ratio,
    t2.win_pct_against_opp_nationality - t3.win_pct_against_opp_nationality AS win_pct_against_opp_nationality_diff,
    1.0 * t2.win_pct_against_opp_nationality / t3.win_pct_against_opp_nationality AS win_pct_against_opp_nationality_ratio,
    t2.lose_pct_against_opp_nationality - t3.lose_pct_against_opp_nationality AS lose_pct_against_opp_nationality_diff,
    1.0 * t2.lose_pct_against_opp_nationality / t3.lose_pct_against_opp_nationality AS lose_pct_against_opp_nationality_ratio,
    t2.wins_by_is_home_country - t3.wins_by_is_home_country AS wins_by_is_home_country_diff,
    1.0 * t2.wins_by_is_home_country / t3.wins_by_is_home_country AS wins_by_is_home_country_ratio,
    t2.losses_by_is_home_country - t3.losses_by_is_home_country AS losses_by_is_home_country_diff,
    1.0 * t2.losses_by_is_home_country / t3.losses_by_is_home_country AS losses_by_is_home_country_ratio,
    t2.win_pct_by_is_home_country - t3.win_pct_by_is_home_country AS win_pct_by_is_home_country_diff,
    1.0 * t2.win_pct_by_is_home_country / t3.win_pct_by_is_home_country AS win_pct_by_is_home_country_ratio,
    t2.lose_pct_by_is_home_country - t3.lose_pct_by_is_home_country AS lose_pct_by_is_home_country_diff,
    1.0 * t2.lose_pct_by_is_home_country / t3.lose_pct_by_is_home_country AS lose_pct_by_is_home_country_ratio,
    t2.wins_by_opp_is_home_country - t3.wins_by_opp_is_home_country AS wins_by_opp_is_home_country_diff,
    1.0 * t2.wins_by_opp_is_home_country / t3.wins_by_opp_is_home_country AS wins_by_opp_is_home_country_ratio,
    t2.losses_by_opp_is_home_country - t3.losses_by_opp_is_home_country AS losses_by_opp_is_home_country_diff,
    1.0 * t2.losses_by_opp_is_home_country / t3.losses_by_opp_is_home_country AS losses_by_opp_is_home_country_ratio,
    t2.win_pct_by_opp_is_home_country - t3.win_pct_by_opp_is_home_country AS win_pct_by_opp_is_home_country_diff,
    1.0 * t2.win_pct_by_opp_is_home_country / t3.win_pct_by_opp_is_home_country AS win_pct_by_opp_is_home_country_ratio,
    t2.lose_pct_by_opp_is_home_country - t3.lose_pct_by_opp_is_home_country AS lose_pct_by_opp_is_home_country_diff,
    1.0 * t2.lose_pct_by_opp_is_home_country / t3.lose_pct_by_opp_is_home_country AS lose_pct_by_opp_is_home_country_ratio,
    t2.wins_by_is_home_country_and_opp_is_home_country - t3.wins_by_is_home_country_and_opp_is_home_country AS wins_by_is_home_country_and_opp_is_home_country_diff,
    1.0 * t2.wins_by_is_home_country_and_opp_is_home_country / t3.wins_by_is_home_country_and_opp_is_home_country AS wins_by_is_home_country_and_opp_is_home_country_ratio,
    t2.losses_by_is_home_country_and_opp_is_home_country - t3.losses_by_is_home_country_and_opp_is_home_country AS losses_by_is_home_country_and_opp_is_home_country_diff,
    1.0 * t2.losses_by_is_home_country_and_opp_is_home_country / t3.losses_by_is_home_country_and_opp_is_home_country AS losses_by_is_home_country_and_opp_is_home_country_ratio,
    t2.win_pct_by_is_home_country_and_opp_is_home_country - t3.win_pct_by_is_home_country_and_opp_is_home_country AS win_pct_by_is_home_country_and_opp_is_home_country_diff,
    1.0 * t2.win_pct_by_is_home_country_and_opp_is_home_country / t3.win_pct_by_is_home_country_and_opp_is_home_country AS win_pct_by_is_home_country_and_opp_is_home_country_ratio,
    t2.lose_pct_by_is_home_country_and_opp_is_home_country - t3.lose_pct_by_is_home_country_and_opp_is_home_country AS lose_pct_by_is_home_country_and_opp_is_home_country_diff,
    1.0 * t2.lose_pct_by_is_home_country_and_opp_is_home_country / t3.lose_pct_by_is_home_country_and_opp_is_home_country AS lose_pct_by_is_home_country_and_opp_is_home_country_ratio,
    t2.wins_by_is_title_bout - t3.wins_by_is_title_bout AS wins_by_is_title_bout_diff,
    1.0 * t2.wins_by_is_title_bout / t3.wins_by_is_title_bout AS wins_by_is_title_bout_ratio,
    t2.losses_by_is_title_bout - t3.losses_by_is_title_bout AS losses_by_is_title_bout_diff,
    1.0 * t2.losses_by_is_title_bout / t3.losses_by_is_title_bout AS losses_by_is_title_bout_ratio,
    t2.win_pct_by_is_title_bout - t3.win_pct_by_is_title_bout AS win_pct_by_is_title_bout_diff,
    1.0 * t2.win_pct_by_is_title_bout / t3.win_pct_by_is_title_bout AS win_pct_by_is_title_bout_ratio,
    t2.lose_pct_by_is_title_bout - t3.lose_pct_by_is_title_bout AS lose_pct_by_is_title_bout_diff,
    1.0 * t2.lose_pct_by_is_title_bout / t3.lose_pct_by_is_title_bout AS lose_pct_by_is_title_bout_ratio,
    t2.wins_by_weight_class - t3.wins_by_weight_class AS wins_by_weight_class_diff,
    1.0 * t2.wins_by_weight_class / t3.wins_by_weight_class AS wins_by_weight_class_ratio,
    t2.losses_by_weight_class - t3.losses_by_weight_class AS losses_by_weight_class_diff,
    1.0 * t2.losses_by_weight_class / t3.losses_by_weight_class AS losses_by_weight_class_ratio,
    t2.win_pct_by_weight_class - t3.win_pct_by_weight_class AS win_pct_by_weight_class_diff,
    1.0 * t2.win_pct_by_weight_class / t3.win_pct_by_weight_class AS win_pct_by_weight_class_ratio,
    t2.lose_pct_by_weight_class - t3.lose_pct_by_weight_class AS lose_pct_by_weight_class_diff,
    1.0 * t2.lose_pct_by_weight_class / t3.lose_pct_by_weight_class AS lose_pct_by_weight_class_ratio,
    t2.avg_opp_wins_by_country - t3.avg_opp_wins_by_country AS avg_opp_wins_by_country_diff,
    1.0 * t2.avg_opp_wins_by_country / t3.avg_opp_wins_by_country AS avg_opp_wins_by_country_ratio,
    t2.avg_opp_wins_by_country_diff - t3.avg_opp_wins_by_country_diff AS avg_opp_wins_by_country_diff_diff,
    1.0 * t2.avg_opp_wins_by_country_diff / t3.avg_opp_wins_by_country_diff AS avg_opp_wins_by_country_diff_ratio,
    t2.avg_opp_losses_by_country - t3.avg_opp_losses_by_country AS avg_opp_losses_by_country_diff,
    1.0 * t2.avg_opp_losses_by_country / t3.avg_opp_losses_by_country AS avg_opp_losses_by_country_ratio,
    t2.avg_opp_losses_by_country_diff - t3.avg_opp_losses_by_country_diff AS avg_opp_losses_by_country_diff_diff,
    1.0 * t2.avg_opp_losses_by_country_diff / t3.avg_opp_losses_by_country_diff AS avg_opp_losses_by_country_diff_ratio,
    t2.avg_opp_win_pct_by_country - t3.avg_opp_win_pct_by_country AS avg_opp_win_pct_by_country_diff,
    1.0 * t2.avg_opp_win_pct_by_country / t3.avg_opp_win_pct_by_country AS avg_opp_win_pct_by_country_ratio,
    t2.avg_opp_win_pct_by_country_diff - t3.avg_opp_win_pct_by_country_diff AS avg_opp_win_pct_by_country_diff_diff,
    1.0 * t2.avg_opp_win_pct_by_country_diff / t3.avg_opp_win_pct_by_country_diff AS avg_opp_win_pct_by_country_diff_ratio,
    t2.avg_opp_lose_pct_by_country - t3.avg_opp_lose_pct_by_country AS avg_opp_lose_pct_by_country_diff,
    1.0 * t2.avg_opp_lose_pct_by_country / t3.avg_opp_lose_pct_by_country AS avg_opp_lose_pct_by_country_ratio,
    t2.avg_opp_lose_pct_by_country_diff - t3.avg_opp_lose_pct_by_country_diff AS avg_opp_lose_pct_by_country_diff_diff,
    1.0 * t2.avg_opp_lose_pct_by_country_diff / t3.avg_opp_lose_pct_by_country_diff AS avg_opp_lose_pct_by_country_diff_ratio,
    t2.avg_opp_wins_against_opp_nationality - t3.avg_opp_wins_against_opp_nationality AS avg_opp_wins_against_opp_nationality_diff,
    1.0 * t2.avg_opp_wins_against_opp_nationality / t3.avg_opp_wins_against_opp_nationality AS avg_opp_wins_against_opp_nationality_ratio,
    t2.avg_opp_wins_against_opp_nationality_diff - t3.avg_opp_wins_against_opp_nationality_diff AS avg_opp_wins_against_opp_nationality_diff_diff,
    1.0 * t2.avg_opp_wins_against_opp_nationality_diff / t3.avg_opp_wins_against_opp_nationality_diff AS avg_opp_wins_against_opp_nationality_diff_ratio,
    t2.avg_opp_losses_against_opp_nationality - t3.avg_opp_losses_against_opp_nationality AS avg_opp_losses_against_opp_nationality_diff,
    1.0 * t2.avg_opp_losses_against_opp_nationality / t3.avg_opp_losses_against_opp_nationality AS avg_opp_losses_against_opp_nationality_ratio,
    t2.avg_opp_losses_against_opp_nationality_diff - t3.avg_opp_losses_against_opp_nationality_diff AS avg_opp_losses_against_opp_nationality_diff_diff,
    1.0 * t2.avg_opp_losses_against_opp_nationality_diff / t3.avg_opp_losses_against_opp_nationality_diff AS avg_opp_losses_against_opp_nationality_diff_ratio,
    t2.avg_opp_win_pct_against_opp_nationality - t3.avg_opp_win_pct_against_opp_nationality AS avg_opp_win_pct_against_opp_nationality_diff,
    1.0 * t2.avg_opp_win_pct_against_opp_nationality / t3.avg_opp_win_pct_against_opp_nationality AS avg_opp_win_pct_against_opp_nationality_ratio,
    t2.avg_opp_win_pct_against_opp_nationality_diff - t3.avg_opp_win_pct_against_opp_nationality_diff AS avg_opp_win_pct_against_opp_nationality_diff_diff,
    1.0 * t2.avg_opp_win_pct_against_opp_nationality_diff / t3.avg_opp_win_pct_against_opp_nationality_diff AS avg_opp_win_pct_against_opp_nationality_diff_ratio,
    t2.avg_opp_lose_pct_against_opp_nationality - t3.avg_opp_lose_pct_against_opp_nationality AS avg_opp_lose_pct_against_opp_nationality_diff,
    1.0 * t2.avg_opp_lose_pct_against_opp_nationality / t3.avg_opp_lose_pct_against_opp_nationality AS avg_opp_lose_pct_against_opp_nationality_ratio,
    t2.avg_opp_lose_pct_against_opp_nationality_diff - t3.avg_opp_lose_pct_against_opp_nationality_diff AS avg_opp_lose_pct_against_opp_nationality_diff_diff,
    1.0 * t2.avg_opp_lose_pct_against_opp_nationality_diff / t3.avg_opp_lose_pct_against_opp_nationality_diff AS avg_opp_lose_pct_against_opp_nationality_diff_ratio,
    t2.avg_opp_wins_by_is_home_country - t3.avg_opp_wins_by_is_home_country AS avg_opp_wins_by_is_home_country_diff,
    1.0 * t2.avg_opp_wins_by_is_home_country / t3.avg_opp_wins_by_is_home_country AS avg_opp_wins_by_is_home_country_ratio,
    t2.avg_opp_wins_by_is_home_country_diff - t3.avg_opp_wins_by_is_home_country_diff AS avg_opp_wins_by_is_home_country_diff_diff,
    1.0 * t2.avg_opp_wins_by_is_home_country_diff / t3.avg_opp_wins_by_is_home_country_diff AS avg_opp_wins_by_is_home_country_diff_ratio,
    t2.avg_opp_losses_by_is_home_country - t3.avg_opp_losses_by_is_home_country AS avg_opp_losses_by_is_home_country_diff,
    1.0 * t2.avg_opp_losses_by_is_home_country / t3.avg_opp_losses_by_is_home_country AS avg_opp_losses_by_is_home_country_ratio,
    t2.avg_opp_losses_by_is_home_country_diff - t3.avg_opp_losses_by_is_home_country_diff AS avg_opp_losses_by_is_home_country_diff_diff,
    1.0 * t2.avg_opp_losses_by_is_home_country_diff / t3.avg_opp_losses_by_is_home_country_diff AS avg_opp_losses_by_is_home_country_diff_ratio,
    t2.avg_opp_win_pct_by_is_home_country - t3.avg_opp_win_pct_by_is_home_country AS avg_opp_win_pct_by_is_home_country_diff,
    1.0 * t2.avg_opp_win_pct_by_is_home_country / t3.avg_opp_win_pct_by_is_home_country AS avg_opp_win_pct_by_is_home_country_ratio,
    t2.avg_opp_win_pct_by_is_home_country_diff - t3.avg_opp_win_pct_by_is_home_country_diff AS avg_opp_win_pct_by_is_home_country_diff_diff,
    1.0 * t2.avg_opp_win_pct_by_is_home_country_diff / t3.avg_opp_win_pct_by_is_home_country_diff AS avg_opp_win_pct_by_is_home_country_diff_ratio,
    t2.avg_opp_lose_pct_by_is_home_country - t3.avg_opp_lose_pct_by_is_home_country AS avg_opp_lose_pct_by_is_home_country_diff,
    1.0 * t2.avg_opp_lose_pct_by_is_home_country / t3.avg_opp_lose_pct_by_is_home_country AS avg_opp_lose_pct_by_is_home_country_ratio,
    t2.avg_opp_lose_pct_by_is_home_country_diff - t3.avg_opp_lose_pct_by_is_home_country_diff AS avg_opp_lose_pct_by_is_home_country_diff_diff,
    1.0 * t2.avg_opp_lose_pct_by_is_home_country_diff / t3.avg_opp_lose_pct_by_is_home_country_diff AS avg_opp_lose_pct_by_is_home_country_diff_ratio,
    t2.avg_opp_wins_by_opp_is_home_country - t3.avg_opp_wins_by_opp_is_home_country AS avg_opp_wins_by_opp_is_home_country_diff,
    1.0 * t2.avg_opp_wins_by_opp_is_home_country / t3.avg_opp_wins_by_opp_is_home_country AS avg_opp_wins_by_opp_is_home_country_ratio,
    t2.avg_opp_wins_by_opp_is_home_country_diff - t3.avg_opp_wins_by_opp_is_home_country_diff AS avg_opp_wins_by_opp_is_home_country_diff_diff,
    1.0 * t2.avg_opp_wins_by_opp_is_home_country_diff / t3.avg_opp_wins_by_opp_is_home_country_diff AS avg_opp_wins_by_opp_is_home_country_diff_ratio,
    t2.avg_opp_losses_by_opp_is_home_country - t3.avg_opp_losses_by_opp_is_home_country AS avg_opp_losses_by_opp_is_home_country_diff,
    1.0 * t2.avg_opp_losses_by_opp_is_home_country / t3.avg_opp_losses_by_opp_is_home_country AS avg_opp_losses_by_opp_is_home_country_ratio,
    t2.avg_opp_losses_by_opp_is_home_country_diff - t3.avg_opp_losses_by_opp_is_home_country_diff AS avg_opp_losses_by_opp_is_home_country_diff_diff,
    1.0 * t2.avg_opp_losses_by_opp_is_home_country_diff / t3.avg_opp_losses_by_opp_is_home_country_diff AS avg_opp_losses_by_opp_is_home_country_diff_ratio,
    t2.avg_opp_win_pct_by_opp_is_home_country - t3.avg_opp_win_pct_by_opp_is_home_country AS avg_opp_win_pct_by_opp_is_home_country_diff,
    1.0 * t2.avg_opp_win_pct_by_opp_is_home_country / t3.avg_opp_win_pct_by_opp_is_home_country AS avg_opp_win_pct_by_opp_is_home_country_ratio,
    t2.avg_opp_win_pct_by_opp_is_home_country_diff - t3.avg_opp_win_pct_by_opp_is_home_country_diff AS avg_opp_win_pct_by_opp_is_home_country_diff_diff,
    1.0 * t2.avg_opp_win_pct_by_opp_is_home_country_diff / t3.avg_opp_win_pct_by_opp_is_home_country_diff AS avg_opp_win_pct_by_opp_is_home_country_diff_ratio,
    t2.avg_opp_lose_pct_by_opp_is_home_country - t3.avg_opp_lose_pct_by_opp_is_home_country AS avg_opp_lose_pct_by_opp_is_home_country_diff,
    1.0 * t2.avg_opp_lose_pct_by_opp_is_home_country / t3.avg_opp_lose_pct_by_opp_is_home_country AS avg_opp_lose_pct_by_opp_is_home_country_ratio,
    t2.avg_opp_lose_pct_by_opp_is_home_country_diff - t3.avg_opp_lose_pct_by_opp_is_home_country_diff AS avg_opp_lose_pct_by_opp_is_home_country_diff_diff,
    1.0 * t2.avg_opp_lose_pct_by_opp_is_home_country_diff / t3.avg_opp_lose_pct_by_opp_is_home_country_diff AS avg_opp_lose_pct_by_opp_is_home_country_diff_ratio,
    t2.avg_opp_wins_by_is_home_country_and_opp_is_home_country - t3.avg_opp_wins_by_is_home_country_and_opp_is_home_country AS avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff,
    1.0 * t2.avg_opp_wins_by_is_home_country_and_opp_is_home_country / t3.avg_opp_wins_by_is_home_country_and_opp_is_home_country AS avg_opp_wins_by_is_home_country_and_opp_is_home_country_ratio,
    t2.avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff - t3.avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff AS avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff_diff,
    1.0 * t2.avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff / t3.avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff AS avg_opp_wins_by_is_home_country_and_opp_is_home_country_diff_ratio,
    t2.avg_opp_losses_by_is_home_country_and_opp_is_home_country - t3.avg_opp_losses_by_is_home_country_and_opp_is_home_country AS avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff,
    1.0 * t2.avg_opp_losses_by_is_home_country_and_opp_is_home_country / t3.avg_opp_losses_by_is_home_country_and_opp_is_home_country AS avg_opp_losses_by_is_home_country_and_opp_is_home_country_ratio,
    t2.avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff - t3.avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff AS avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff_diff,
    1.0 * t2.avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff / t3.avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff AS avg_opp_losses_by_is_home_country_and_opp_is_home_country_diff_ratio,
    t2.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country - t3.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country AS avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff,
    1.0 * t2.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country / t3.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country AS avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_ratio,
    t2.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff - t3.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff AS avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff_diff,
    1.0 * t2.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff / t3.avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff AS avg_opp_win_pct_by_is_home_country_and_opp_is_home_country_diff_ratio,
    t2.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country - t3.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country AS avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff,
    1.0 * t2.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country / t3.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country AS avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_ratio,
    t2.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff - t3.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff AS avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff_diff,
    1.0 * t2.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff / t3.avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff AS avg_opp_lose_pct_by_is_home_country_and_opp_is_home_country_diff_ratio,
    t2.avg_opp_wins_by_is_title_bout - t3.avg_opp_wins_by_is_title_bout AS avg_opp_wins_by_is_title_bout_diff,
    1.0 * t2.avg_opp_wins_by_is_title_bout / t3.avg_opp_wins_by_is_title_bout AS avg_opp_wins_by_is_title_bout_ratio,
    t2.avg_opp_wins_by_is_title_bout_diff - t3.avg_opp_wins_by_is_title_bout_diff AS avg_opp_wins_by_is_title_bout_diff_diff,
    1.0 * t2.avg_opp_wins_by_is_title_bout_diff / t3.avg_opp_wins_by_is_title_bout_diff AS avg_opp_wins_by_is_title_bout_diff_ratio,
    t2.avg_opp_losses_by_is_title_bout - t3.avg_opp_losses_by_is_title_bout AS avg_opp_losses_by_is_title_bout_diff,
    1.0 * t2.avg_opp_losses_by_is_title_bout / t3.avg_opp_losses_by_is_title_bout AS avg_opp_losses_by_is_title_bout_ratio,
    t2.avg_opp_losses_by_is_title_bout_diff - t3.avg_opp_losses_by_is_title_bout_diff AS avg_opp_losses_by_is_title_bout_diff_diff,
    1.0 * t2.avg_opp_losses_by_is_title_bout_diff / t3.avg_opp_losses_by_is_title_bout_diff AS avg_opp_losses_by_is_title_bout_diff_ratio,
    t2.avg_opp_win_pct_by_is_title_bout - t3.avg_opp_win_pct_by_is_title_bout AS avg_opp_win_pct_by_is_title_bout_diff,
    1.0 * t2.avg_opp_win_pct_by_is_title_bout / t3.avg_opp_win_pct_by_is_title_bout AS avg_opp_win_pct_by_is_title_bout_ratio,
    t2.avg_opp_win_pct_by_is_title_bout_diff - t3.avg_opp_win_pct_by_is_title_bout_diff AS avg_opp_win_pct_by_is_title_bout_diff_diff,
    1.0 * t2.avg_opp_win_pct_by_is_title_bout_diff / t3.avg_opp_win_pct_by_is_title_bout_diff AS avg_opp_win_pct_by_is_title_bout_diff_ratio,
    t2.avg_opp_lose_pct_by_is_title_bout - t3.avg_opp_lose_pct_by_is_title_bout AS avg_opp_lose_pct_by_is_title_bout_diff,
    1.0 * t2.avg_opp_lose_pct_by_is_title_bout / t3.avg_opp_lose_pct_by_is_title_bout AS avg_opp_lose_pct_by_is_title_bout_ratio,
    t2.avg_opp_lose_pct_by_is_title_bout_diff - t3.avg_opp_lose_pct_by_is_title_bout_diff AS avg_opp_lose_pct_by_is_title_bout_diff_diff,
    1.0 * t2.avg_opp_lose_pct_by_is_title_bout_diff / t3.avg_opp_lose_pct_by_is_title_bout_diff AS avg_opp_lose_pct_by_is_title_bout_diff_ratio,
    t2.avg_opp_wins_by_weight_class - t3.avg_opp_wins_by_weight_class AS avg_opp_wins_by_weight_class_diff,
    1.0 * t2.avg_opp_wins_by_weight_class / t3.avg_opp_wins_by_weight_class AS avg_opp_wins_by_weight_class_ratio,
    t2.avg_opp_wins_by_weight_class_diff - t3.avg_opp_wins_by_weight_class_diff AS avg_opp_wins_by_weight_class_diff_diff,
    1.0 * t2.avg_opp_wins_by_weight_class_diff / t3.avg_opp_wins_by_weight_class_diff AS avg_opp_wins_by_weight_class_diff_ratio,
    t2.avg_opp_losses_by_weight_class - t3.avg_opp_losses_by_weight_class AS avg_opp_losses_by_weight_class_diff,
    1.0 * t2.avg_opp_losses_by_weight_class / t3.avg_opp_losses_by_weight_class AS avg_opp_losses_by_weight_class_ratio,
    t2.avg_opp_losses_by_weight_class_diff - t3.avg_opp_losses_by_weight_class_diff AS avg_opp_losses_by_weight_class_diff_diff,
    1.0 * t2.avg_opp_losses_by_weight_class_diff / t3.avg_opp_losses_by_weight_class_diff AS avg_opp_losses_by_weight_class_diff_ratio,
    t2.avg_opp_win_pct_by_weight_class - t3.avg_opp_win_pct_by_weight_class AS avg_opp_win_pct_by_weight_class_diff,
    1.0 * t2.avg_opp_win_pct_by_weight_class / t3.avg_opp_win_pct_by_weight_class AS avg_opp_win_pct_by_weight_class_ratio,
    t2.avg_opp_win_pct_by_weight_class_diff - t3.avg_opp_win_pct_by_weight_class_diff AS avg_opp_win_pct_by_weight_class_diff_diff,
    1.0 * t2.avg_opp_win_pct_by_weight_class_diff / t3.avg_opp_win_pct_by_weight_class_diff AS avg_opp_win_pct_by_weight_class_diff_ratio,
    t2.avg_opp_lose_pct_by_weight_class - t3.avg_opp_lose_pct_by_weight_class AS avg_opp_lose_pct_by_weight_class_diff,
    1.0 * t2.avg_opp_lose_pct_by_weight_class / t3.avg_opp_lose_pct_by_weight_class AS avg_opp_lose_pct_by_weight_class_ratio,
    t2.avg_opp_lose_pct_by_weight_class_diff - t3.avg_opp_lose_pct_by_weight_class_diff AS avg_opp_lose_pct_by_weight_class_diff_diff,
    1.0 * t2.avg_opp_lose_pct_by_weight_class_diff / t3.avg_opp_lose_pct_by_weight_class_diff AS avg_opp_lose_pct_by_weight_class_diff_ratio,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte12 AS t2 ON t1.id = t2.bout_id
    AND t1.red_fighter_id = t2.fighter_id
    LEFT JOIN cte12 AS t3 ON t1.id = t3.bout_id
    AND t1.blue_fighter_id = t3.fighter_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );