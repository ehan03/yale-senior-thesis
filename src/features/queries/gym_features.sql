WITH cte1 AS (
    SELECT *,
        ROW_NUMBER() OVER (
            ORDER BY t1.rowid
        ) AS rn
    FROM misc.gym_elo_ratings AS t1
),
cte2 AS (
    SELECT red_gym_id AS gym_id,
        rn,
        bout_id,
        event_id,
        blue_gym_id AS opp_gym_id,
        CASE
            WHEN red_gym_id = blue_gym_id THEN NULL
            WHEN red_outcome = 'W' THEN 1
            ELSE 0
        END AS win_flag,
        red_gym_elo AS gym_elo,
        blue_gym_elo AS opp_gym_elo
    FROM cte1
    WHERE red_gym_id IS NOT NULL
    UNION
    SELECT blue_gym_id AS gym_id,
        rn,
        bout_id,
        event_id,
        red_gym_id AS opp_gym_id,
        CASE
            WHEN red_gym_id = blue_gym_id THEN NULL
            WHEN red_outcome = 'L' THEN 1
            ELSE 0
        END AS win_flag,
        blue_gym_elo AS gym_elo,
        red_gym_elo AS opp_gym_elo
    FROM cte1
    WHERE blue_gym_id IS NOT NULL
),
cte3 AS (
    SELECT gym_id,
        ROW_NUMBER() OVER (
            PARTITION BY gym_id
            ORDER BY rn
        ) AS bout_order,
        bout_id,
        ROW_NUMBER() OVER (
            PARTITION BY gym_id,
            event_id
            ORDER BY rn
        ) AS bout_order_in_event,
        event_id,
        opp_gym_id,
        win_flag,
        gym_elo,
        opp_gym_elo
    FROM cte2
),
cte4 AS (
    SELECT gym_id,
        ROW_NUMBER() OVER (
            PARTITION BY gym_id
            ORDER BY bout_order
        ) AS event_order,
        event_id,
        gym_elo
    FROM cte3
    WHERE bout_order_in_event = 1
),
cte5 AS (
    SELECT gym_id,
        event_order,
        event_id,
        gym_elo,
        AVG(gym_elo) OVER (
            PARTITION BY gym_id
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_elo,
        gym_elo - LAG(gym_elo) OVER (
            PARTITION BY gym_id
            ORDER BY event_order
        ) AS gym_elo_change
    FROM cte4
),
event_level_feats AS (
    SELECT *,
        AVG(gym_elo_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_elo_change
    FROM cte5
),
cte6 AS (
    SELECT t1.gym_id,
        t1.bout_order,
        t1.bout_id,
        t1.bout_order_in_event,
        t2.event_order,
        t1.event_id,
        t1.opp_gym_id,
        t1.win_flag,
        t1.gym_elo,
        t2.gym_avg_elo,
        t2.gym_elo_change,
        t2.gym_avg_elo_change,
        t1.opp_gym_elo
    FROM cte3 AS t1
        LEFT JOIN event_level_feats AS t2 ON t1.gym_id = t2.gym_id
        AND t1.event_id = t2.event_id
),
cte7 AS (
    SELECT gym_id,
        bout_order,
        bout_id,
        bout_order_in_event,
        event_order,
        event_id,
        opp_gym_id,
        AVG(win_flag) OVER (
            PARTITION BY gym_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_win_rate,
        gym_elo,
        gym_avg_elo,
        gym_elo_change,
        gym_avg_elo_change,
        AVG(opp_gym_elo) OVER (
            PARTITION BY gym_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_opp_elo,
        AVG(gym_elo - opp_gym_elo) OVER (
            PARTITION BY gym_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_elo_diff
    FROM cte6
),
cte8 AS (
    SELECT t1.*,
        AVG(t2.gym_win_rate) OVER (
            PARTITION BY t1.gym_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_opp_win_rate,
        AVG(t1.gym_win_rate - t2.gym_win_rate) OVER (
            PARTITION BY t1.gym_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_win_rate_diff,
        AVG(t2.gym_avg_elo) OVER (
            PARTITION BY t1.gym_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_opp_avg_elo,
        AVG(t1.gym_avg_elo - t2.gym_avg_elo) OVER (
            PARTITION BY t1.gym_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_avg_elo_diff,
        AVG(t2.gym_elo_change) OVER (
            PARTITION BY t1.gym_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_opp_elo_change,
        AVG(t1.gym_elo_change - t2.gym_elo_change) OVER (
            PARTITION BY t1.gym_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_elo_change_diff,
        AVG(t2.gym_avg_elo_change) OVER (
            PARTITION BY t1.gym_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_opp_avg_elo_change,
        AVG(t1.gym_avg_elo_change - t2.gym_avg_elo_change) OVER (
            PARTITION BY t1.gym_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS gym_avg_avg_elo_change_diff
    FROM cte7 AS t1
        LEFT JOIN cte7 AS t2 ON t1.gym_id = t2.opp_gym_id
        AND t1.bout_id = t2.bout_id
        AND t1.opp_gym_id = t2.gym_id
),
gym_feats AS (
    SELECT gym_id,
        event_id,
        gym_win_rate,
        gym_elo,
        gym_avg_elo,
        gym_elo_change,
        gym_avg_elo_change,
        gym_avg_opp_win_rate,
        gym_avg_win_rate_diff,
        gym_avg_opp_elo,
        gym_avg_elo_diff,
        gym_avg_opp_avg_elo,
        gym_avg_avg_elo_diff,
        gym_avg_opp_elo_change,
        gym_avg_elo_change_diff,
        gym_avg_opp_avg_elo_change,
        gym_avg_avg_elo_change_diff
    FROM cte8
    WHERE bout_order_in_event = 1
),
cte9 AS (
    SELECT t1.bout_id,
        t1.event_id,
        t4.red_fighter_id,
        t4.blue_fighter_id,
        t1.red_gym_id,
        t2.gym_win_rate AS red_gym_win_rate,
        t1.red_gym_elo,
        t2.gym_avg_elo AS red_gym_avg_elo,
        t2.gym_elo_change AS red_gym_elo_change,
        t2.gym_avg_elo_change AS red_gym_avg_elo_change,
        t2.gym_avg_opp_win_rate AS red_gym_avg_opp_win_rate,
        t2.gym_avg_win_rate_diff AS red_gym_avg_win_rate_diff,
        t2.gym_avg_opp_elo AS red_gym_avg_opp_elo,
        t2.gym_avg_elo_diff AS red_gym_avg_elo_diff,
        t2.gym_avg_opp_avg_elo AS red_gym_avg_opp_avg_elo,
        t2.gym_avg_avg_elo_diff AS red_gym_avg_avg_elo_diff,
        t2.gym_avg_opp_elo_change AS red_gym_avg_opp_elo_change,
        t2.gym_avg_elo_change_diff AS red_gym_avg_elo_change_diff,
        t2.gym_avg_opp_avg_elo_change AS red_gym_avg_opp_avg_elo_change,
        t2.gym_avg_avg_elo_change_diff AS red_gym_avg_avg_elo_change_diff,
        t1.blue_gym_id,
        t3.gym_win_rate AS blue_gym_win_rate,
        t1.blue_gym_elo,
        t3.gym_avg_elo AS blue_gym_avg_elo,
        t3.gym_elo_change AS blue_gym_elo_change,
        t3.gym_avg_elo_change AS blue_gym_avg_elo_change,
        t3.gym_avg_opp_win_rate AS blue_gym_avg_opp_win_rate,
        t3.gym_avg_win_rate_diff AS blue_gym_avg_win_rate_diff,
        t3.gym_avg_opp_elo AS blue_gym_avg_opp_elo,
        t3.gym_avg_elo_diff AS blue_gym_avg_elo_diff,
        t3.gym_avg_opp_avg_elo AS blue_gym_avg_opp_avg_elo,
        t3.gym_avg_avg_elo_diff AS blue_gym_avg_avg_elo_diff,
        t3.gym_avg_opp_elo_change AS blue_gym_avg_opp_elo_change,
        t3.gym_avg_elo_change_diff AS blue_gym_avg_elo_change_diff,
        t3.gym_avg_opp_avg_elo_change AS blue_gym_avg_opp_avg_elo_change,
        t3.gym_avg_avg_elo_change_diff AS blue_gym_avg_avg_elo_change_diff
    FROM misc.gym_elo_ratings AS t1
        LEFT JOIN gym_feats AS t2 ON t1.red_gym_id = t2.gym_id
        AND t1.event_id = t2.event_id
        LEFT JOIN gym_feats AS t3 ON t1.blue_gym_id = t3.gym_id
        AND t1.event_id = t3.event_id
        INNER JOIN ufcstats_bouts AS t4 ON t1.bout_id = t4.id
),
cte10 AS (
    SELECT red_fighter_id AS fighter_id,
        bout_id,
        red_gym_id AS gym_id,
        red_gym_win_rate AS gym_win_rate,
        red_gym_elo AS gym_elo,
        red_gym_avg_elo AS gym_avg_elo,
        red_gym_elo_change AS gym_elo_change,
        red_gym_avg_elo_change AS gym_avg_elo_change,
        red_gym_avg_opp_win_rate AS gym_avg_opp_win_rate,
        red_gym_avg_win_rate_diff AS gym_avg_win_rate_diff,
        red_gym_avg_opp_elo AS gym_avg_opp_elo,
        red_gym_avg_elo_diff AS gym_avg_elo_diff,
        red_gym_avg_opp_avg_elo AS gym_avg_opp_avg_elo,
        red_gym_avg_avg_elo_diff AS gym_avg_avg_elo_diff,
        red_gym_avg_opp_elo_change AS gym_avg_opp_elo_change,
        red_gym_avg_elo_change_diff AS gym_avg_elo_change_diff,
        red_gym_avg_opp_avg_elo_change AS gym_avg_opp_avg_elo_change,
        red_gym_avg_avg_elo_change_diff AS gym_avg_avg_elo_change_diff
    FROM cte9
    UNION
    SELECT blue_fighter_id AS fighter_id,
        bout_id,
        blue_gym_id AS gym_id,
        blue_gym_win_rate AS gym_win_rate,
        blue_gym_elo AS gym_elo,
        blue_gym_avg_elo AS gym_avg_elo,
        blue_gym_elo_change AS gym_elo_change,
        blue_gym_avg_elo_change AS gym_avg_elo_change,
        blue_gym_avg_opp_win_rate AS gym_avg_opp_win_rate,
        blue_gym_avg_win_rate_diff AS gym_avg_win_rate_diff,
        blue_gym_avg_opp_elo AS gym_avg_opp_elo,
        blue_gym_avg_elo_diff AS gym_avg_elo_diff,
        blue_gym_avg_opp_avg_elo AS gym_avg_opp_avg_elo,
        blue_gym_avg_avg_elo_diff AS gym_avg_avg_elo_diff,
        blue_gym_avg_opp_elo_change AS gym_avg_opp_elo_change,
        blue_gym_avg_elo_change_diff AS gym_avg_elo_change_diff,
        blue_gym_avg_opp_avg_elo_change AS gym_avg_opp_avg_elo_change,
        blue_gym_avg_avg_elo_change_diff AS gym_avg_avg_elo_change_diff
    FROM cte9
),
cte11 AS (
    SELECT red_fighter_id AS fighter_id,
        id AS bout_id,
        CASE
            WHEN red_outcome = 'W' THEN 1
            ELSE 0
        END AS win_flag
    FROM ufcstats_bouts
    UNION
    SELECT blue_fighter_id AS fighter_id,
        id AS bout_id,
        CASE
            WHEN blue_outcome = 'W' THEN 1
            ELSE 0
        END AS win_flag
    FROM ufcstats_bouts
),
cte12 AS (
    SELECT t1.fighter_id,
        t1.bout_id,
        t1.'order',
        t1.opponent_id,
        t2.win_flag,
        t3.gym_id,
        t3.gym_win_rate,
        t3.gym_elo,
        t3.gym_avg_elo,
        t3.gym_elo_change,
        t3.gym_avg_elo_change,
        t3.gym_avg_opp_win_rate,
        t3.gym_avg_win_rate_diff,
        t3.gym_avg_opp_elo,
        t3.gym_avg_elo_diff,
        t3.gym_avg_opp_avg_elo,
        t3.gym_avg_avg_elo_diff,
        t3.gym_avg_opp_elo_change,
        t3.gym_avg_elo_change_diff,
        t3.gym_avg_opp_avg_elo_change,
        t3.gym_avg_avg_elo_change_diff
    FROM ufcstats_fighter_histories AS t1
        INNER JOIN cte11 AS t2 ON t1.fighter_id = t2.fighter_id
        AND t1.bout_id = t2.bout_id
        INNER JOIN cte10 AS t3 ON t1.fighter_id = t3.fighter_id
        AND t1.bout_id = t3.bout_id
),
cte13 AS (
    SELECT t1.*,
        AVG(t1.gym_win_rate) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_win_rate,
        AVG(t1.gym_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_elo,
        AVG(t1.gym_avg_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_elo,
        AVG(t1.gym_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_elo_change,
        AVG(t1.gym_avg_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_elo_change,
        AVG(t1.gym_avg_opp_win_rate) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_opp_win_rate,
        AVG(t1.gym_avg_win_rate_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_win_rate_diff,
        AVG(t1.gym_avg_opp_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_opp_elo,
        AVG(t1.gym_avg_elo_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_elo_diff,
        AVG(t1.gym_avg_opp_avg_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_opp_avg_elo,
        AVG(t1.gym_avg_avg_elo_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_avg_elo_diff,
        AVG(t1.gym_avg_opp_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_opp_elo_change,
        AVG(t1.gym_avg_elo_change_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_elo_change_diff,
        AVG(t1.gym_avg_opp_avg_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_opp_avg_elo_change,
        AVG(t1.gym_avg_avg_elo_change_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_gym_avg_avg_elo_change_diff,
        AVG(t1.win_flag) OVER (
            PARTITION BY t1.fighter_id,
            t1.gym_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_win_rate_within_gym,
        AVG(t1.win_flag) OVER (
            PARTITION BY t1.fighter_id,
            t2.gym_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_win_rate_against_gym
    FROM cte12 AS t1
        LEFT JOIN cte12 AS t2 ON t1.fighter_id = t2.opponent_id
        AND t1.bout_id = t2.bout_id
        AND t1.opponent_id = t2.fighter_id
),
cte14 AS (
    SELECT t1.*,
        AVG(t2.gym_win_rate) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_win_rate,
        AVG(t1.gym_win_rate - t2.gym_win_rate) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_win_rate_diff,
        AVG(t2.gym_avg_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_elo,
        AVG(t1.gym_avg_elo - t2.gym_avg_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_elo_diff,
        AVG(t2.gym_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_elo_change,
        AVG(t1.gym_elo_change - t2.gym_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_elo_change_diff,
        AVG(t2.gym_avg_opp_win_rate) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_opp_win_rate,
        AVG(
            t1.gym_avg_opp_win_rate - t2.gym_avg_opp_win_rate
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_win_rate_diff,
        AVG(t2.gym_avg_opp_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_opp_elo,
        AVG(t1.gym_avg_opp_elo - t2.gym_avg_opp_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_opp_elo_diff,
        AVG(t2.gym_avg_elo_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_elo_diff,
        AVG(t1.gym_avg_elo_diff - t2.gym_avg_elo_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_elo_diff_diff,
        AVG(t2.gym_avg_opp_avg_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_opp_avg_elo,
        AVG(t1.gym_avg_opp_avg_elo - t2.gym_avg_opp_avg_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_opp_avg_elo_diff,
        AVG(t2.gym_avg_avg_elo_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_avg_elo_diff,
        AVG(
            t1.gym_avg_avg_elo_diff - t2.gym_avg_avg_elo_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_avg_elo_diff_diff,
        AVG(t2.gym_avg_opp_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_opp_elo_change,
        AVG(
            t1.gym_avg_opp_elo_change - t2.gym_avg_opp_elo_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_opp_elo_change_diff,
        AVG(t2.gym_avg_elo_change_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_elo_change_diff,
        AVG(
            t1.gym_avg_elo_change_diff - t2.gym_avg_elo_change_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_elo_change_diff_diff,
        AVG(t2.gym_avg_opp_avg_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_opp_avg_elo_change,
        AVG(
            t1.gym_avg_opp_avg_elo_change - t2.gym_avg_opp_avg_elo_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_opp_avg_elo_change_diff,
        AVG(t2.gym_avg_avg_elo_change_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_avg_opp_gym_avg_avg_elo_change_diff,
        AVG(
            t1.gym_avg_avg_elo_change_diff - t2.gym_avg_avg_elo_change_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_gym_avg_avg_elo_change_diff_diff,
        AVG(t2.fighter_avg_gym_win_rate) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_win_rate,
        AVG(
            t1.fighter_avg_gym_win_rate - t2.fighter_avg_gym_win_rate
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_win_rate_diff,
        AVG(t2.fighter_avg_gym_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_elo,
        AVG(t1.fighter_avg_gym_elo - t2.fighter_avg_gym_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_elo_diff,
        AVG(t2.fighter_avg_gym_avg_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_elo,
        AVG(
            t1.fighter_avg_gym_avg_elo - t2.fighter_avg_gym_avg_elo
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_elo_diff,
        AVG(t2.fighter_avg_gym_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_elo_change,
        AVG(
            t1.fighter_avg_gym_elo_change - t2.fighter_avg_gym_elo_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_elo_change_diff,
        AVG(t2.fighter_avg_gym_avg_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_elo_change,
        AVG(
            t1.fighter_avg_gym_avg_elo_change - t2.fighter_avg_gym_avg_elo_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_elo_change_diff,
        AVG(t2.fighter_avg_gym_avg_opp_win_rate) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_opp_win_rate,
        AVG(
            t1.fighter_avg_gym_avg_opp_win_rate - t2.fighter_avg_gym_avg_opp_win_rate
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_opp_win_rate_diff,
        AVG(t2.fighter_avg_gym_avg_win_rate_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_win_rate_diff,
        AVG(
            t1.fighter_avg_gym_avg_win_rate_diff - t2.fighter_avg_gym_avg_win_rate_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_win_rate_diff_diff,
        AVG(t2.fighter_avg_gym_avg_opp_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_opp_elo,
        AVG(
            t1.fighter_avg_gym_avg_opp_elo - t2.fighter_avg_gym_avg_opp_elo
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_opp_elo_diff,
        AVG(t2.fighter_avg_gym_avg_elo_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_elo_diff,
        AVG(
            t1.fighter_avg_gym_avg_elo_diff - t2.fighter_avg_gym_avg_elo_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_elo_diff_diff,
        AVG(t2.fighter_avg_gym_avg_opp_avg_elo) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_opp_avg_elo,
        AVG(
            t1.fighter_avg_gym_avg_opp_avg_elo - t2.fighter_avg_gym_avg_opp_avg_elo
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_opp_avg_elo_diff,
        AVG(t2.fighter_avg_gym_avg_avg_elo_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_avg_elo_diff,
        AVG(
            t1.fighter_avg_gym_avg_avg_elo_diff - t2.fighter_avg_gym_avg_avg_elo_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_avg_elo_diff_diff,
        AVG(t2.fighter_avg_gym_avg_opp_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_opp_elo_change,
        AVG(
            t1.fighter_avg_gym_avg_opp_elo_change - t2.fighter_avg_gym_avg_opp_elo_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_opp_elo_change_diff,
        AVG(t2.fighter_avg_gym_avg_opp_avg_elo_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_opp_avg_elo_change,
        AVG(
            t1.fighter_avg_gym_avg_opp_avg_elo_change - t2.fighter_avg_gym_avg_opp_avg_elo_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_opp_avg_elo_change_diff,
        AVG(t2.fighter_avg_gym_avg_avg_elo_change_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_avg_gym_avg_avg_elo_change_diff,
        AVG(
            t1.fighter_avg_gym_avg_avg_elo_change_diff - t2.fighter_avg_gym_avg_avg_elo_change_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_avg_gym_avg_avg_elo_change_diff_diff,
        AVG(t2.fighter_win_rate_within_gym) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_win_rate_within_gym,
        AVG(
            t1.fighter_win_rate_within_gym - t2.fighter_win_rate_within_gym
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_win_rate_within_gym_diff,
        AVG(t2.fighter_win_rate_against_gym) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_fighter_win_rate_against_gym,
        AVG(
            t1.fighter_win_rate_against_gym - t2.fighter_win_rate_against_gym
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS fighter_opp_avg_fighter_win_rate_against_gym_diff
    FROM cte13 AS t1
        LEFT JOIN cte13 AS t2 ON t1.fighter_id = t2.opponent_id
        AND t1.bout_id = t2.bout_id
        AND t1.opponent_id = t2.fighter_id
)
SELECT id,
    t2.gym_win_rate - t3.gym_win_rate AS gym_win_rate_diff,
    t2.gym_elo - t3.gym_elo AS gym_elo_diff,
    t2.gym_avg_elo - t3.gym_avg_elo AS gym_avg_elo_diff,
    t2.gym_elo_change - t3.gym_elo_change AS gym_elo_change_diff,
    t2.gym_avg_elo_change - t3.gym_avg_elo_change AS gym_avg_elo_change_diff,
    t2.gym_avg_opp_win_rate - t3.gym_avg_opp_win_rate AS gym_avg_opp_win_rate_diff,
    t2.gym_avg_win_rate_diff - t3.gym_avg_win_rate_diff AS gym_avg_win_rate_diff_diff,
    t2.gym_avg_opp_elo - t3.gym_avg_opp_elo AS gym_avg_opp_elo_diff,
    t2.gym_avg_elo_diff - t3.gym_avg_elo_diff AS gym_avg_elo_diff_diff,
    t2.gym_avg_opp_avg_elo - t3.gym_avg_opp_avg_elo AS gym_avg_opp_avg_elo_diff,
    t2.gym_avg_avg_elo_diff - t3.gym_avg_avg_elo_diff AS gym_avg_avg_elo_diff_diff,
    t2.gym_avg_opp_elo_change - t3.gym_avg_opp_elo_change AS gym_avg_opp_elo_change_diff,
    t2.gym_avg_elo_change_diff - t3.gym_avg_elo_change_diff AS gym_avg_elo_change_diff_diff,
    t2.gym_avg_opp_avg_elo_change - t3.gym_avg_opp_avg_elo_change AS gym_avg_opp_avg_elo_change_diff,
    t2.gym_avg_avg_elo_change_diff - t3.gym_avg_avg_elo_change_diff AS gym_avg_avg_elo_change_diff_diff,
    t2.fighter_avg_gym_win_rate - t3.fighter_avg_gym_win_rate AS fighter_avg_gym_win_rate_diff,
    t2.fighter_avg_gym_elo - t3.fighter_avg_gym_elo AS fighter_avg_gym_elo_diff,
    t2.fighter_avg_gym_avg_elo - t3.fighter_avg_gym_avg_elo AS fighter_avg_gym_avg_elo_diff,
    t2.fighter_avg_gym_elo_change - t3.fighter_avg_gym_elo_change AS fighter_avg_gym_elo_change_diff,
    t2.fighter_avg_gym_avg_elo_change - t3.fighter_avg_gym_avg_elo_change AS fighter_avg_gym_avg_elo_change_diff,
    t2.fighter_avg_gym_avg_opp_win_rate - t3.fighter_avg_gym_avg_opp_win_rate AS fighter_avg_gym_avg_opp_win_rate_diff,
    t2.fighter_avg_gym_avg_win_rate_diff - t3.fighter_avg_gym_avg_win_rate_diff AS fighter_avg_gym_avg_win_rate_diff_diff,
    t2.fighter_avg_gym_avg_opp_elo - t3.fighter_avg_gym_avg_opp_elo AS fighter_avg_gym_avg_opp_elo_diff,
    t2.fighter_avg_gym_avg_elo_diff - t3.fighter_avg_gym_avg_elo_diff AS fighter_avg_gym_avg_elo_diff_diff,
    t2.fighter_avg_gym_avg_opp_avg_elo - t3.fighter_avg_gym_avg_opp_avg_elo AS fighter_avg_gym_avg_opp_avg_elo_diff,
    t2.fighter_avg_gym_avg_avg_elo_diff - t3.fighter_avg_gym_avg_avg_elo_diff AS fighter_avg_gym_avg_avg_elo_diff_diff,
    t2.fighter_avg_gym_avg_opp_elo_change - t3.fighter_avg_gym_avg_opp_elo_change AS fighter_avg_gym_avg_opp_elo_change_diff,
    t2.fighter_avg_gym_avg_elo_change_diff - t3.fighter_avg_gym_avg_elo_change_diff AS fighter_avg_gym_avg_elo_change_diff_diff,
    t2.fighter_avg_gym_avg_opp_avg_elo_change - t3.fighter_avg_gym_avg_opp_avg_elo_change AS fighter_avg_gym_avg_opp_avg_elo_change_diff,
    t2.fighter_avg_gym_avg_avg_elo_change_diff - t3.fighter_avg_gym_avg_avg_elo_change_diff AS fighter_avg_gym_avg_avg_elo_change_diff_diff,
    t2.fighter_win_rate_within_gym - t3.fighter_win_rate_within_gym AS fighter_win_rate_within_gym_diff,
    t2.fighter_win_rate_against_gym - t3.fighter_win_rate_against_gym AS fighter_win_rate_against_gym_diff,
    t2.fighter_avg_opp_gym_win_rate - t3.fighter_avg_opp_gym_win_rate AS fighter_avg_opp_gym_win_rate_diff,
    t2.fighter_opp_avg_gym_win_rate_diff - t3.fighter_opp_avg_gym_win_rate_diff AS fighter_opp_avg_gym_win_rate_diff_diff,
    t2.fighter_avg_opp_gym_avg_elo - t3.fighter_avg_opp_gym_avg_elo AS fighter_avg_opp_gym_avg_elo_diff,
    t2.fighter_opp_avg_gym_avg_elo_diff - t3.fighter_opp_avg_gym_avg_elo_diff AS fighter_opp_avg_gym_avg_elo_diff_diff,
    t2.fighter_avg_opp_gym_elo_change - t3.fighter_avg_opp_gym_elo_change AS fighter_avg_opp_gym_elo_change_diff,
    t2.fighter_opp_avg_gym_elo_change_diff - t3.fighter_opp_avg_gym_elo_change_diff AS fighter_opp_avg_gym_elo_change_diff_diff,
    t2.fighter_avg_opp_gym_avg_opp_win_rate - t3.fighter_avg_opp_gym_avg_opp_win_rate AS fighter_avg_opp_gym_avg_opp_win_rate_diff,
    t2.fighter_opp_avg_gym_avg_win_rate_diff - t3.fighter_opp_avg_gym_avg_win_rate_diff AS fighter_opp_avg_gym_avg_win_rate_diff_diff,
    t2.fighter_avg_opp_gym_avg_opp_elo - t3.fighter_avg_opp_gym_avg_opp_elo AS fighter_avg_opp_gym_avg_opp_elo_diff,
    t2.fighter_opp_avg_gym_avg_opp_elo_diff - t3.fighter_opp_avg_gym_avg_opp_elo_diff AS fighter_opp_avg_gym_avg_opp_elo_diff_diff,
    t2.fighter_avg_opp_gym_avg_elo_diff - t3.fighter_avg_opp_gym_avg_elo_diff AS fighter_avg_opp_gym_avg_elo_diff_diff,
    t2.fighter_opp_avg_gym_avg_elo_diff_diff - t3.fighter_opp_avg_gym_avg_elo_diff_diff AS fighter_opp_avg_gym_avg_elo_diff_diff_diff,
    t2.fighter_avg_opp_gym_avg_opp_avg_elo - t3.fighter_avg_opp_gym_avg_opp_avg_elo AS fighter_avg_opp_gym_avg_opp_avg_elo_diff,
    t2.fighter_opp_avg_gym_avg_opp_avg_elo_diff - t3.fighter_opp_avg_gym_avg_opp_avg_elo_diff AS fighter_opp_avg_gym_avg_opp_avg_elo_diff_diff,
    t2.fighter_avg_opp_gym_avg_avg_elo_diff - t3.fighter_avg_opp_gym_avg_avg_elo_diff AS fighter_avg_opp_gym_avg_avg_elo_diff_diff,
    t2.fighter_opp_avg_gym_avg_avg_elo_diff_diff - t3.fighter_opp_avg_gym_avg_avg_elo_diff_diff AS fighter_opp_avg_gym_avg_avg_elo_diff_diff_diff,
    t2.fighter_avg_opp_gym_avg_opp_elo_change - t3.fighter_avg_opp_gym_avg_opp_elo_change AS fighter_avg_opp_gym_avg_opp_elo_change_diff,
    t2.fighter_opp_avg_gym_avg_opp_elo_change_diff - t3.fighter_opp_avg_gym_avg_opp_elo_change_diff AS fighter_opp_avg_gym_avg_opp_elo_change_diff_diff,
    t2.fighter_avg_opp_gym_avg_elo_change_diff - t3.fighter_avg_opp_gym_avg_elo_change_diff AS fighter_avg_opp_gym_avg_elo_change_diff_diff,
    t2.fighter_opp_avg_gym_avg_elo_change_diff_diff - t3.fighter_opp_avg_gym_avg_elo_change_diff_diff AS fighter_opp_avg_gym_avg_elo_change_diff_diff_diff,
    t2.fighter_avg_opp_gym_avg_opp_avg_elo_change - t3.fighter_avg_opp_gym_avg_opp_avg_elo_change AS fighter_avg_opp_gym_avg_opp_avg_elo_change_diff,
    t2.fighter_opp_avg_gym_avg_opp_avg_elo_change_diff - t3.fighter_opp_avg_gym_avg_opp_avg_elo_change_diff AS fighter_opp_avg_gym_avg_opp_avg_elo_change_diff_diff,
    t2.fighter_avg_opp_gym_avg_avg_elo_change_diff - t3.fighter_avg_opp_gym_avg_avg_elo_change_diff AS fighter_avg_opp_gym_avg_avg_elo_change_diff_diff,
    t2.fighter_opp_avg_gym_avg_avg_elo_change_diff_diff - t3.fighter_opp_avg_gym_avg_avg_elo_change_diff_diff AS fighter_opp_avg_gym_avg_avg_elo_change_diff_diff_diff,
    t2.avg_opp_fighter_avg_gym_win_rate - t3.avg_opp_fighter_avg_gym_win_rate AS avg_opp_fighter_avg_gym_win_rate_diff,
    t2.fighter_opp_avg_fighter_avg_gym_win_rate_diff - t3.fighter_opp_avg_fighter_avg_gym_win_rate_diff AS fighter_opp_avg_fighter_avg_gym_win_rate_diff_diff,
    t2.avg_opp_fighter_avg_gym_elo - t3.avg_opp_fighter_avg_gym_elo AS avg_opp_fighter_avg_gym_elo_diff,
    t2.fighter_opp_avg_fighter_avg_gym_elo_diff - t3.fighter_opp_avg_fighter_avg_gym_elo_diff AS fighter_opp_avg_fighter_avg_gym_elo_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_elo - t3.avg_opp_fighter_avg_gym_avg_elo AS avg_opp_fighter_avg_gym_avg_elo_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_elo_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_elo_diff AS fighter_opp_avg_fighter_avg_gym_avg_elo_diff_diff,
    t2.avg_opp_fighter_avg_gym_elo_change - t3.avg_opp_fighter_avg_gym_elo_change AS avg_opp_fighter_avg_gym_elo_change_diff,
    t2.fighter_opp_avg_fighter_avg_gym_elo_change_diff - t3.fighter_opp_avg_fighter_avg_gym_elo_change_diff AS fighter_opp_avg_fighter_avg_gym_elo_change_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_elo_change - t3.avg_opp_fighter_avg_gym_avg_elo_change AS avg_opp_fighter_avg_gym_avg_elo_change_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_elo_change_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_elo_change_diff AS fighter_opp_avg_fighter_avg_gym_avg_elo_change_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_opp_win_rate - t3.avg_opp_fighter_avg_gym_avg_opp_win_rate AS avg_opp_fighter_avg_gym_avg_opp_win_rate_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_opp_win_rate_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_opp_win_rate_diff AS fighter_opp_avg_fighter_avg_gym_avg_opp_win_rate_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_win_rate_diff - t3.avg_opp_fighter_avg_gym_avg_win_rate_diff AS avg_opp_fighter_avg_gym_avg_win_rate_diff_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_win_rate_diff_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_win_rate_diff_diff AS fighter_opp_avg_fighter_avg_gym_avg_win_rate_diff_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_opp_elo - t3.avg_opp_fighter_avg_gym_avg_opp_elo AS avg_opp_fighter_avg_gym_avg_opp_elo_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_opp_elo_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_opp_elo_diff AS fighter_opp_avg_fighter_avg_gym_avg_opp_elo_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_elo_diff - t3.avg_opp_fighter_avg_gym_avg_elo_diff AS avg_opp_fighter_avg_gym_avg_elo_diff_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_elo_diff_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_elo_diff_diff AS fighter_opp_avg_fighter_avg_gym_avg_elo_diff_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_opp_avg_elo - t3.avg_opp_fighter_avg_gym_avg_opp_avg_elo AS avg_opp_fighter_avg_gym_avg_opp_avg_elo_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_opp_avg_elo_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_opp_avg_elo_diff AS fighter_opp_avg_fighter_avg_gym_avg_opp_avg_elo_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_avg_elo_diff - t3.avg_opp_fighter_avg_gym_avg_avg_elo_diff AS avg_opp_fighter_avg_gym_avg_avg_elo_diff_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_avg_elo_diff_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_avg_elo_diff_diff AS fighter_opp_avg_fighter_avg_gym_avg_avg_elo_diff_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_opp_elo_change - t3.avg_opp_fighter_avg_gym_avg_opp_elo_change AS avg_opp_fighter_avg_gym_avg_opp_elo_change_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_opp_elo_change_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_opp_elo_change_diff AS fighter_opp_avg_fighter_avg_gym_avg_opp_elo_change_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_opp_avg_elo_change - t3.avg_opp_fighter_avg_gym_avg_opp_avg_elo_change AS avg_opp_fighter_avg_gym_avg_opp_avg_elo_change_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_opp_avg_elo_change_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_opp_avg_elo_change_diff AS fighter_opp_avg_fighter_avg_gym_avg_opp_avg_elo_change_diff_diff,
    t2.avg_opp_fighter_avg_gym_avg_avg_elo_change_diff - t3.avg_opp_fighter_avg_gym_avg_avg_elo_change_diff AS avg_opp_fighter_avg_gym_avg_avg_elo_change_diff_diff,
    t2.fighter_opp_avg_fighter_avg_gym_avg_avg_elo_change_diff_diff - t3.fighter_opp_avg_fighter_avg_gym_avg_avg_elo_change_diff_diff AS fighter_opp_avg_fighter_avg_gym_avg_avg_elo_change_diff_diff_diff,
    t2.avg_opp_fighter_win_rate_within_gym - t3.avg_opp_fighter_win_rate_within_gym AS avg_opp_fighter_win_rate_within_gym_diff,
    t2.fighter_opp_avg_fighter_win_rate_within_gym_diff - t3.fighter_opp_avg_fighter_win_rate_within_gym_diff AS fighter_opp_avg_fighter_win_rate_within_gym_diff_diff,
    t2.avg_opp_fighter_win_rate_against_gym - t3.avg_opp_fighter_win_rate_against_gym AS avg_opp_fighter_win_rate_against_gym_diff,
    t2.fighter_opp_avg_fighter_win_rate_against_gym_diff - t3.fighter_opp_avg_fighter_win_rate_against_gym_diff AS fighter_opp_avg_fighter_win_rate_against_gym_diff_diff,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte14 AS t2 ON t1.red_fighter_id = t2.fighter_id
    AND t1.id = t2.bout_id
    LEFT JOIN cte14 AS t3 ON t1.blue_fighter_id = t3.fighter_id
    AND t1.id = t3.bout_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );