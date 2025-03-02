WITH cte1 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.bout_id_integer,
        t1.opponent_id,
        CASE
            WHEN t2.overall_percentage IS NOT NULL THEN t2.overall_percentage / 100.0
            ELSE t1.pick_em_percent / 100.0
        END AS community_pick_win_pct,
        (t2.ko_tko_percentage / 100.0) * (t2.overall_percentage / 100.0) AS community_pick_win_by_ko_tko_pct,
        (t2.submission_percentage / 100.0) * (t2.overall_percentage / 100.0) AS community_pick_win_by_submission_pct,
        (t2.decision_percentage / 100.0) * (t2.overall_percentage / 100.0) AS community_pick_win_by_decision_pct
    FROM tapology_fighter_histories AS t1
        LEFT JOIN tapology_community_picks AS t2 ON t1.fighter_id = t2.fighter_id
        AND t1.bout_id = t2.bout_id
),
cte2 AS (
    SELECT fighter_id,
        t1.'order',
        bout_id,
        bout_id_integer,
        opponent_id,
        AVG(community_pick_win_pct) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_pct,
        AVG(community_pick_win_by_ko_tko_pct) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_by_ko_tko_pct,
        AVG(community_pick_win_by_submission_pct) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_by_submission_pct,
        AVG(community_pick_win_by_decision_pct) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_by_decision_pct
    FROM cte1 AS t1
),
cte3 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.bout_id_integer,
        t1.opponent_id,
        t1.avg_community_pick_win_pct,
        t1.avg_community_pick_win_by_ko_tko_pct,
        t1.avg_community_pick_win_by_submission_pct,
        t1.avg_community_pick_win_by_decision_pct,
        AVG(t2.avg_community_pick_win_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_community_pick_win_pct,
        AVG(
            t1.avg_community_pick_win_pct - t2.avg_community_pick_win_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_pct_diff,
        AVG(
            1.0 * t1.avg_community_pick_win_pct / t2.avg_community_pick_win_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_pct_ratio,
        AVG(t2.avg_community_pick_win_by_ko_tko_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_community_pick_win_by_ko_tko_pct,
        AVG(
            t1.avg_community_pick_win_by_ko_tko_pct - t2.avg_community_pick_win_by_ko_tko_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_by_ko_tko_pct_diff,
        AVG(
            1.0 * t1.avg_community_pick_win_by_ko_tko_pct / t2.avg_community_pick_win_by_ko_tko_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_by_ko_tko_pct_ratio,
        AVG(t2.avg_community_pick_win_by_submission_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_community_pick_win_by_submission_pct,
        AVG(
            t1.avg_community_pick_win_by_submission_pct - t2.avg_community_pick_win_by_submission_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_by_submission_pct_diff,
        AVG(
            1.0 * t1.avg_community_pick_win_by_submission_pct / t2.avg_community_pick_win_by_submission_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_by_submission_pct_ratio,
        AVG(t2.avg_community_pick_win_by_decision_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_community_pick_win_by_decision_pct,
        AVG(
            t1.avg_community_pick_win_by_decision_pct - t2.avg_community_pick_win_by_decision_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_by_decision_pct_diff,
        AVG(
            1.0 * t1.avg_community_pick_win_by_decision_pct / t2.avg_community_pick_win_by_decision_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_community_pick_win_by_decision_pct_ratio
    FROM cte2 AS t1
        LEFT JOIN cte2 AS t2 ON t1.fighter_id = t2.opponent_id
        AND t1.opponent_id = t2.fighter_id
        AND t1.bout_id_integer = t2.bout_id_integer
),
cte4 AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t3.ufcstats_id AS bout_id,
        t1.avg_community_pick_win_pct,
        t1.avg_community_pick_win_by_ko_tko_pct,
        t1.avg_community_pick_win_by_submission_pct,
        t1.avg_community_pick_win_by_decision_pct,
        t1.avg_opp_avg_community_pick_win_pct,
        t1.avg_community_pick_win_pct_diff,
        t1.avg_community_pick_win_pct_ratio,
        t1.avg_opp_avg_community_pick_win_by_ko_tko_pct,
        t1.avg_community_pick_win_by_ko_tko_pct_diff,
        t1.avg_community_pick_win_by_ko_tko_pct_ratio,
        t1.avg_opp_avg_community_pick_win_by_submission_pct,
        t1.avg_community_pick_win_by_submission_pct_diff,
        t1.avg_community_pick_win_by_submission_pct_ratio,
        t1.avg_opp_avg_community_pick_win_by_decision_pct,
        t1.avg_community_pick_win_by_decision_pct_diff,
        t1.avg_community_pick_win_by_decision_pct_ratio
    FROM cte3 AS t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.tapology_id
        INNER JOIN bout_mapping AS t3 ON t1.bout_id = t3.tapology_id
)
SELECT id,
    t2.avg_community_pick_win_pct - t3.avg_community_pick_win_pct AS community_pick_win_pct_diff,
    1.0 * t2.avg_community_pick_win_pct / t3.avg_community_pick_win_pct AS community_pick_win_pct_ratio,
    t2.avg_community_pick_win_by_ko_tko_pct - t3.avg_community_pick_win_by_ko_tko_pct AS community_pick_win_by_ko_tko_pct_diff,
    1.0 * t2.avg_community_pick_win_by_ko_tko_pct / t3.avg_community_pick_win_by_ko_tko_pct AS community_pick_win_by_ko_tko_pct_ratio,
    t2.avg_community_pick_win_by_submission_pct - t3.avg_community_pick_win_by_submission_pct AS community_pick_win_by_submission_pct_diff,
    1.0 * t2.avg_community_pick_win_by_submission_pct / t3.avg_community_pick_win_by_submission_pct AS community_pick_win_by_submission_pct_ratio,
    t2.avg_community_pick_win_by_decision_pct - t3.avg_community_pick_win_by_decision_pct AS community_pick_win_by_decision_pct_diff,
    1.0 * t2.avg_community_pick_win_by_decision_pct / t3.avg_community_pick_win_by_decision_pct AS community_pick_win_by_decision_pct_ratio,
    t2.avg_opp_avg_community_pick_win_pct - t3.avg_opp_avg_community_pick_win_pct AS opp_avg_community_pick_win_pct_diff,
    1.0 * t2.avg_opp_avg_community_pick_win_pct / t3.avg_opp_avg_community_pick_win_pct AS opp_avg_community_pick_win_pct_ratio,
    t2.avg_community_pick_win_pct_diff - t3.avg_community_pick_win_pct_diff AS community_pick_win_pct_diff_diff,
    1.0 * t2.avg_community_pick_win_pct_diff / t3.avg_community_pick_win_pct_diff AS community_pick_win_pct_diff_ratio,
    t2.avg_community_pick_win_pct_ratio - t3.avg_community_pick_win_pct_ratio AS community_pick_win_pct_ratio_diff,
    1.0 * t2.avg_community_pick_win_pct_ratio / t3.avg_community_pick_win_pct_ratio AS community_pick_win_pct_ratio_ratio,
    t2.avg_opp_avg_community_pick_win_by_ko_tko_pct - t3.avg_opp_avg_community_pick_win_by_ko_tko_pct AS opp_avg_community_pick_win_by_ko_tko_pct_diff,
    1.0 * t2.avg_opp_avg_community_pick_win_by_ko_tko_pct / t3.avg_opp_avg_community_pick_win_by_ko_tko_pct AS opp_avg_community_pick_win_by_ko_tko_pct_ratio,
    t2.avg_community_pick_win_by_ko_tko_pct_diff - t3.avg_community_pick_win_by_ko_tko_pct_diff AS community_pick_win_by_ko_tko_pct_diff_diff,
    1.0 * t2.avg_community_pick_win_by_ko_tko_pct_diff / t3.avg_community_pick_win_by_ko_tko_pct_diff AS community_pick_win_by_ko_tko_pct_diff_ratio,
    t2.avg_community_pick_win_by_ko_tko_pct_ratio - t3.avg_community_pick_win_by_ko_tko_pct_ratio AS community_pick_win_by_ko_tko_pct_ratio_diff,
    1.0 * t2.avg_community_pick_win_by_ko_tko_pct_ratio / t3.avg_community_pick_win_by_ko_tko_pct_ratio AS community_pick_win_by_ko_tko_pct_ratio_ratio,
    t2.avg_opp_avg_community_pick_win_by_submission_pct - t3.avg_opp_avg_community_pick_win_by_submission_pct AS opp_avg_community_pick_win_by_submission_pct_diff,
    1.0 * t2.avg_opp_avg_community_pick_win_by_submission_pct / t3.avg_opp_avg_community_pick_win_by_submission_pct AS opp_avg_community_pick_win_by_submission_pct_ratio,
    t2.avg_community_pick_win_by_submission_pct_diff - t3.avg_community_pick_win_by_submission_pct_diff AS community_pick_win_by_submission_pct_diff_diff,
    1.0 * t2.avg_community_pick_win_by_submission_pct_diff / t3.avg_community_pick_win_by_submission_pct_diff AS community_pick_win_by_submission_pct_diff_ratio,
    t2.avg_community_pick_win_by_submission_pct_ratio - t3.avg_community_pick_win_by_submission_pct_ratio AS community_pick_win_by_submission_pct_ratio_diff,
    1.0 * t2.avg_community_pick_win_by_submission_pct_ratio / t3.avg_community_pick_win_by_submission_pct_ratio AS community_pick_win_by_submission_pct_ratio_ratio,
    t2.avg_opp_avg_community_pick_win_by_decision_pct - t3.avg_opp_avg_community_pick_win_by_decision_pct AS opp_avg_community_pick_win_by_decision_pct_diff,
    1.0 * t2.avg_opp_avg_community_pick_win_by_decision_pct / t3.avg_opp_avg_community_pick_win_by_decision_pct AS opp_avg_community_pick_win_by_decision_pct_ratio,
    t2.avg_community_pick_win_by_decision_pct_diff - t3.avg_community_pick_win_by_decision_pct_diff AS community_pick_win_by_decision_pct_diff_diff,
    1.0 * t2.avg_community_pick_win_by_decision_pct_diff / t3.avg_community_pick_win_by_decision_pct_diff AS community_pick_win_by_decision_pct_diff_ratio,
    t2.avg_community_pick_win_by_decision_pct_ratio - t3.avg_community_pick_win_by_decision_pct_ratio AS community_pick_win_by_decision_pct_ratio_diff,
    1.0 * t2.avg_community_pick_win_by_decision_pct_ratio / t3.avg_community_pick_win_by_decision_pct_ratio AS community_pick_win_by_decision_pct_ratio_ratio,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte4 AS t2 ON t1.id = t2.bout_id
    AND t1.red_fighter_id = t2.fighter_id
    LEFT JOIN cte4 AS t3 ON t1.id = t3.bout_id
    AND t1.blue_fighter_id = t3.fighter_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );