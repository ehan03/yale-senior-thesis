WITH cte1 AS (
    SELECT t1.id,
        t3.ufcstats_id AS ufcstats_bout_id,
        event_id,
        date,
        bout_order,
        fighter_1_id,
        fighter_2_id
    FROM mmadecisions_bouts AS t1
        LEFT JOIN mmadecisions_events AS t2 ON t1.event_id = t2.id
        LEFT JOIN bout_mapping AS t3 ON t1.id = t3.mmadecisions_id
),
cte2 AS (
    SELECT fighter_1_id AS mmadecisions_fighter_id,
        fighter_2_id AS opp_mmadecisions_fighter_id,
        bout_order,
        ufcstats_bout_id,
        id AS mmadecisions_bout_id,
        event_id AS mmadecisions_event_id,
        date
    FROM cte1
    UNION
    SELECT fighter_2_id AS mmadecisions_fighter_id,
        fighter_1_id AS opp_mmadecisions_fighter_id,
        bout_order,
        ufcstats_bout_id,
        id AS mmadecisions_bout_id,
        event_id AS mmadecisions_event_id,
        date
    FROM cte1
    ORDER BY mmadecisions_fighter_id,
        date,
        mmadecisions_event_id,
        bout_order
),
cte3 AS (
    SELECT t2.ufcstats_id AS ufcstats_fighter_id,
        t1.mmadecisions_fighter_id,
        t1.ufcstats_bout_id,
        t1.mmadecisions_bout_id,
        t1.opp_mmadecisions_fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY t1.mmadecisions_fighter_id
            ORDER BY t1.date
        ) AS rn
    FROM cte2 AS t1
        LEFT JOIN fighter_mapping AS t2 ON t1.mmadecisions_fighter_id = t2.mmadecisions_id
),
num_rounds AS (
    SELECT bout_id,
        MAX(CAST(round AS INTEGER)) AS num_rounds
    FROM mmadecisions_judge_scores
    GROUP BY bout_id
),
agg_deductions AS (
    SELECT bout_id,
        fighter_id,
        SUM(points_deducted) AS points_deducted
    FROM mmadecisions_deductions
    GROUP BY bout_id,
        fighter_id
),
judge_totals AS (
    SELECT t1.bout_id,
        fighter_1_id,
        fighter_2_id,
        fighter_1_score + IFNULL(t3.points_deducted, 0) AS fighter_1_total_judge_score,
        fighter_2_score + IFNULL(t4.points_deducted, 0) AS fighter_2_total_judge_score,
        num_rounds
    FROM mmadecisions_judge_scores AS t1
        LEFT JOIN mmadecisions_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN agg_deductions AS t3 ON t1.bout_id = t3.bout_id
        AND t2.fighter_1_id = t3.fighter_id
        LEFT JOIN agg_deductions AS t4 ON t1.bout_id = t4.bout_id
        AND t2.fighter_2_id = t4.fighter_id
        LEFT JOIN num_rounds AS t5 ON t1.bout_id = t5.bout_id
    WHERE t1.round = 'Total'
        AND t1.fighter_1_score > 1
        AND t1.fighter_2_score > 1
),
cte4 AS (
    SELECT bout_id,
        fighter_1_id,
        fighter_2_id,
        SUM(fighter_1_total_judge_score) AS fighter_1_total_judge_score_sum,
        SUM(fighter_2_total_judge_score) AS fighter_2_total_judge_score_sum,
        SUM(num_rounds) AS judge_num_rounds_sum
    FROM judge_totals
    GROUP BY bout_id,
        fighter_1_id,
        fighter_2_id
),
cte5 AS (
    SELECT fighter_1_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_2_id AS opp_mmadecisions_fighter_id,
        fighter_1_total_judge_score_sum AS total_judge_score_sum,
        fighter_2_total_judge_score_sum AS opp_total_judge_score_sum,
        judge_num_rounds_sum
    FROM cte4
    UNION
    SELECT fighter_2_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_1_id AS opp_mmadecisions_fighter_id,
        fighter_2_total_judge_score_sum AS total_judge_score_sum,
        fighter_1_total_judge_score_sum AS opp_total_judge_score_sum,
        judge_num_rounds_sum
    FROM cte4
),
media_totals AS (
    SELECT t1.bout_id,
        fighter_1_id,
        fighter_2_id,
        fighter_1_score + IFNULL(t3.points_deducted, 0) AS fighter_1_total_media_score,
        fighter_2_score + IFNULL(t4.points_deducted, 0) AS fighter_2_total_media_score,
        num_rounds
    FROM mmadecisions_media_scores AS t1
        LEFT JOIN mmadecisions_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN agg_deductions AS t3 ON t1.bout_id = t3.bout_id
        AND t2.fighter_1_id = t3.fighter_id
        LEFT JOIN agg_deductions AS t4 ON t1.bout_id = t4.bout_id
        AND t2.fighter_2_id = t4.fighter_id
        LEFT JOIN num_rounds AS t5 ON t1.bout_id = t5.bout_id
),
cte6 AS (
    SELECT bout_id,
        fighter_1_id,
        fighter_2_id,
        SUM(fighter_1_total_media_score) AS fighter_1_total_media_score_sum,
        SUM(fighter_2_total_media_score) AS fighter_2_total_media_score_sum,
        SUM(num_rounds) AS media_num_rounds_sum
    FROM media_totals
    GROUP BY bout_id,
        fighter_1_id,
        fighter_2_id
),
cte7 AS (
    SELECT fighter_1_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_2_id AS opp_mmadecisions_fighter_id,
        fighter_1_total_media_score_sum AS total_media_score_sum,
        fighter_2_total_media_score_sum AS opp_total_media_score_sum,
        media_num_rounds_sum
    FROM cte6
    UNION
    SELECT fighter_2_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_1_id AS opp_mmadecisions_fighter_id,
        fighter_2_total_media_score_sum AS total_media_score_sum,
        fighter_1_total_media_score_sum AS opp_total_media_score_sum,
        media_num_rounds_sum
    FROM cte6
),
r1_judge_scores AS (
    SELECT t1.bout_id,
        fighter_1_id,
        fighter_2_id,
        fighter_1_score + IFNULL(t3.points_deducted, 0) AS fighter_1_r1_judge_score,
        fighter_2_score + IFNULL(t4.points_deducted, 0) AS fighter_2_r1_judge_score
    FROM mmadecisions_judge_scores AS t1
        LEFT JOIN mmadecisions_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN mmadecisions_deductions AS t3 ON t1.bout_id = t3.bout_id
        AND t2.fighter_1_id = t3.fighter_id
        AND t1.round = CAST(t3.round_number AS TEXT)
        LEFT JOIN mmadecisions_deductions AS t4 ON t1.bout_id = t4.bout_id
        AND t2.fighter_2_id = t4.fighter_id
        AND t1.round = CAST(t4.round_number AS TEXT)
    WHERE t1.round = '1'
        AND t1.fighter_1_score > 1
        AND t1.fighter_2_score > 1
),
cte9 AS (
    SELECT bout_id,
        fighter_1_id,
        fighter_2_id,
        SUM(fighter_1_r1_judge_score) AS fighter_1_r1_judge_score_sum,
        SUM(fighter_2_r1_judge_score) AS fighter_2_r1_judge_score_sum,
        COUNT(*) AS judge_num_r1
    FROM r1_judge_scores
    GROUP BY bout_id,
        fighter_1_id,
        fighter_2_id
),
r2_judge_scores AS (
    SELECT t1.bout_id,
        fighter_1_id,
        fighter_2_id,
        fighter_1_score + IFNULL(t3.points_deducted, 0) AS fighter_1_r2_judge_score,
        fighter_2_score + IFNULL(t4.points_deducted, 0) AS fighter_2_r2_judge_score
    FROM mmadecisions_judge_scores AS t1
        LEFT JOIN mmadecisions_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN mmadecisions_deductions AS t3 ON t1.bout_id = t3.bout_id
        AND t2.fighter_1_id = t3.fighter_id
        AND t1.round = CAST(t3.round_number AS TEXT)
        LEFT JOIN mmadecisions_deductions AS t4 ON t1.bout_id = t4.bout_id
        AND t2.fighter_2_id = t4.fighter_id
        AND t1.round = CAST(t4.round_number AS TEXT)
    WHERE t1.round = '2'
        AND t1.fighter_1_score > 1
        AND t1.fighter_2_score > 1
),
cte10 AS (
    SELECT bout_id,
        fighter_1_id,
        fighter_2_id,
        SUM(fighter_1_r2_judge_score) AS fighter_1_r2_judge_score_sum,
        SUM(fighter_2_r2_judge_score) AS fighter_2_r2_judge_score_sum,
        COUNT(*) AS judge_num_r2
    FROM r2_judge_scores
    GROUP BY bout_id,
        fighter_1_id,
        fighter_2_id
),
r3_judge_scores AS (
    SELECT t1.bout_id,
        fighter_1_id,
        fighter_2_id,
        fighter_1_score + IFNULL(t3.points_deducted, 0) AS fighter_1_r3_judge_score,
        fighter_2_score + IFNULL(t4.points_deducted, 0) AS fighter_2_r3_judge_score
    FROM mmadecisions_judge_scores AS t1
        LEFT JOIN mmadecisions_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN mmadecisions_deductions AS t3 ON t1.bout_id = t3.bout_id
        AND t2.fighter_1_id = t3.fighter_id
        AND t1.round = CAST(t3.round_number AS TEXT)
        LEFT JOIN mmadecisions_deductions AS t4 ON t1.bout_id = t4.bout_id
        AND t2.fighter_2_id = t4.fighter_id
        AND t1.round = CAST(t4.round_number AS TEXT)
    WHERE t1.round = '3'
        AND t1.fighter_1_score > 1
        AND t1.fighter_2_score > 1
),
cte11 AS (
    SELECT bout_id,
        fighter_1_id,
        fighter_2_id,
        SUM(fighter_1_r3_judge_score) AS fighter_1_r3_judge_score_sum,
        SUM(fighter_2_r3_judge_score) AS fighter_2_r3_judge_score_sum,
        COUNT(*) AS judge_num_r3
    FROM r3_judge_scores
    GROUP BY bout_id,
        fighter_1_id,
        fighter_2_id
),
cte12 AS (
    SELECT fighter_1_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_2_id AS opp_mmadecisions_fighter_id,
        fighter_1_r1_judge_score_sum AS r1_judge_score_sum,
        fighter_2_r1_judge_score_sum AS opp_r1_judge_score_sum,
        judge_num_r1
    FROM cte9
    UNION
    SELECT fighter_2_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_1_id AS opp_mmadecisions_fighter_id,
        fighter_2_r1_judge_score_sum AS r1_judge_score_sum,
        fighter_1_r1_judge_score_sum AS opp_r1_judge_score_sum,
        judge_num_r1
    FROM cte9
),
cte13 AS (
    SELECT fighter_1_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_2_id AS opp_mmadecisions_fighter_id,
        fighter_1_r2_judge_score_sum AS r2_judge_score_sum,
        fighter_2_r2_judge_score_sum AS opp_r2_judge_score_sum,
        judge_num_r2
    FROM cte10
    UNION
    SELECT fighter_2_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_1_id AS opp_mmadecisions_fighter_id,
        fighter_2_r2_judge_score_sum AS r2_judge_score_sum,
        fighter_1_r2_judge_score_sum AS opp_r2_judge_score_sum,
        judge_num_r2
    FROM cte10
),
cte14 AS (
    SELECT fighter_1_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_2_id AS opp_mmadecisions_fighter_id,
        fighter_1_r3_judge_score_sum AS r3_judge_score_sum,
        fighter_2_r3_judge_score_sum AS opp_r3_judge_score_sum,
        judge_num_r3
    FROM cte11
    UNION
    SELECT fighter_2_id AS mmadecisions_fighter_id,
        bout_id AS mmadecisions_bout_id,
        fighter_1_id AS opp_mmadecisions_fighter_id,
        fighter_2_r3_judge_score_sum AS r3_judge_score_sum,
        fighter_1_r3_judge_score_sum AS opp_r3_judge_score_sum,
        judge_num_r3
    FROM cte11
),
cte8 AS (
    SELECT t1.ufcstats_fighter_id,
        t1.mmadecisions_fighter_id,
        t1.ufcstats_bout_id,
        t1.mmadecisions_bout_id,
        t1.opp_mmadecisions_fighter_id,
        t1.rn,
        t2.total_judge_score_sum,
        t2.opp_total_judge_score_sum,
        t2.judge_num_rounds_sum,
        t3.total_media_score_sum,
        t3.opp_total_media_score_sum,
        t3.media_num_rounds_sum,
        t4.r1_judge_score_sum,
        t4.opp_r1_judge_score_sum,
        t4.judge_num_r1,
        t5.r2_judge_score_sum,
        t5.opp_r2_judge_score_sum,
        t5.judge_num_r2,
        t6.r3_judge_score_sum,
        t6.opp_r3_judge_score_sum,
        t6.judge_num_r3
    FROM cte3 AS t1
        LEFT JOIN cte5 AS t2 ON t1.mmadecisions_bout_id = t2.mmadecisions_bout_id
        AND t1.mmadecisions_fighter_id = t2.mmadecisions_fighter_id
        AND t1.opp_mmadecisions_fighter_id = t2.opp_mmadecisions_fighter_id
        LEFT JOIN cte7 AS t3 ON t1.mmadecisions_bout_id = t3.mmadecisions_bout_id
        AND t1.mmadecisions_fighter_id = t3.mmadecisions_fighter_id
        AND t1.opp_mmadecisions_fighter_id = t3.opp_mmadecisions_fighter_id
        LEFT JOIN cte12 AS t4 ON t1.mmadecisions_bout_id = t4.mmadecisions_bout_id
        AND t1.mmadecisions_fighter_id = t4.mmadecisions_fighter_id
        AND t1.opp_mmadecisions_fighter_id = t4.opp_mmadecisions_fighter_id
        LEFT JOIN cte13 AS t5 ON t1.mmadecisions_bout_id = t5.mmadecisions_bout_id
        AND t1.mmadecisions_fighter_id = t5.mmadecisions_fighter_id
        AND t1.opp_mmadecisions_fighter_id = t5.opp_mmadecisions_fighter_id
        LEFT JOIN cte14 AS t6 ON t1.mmadecisions_bout_id = t6.mmadecisions_bout_id
        AND t1.mmadecisions_fighter_id = t6.mmadecisions_fighter_id
        AND t1.opp_mmadecisions_fighter_id = t6.opp_mmadecisions_fighter_id
),
cte15 AS (
    SELECT ufcstats_fighter_id,
        mmadecisions_fighter_id,
        ufcstats_bout_id,
        mmadecisions_bout_id,
        rn,
        SUM(total_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_judge_score_sum,
        SUM(total_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_total_judge_score_sum,
        SUM(opp_total_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS opp_total_judge_score_sum,
        SUM(opp_total_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_opp_total_judge_score_sum,
        SUM(judge_num_rounds_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS judge_num_rounds_sum,
        SUM(judge_num_rounds_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_judge_num_rounds_sum,
        SUM(total_media_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_media_score_sum,
        SUM(total_media_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_total_media_score_sum,
        SUM(opp_total_media_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS opp_total_media_score_sum,
        SUM(opp_total_media_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_opp_total_media_score_sum,
        SUM(media_num_rounds_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS media_num_rounds_sum,
        SUM(media_num_rounds_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_media_num_rounds_sum,
        SUM(r1_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS r1_judge_score_sum,
        SUM(r1_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_r1_judge_score_sum,
        SUM(opp_r1_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS opp_r1_judge_score_sum,
        SUM(opp_r1_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_opp_r1_judge_score_sum,
        SUM(judge_num_r1) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS judge_num_r1,
        SUM(judge_num_r1) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_judge_num_r1,
        SUM(r2_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS r2_judge_score_sum,
        SUm(r2_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_r2_judge_score_sum,
        SUM(opp_r2_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS opp_r2_judge_score_sum,
        SUM(opp_r2_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_opp_r2_judge_score_sum,
        SUM(judge_num_r2) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS judge_num_r2,
        SUM(judge_num_r2) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_judge_num_r2,
        SUM(r3_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS r3_judge_score_sum,
        SUM(r3_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_r3_judge_score_sum,
        SUM(opp_r3_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS opp_r3_judge_score_sum,
        SUM(opp_r3_judge_score_sum) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_opp_r3_judge_score_sum,
        SUM(judge_num_r3) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS judge_num_r3,
        SUM(judge_num_r3) OVER (
            PARTITION BY mmadecisions_fighter_id
            ORDER BY rn ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS prev_judge_num_r3
    FROM cte8
),
cte16 AS (
    SELECT fighter_id,
        t1.'order',
        bout_id,
        opponent_id,
        total_judge_score_sum,
        prev_total_judge_score_sum,
        opp_total_judge_score_sum,
        prev_opp_total_judge_score_sum,
        judge_num_rounds_sum,
        prev_judge_num_rounds_sum,
        total_media_score_sum,
        prev_total_media_score_sum,
        opp_total_media_score_sum,
        prev_opp_total_media_score_sum,
        media_num_rounds_sum,
        prev_media_num_rounds_sum,
        r1_judge_score_sum,
        prev_r1_judge_score_sum,
        opp_r1_judge_score_sum,
        prev_opp_r1_judge_score_sum,
        judge_num_r1,
        prev_judge_num_r1,
        r2_judge_score_sum,
        prev_r2_judge_score_sum,
        opp_r2_judge_score_sum,
        prev_opp_r2_judge_score_sum,
        judge_num_r2,
        prev_judge_num_r2,
        r3_judge_score_sum,
        prev_r3_judge_score_sum,
        opp_r3_judge_score_sum,
        prev_opp_r3_judge_score_sum,
        judge_num_r3,
        prev_judge_num_r3
    FROM ufcstats_fighter_histories AS t1
        LEFT JOIN cte15 AS t2 ON t1.fighter_id = t2.ufcstats_fighter_id
        AND t1.bout_id = t2.ufcstats_bout_id
),
cte17 AS (
    SELECT fighter_id,
        t1.'order',
        bout_id,
        total_judge_score_sum,
        COALESCE(
            total_judge_score_sum,
            FIRST_VALUE(total_judge_score_sum) OVER (
                PARTITION BY fighter_id,
                total_judge_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_total_judge_score_sum,
        prev_total_judge_score_sum,
        opp_total_judge_score_sum,
        COALESCE(
            opp_total_judge_score_sum,
            FIRST_VALUE(opp_total_judge_score_sum) OVER (
                PARTITION BY fighter_id,
                opp_total_judge_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_opp_total_judge_score_sum,
        prev_opp_total_judge_score_sum,
        judge_num_rounds_sum,
        COALESCE(
            judge_num_rounds_sum,
            FIRST_VALUE(judge_num_rounds_sum) OVER (
                PARTITION BY fighter_id,
                judge_num_rounds_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_judge_num_rounds_sum,
        prev_judge_num_rounds_sum,
        total_media_score_sum,
        COALESCE(
            total_media_score_sum,
            FIRST_VALUE(total_media_score_sum) OVER (
                PARTITION BY fighter_id,
                total_media_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_total_media_score_sum,
        prev_total_media_score_sum,
        opp_total_media_score_sum,
        COALESCE(
            opp_total_media_score_sum,
            FIRST_VALUE(opp_total_media_score_sum) OVER (
                PARTITION BY fighter_id,
                opp_total_media_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_opp_total_media_score_sum,
        prev_opp_total_media_score_sum,
        media_num_rounds_sum,
        COALESCE(
            media_num_rounds_sum,
            FIRST_VALUE(media_num_rounds_sum) OVER (
                PARTITION BY fighter_id,
                media_num_rounds_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_media_num_rounds_sum,
        prev_media_num_rounds_sum,
        r1_judge_score_sum,
        COALESCE(
            r1_judge_score_sum,
            FIRST_VALUE(r1_judge_score_sum) OVER (
                PARTITION BY fighter_id,
                r1_judge_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_r1_judge_score_sum,
        prev_r1_judge_score_sum,
        opp_r1_judge_score_sum,
        COALESCE(
            opp_r1_judge_score_sum,
            FIRST_VALUE(opp_r1_judge_score_sum) OVER (
                PARTITION BY fighter_id,
                opp_r1_judge_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_opp_r1_judge_score_sum,
        prev_opp_r1_judge_score_sum,
        judge_num_r1,
        COALESCE(
            judge_num_r1,
            FIRST_VALUE(judge_num_r1) OVER (
                PARTITION BY fighter_id,
                judge_num_r1_group
                ORDER BY t1.'order'
            )
        ) AS ffill_judge_num_r1,
        prev_judge_num_r1,
        r2_judge_score_sum,
        COALESCE(
            r2_judge_score_sum,
            FIRST_VALUE(r2_judge_score_sum) OVER (
                PARTITION BY fighter_id,
                r2_judge_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_r2_judge_score_sum,
        prev_r2_judge_score_sum,
        opp_r2_judge_score_sum,
        COALESCE(
            opp_r2_judge_score_sum,
            FIRST_VALUE(opp_r2_judge_score_sum) OVER (
                PARTITION BY fighter_id,
                opp_r2_judge_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_opp_r2_judge_score_sum,
        prev_opp_r2_judge_score_sum,
        judge_num_r2,
        COALESCE(
            judge_num_r2,
            FIRST_VALUE(judge_num_r2) OVER (
                PARTITION BY fighter_id,
                judge_num_r2_group
                ORDER BY t1.'order'
            )
        ) AS ffill_judge_num_r2,
        prev_judge_num_r2,
        r3_judge_score_sum,
        COALESCE(
            r3_judge_score_sum,
            FIRST_VALUE(r3_judge_score_sum) OVER (
                PARTITION BY fighter_id,
                r3_judge_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_r3_judge_score_sum,
        prev_r3_judge_score_sum,
        opp_r3_judge_score_sum,
        COALESCE(
            opp_r3_judge_score_sum,
            FIRST_VALUE(opp_r3_judge_score_sum) OVER (
                PARTITION BY fighter_id,
                opp_r3_judge_score_sum_group
                ORDER BY t1.'order'
            )
        ) AS ffill_opp_r3_judge_score_sum,
        prev_opp_r3_judge_score_sum,
        judge_num_r3,
        COALESCE(
            judge_num_r3,
            FIRST_VALUE(judge_num_r3) OVER (
                PARTITION BY fighter_id,
                judge_num_r3_group
                ORDER BY t1.'order'
            )
        ) AS ffill_judge_num_r3,
        prev_judge_num_r3
    FROM (
            SELECT fighter_id,
                t2.'order',
                bout_id,
                total_judge_score_sum,
                COUNT(total_judge_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS total_judge_score_sum_group,
                prev_total_judge_score_sum,
                opp_total_judge_score_sum,
                COUNT(opp_total_judge_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS opp_total_judge_score_sum_group,
                prev_opp_total_judge_score_sum,
                judge_num_rounds_sum,
                COUNT(judge_num_rounds_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS judge_num_rounds_sum_group,
                prev_judge_num_rounds_sum,
                total_media_score_sum,
                COUNT(total_media_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS total_media_score_sum_group,
                prev_total_media_score_sum,
                opp_total_media_score_sum,
                COUNT(opp_total_media_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS opp_total_media_score_sum_group,
                prev_opp_total_media_score_sum,
                media_num_rounds_sum,
                COUNT(media_num_rounds_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS media_num_rounds_sum_group,
                prev_media_num_rounds_sum,
                r1_judge_score_sum,
                COUNT(r1_judge_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS r1_judge_score_sum_group,
                prev_r1_judge_score_sum,
                opp_r1_judge_score_sum,
                COUNT(opp_r1_judge_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS opp_r1_judge_score_sum_group,
                prev_opp_r1_judge_score_sum,
                judge_num_r1,
                COUNT(judge_num_r1) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS judge_num_r1_group,
                prev_judge_num_r1,
                r2_judge_score_sum,
                COUNT(r2_judge_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS r2_judge_score_sum_group,
                prev_r2_judge_score_sum,
                opp_r2_judge_score_sum,
                COUNT(opp_r2_judge_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS opp_r2_judge_score_sum_group,
                prev_opp_r2_judge_score_sum,
                judge_num_r2,
                COUNT(judge_num_r2) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS judge_num_r2_group,
                prev_judge_num_r2,
                r3_judge_score_sum,
                COUNT(r3_judge_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS r3_judge_score_sum_group,
                prev_r3_judge_score_sum,
                opp_r3_judge_score_sum,
                COUNT(opp_r3_judge_score_sum) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS opp_r3_judge_score_sum_group,
                prev_opp_r3_judge_score_sum,
                judge_num_r3,
                COUNT(judge_num_r3) OVER (
                    PARTITION BY fighter_id
                    ORDER BY t2.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
                ) AS judge_num_r3_group,
                prev_judge_num_r3
            FROM cte16 AS t2
        ) t1
),
cte18 AS (
    SELECT fighter_id,
        bout_id,
        CASE
            WHEN total_judge_score_sum IS NOT NULL THEN prev_total_judge_score_sum
            ELSE ffill_total_judge_score_sum
        END AS total_judge_score_sum,
        CASE
            WHEN opp_total_judge_score_sum IS NOT NULL THEN prev_opp_total_judge_score_sum
            ELSE ffill_opp_total_judge_score_sum
        END AS opp_total_judge_score_sum,
        CASE
            WHEN judge_num_rounds_sum IS NOT NULL THEN prev_judge_num_rounds_sum
            ELSE ffill_judge_num_rounds_sum
        END AS judge_num_rounds_sum,
        CASE
            WHEN total_media_score_sum IS NOT NULL THEN prev_total_media_score_sum
            ELSE ffill_total_media_score_sum
        END AS total_media_score_sum,
        CASE
            WHEN opp_total_media_score_sum IS NOT NULL THEN prev_opp_total_media_score_sum
            ELSE ffill_opp_total_media_score_sum
        END AS opp_total_media_score_sum,
        CASE
            WHEN media_num_rounds_sum IS NOT NULL THEN prev_media_num_rounds_sum
            ELSE ffill_media_num_rounds_sum
        END AS media_num_rounds_sum,
        CASE
            WHEN r1_judge_score_sum IS NOT NULL THEN prev_r1_judge_score_sum
            ELSE ffill_r1_judge_score_sum
        END AS r1_judge_score_sum,
        CASE
            WHEN opp_r1_judge_score_sum IS NOT NULL THEN prev_opp_r1_judge_score_sum
            ELSE ffill_opp_r1_judge_score_sum
        END AS opp_r1_judge_score_sum,
        CASE
            WHEN judge_num_r1 IS NOT NULL THEN prev_judge_num_r1
            ELSE ffill_judge_num_r1
        END AS judge_num_r1,
        CASE
            WHEN r2_judge_score_sum IS NOT NULL THEN prev_r2_judge_score_sum
            ELSE ffill_r2_judge_score_sum
        END AS r2_judge_score_sum,
        CASE
            WHEN opp_r2_judge_score_sum IS NOT NULL THEN prev_opp_r2_judge_score_sum
            ELSE ffill_opp_r2_judge_score_sum
        END AS opp_r2_judge_score_sum,
        CASE
            WHEN judge_num_r2 IS NOT NULL THEN prev_judge_num_r2
            ELSE ffill_judge_num_r2
        END AS judge_num_r2,
        CASE
            WHEN r3_judge_score_sum IS NOT NULL THEN prev_r3_judge_score_sum
            ELSE ffill_r3_judge_score_sum
        END AS r3_judge_score_sum,
        CASE
            WHEN opp_r3_judge_score_sum IS NOT NULL THEN prev_opp_r3_judge_score_sum
            ELSE ffill_opp_r3_judge_score_sum
        END AS opp_r3_judge_score_sum,
        CASE
            WHEN judge_num_r3 IS NOT NULL THEN prev_judge_num_r3
            ELSE ffill_judge_num_r3
        END AS judge_num_r3
    FROM cte17
),
cte19 AS (
    SELECT fighter_id,
        bout_id,
        1.0 * total_judge_score_sum / judge_num_rounds_sum AS avg_judge_score_per_round,
        1.0 * opp_total_judge_score_sum / judge_num_rounds_sum AS avg_opp_judge_score_per_round,
        1.0 * total_media_score_sum / media_num_rounds_sum AS avg_media_score_per_round,
        1.0 * opp_total_media_score_sum / media_num_rounds_sum AS avg_opp_media_score_per_round,
        1.0 * r1_judge_score_sum / judge_num_r1 AS avg_judge_score_round_1,
        1.0 * opp_r1_judge_score_sum / judge_num_r1 AS avg_opp_judge_score_round_1,
        1.0 * r2_judge_score_sum / judge_num_r2 AS avg_judge_score_round_2,
        1.0 * opp_r2_judge_score_sum / judge_num_r2 AS avg_opp_judge_score_round_2,
        1.0 * r3_judge_score_sum / judge_num_r3 AS avg_judge_score_round_3,
        1.0 * opp_r3_judge_score_sum / judge_num_r3 AS avg_opp_judge_score_round_3
    FROM cte18
)
SELECT id,
    t2.avg_judge_score_per_round - t3.avg_judge_score_per_round AS avg_judge_score_per_round_diff,
    t2.avg_judge_score_per_round / t3.avg_judge_score_per_round AS avg_judge_score_per_round_ratio,
    t2.avg_opp_judge_score_per_round - t3.avg_opp_judge_score_per_round AS avg_opp_judge_score_per_round_diff,
    t2.avg_opp_judge_score_per_round / t3.avg_opp_judge_score_per_round AS avg_opp_judge_score_per_round_ratio,
    (
        t2.avg_judge_score_per_round - t2.avg_opp_judge_score_per_round
    ) - (
        t3.avg_judge_score_per_round - t3.avg_opp_judge_score_per_round
    ) AS avg_judge_score_per_round_adv_diff,
    (
        t2.avg_judge_score_per_round - t2.avg_opp_judge_score_per_round
    ) / (
        t3.avg_judge_score_per_round - t3.avg_opp_judge_score_per_round
    ) AS avg_judge_score_per_round_adv_ratio,
    t2.avg_media_score_per_round - t3.avg_media_score_per_round AS avg_media_score_per_round_diff,
    t2.avg_media_score_per_round / t3.avg_media_score_per_round AS avg_media_score_per_round_ratio,
    t2.avg_opp_media_score_per_round - t3.avg_opp_media_score_per_round AS avg_opp_media_score_per_round_diff,
    t2.avg_opp_media_score_per_round / t3.avg_opp_media_score_per_round AS avg_opp_media_score_per_round_ratio,
    (
        t2.avg_media_score_per_round - t2.avg_opp_media_score_per_round
    ) - (
        t3.avg_media_score_per_round - t3.avg_opp_media_score_per_round
    ) AS avg_media_score_per_round_adv_diff,
    (
        t2.avg_media_score_per_round - t2.avg_opp_media_score_per_round
    ) / (
        t3.avg_media_score_per_round - t3.avg_opp_media_score_per_round
    ) AS avg_media_score_per_round_adv_ratio,
    t2.avg_judge_score_round_1 - t3.avg_judge_score_round_1 AS avg_judge_score_round_1_diff,
    t2.avg_judge_score_round_1 / t3.avg_judge_score_round_1 AS avg_judge_score_round_1_ratio,
    t2.avg_opp_judge_score_round_1 - t3.avg_opp_judge_score_round_1 AS avg_opp_judge_score_round_1_diff,
    t2.avg_opp_judge_score_round_1 / t3.avg_opp_judge_score_round_1 AS avg_opp_judge_score_round_1_ratio,
    (
        t2.avg_judge_score_round_1 - t2.avg_opp_judge_score_round_1
    ) - (
        t3.avg_judge_score_round_1 - t3.avg_opp_judge_score_round_1
    ) AS avg_judge_score_round_1_adv_diff,
    (
        t2.avg_judge_score_round_1 - t2.avg_opp_judge_score_round_1
    ) / (
        t3.avg_judge_score_round_1 - t3.avg_opp_judge_score_round_1
    ) AS avg_judge_score_round_1_adv_ratio,
    t2.avg_judge_score_round_2 - t3.avg_judge_score_round_2 AS avg_judge_score_round_2_diff,
    t2.avg_judge_score_round_2 / t3.avg_judge_score_round_2 AS avg_judge_score_round_2_ratio,
    t2.avg_opp_judge_score_round_2 - t3.avg_opp_judge_score_round_2 AS avg_opp_judge_score_round_2_diff,
    t2.avg_opp_judge_score_round_2 / t3.avg_opp_judge_score_round_2 AS avg_opp_judge_score_round_2_ratio,
    (
        t2.avg_judge_score_round_2 - t2.avg_opp_judge_score_round_2
    ) - (
        t3.avg_judge_score_round_2 - t3.avg_opp_judge_score_round_2
    ) AS avg_judge_score_round_2_adv_diff,
    (
        t2.avg_judge_score_round_2 - t2.avg_opp_judge_score_round_2
    ) / (
        t3.avg_judge_score_round_2 - t3.avg_opp_judge_score_round_2
    ) AS avg_judge_score_round_2_adv_ratio,
    t2.avg_judge_score_round_3 - t3.avg_judge_score_round_3 AS avg_judge_score_round_3_diff,
    t2.avg_judge_score_round_3 / t3.avg_judge_score_round_3 AS avg_judge_score_round_3_ratio,
    t2.avg_opp_judge_score_round_3 - t3.avg_opp_judge_score_round_3 AS avg_opp_judge_score_round_3_diff,
    t2.avg_opp_judge_score_round_3 / t3.avg_opp_judge_score_round_3 AS avg_opp_judge_score_round_3_ratio,
    (
        t2.avg_judge_score_round_3 - t2.avg_opp_judge_score_round_3
    ) - (
        t3.avg_judge_score_round_3 - t3.avg_opp_judge_score_round_3
    ) AS avg_judge_score_round_3_adv_diff,
    (
        t2.avg_judge_score_round_3 - t2.avg_opp_judge_score_round_3
    ) / (
        t3.avg_judge_score_round_3 - t3.avg_opp_judge_score_round_3
    ) AS avg_judge_score_round_3_adv_ratio,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte19 AS t2 ON t1.red_fighter_id = t2.fighter_id
    AND t1.id = t2.bout_id
    LEFT JOIN cte19 AS t3 ON t1.blue_fighter_id = t3.fighter_id
    AND t1.id = t3.bout_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );