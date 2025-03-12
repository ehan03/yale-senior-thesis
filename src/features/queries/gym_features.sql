WITH cte1 AS (
    SELECT fighter_id,
        bout_id,
        CASE
            WHEN gym_id IS NOT NULL THEN gym_id
            ELSE gym_name
        END AS gym_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id,
            bout_id
            ORDER BY t1.rowid
        ) AS gym_rank
    FROM tapology_fighter_gyms t1
    WHERE gym_purpose = 'Primary'
),
cte2 AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id,
            bout_id
            ORDER BY gym_rank
        ) AS primary_gym_rank
    FROM cte1 AS t1
),
cte3 AS (
    SELECT *
    FROM cte2
    WHERE primary_gym_rank = 1
),
cte4 AS (
    SELECT t1.fighter_id,
        t1.bout_id,
        CASE
            WHEN t1.gym_id IS NOT NULL THEN t1.gym_id
            ELSE t1.gym_name
        END AS gym_id,
        COUNT(t1.gym_name) OVER (PARTITION BY t1.fighter_id, t1.bout_id) AS gym_count,
        ROW_NUMBER() OVER (
            PARTITION BY t1.fighter_id,
            t1.bout_id
            ORDER BY t1.rowid
        ) AS gym_rank
    FROM tapology_fighter_gyms AS t1
),
cte5 AS (
    SELECT t1.fighter_id,
        t1.bout_id,
        t1.gym_id,
        t1.gym_count,
        t1.gym_rank,
        CASE
            WHEN t2.fighter_id IS NOT NULL
            AND t2.bout_id IS NOT NULL THEN 1
            ELSE 0
        END AS has_primary_flag,
        t3.primary_gym_rank
    FROM cte4 AS t1
        LEFT JOIN cte3 AS t2 ON t1.fighter_id = t2.fighter_id
        AND t1.bout_id = t2.bout_id
        LEFT JOIN cte3 AS t3 ON t1.fighter_id = t3.fighter_id
        AND t1.bout_id = t3.bout_id
        AND t1.gym_id = t3.gym_id
),
cte6 AS (
    SELECT fighter_id,
        bout_id,
        gym_id
    FROM cte5
    WHERE gym_count = 1
    UNION
    SELECT fighter_id,
        bout_id,
        gym_id
    FROM cte5
    WHERE gym_count > 1
        AND has_primary_flag = 1
        AND primary_gym_rank = 1
    UNION
    SELECT fighter_id,
        bout_id,
        gym_id
    FROM cte5
    WHERE gym_count > 1
        AND has_primary_flag = 0
        AND gym_rank = 1
),
fighter_gyms AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t3.ufcstats_id AS bout_id,
        CASE
            WHEN t4.parent_id IS NOT NULL THEN t4.parent_id
            ELSE t1.gym_id
        END AS gym_id
    FROM cte6 AS t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.tapology_id
        INNER JOIN bout_mapping AS t3 ON t1.bout_id = t3.tapology_id
        LEFT JOIN tapology_gyms AS t4 ON t1.gym_id = t4.id
),
cte7 AS (
    SELECT t1.id AS bout_id,
        t1.bout_order,
        t1.event_id,
        t2.wikipedia_id AS event_order,
        t1.red_fighter_id,
        t1.blue_fighter_id,
        t1.red_outcome,
        t3.gym_id AS red_gym_id,
        t4.gym_id AS blue_gym_id
    FROM ufcstats_bouts AS t1
        INNER JOIN event_mapping AS t2 ON t1.event_id = t2.ufcstats_id
        LEFT JOIN fighter_gyms AS t3 ON t3.fighter_id = t1.red_fighter_id
        AND t3.bout_id = t1.id
        LEFT JOIN fighter_gyms AS t4 ON t4.fighter_id = t1.blue_fighter_id
        AND t4.bout_id = t1.id
    ORDER BY t2.wikipedia_id,
        t1.bout_order
),
cte8 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.opponent_id,
        t3.fightmatrix_id AS fightmatrix_event_id
    FROM ufcstats_fighter_histories AS t1
        LEFT JOIN ufcstats_bouts AS t2 ON t1.bout_id = t2.id
        INNER JOIN event_mapping AS t3 ON t2.event_id = t3.ufcstats_id
),
cte9 AS (
    SELECT t1.fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        t1.bout_id,
        t1.opponent_id,
        t1.fightmatrix_event_id
    FROM cte8 AS t1
),
cte10 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.event_id,
        t1.opponent_id,
        t1.fighter_elo_k170_pre AS elo_k170,
        t1.fighter_elo_k170_pre - LAG(t1.fighter_elo_k170_pre) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
        ) AS elo_k170_change,
        t1.fighter_elo_modified_pre AS elo_modified,
        t1.fighter_elo_modified_pre - LAG(t1.fighter_elo_modified_pre) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
        ) AS elo_modified_change,
        t1.fighter_glicko_1_pre AS glicko_1,
        t1.fighter_glicko_1_pre - LAG(t1.fighter_glicko_1_pre) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
        ) AS glicko_1_change
    FROM fightmatrix_fighter_histories AS t1
),
cte11 AS (
    SELECT t3.ufcstats_id AS fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        t1.event_id AS fightmatrix_event_id,
        t4.ufcstats_id AS opponent_id,
        t1.elo_k170,
        t1.elo_k170_change,
        t1.elo_modified,
        t1.elo_modified_change,
        t1.glicko_1,
        t1.glicko_1_change
    FROM cte10 AS t1
        INNER JOIN event_mapping AS t2 ON t1.event_id = t2.fightmatrix_id
        INNER JOIN fighter_mapping AS t3 ON t1.fighter_id = t3.fightmatrix_id
        INNER JOIN fighter_mapping AS t4 ON t1.opponent_id = t4.fightmatrix_id
),
cte12 AS (
    SELECT t1.fighter_id,
        t1.bout_id,
        t2.elo_k170,
        t2.elo_k170_change,
        t2.elo_modified,
        t2.elo_modified_change,
        t2.glicko_1,
        t2.glicko_1_change
    FROM cte9 AS t1
        LEFT JOIN cte11 AS t2 ON t1.fighter_id = t2.fighter_id
        AND t1.ufc_order = t2.ufc_order
        AND t1.fightmatrix_event_id = t2.fightmatrix_event_id
        AND t1.opponent_id = t2.opponent_id
),
cte13 AS (
    SELECT t1.bout_id,
        t1.bout_order,
        t1.event_id,
        t1.event_order,
        t1.red_fighter_id,
        t1.blue_fighter_id,
        t1.red_outcome,
        t1.red_gym_id,
        t1.blue_gym_id,
        t2.elo_k170 AS red_elo_k170,
        t2.elo_k170_change AS red_elo_k170_change,
        t2.elo_modified AS red_elo_modified,
        t2.elo_modified_change AS red_elo_modified_change,
        t2.glicko_1 AS red_glicko_1,
        t2.glicko_1_change AS red_glicko_1_change,
        t3.elo_k170 AS blue_elo_k170,
        t3.elo_k170_change AS blue_elo_k170_change,
        t3.elo_modified AS blue_elo_modified,
        t3.elo_modified_change AS blue_elo_modified_change,
        t3.glicko_1 AS blue_glicko_1,
        t3.glicko_1_change AS blue_glicko_1_change
    FROM cte7 AS t1
        LEFT JOIN cte12 AS t2 ON t1.red_fighter_id = t2.fighter_id
        AND t1.bout_id = t2.bout_id
        LEFT JOIN cte12 AS t3 ON t1.blue_fighter_id = t3.fighter_id
        AND t1.bout_id = t3.bout_id
),
cte14 AS (
    SELECT red_gym_id AS gym_id,
        bout_id,
        bout_order,
        event_id,
        event_order,
        blue_gym_id AS opp_gym_id,
        red_elo_k170 AS elo_k170,
        red_elo_k170_change AS elo_k170_change,
        red_elo_modified AS elo_modified,
        red_elo_modified_change AS elo_modified_change,
        red_glicko_1 AS glicko_1,
        red_glicko_1_change AS glicko_1_change,
        blue_elo_k170 AS opp_elo_k170,
        blue_elo_k170_change AS opp_elo_k170_change,
        blue_elo_modified AS opp_elo_modified,
        blue_elo_modified_change AS opp_elo_modified_change,
        blue_glicko_1 AS opp_glicko_1,
        blue_glicko_1_change AS opp_glicko_1_change
    FROM cte13
    WHERE red_gym_id IS NOT NULL
    UNION
    SELECT blue_gym_id AS gym_id,
        bout_id,
        bout_order,
        event_id,
        event_order,
        red_gym_id AS opp_gym_id,
        blue_elo_k170 AS elo_k170,
        blue_elo_k170_change AS elo_k170_change,
        blue_elo_modified AS elo_modified,
        blue_elo_modified_change AS elo_modified_change,
        blue_glicko_1 AS glicko_1,
        blue_glicko_1_change AS glicko_1_change,
        red_elo_k170 AS opp_elo_k170,
        red_elo_k170_change AS opp_elo_k170_change,
        red_elo_modified AS opp_elo_modified,
        red_elo_modified_change AS opp_elo_modified_change,
        red_glicko_1 AS opp_glicko_1,
        red_glicko_1_change AS opp_glicko_1_change
    FROM cte13
    WHERE blue_gym_id IS NOT NULL
    ORDER BY gym_id,
        event_order,
        bout_order
),
cte15 AS (
    SELECT gym_id,
        ROW_NUMBER() OVER (
            PARTITION BY gym_id,
            event_id
            ORDER BY bout_order
        ) gym_bout_order_in_event,
        event_id,
        AVG(elo_k170) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_elo_k170,
        AVG(elo_k170_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_elo_k170_change,
        AVG(elo_modified) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_elo_modified,
        AVG(elo_modified_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_elo_modified_change,
        AVG(glicko_1) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_glicko_1,
        AVG(glicko_1_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_glicko_1_change,
        AVG(opp_elo_k170) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_gym_elo_k170,
        AVG(elo_k170 - opp_elo_k170) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_elo_k170_diff,
        AVG(opp_elo_k170_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_gym_elo_k170_change,
        AVG(elo_k170_change - opp_elo_k170_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_elo_k170_change_diff,
        AVG(opp_elo_modified) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_gym_elo_modified,
        AVG(elo_modified - opp_elo_modified) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_elo_modified_diff,
        AVG(opp_elo_modified_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_gym_elo_modified_change,
        AVG(elo_modified_change - opp_elo_modified_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_elo_modified_change_diff,
        AVG(opp_glicko_1) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_gym_glicko_1,
        AVG(glicko_1 - opp_glicko_1) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_glicko_1_diff,
        AVG(opp_glicko_1_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_gym_glicko_1_change,
        AVG(glicko_1_change - opp_glicko_1_change) OVER (
            PARTITION BY gym_id
            ORDER BY event_order,
                bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_gym_glicko_1_change_diff
    FROM cte14
    ORDER BY gym_id,
        event_order,
        bout_order
),
cte16 AS (
    SELECT gym_id,
        event_id,
        avg_gym_elo_k170,
        avg_gym_elo_k170_change,
        avg_gym_elo_modified,
        avg_gym_elo_modified_change,
        avg_gym_glicko_1,
        avg_gym_glicko_1_change,
        avg_opp_gym_elo_k170,
        avg_gym_elo_k170_diff,
        avg_opp_gym_elo_k170_change,
        avg_gym_elo_k170_change_diff,
        avg_opp_gym_elo_modified,
        avg_gym_elo_modified_diff,
        avg_opp_gym_elo_modified_change,
        avg_gym_elo_modified_change_diff,
        avg_opp_gym_glicko_1,
        avg_gym_glicko_1_diff,
        avg_opp_gym_glicko_1_change,
        avg_gym_glicko_1_change_diff
    FROM cte15
    WHERE gym_bout_order_in_event = 1
)
SELECT t1.id,
    t3.avg_gym_elo_k170 - t4.avg_gym_elo_k170 AS avg_gym_elo_k170_diff,
    t3.avg_gym_elo_k170_change - t4.avg_gym_elo_k170_change AS avg_gym_elo_k170_change_diff,
    t3.avg_gym_elo_modified - t4.avg_gym_elo_modified AS avg_gym_elo_modified_diff,
    t3.avg_gym_elo_modified_change - t4.avg_gym_elo_modified_change AS avg_gym_elo_modified_change_diff,
    t3.avg_gym_glicko_1 - t4.avg_gym_glicko_1 AS avg_gym_glicko_1_diff,
    t3.avg_gym_glicko_1_change - t4.avg_gym_glicko_1_change AS avg_gym_glicko_1_change_diff,
    t3.avg_opp_gym_elo_k170 - t4.avg_opp_gym_elo_k170 AS avg_opp_gym_elo_k170_diff,
    t3.avg_gym_elo_k170_diff - t4.avg_gym_elo_k170_diff AS avg_gym_elo_k170_diff_diff,
    t3.avg_opp_gym_elo_k170_change - t4.avg_opp_gym_elo_k170_change AS avg_opp_gym_elo_k170_change_diff,
    t3.avg_gym_elo_k170_change_diff - t4.avg_gym_elo_k170_change_diff AS avg_gym_elo_k170_change_diff_diff,
    t3.avg_opp_gym_elo_modified - t4.avg_opp_gym_elo_modified AS avg_opp_gym_elo_modified_diff,
    t3.avg_gym_elo_modified_diff - t4.avg_gym_elo_modified_diff AS avg_gym_elo_modified_diff_diff,
    t3.avg_opp_gym_elo_modified_change - t4.avg_opp_gym_elo_modified_change AS avg_opp_gym_elo_modified_change_diff,
    t3.avg_gym_elo_modified_change_diff - t4.avg_gym_elo_modified_change_diff AS avg_gym_elo_modified_change_diff_diff,
    t3.avg_opp_gym_glicko_1 - t4.avg_opp_gym_glicko_1 AS avg_opp_gym_glicko_1_diff,
    t3.avg_gym_glicko_1_diff - t4.avg_gym_glicko_1_diff AS avg_gym_glicko_1_diff_diff,
    t3.avg_opp_gym_glicko_1_change - t4.avg_opp_gym_glicko_1_change AS avg_opp_gym_glicko_1_change_diff,
    t3.avg_gym_glicko_1_change_diff - t4.avg_gym_glicko_1_change_diff AS avg_gym_glicko_1_change_diff_diff,
    CASE
        WHEN t1.red_outcome = 'W' THEN 1
        WHEN t1.red_outcome = 'L' THEN 0
        ELSE NULL
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte7 AS t2 ON t1.id = t2.bout_id
    LEFT JOIN cte16 AS t3 ON t2.red_gym_id = t3.gym_id
    AND t2.event_id = t3.event_id
    LEFT JOIN cte16 AS t4 ON t2.blue_gym_id = t4.gym_id
    AND t2.event_id = t4.event_id
WHERE t1.event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );