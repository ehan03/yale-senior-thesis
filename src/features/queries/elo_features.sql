WITH cte1 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        opponent_id,
        fighter_elo_k170_pre AS elo_k170,
        AVG(fighter_elo_k170_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_k170,
        LAG(fighter_elo_k170_post - fighter_elo_k170_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS elo_k170_change,
        fighter_elo_modified_pre AS elo_modified,
        AVG(fighter_elo_modified_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_modified,
        LAG(
            fighter_elo_modified_post - fighter_elo_modified_pre
        ) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS elo_modified_change,
        fighter_glicko_1_pre AS glicko_1,
        AVG(fighter_glicko_1_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_glicko_1,
        LAG(fighter_glicko_1_post - fighter_glicko_1_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS glicko_1_change,
        AVG(opponent_elo_k170_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_elo_k170,
        opponent_elo_k170_pre - LAG(opponent_elo_k170_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS opp_elo_k170_delta,
        AVG(opponent_elo_modified_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_elo_modified,
        opponent_elo_modified_pre - LAG(opponent_elo_modified_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS opp_elo_modified_delta,
        AVG(opponent_glicko_1_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_glicko_1,
        opponent_glicko_1_pre - LAG(opponent_glicko_1_pre) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS opp_glicko_1_delta
    FROM fightmatrix_fighter_histories AS t1
),
cte2 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        opponent_id,
        elo_k170,
        avg_elo_k170,
        elo_k170_change,
        AVG(elo_k170_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_elo_k170_change,
        elo_modified,
        avg_elo_modified,
        elo_modified_change,
        AVG(elo_modified_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_elo_modified_change,
        glicko_1,
        avg_glicko_1,
        glicko_1_change,
        AVG(glicko_1_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_glicko_1_change,
        avg_opp_elo_k170,
        opp_elo_k170_delta,
        AVG(opp_elo_k170_delta) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_opp_elo_k170_delta,
        avg_opp_elo_modified,
        opp_elo_modified_delta,
        AVG(opp_elo_modified_delta) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_opp_elo_modified_delta,
        avg_opp_glicko_1,
        opp_glicko_1_delta,
        AVG(opp_glicko_1_delta) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_opp_glicko_1_delta,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id,
            event_id,
            opponent_id
            ORDER BY t1.'order'
        ) AS temp_rn
    FROM cte1 AS t1
),
cte3 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.event_id,
        t1.opponent_id,
        t1.elo_k170,
        t1.avg_elo_k170,
        t1.elo_k170_change,
        t1.avg_elo_k170_change,
        t1.elo_modified,
        t1.avg_elo_modified,
        t1.elo_modified_change,
        t1.avg_elo_modified_change,
        t1.glicko_1,
        t1.avg_glicko_1,
        t1.glicko_1_change,
        t1.avg_glicko_1_change,
        t1.avg_opp_elo_k170,
        t1.opp_elo_k170_delta,
        t1.avg_opp_elo_k170_delta,
        t1.avg_opp_elo_modified,
        t1.opp_elo_modified_delta,
        t1.avg_opp_elo_modified_delta,
        t1.avg_opp_glicko_1,
        t1.opp_glicko_1_delta,
        t1.avg_opp_glicko_1_delta,
        AVG(t1.elo_k170 - t2.elo_k170) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_k170_diff,
        AVG(1.0 * t1.elo_k170 / t2.elo_k170) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_k170_ratio,
        AVG(t1.avg_elo_k170 - t2.avg_elo_k170) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_elo_k170_diff,
        AVG(1.0 * t1.avg_elo_k170 / t2.avg_elo_k170) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_elo_k170_ratio,
        AVG(t1.elo_k170_change - t2.elo_k170_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_k170_change_diff,
        AVG(1.0 * t1.elo_k170_change / t2.elo_k170_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_k170_change_ratio,
        AVG(t1.avg_elo_k170_change - t2.avg_elo_k170_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_elo_k170_change_diff,
        AVG(
            1.0 * t1.avg_elo_k170_change / t2.avg_elo_k170_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_elo_k170_change_ratio,
        AVG(t1.elo_modified - t2.elo_modified) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_modified_diff,
        AVG(1.0 * t1.elo_modified / t2.elo_modified) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_modified_ratio,
        AVG(t1.avg_elo_modified - t2.avg_elo_modified) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_elo_modified_diff,
        AVG(1.0 * t1.avg_elo_modified / t2.avg_elo_modified) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_elo_modified_ratio,
        AVG(t1.elo_modified_change - t2.elo_modified_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_modified_change_diff,
        AVG(
            1.0 * t1.elo_modified_change / t2.elo_modified_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elo_modified_change_ratio,
        AVG(
            t1.avg_elo_modified_change - t2.avg_elo_modified_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_elo_modified_change_diff,
        AVG(
            1.0 * t1.avg_elo_modified_change / t2.avg_elo_modified_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_elo_modified_change_ratio,
        AVG(t1.glicko_1 - t2.glicko_1) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_glicko_1_diff,
        AVG(1.0 * t1.glicko_1 / t2.glicko_1) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_glicko_1_ratio,
        AVG(t1.avg_glicko_1 - t2.avg_glicko_1) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_glicko_1_diff,
        AVG(1.0 * t1.avg_glicko_1 / t2.avg_glicko_1) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_glicko_1_ratio,
        AVG(t1.glicko_1_change - t2.glicko_1_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_glicko_1_change_diff,
        AVG(1.0 * t1.glicko_1_change / t2.glicko_1_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_glicko_1_change_ratio,
        AVG(t1.avg_glicko_1_change - t2.avg_glicko_1_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_glicko_1_change_diff,
        AVG(
            1.0 * t1.avg_glicko_1_change / t2.avg_glicko_1_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_glicko_1_change_ratio,
        AVG(t1.avg_opp_elo_k170 - t2.avg_opp_elo_k170) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_elo_k170_diff,
        AVG(1.0 * t1.avg_opp_elo_k170 / t2.avg_opp_elo_k170) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_elo_k170_ratio,
        AVG(t1.opp_elo_k170_delta - t2.opp_elo_k170_delta) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_elo_k170_delta_diff,
        AVG(
            1.0 * t1.opp_elo_k170_delta / t2.opp_elo_k170_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_elo_k170_delta_ratio,
        AVG(
            t1.avg_opp_elo_k170_delta - t2.avg_opp_elo_k170_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_elo_k170_delta_diff,
        AVG(
            1.0 * t1.avg_opp_elo_k170_delta / t2.avg_opp_elo_k170_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_elo_k170_delta_ratio,
        AVG(
            t1.avg_opp_elo_modified - t2.avg_opp_elo_modified
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_elo_modified_diff,
        AVG(
            1.0 * t1.avg_opp_elo_modified / t2.avg_opp_elo_modified
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_elo_modified_ratio,
        AVG(
            t1.opp_elo_modified_delta - t2.opp_elo_modified_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_elo_modified_delta_diff,
        AVG(
            1.0 * t1.opp_elo_modified_delta / t2.opp_elo_modified_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_elo_modified_delta_ratio,
        AVG(
            t1.avg_opp_elo_modified_delta - t2.avg_opp_elo_modified_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_elo_modified_delta_diff,
        AVG(
            1.0 * t1.avg_opp_elo_modified_delta / t2.avg_opp_elo_modified_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_elo_modified_delta_ratio,
        AVG(t1.avg_opp_glicko_1 - t2.avg_opp_glicko_1) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_glicko_1_diff,
        AVG(1.0 * t1.avg_opp_glicko_1 / t2.avg_opp_glicko_1) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_glicko_1_ratio,
        AVG(t1.opp_glicko_1_delta - t2.opp_glicko_1_delta) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_glicko_1_delta_diff,
        AVG(
            1.0 * t1.opp_glicko_1_delta / t2.opp_glicko_1_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_glicko_1_delta_ratio,
        AVG(
            t1.avg_opp_glicko_1_delta - t2.avg_opp_glicko_1_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_glicko_1_delta_diff,
        AVG(
            1.0 * t1.avg_opp_glicko_1_delta / t2.avg_opp_glicko_1_delta
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_glicko_1_delta_ratio
    FROM cte2 AS t1
        LEFT JOIN cte2 AS t2 ON t1.opponent_id = t2.fighter_id
        AND t1.event_id = t2.event_id
        AND t1.fighter_id = t2.opponent_id
        AND t1.temp_rn = t2.temp_rn
),
cte4 AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t1.'order',
        t4.ufcstats_id AS event_id,
        t3.ufcstats_id AS opponent_id,
        t1.elo_k170,
        t1.avg_elo_k170,
        t1.elo_k170_change,
        t1.avg_elo_k170_change,
        t1.elo_modified,
        t1.avg_elo_modified,
        t1.elo_modified_change,
        t1.avg_elo_modified_change,
        t1.glicko_1,
        t1.avg_glicko_1,
        t1.glicko_1_change,
        t1.avg_glicko_1_change,
        t1.avg_opp_elo_k170,
        t1.opp_elo_k170_delta,
        t1.avg_opp_elo_k170_delta,
        t1.avg_opp_elo_modified,
        t1.opp_elo_modified_delta,
        t1.avg_opp_elo_modified_delta,
        t1.avg_opp_glicko_1,
        t1.opp_glicko_1_delta,
        t1.avg_opp_glicko_1_delta,
        t1.avg_elo_k170_diff,
        t1.avg_elo_k170_ratio,
        t1.avg_avg_elo_k170_diff,
        t1.avg_avg_elo_k170_ratio,
        t1.avg_elo_k170_change_diff,
        t1.avg_elo_k170_change_ratio,
        t1.avg_avg_elo_k170_change_diff,
        t1.avg_avg_elo_k170_change_ratio,
        t1.avg_elo_modified_diff,
        t1.avg_elo_modified_ratio,
        t1.avg_avg_elo_modified_diff,
        t1.avg_avg_elo_modified_ratio,
        t1.avg_elo_modified_change_diff,
        t1.avg_elo_modified_change_ratio,
        t1.avg_avg_elo_modified_change_diff,
        t1.avg_avg_elo_modified_change_ratio,
        t1.avg_glicko_1_diff,
        t1.avg_glicko_1_ratio,
        t1.avg_avg_glicko_1_diff,
        t1.avg_avg_glicko_1_ratio,
        t1.avg_glicko_1_change_diff,
        t1.avg_glicko_1_change_ratio,
        t1.avg_avg_glicko_1_change_diff,
        t1.avg_avg_glicko_1_change_ratio,
        t1.avg_avg_opp_elo_k170_diff,
        t1.avg_avg_opp_elo_k170_ratio,
        t1.avg_opp_elo_k170_delta_diff,
        t1.avg_opp_elo_k170_delta_ratio,
        t1.avg_avg_opp_elo_k170_delta_diff,
        t1.avg_avg_opp_elo_k170_delta_ratio,
        t1.avg_avg_opp_elo_modified_diff,
        t1.avg_avg_opp_elo_modified_ratio,
        t1.avg_opp_elo_modified_delta_diff,
        t1.avg_opp_elo_modified_delta_ratio,
        t1.avg_avg_opp_elo_modified_delta_diff,
        t1.avg_avg_opp_elo_modified_delta_ratio,
        t1.avg_avg_opp_glicko_1_diff,
        t1.avg_avg_opp_glicko_1_ratio,
        t1.avg_opp_glicko_1_delta_diff,
        t1.avg_opp_glicko_1_delta_ratio,
        t1.avg_avg_opp_glicko_1_delta_diff,
        t1.avg_avg_opp_glicko_1_delta_ratio
    FROM cte3 AS t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.fightmatrix_id
        INNER JOIN fighter_mapping AS t3 ON t1.opponent_id = t3.fightmatrix_id
        INNER JOIN event_mapping AS t4 ON t1.event_id = t4.fightmatrix_id
),
cte5 AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        opponent_id,
        t1.elo_k170,
        t1.avg_elo_k170,
        t1.elo_k170_change,
        t1.avg_elo_k170_change,
        t1.elo_modified,
        t1.avg_elo_modified,
        t1.elo_modified_change,
        t1.avg_elo_modified_change,
        t1.glicko_1,
        t1.avg_glicko_1,
        t1.glicko_1_change,
        t1.avg_glicko_1_change,
        t1.avg_opp_elo_k170,
        t1.opp_elo_k170_delta,
        t1.avg_opp_elo_k170_delta,
        t1.avg_opp_elo_modified,
        t1.opp_elo_modified_delta,
        t1.avg_opp_elo_modified_delta,
        t1.avg_opp_glicko_1,
        t1.opp_glicko_1_delta,
        t1.avg_opp_glicko_1_delta,
        t1.avg_elo_k170_diff,
        t1.avg_elo_k170_ratio,
        t1.avg_avg_elo_k170_diff,
        t1.avg_avg_elo_k170_ratio,
        t1.avg_elo_k170_change_diff,
        t1.avg_elo_k170_change_ratio,
        t1.avg_avg_elo_k170_change_diff,
        t1.avg_avg_elo_k170_change_ratio,
        t1.avg_elo_modified_diff,
        t1.avg_elo_modified_ratio,
        t1.avg_avg_elo_modified_diff,
        t1.avg_avg_elo_modified_ratio,
        t1.avg_elo_modified_change_diff,
        t1.avg_elo_modified_change_ratio,
        t1.avg_avg_elo_modified_change_diff,
        t1.avg_avg_elo_modified_change_ratio,
        t1.avg_glicko_1_diff,
        t1.avg_glicko_1_ratio,
        t1.avg_avg_glicko_1_diff,
        t1.avg_avg_glicko_1_ratio,
        t1.avg_glicko_1_change_diff,
        t1.avg_glicko_1_change_ratio,
        t1.avg_avg_glicko_1_change_diff,
        t1.avg_avg_glicko_1_change_ratio,
        t1.avg_avg_opp_elo_k170_diff,
        t1.avg_avg_opp_elo_k170_ratio,
        t1.avg_opp_elo_k170_delta_diff,
        t1.avg_opp_elo_k170_delta_ratio,
        t1.avg_avg_opp_elo_k170_delta_diff,
        t1.avg_avg_opp_elo_k170_delta_ratio,
        t1.avg_avg_opp_elo_modified_diff,
        t1.avg_avg_opp_elo_modified_ratio,
        t1.avg_opp_elo_modified_delta_diff,
        t1.avg_opp_elo_modified_delta_ratio,
        t1.avg_avg_opp_elo_modified_delta_diff,
        t1.avg_avg_opp_elo_modified_delta_ratio,
        t1.avg_avg_opp_glicko_1_diff,
        t1.avg_avg_opp_glicko_1_ratio,
        t1.avg_opp_glicko_1_delta_diff,
        t1.avg_opp_glicko_1_delta_ratio,
        t1.avg_avg_opp_glicko_1_delta_diff,
        t1.avg_avg_opp_glicko_1_delta_ratio
    FROM cte4 AS t1
),
cte6 AS (
    SELECT t1.*
    FROM ufcstats_fighter_histories AS t1
        LEFT JOIN ufcstats_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN ufcstats_events AS t3 ON t2.event_id = t3.id
    WHERE t3.is_ufc_event = 1
),
cte7 AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        bout_id,
        opponent_id
    FROM cte6 AS t1
),
cte8 AS (
    SELECT t1.fighter_id,
        t1.bout_id,
        t2.elo_k170,
        t2.avg_elo_k170,
        t2.elo_k170_change,
        t2.avg_elo_k170_change,
        t2.elo_modified,
        t2.avg_elo_modified,
        t2.elo_modified_change,
        t2.avg_elo_modified_change,
        t2.glicko_1,
        t2.avg_glicko_1,
        t2.glicko_1_change,
        t2.avg_glicko_1_change,
        t2.avg_opp_elo_k170,
        t2.opp_elo_k170_delta,
        t2.avg_opp_elo_k170_delta,
        t2.avg_opp_elo_modified,
        t2.opp_elo_modified_delta,
        t2.avg_opp_elo_modified_delta,
        t2.avg_opp_glicko_1,
        t2.opp_glicko_1_delta,
        t2.avg_opp_glicko_1_delta,
        t2.avg_elo_k170_diff,
        t2.avg_elo_k170_ratio,
        t2.avg_avg_elo_k170_diff,
        t2.avg_avg_elo_k170_ratio,
        t2.avg_elo_k170_change_diff,
        t2.avg_elo_k170_change_ratio,
        t2.avg_avg_elo_k170_change_diff,
        t2.avg_avg_elo_k170_change_ratio,
        t2.avg_elo_modified_diff,
        t2.avg_elo_modified_ratio,
        t2.avg_avg_elo_modified_diff,
        t2.avg_avg_elo_modified_ratio,
        t2.avg_elo_modified_change_diff,
        t2.avg_elo_modified_change_ratio,
        t2.avg_avg_elo_modified_change_diff,
        t2.avg_avg_elo_modified_change_ratio,
        t2.avg_glicko_1_diff,
        t2.avg_glicko_1_ratio,
        t2.avg_avg_glicko_1_diff,
        t2.avg_avg_glicko_1_ratio,
        t2.avg_glicko_1_change_diff,
        t2.avg_glicko_1_change_ratio,
        t2.avg_avg_glicko_1_change_diff,
        t2.avg_avg_glicko_1_change_ratio,
        t2.avg_avg_opp_elo_k170_diff,
        t2.avg_avg_opp_elo_k170_ratio,
        t2.avg_opp_elo_k170_delta_diff,
        t2.avg_opp_elo_k170_delta_ratio,
        t2.avg_avg_opp_elo_k170_delta_diff,
        t2.avg_avg_opp_elo_k170_delta_ratio,
        t2.avg_avg_opp_elo_modified_diff,
        t2.avg_avg_opp_elo_modified_ratio,
        t2.avg_opp_elo_modified_delta_diff,
        t2.avg_opp_elo_modified_delta_ratio,
        t2.avg_avg_opp_elo_modified_delta_diff,
        t2.avg_avg_opp_elo_modified_delta_ratio,
        t2.avg_avg_opp_glicko_1_diff,
        t2.avg_avg_opp_glicko_1_ratio,
        t2.avg_opp_glicko_1_delta_diff,
        t2.avg_opp_glicko_1_delta_ratio,
        t2.avg_avg_opp_glicko_1_delta_diff,
        t2.avg_avg_opp_glicko_1_delta_ratio
    FROM cte7 AS t1
        INNER JOIN cte5 AS t2 ON t1.fighter_id = t2.fighter_id
        AND t1.ufc_order = t2.ufc_order
        AND t1.opponent_id = t2.opponent_id
)
SELECT id,
    t2.elo_k170 - t3.elo_k170 AS elo_k170_diff,
    1.0 * t2.elo_k170 / t3.elo_k170 AS elo_k170_ratio,
    t2.avg_elo_k170 - t3.avg_elo_k170 AS avg_elo_k170_diff,
    1.0 * t2.avg_elo_k170 / t3.avg_elo_k170 AS avg_elo_k170_ratio,
    t2.elo_k170_change - t3.elo_k170_change AS elo_k170_change_diff,
    1.0 * t2.elo_k170_change / t3.elo_k170_change AS elo_k170_change_ratio,
    t2.avg_elo_k170_change - t3.avg_elo_k170_change AS avg_elo_k170_change_diff,
    1.0 * t2.avg_elo_k170_change / t3.avg_elo_k170_change AS avg_elo_k170_change_ratio,
    t2.elo_modified - t3.elo_modified AS elo_modified_diff,
    1.0 * t2.elo_modified / t3.elo_modified AS elo_modified_ratio,
    t2.avg_elo_modified - t3.avg_elo_modified AS avg_elo_modified_diff,
    1.0 * t2.avg_elo_modified / t3.avg_elo_modified AS avg_elo_modified_ratio,
    t2.elo_modified_change - t3.elo_modified_change AS elo_modified_change_diff,
    1.0 * t2.elo_modified_change / t3.elo_modified_change AS elo_modified_change_ratio,
    t2.avg_elo_modified_change - t3.avg_elo_modified_change AS avg_elo_modified_change_diff,
    1.0 * t2.avg_elo_modified_change / t3.avg_elo_modified_change AS avg_elo_modified_change_ratio,
    t2.glicko_1 - t3.glicko_1 AS glicko_1_diff,
    1.0 * t2.glicko_1 / t3.glicko_1 AS glicko_1_ratio,
    t2.avg_glicko_1 - t3.avg_glicko_1 AS avg_glicko_1_diff,
    1.0 * t2.avg_glicko_1 / t3.avg_glicko_1 AS avg_glicko_1_ratio,
    t2.glicko_1_change - t3.glicko_1_change AS glicko_1_change_diff,
    1.0 * t2.glicko_1_change / t3.glicko_1_change AS glicko_1_change_ratio,
    t2.avg_glicko_1_change - t3.avg_glicko_1_change AS avg_glicko_1_change_diff,
    1.0 * t2.avg_glicko_1_change / t3.avg_glicko_1_change AS avg_glicko_1_change_ratio,
    t2.avg_opp_elo_k170 - t3.avg_opp_elo_k170 AS avg_opp_elo_k170_diff,
    1.0 * t2.avg_opp_elo_k170 / t3.avg_opp_elo_k170 AS avg_opp_elo_k170_ratio,
    t2.opp_elo_k170_delta - t3.opp_elo_k170_delta AS opp_elo_k170_delta_diff,
    1.0 * t2.opp_elo_k170_delta / t3.opp_elo_k170_delta AS opp_elo_k170_delta_ratio,
    t2.avg_opp_elo_k170_delta - t3.avg_opp_elo_k170_delta AS avg_opp_elo_k170_delta_diff,
    1.0 * t2.avg_opp_elo_k170_delta / t3.avg_opp_elo_k170_delta AS avg_opp_elo_k170_delta_ratio,
    t2.avg_opp_elo_modified - t3.avg_opp_elo_modified AS avg_opp_elo_modified_diff,
    1.0 * t2.avg_opp_elo_modified / t3.avg_opp_elo_modified AS avg_opp_elo_modified_ratio,
    t2.opp_elo_modified_delta - t3.opp_elo_modified_delta AS opp_elo_modified_delta_diff,
    1.0 * t2.opp_elo_modified_delta / t3.opp_elo_modified_delta AS opp_elo_modified_delta_ratio,
    t2.avg_opp_elo_modified_delta - t3.avg_opp_elo_modified_delta AS avg_opp_elo_modified_delta_diff,
    1.0 * t2.avg_opp_elo_modified_delta / t3.avg_opp_elo_modified_delta AS avg_opp_elo_modified_delta_ratio,
    t2.avg_opp_glicko_1 - t3.avg_opp_glicko_1 AS avg_opp_glicko_1_diff,
    1.0 * t2.avg_opp_glicko_1 / t3.avg_opp_glicko_1 AS avg_opp_glicko_1_ratio,
    t2.opp_glicko_1_delta - t3.opp_glicko_1_delta AS opp_glicko_1_delta_diff,
    1.0 * t2.opp_glicko_1_delta / t3.opp_glicko_1_delta AS opp_glicko_1_delta_ratio,
    t2.avg_opp_glicko_1_delta - t3.avg_opp_glicko_1_delta AS avg_opp_glicko_1_delta_diff,
    1.0 * t2.avg_opp_glicko_1_delta / t3.avg_opp_glicko_1_delta AS avg_opp_glicko_1_delta_ratio,
    t2.avg_elo_k170_diff - t3.avg_elo_k170_diff AS avg_elo_k170_diff_diff,
    1.0 * t2.avg_elo_k170_diff / t3.avg_elo_k170_diff AS avg_elo_k170_diff_ratio,
    t2.avg_elo_k170_ratio - t3.avg_elo_k170_ratio AS avg_elo_k170_ratio_diff,
    1.0 * t2.avg_elo_k170_ratio / t3.avg_elo_k170_ratio AS avg_elo_k170_ratio_ratio,
    t2.avg_avg_elo_k170_diff - t3.avg_avg_elo_k170_diff AS avg_avg_elo_k170_diff_diff,
    1.0 * t2.avg_avg_elo_k170_diff / t3.avg_avg_elo_k170_diff AS avg_avg_elo_k170_diff_ratio,
    t2.avg_avg_elo_k170_ratio - t3.avg_avg_elo_k170_ratio AS avg_avg_elo_k170_ratio_diff,
    1.0 * t2.avg_avg_elo_k170_ratio / t3.avg_avg_elo_k170_ratio AS avg_avg_elo_k170_ratio_ratio,
    t2.avg_elo_k170_change_diff - t3.avg_elo_k170_change_diff AS avg_elo_k170_change_diff_diff,
    1.0 * t2.avg_elo_k170_change_diff / t3.avg_elo_k170_change_diff AS avg_elo_k170_change_diff_ratio,
    t2.avg_elo_k170_change_ratio - t3.avg_elo_k170_change_ratio AS avg_elo_k170_change_ratio_diff,
    1.0 * t2.avg_elo_k170_change_ratio / t3.avg_elo_k170_change_ratio AS avg_elo_k170_change_ratio_ratio,
    t2.avg_avg_elo_k170_change_diff - t3.avg_avg_elo_k170_change_diff AS avg_avg_elo_k170_change_diff_diff,
    1.0 * t2.avg_avg_elo_k170_change_diff / t3.avg_avg_elo_k170_change_diff AS avg_avg_elo_k170_change_diff_ratio,
    t2.avg_avg_elo_k170_change_ratio - t3.avg_avg_elo_k170_change_ratio AS avg_avg_elo_k170_change_ratio_diff,
    1.0 * t2.avg_avg_elo_k170_change_ratio / t3.avg_avg_elo_k170_change_ratio AS avg_avg_elo_k170_change_ratio_ratio,
    t2.avg_elo_modified_diff - t3.avg_elo_modified_diff AS avg_elo_modified_diff_diff,
    1.0 * t2.avg_elo_modified_diff / t3.avg_elo_modified_diff AS avg_elo_modified_diff_ratio,
    t2.avg_elo_modified_ratio - t3.avg_elo_modified_ratio AS avg_elo_modified_ratio_diff,
    1.0 * t2.avg_elo_modified_ratio / t3.avg_elo_modified_ratio AS avg_elo_modified_ratio_ratio,
    t2.avg_avg_elo_modified_diff - t3.avg_avg_elo_modified_diff AS avg_avg_elo_modified_diff_diff,
    1.0 * t2.avg_avg_elo_modified_diff / t3.avg_avg_elo_modified_diff AS avg_avg_elo_modified_diff_ratio,
    t2.avg_avg_elo_modified_ratio - t3.avg_avg_elo_modified_ratio AS avg_avg_elo_modified_ratio_diff,
    1.0 * t2.avg_avg_elo_modified_ratio / t3.avg_avg_elo_modified_ratio AS avg_avg_elo_modified_ratio_ratio,
    t2.avg_elo_modified_change_diff - t3.avg_elo_modified_change_diff AS avg_elo_modified_change_diff_diff,
    1.0 * t2.avg_elo_modified_change_diff / t3.avg_elo_modified_change_diff AS avg_elo_modified_change_diff_ratio,
    t2.avg_elo_modified_change_ratio - t3.avg_elo_modified_change_ratio AS avg_elo_modified_change_ratio_diff,
    1.0 * t2.avg_elo_modified_change_ratio / t3.avg_elo_modified_change_ratio AS avg_elo_modified_change_ratio_ratio,
    t2.avg_avg_elo_modified_change_diff - t3.avg_avg_elo_modified_change_diff AS avg_avg_elo_modified_change_diff_diff,
    1.0 * t2.avg_avg_elo_modified_change_diff / t3.avg_avg_elo_modified_change_diff AS avg_avg_elo_modified_change_diff_ratio,
    t2.avg_avg_elo_modified_change_ratio - t3.avg_avg_elo_modified_change_ratio AS avg_avg_elo_modified_change_ratio_diff,
    1.0 * t2.avg_avg_elo_modified_change_ratio / t3.avg_avg_elo_modified_change_ratio AS avg_avg_elo_modified_change_ratio_ratio,
    t2.avg_glicko_1_diff - t3.avg_glicko_1_diff AS avg_glicko_1_diff_diff,
    1.0 * t2.avg_glicko_1_diff / t3.avg_glicko_1_diff AS avg_glicko_1_diff_ratio,
    t2.avg_glicko_1_ratio - t3.avg_glicko_1_ratio AS avg_glicko_1_ratio_diff,
    1.0 * t2.avg_glicko_1_ratio / t3.avg_glicko_1_ratio AS avg_glicko_1_ratio_ratio,
    t2.avg_avg_glicko_1_diff - t3.avg_avg_glicko_1_diff AS avg_avg_glicko_1_diff_diff,
    1.0 * t2.avg_avg_glicko_1_diff / t3.avg_avg_glicko_1_diff AS avg_avg_glicko_1_diff_ratio,
    t2.avg_avg_glicko_1_ratio - t3.avg_avg_glicko_1_ratio AS avg_avg_glicko_1_ratio_diff,
    1.0 * t2.avg_avg_glicko_1_ratio / t3.avg_avg_glicko_1_ratio AS avg_avg_glicko_1_ratio_ratio,
    t2.avg_glicko_1_change_diff - t3.avg_glicko_1_change_diff AS avg_glicko_1_change_diff_diff,
    1.0 * t2.avg_glicko_1_change_diff / t3.avg_glicko_1_change_diff AS avg_glicko_1_change_diff_ratio,
    t2.avg_glicko_1_change_ratio - t3.avg_glicko_1_change_ratio AS avg_glicko_1_change_ratio_diff,
    1.0 * t2.avg_glicko_1_change_ratio / t3.avg_glicko_1_change_ratio AS avg_glicko_1_change_ratio_ratio,
    t2.avg_avg_glicko_1_change_diff - t3.avg_avg_glicko_1_change_diff AS avg_avg_glicko_1_change_diff_diff,
    1.0 * t2.avg_avg_glicko_1_change_diff / t3.avg_avg_glicko_1_change_diff AS avg_avg_glicko_1_change_diff_ratio,
    t2.avg_avg_glicko_1_change_ratio - t3.avg_avg_glicko_1_change_ratio AS avg_avg_glicko_1_change_ratio_diff,
    1.0 * t2.avg_avg_glicko_1_change_ratio / t3.avg_avg_glicko_1_change_ratio AS avg_avg_glicko_1_change_ratio_ratio,
    t2.avg_avg_opp_elo_k170_diff - t3.avg_avg_opp_elo_k170_diff AS avg_avg_opp_elo_k170_diff_diff,
    1.0 * t2.avg_avg_opp_elo_k170_diff / t3.avg_avg_opp_elo_k170_diff AS avg_avg_opp_elo_k170_diff_ratio,
    t2.avg_avg_opp_elo_k170_ratio - t3.avg_avg_opp_elo_k170_ratio AS avg_avg_opp_elo_k170_ratio_diff,
    1.0 * t2.avg_avg_opp_elo_k170_ratio / t3.avg_avg_opp_elo_k170_ratio AS avg_avg_opp_elo_k170_ratio_ratio,
    t2.avg_opp_elo_k170_delta_diff - t3.avg_opp_elo_k170_delta_diff AS avg_opp_elo_k170_delta_diff_diff,
    1.0 * t2.avg_opp_elo_k170_delta_diff / t3.avg_opp_elo_k170_delta_diff AS avg_opp_elo_k170_delta_diff_ratio,
    t2.avg_opp_elo_k170_delta_ratio - t3.avg_opp_elo_k170_delta_ratio AS avg_opp_elo_k170_delta_ratio_diff,
    1.0 * t2.avg_opp_elo_k170_delta_ratio / t3.avg_opp_elo_k170_delta_ratio AS avg_opp_elo_k170_delta_ratio_ratio,
    t2.avg_avg_opp_elo_k170_delta_diff - t3.avg_avg_opp_elo_k170_delta_diff AS avg_avg_opp_elo_k170_delta_diff_diff,
    1.0 * t2.avg_avg_opp_elo_k170_delta_diff / t3.avg_avg_opp_elo_k170_delta_diff AS avg_avg_opp_elo_k170_delta_diff_ratio,
    t2.avg_avg_opp_elo_k170_delta_ratio - t3.avg_avg_opp_elo_k170_delta_ratio AS avg_avg_opp_elo_k170_delta_ratio_diff,
    1.0 * t2.avg_avg_opp_elo_k170_delta_ratio / t3.avg_avg_opp_elo_k170_delta_ratio AS avg_avg_opp_elo_k170_delta_ratio_ratio,
    t2.avg_avg_opp_elo_modified_diff - t3.avg_avg_opp_elo_modified_diff AS avg_avg_opp_elo_modified_diff_diff,
    1.0 * t2.avg_avg_opp_elo_modified_diff / t3.avg_avg_opp_elo_modified_diff AS avg_avg_opp_elo_modified_diff_ratio,
    t2.avg_avg_opp_elo_modified_ratio - t3.avg_avg_opp_elo_modified_ratio AS avg_avg_opp_elo_modified_ratio_diff,
    1.0 * t2.avg_avg_opp_elo_modified_ratio / t3.avg_avg_opp_elo_modified_ratio AS avg_avg_opp_elo_modified_ratio_ratio,
    t2.avg_opp_elo_modified_delta_diff - t3.avg_opp_elo_modified_delta_diff AS avg_opp_elo_modified_delta_diff_diff,
    1.0 * t2.avg_opp_elo_modified_delta_diff / t3.avg_opp_elo_modified_delta_diff AS avg_opp_elo_modified_delta_diff_ratio,
    t2.avg_opp_elo_modified_delta_ratio - t3.avg_opp_elo_modified_delta_ratio AS avg_opp_elo_modified_delta_ratio_diff,
    1.0 * t2.avg_opp_elo_modified_delta_ratio / t3.avg_opp_elo_modified_delta_ratio AS avg_opp_elo_modified_delta_ratio_ratio,
    t2.avg_avg_opp_elo_modified_delta_diff - t3.avg_avg_opp_elo_modified_delta_diff AS avg_avg_opp_elo_modified_delta_diff_diff,
    1.0 * t2.avg_avg_opp_elo_modified_delta_diff / t3.avg_avg_opp_elo_modified_delta_diff AS avg_avg_opp_elo_modified_delta_diff_ratio,
    t2.avg_avg_opp_elo_modified_delta_ratio - t3.avg_avg_opp_elo_modified_delta_ratio AS avg_avg_opp_elo_modified_delta_ratio_diff,
    1.0 * t2.avg_avg_opp_elo_modified_delta_ratio / t3.avg_avg_opp_elo_modified_delta_ratio AS avg_avg_opp_elo_modified_delta_ratio_ratio,
    t2.avg_avg_opp_glicko_1_diff - t3.avg_avg_opp_glicko_1_diff AS avg_avg_opp_glicko_1_diff_diff,
    1.0 * t2.avg_avg_opp_glicko_1_diff / t3.avg_avg_opp_glicko_1_diff AS avg_avg_opp_glicko_1_diff_ratio,
    t2.avg_avg_opp_glicko_1_ratio - t3.avg_avg_opp_glicko_1_ratio AS avg_avg_opp_glicko_1_ratio_diff,
    1.0 * t2.avg_avg_opp_glicko_1_ratio / t3.avg_avg_opp_glicko_1_ratio AS avg_avg_opp_glicko_1_ratio_ratio,
    t2.avg_opp_glicko_1_delta_diff - t3.avg_opp_glicko_1_delta_diff AS avg_opp_glicko_1_delta_diff_diff,
    1.0 * t2.avg_opp_glicko_1_delta_diff / t3.avg_opp_glicko_1_delta_diff AS avg_opp_glicko_1_delta_diff_ratio,
    t2.avg_opp_glicko_1_delta_ratio - t3.avg_opp_glicko_1_delta_ratio AS avg_opp_glicko_1_delta_ratio_diff,
    1.0 * t2.avg_opp_glicko_1_delta_ratio / t3.avg_opp_glicko_1_delta_ratio AS avg_opp_glicko_1_delta_ratio_ratio,
    t2.avg_avg_opp_glicko_1_delta_diff - t3.avg_avg_opp_glicko_1_delta_diff AS avg_avg_opp_glicko_1_delta_diff_diff,
    1.0 * t2.avg_avg_opp_glicko_1_delta_diff / t3.avg_avg_opp_glicko_1_delta_diff AS avg_avg_opp_glicko_1_delta_diff_ratio,
    t2.avg_avg_opp_glicko_1_delta_ratio - t3.avg_avg_opp_glicko_1_delta_ratio AS avg_avg_opp_glicko_1_delta_ratio_diff,
    1.0 * t2.avg_avg_opp_glicko_1_delta_ratio / t3.avg_avg_opp_glicko_1_delta_ratio AS avg_avg_opp_glicko_1_delta_ratio_ratio,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte8 AS t2 ON t1.id = t2.bout_id
    AND t1.red_fighter_id = t2.fighter_id
    LEFT JOIN cte8 AS t3 ON t1.id = t3.bout_id
    AND t1.blue_fighter_id = t3.fighter_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );