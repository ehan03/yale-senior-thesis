WITH dob_height_imputed AS (
    SELECT t1.id,
        CASE
            WHEN t1.height_inches IS NOT NULL THEN t1.height_inches
            WHEN t3.height_inches IS NOT NULL THEN t3.height_inches
            WHEN t4.height_inches IS NOT NULL THEN t4.height_inches
            WHEN t5.height_inches IS NOT NULL THEN t5.height_inches
            WHEN t6.height_centimeters IS NOT NULL THEN t6.height_centimeters / 2.54
            WHEN t7.height_inches IS NOT NULL THEN t7.height_inches
            ELSE t8.height_inches
        END AS height_inches,
        CASE
            WHEN t1.date_of_birth IS NOT NULL THEN t1.date_of_birth
            WHEN t3.date_of_birth IS NOT NULL THEN t3.date_of_birth
            WHEN t4.date_of_birth IS NOT NULL THEN t4.date_of_birth
            WHEN t5.date_of_birth IS NOT NULL THEN t5.date_of_birth
            WHEN t6.date_of_birth IS NOT NULL THEN t6.date_of_birth
            ELSE t7.date_of_birth
        END AS date_of_birth
    FROM sherdog_fighters AS t1
        LEFT JOIN fighter_mapping AS t2 ON t1.id = t2.sherdog_id
        LEFT JOIN ufcstats_fighters AS t3 ON t2.ufcstats_id = t3.id
        LEFT JOIN tapology_fighters AS t4 ON t2.tapology_id = t4.id
        LEFT JOIN espn_fighters AS t5 ON t2.espn_id = t5.id
        LEFT JOIN fightoddsio_fighters AS t6 ON t2.fightoddsio_id = t6.id
        LEFT JOIN mmadecisions_fighters AS t7 ON t2.mmadecisions_id = t7.id
        LEFT JOIN betmma_fighters AS t8 ON t2.betmma_id = t8.id
),
cte1 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        date,
        opponent_id,
        t2.height_inches,
        JULIANDAY(t1.date) - JULIANDAY(t2.date_of_birth) AS age_days,
        t3.height_inches AS opp_height_inches,
        JULIANDAY(t1.date) - JULIANDAY(t3.date_of_birth) AS opp_age_days
    FROM sherdog_fighter_histories AS t1
        LEFT JOIN dob_height_imputed AS t2 ON t1.fighter_id = t2.id
        LEFT JOIN dob_height_imputed AS t3 ON t1.opponent_id = t3.id
),
cte2 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        date,
        opponent_id,
        height_inches,
        age_days,
        AVG(age_days) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_age_days,
        AVG(opp_height_inches) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_height_inches,
        AVG(height_inches - opp_height_inches) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_height_diff,
        AVG(opp_age_days) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_age_days,
        AVG(age_days - opp_age_days) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_age_diff,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id,
            date,
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
        t1.height_inches,
        t1.age_days,
        t1.avg_age_days,
        t1.avg_opp_height_inches,
        t1.avg_height_diff,
        t1.avg_opp_age_days,
        t1.avg_age_diff,
        AVG(t1.avg_age_days - t2.avg_age_days) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_age_days_diff,
        AVG(
            t1.avg_opp_height_inches - t2.avg_opp_height_inches
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_height_inches_diff,
        AVG(t1.avg_height_diff - t2.avg_height_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_height_diff_diff,
        AVG(t1.avg_opp_age_days - t2.avg_opp_age_days) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_age_days_diff,
        AVG(t1.avg_age_diff - t2.avg_age_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_age_diff_diff
    FROM cte2 AS t1
        LEFT JOIN cte2 AS t2 ON t1.fighter_id = t2.opponent_id
        AND t1.opponent_id = t2.fighter_id
        AND t1.temp_rn = t2.temp_rn
        AND t1.date = t2.date
),
cte4 AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t1.'order',
        t4.ufcstats_id AS event_id,
        t3.ufcstats_id AS opponent_id,
        t1.height_inches,
        t1.age_days,
        t1.avg_age_days,
        t1.avg_opp_height_inches,
        t1.avg_height_diff,
        t1.avg_opp_age_days,
        t1.avg_age_diff,
        t1.avg_avg_age_days_diff,
        t1.avg_avg_opp_height_inches_diff,
        t1.avg_avg_height_diff_diff,
        t1.avg_avg_opp_age_days_diff,
        t1.avg_avg_age_diff_diff
    FROM cte3 AS t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.sherdog_id
        INNER JOIN fighter_mapping AS t3 ON t1.opponent_id = t3.sherdog_id
        INNER JOIN event_mapping AS t4 ON t1.event_id = t4.sherdog_id
),
height_dob_feats AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        opponent_id,
        height_inches,
        age_days,
        avg_age_days,
        avg_opp_height_inches,
        avg_height_diff,
        avg_opp_age_days,
        avg_age_diff,
        avg_avg_age_days_diff,
        avg_avg_opp_height_inches_diff,
        avg_avg_height_diff_diff,
        avg_avg_opp_age_days_diff,
        avg_avg_age_diff_diff
    FROM cte4 AS t1
),
reach_imputed AS (
    SELECT t1.id,
        CASE
            WHEN t1.reach_inches IS NOT NULL THEN t1.reach_inches
            WHEN t3.reach_inches IS NOT NULL THEN t3.reach_inches
            WHEN t4.reach_inches IS NOT NULL THEN t4.reach_inches
            ELSE t5.reach_inches
        END AS reach_inches,
        t4.leg_reach_inches
    FROM ufcstats_fighters AS t1
        LEFT JOIN fighter_mapping AS t2 ON t1.id = t2.ufcstats_id
        LEFT JOIN tapology_fighters AS t3 ON t2.tapology_id = t3.id
        LEFT JOIN fightoddsio_fighters AS t4 ON t2.fightoddsio_id = t4.id
        LEFT JOIN mmadecisions_fighters AS t5 ON t2.mmadecisions_id = t5.id
),
cte5 AS (
    SELECT t1.fighter_id,
        t1.'order',
        bout_id,
        opponent_id,
        t2.reach_inches,
        t2.leg_reach_inches,
        t3.reach_inches AS opp_reach_inches,
        t3.leg_reach_inches AS opp_leg_reach_inches
    FROM ufcstats_fighter_histories AS t1
        LEFT JOIN reach_imputed AS t2 ON t1.fighter_id = t2.id
        LEFT JOIN reach_imputed AS t3 ON t1.opponent_id = t3.id
),
cte6 AS (
    SELECT t1.fighter_id,
        t1.'order',
        bout_id,
        opponent_id,
        reach_inches,
        leg_reach_inches,
        AVG(opp_reach_inches) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_reach_inches,
        AVG(reach_inches - opp_reach_inches) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_reach_diff,
        AVG(opp_leg_reach_inches) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_leg_reach_inches,
        AVG(leg_reach_inches - opp_leg_reach_inches) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_leg_reach_diff
    FROM cte5 AS t1
),
cte7 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.opponent_id,
        t1.reach_inches,
        t1.leg_reach_inches,
        t1.avg_opp_reach_inches,
        t1.avg_reach_diff,
        t1.avg_opp_leg_reach_inches,
        t1.avg_leg_reach_diff,
        AVG(
            t1.avg_opp_reach_inches - t2.avg_opp_reach_inches
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_reach_inches_diff,
        AVG(t1.avg_reach_diff - t2.avg_reach_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_reach_diff_diff,
        AVG(
            t1.avg_opp_leg_reach_inches - t2.avg_opp_leg_reach_inches
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_leg_reach_inches_diff,
        AVG(t1.avg_leg_reach_diff - t2.avg_leg_reach_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_leg_reach_diff_diff
    FROM cte6 AS t1
        LEFT JOIN cte6 AS t2 ON t1.fighter_id = t2.opponent_id
        AND t1.opponent_id = t2.fighter_id
        AND t1.bout_id = t2.bout_id
),
cte8 AS (
    SELECT t1.*
    FROM cte7 AS t1
        LEFT JOIN ufcstats_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN ufcstats_events AS t3 ON t2.event_id = t3.id
    WHERE t3.is_ufc_event = 1
),
reach_feats AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY 'order'
        ) AS ufc_order,
        bout_id,
        opponent_id,
        reach_inches,
        leg_reach_inches,
        avg_opp_reach_inches,
        avg_reach_diff,
        avg_opp_leg_reach_inches,
        avg_leg_reach_diff,
        avg_avg_opp_reach_inches_diff,
        avg_avg_reach_diff_diff,
        avg_avg_opp_leg_reach_inches_diff,
        avg_avg_leg_reach_diff_diff
    FROM cte8
),
weight_imputed AS (
    SELECT fighter_1_id AS fighter_id,
        id AS bout_id,
        fighter_1_weight_lbs AS weight_lbs
    FROM tapology_bouts
    UNION
    SELECT fighter_2_id AS fighter_id,
        id AS bout_id,
        fighter_2_weight_lbs AS weight_lbs
    FROM tapology_bouts
),
cte9 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        bout_id_integer,
        opponent_id,
        CASE
            WHEN t2.weight_lbs IS NOT NULL THEN t2.weight_lbs
            ELSE t1.weigh_in_result_lbs
        END AS weight_lbs
    FROM tapology_fighter_histories AS t1
        LEFT JOIN weight_imputed AS t2 ON t1.bout_id = t2.bout_id
        AND t1.fighter_id = t2.fighter_id
),
cte10 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.bout_id_integer,
        t1.opponent_id,
        t1.weight_lbs,
        AVG(t1.weight_lbs) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_weight_lbs,
        t1.weight_lbs - LAG(t1.weight_lbs) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
        ) AS weight_lbs_change,
        AVG(t2.weight_lbs) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_weight_lbs,
        t2.weight_lbs - LAG(t2.weight_lbs) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
        ) AS opp_weight_lbs_change,
        AVG(t1.weight_lbs - t2.weight_lbs) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_weight_lbs_diff
    FROM cte9 AS t1
        LEFT JOIN cte9 AS t2 ON t1.fighter_id = t2.opponent_id
        AND t1.opponent_id = t2.fighter_id
        AND t1.bout_id_integer = t2.bout_id_integer
),
cte11 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.bout_id_integer,
        t1.opponent_id,
        t1.weight_lbs,
        t1.avg_weight_lbs,
        t1.weight_lbs_change,
        AVG(t1.weight_lbs_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_weight_lbs_change,
        avg_opp_weight_lbs,
        opp_weight_lbs_change,
        AVG(opp_weight_lbs_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_weight_lbs_change,
        avg_weight_lbs_diff
    FROM cte10 AS t1
),
cte12 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.bout_id_integer,
        t1.opponent_id,
        t1.weight_lbs,
        t1.avg_weight_lbs,
        t1.avg_weight_lbs_change,
        t1.avg_opp_weight_lbs,
        t1.opp_weight_lbs_change,
        t1.avg_opp_weight_lbs_change,
        t1.avg_weight_lbs_diff,
        AVG(t1.avg_weight_lbs - t2.avg_weight_lbs) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_weight_lbs_diff,
        AVG(
            t1.avg_weight_lbs_change - t2.avg_weight_lbs_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_weight_lbs_change_diff,
        AVG(t1.avg_opp_weight_lbs - t2.avg_opp_weight_lbs) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_weight_lbs_diff,
        AVG(
            t1.opp_weight_lbs_change - t2.opp_weight_lbs_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_weight_lbs_change_diff,
        AVG(
            t1.avg_opp_weight_lbs_change - t2.avg_opp_weight_lbs_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_weight_lbs_change_diff,
        AVG(t1.avg_weight_lbs_diff - t2.avg_weight_lbs_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_weight_lbs_diff_diff
    FROM cte11 AS t1
        LEFT JOIN cte11 AS t2 ON t1.fighter_id = t2.opponent_id
        AND t1.opponent_id = t2.fighter_id
        AND t1.bout_id_integer = t2.bout_id_integer
),
weight_feats AS (
    SELECT t4.fighter_id,
        t4.bout_id,
        t1.weight_lbs,
        t1.avg_weight_lbs,
        t1.avg_weight_lbs_change,
        t1.avg_opp_weight_lbs,
        t1.opp_weight_lbs_change,
        t1.avg_opp_weight_lbs_change,
        t1.avg_weight_lbs_diff,
        t1.avg_avg_weight_lbs_diff,
        t1.avg_avg_weight_lbs_change_diff,
        t1.avg_avg_opp_weight_lbs_diff,
        t1.avg_opp_avg_weight_lbs_change_diff,
        t1.avg_avg_opp_weight_lbs_change_diff,
        t1.avg_avg_weight_lbs_diff_diff
    FROM cte12 AS t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.tapology_id
        INNER JOIN bout_mapping AS t3 ON t1.bout_id = t3.tapology_id
        INNER JOIN ufcstats_fighter_histories AS t4 ON t2.ufcstats_id = t4.fighter_id
        AND t3.ufcstats_id = t4.bout_id
),
feats_all AS (
    SELECT t1.fighter_id,
        t1.bout_id,
        t2.height_inches,
        t2.age_days,
        t2.avg_age_days,
        t2.avg_opp_height_inches,
        t2.avg_height_diff,
        t2.avg_opp_age_days,
        t2.avg_age_diff,
        t2.avg_avg_age_days_diff,
        t2.avg_avg_opp_height_inches_diff,
        t2.avg_avg_height_diff_diff,
        t2.avg_avg_opp_age_days_diff,
        t2.avg_avg_age_diff_diff,
        t1.reach_inches,
        t1.leg_reach_inches,
        t1.avg_opp_reach_inches,
        t1.avg_reach_diff,
        t1.avg_opp_leg_reach_inches,
        t1.avg_leg_reach_diff,
        t1.avg_avg_opp_reach_inches_diff,
        t1.avg_avg_reach_diff_diff,
        t1.avg_avg_opp_leg_reach_inches_diff,
        t1.avg_avg_leg_reach_diff_diff,
        t3.weight_lbs,
        t3.avg_weight_lbs,
        t3.avg_weight_lbs_change,
        t3.avg_opp_weight_lbs,
        t3.opp_weight_lbs_change,
        t3.avg_opp_weight_lbs_change,
        t3.avg_weight_lbs_diff,
        t3.avg_avg_weight_lbs_diff,
        t3.avg_avg_weight_lbs_change_diff,
        t3.avg_avg_opp_weight_lbs_diff,
        t3.avg_opp_avg_weight_lbs_change_diff,
        t3.avg_avg_opp_weight_lbs_change_diff,
        t3.avg_avg_weight_lbs_diff_diff
    FROM reach_feats AS t1
        INNER JOIN height_dob_feats AS t2 ON t1.fighter_id = t2.fighter_id
        AND t1.ufc_order = t2.ufc_order
        AND t1.opponent_id = t2.opponent_id
        INNER JOIN weight_feats AS t3 ON t1.fighter_id = t3.fighter_id
        AND t1.bout_id = t3.bout_id
)
SELECT id,
    t2.height_inches - t3.height_inches AS height_diff,
    1.0 * t2.height_inches / t3.height_inches AS height_ratio,
    t2.age_days - t3.age_days AS age_days_diff,
    1.0 * t2.age_days / t3.age_days AS age_days_ratio,
    t2.avg_age_days - t3.avg_age_days AS avg_age_days_diff,
    1.0 * t2.avg_age_days / t3.avg_age_days AS avg_age_days_ratio,
    t2.avg_opp_height_inches - t3.avg_opp_height_inches AS opp_height_diff,
    1.0 * t2.avg_opp_height_inches / t3.avg_opp_height_inches AS opp_height_ratio,
    t2.avg_height_diff - t3.avg_height_diff AS avg_height_diff_diff,
    1.0 * t2.avg_height_diff / t3.avg_height_diff AS avg_height_diff_ratio,
    t2.avg_opp_age_days - t3.avg_opp_age_days AS avg_opp_age_days_diff,
    1.0 * t2.avg_opp_age_days / t3.avg_opp_age_days AS avg_opp_age_days_ratio,
    t2.avg_age_diff - t3.avg_age_diff AS avg_age_diff_diff,
    1.0 * t2.avg_age_diff / t3.avg_age_diff AS avg_age_diff_ratio,
    t2.avg_avg_age_days_diff - t3.avg_avg_age_days_diff AS avg_avg_age_days_diff_diff,
    1.0 * t2.avg_avg_age_days_diff / t3.avg_avg_age_days_diff AS avg_avg_age_days_diff_ratio,
    t2.avg_avg_opp_height_inches_diff - t3.avg_avg_opp_height_inches_diff AS avg_avg_opp_height_inches_diff_diff,
    1.0 * t2.avg_avg_opp_height_inches_diff / t3.avg_avg_opp_height_inches_diff AS avg_avg_opp_height_inches_diff_ratio,
    t2.avg_avg_height_diff_diff - t3.avg_avg_height_diff_diff AS avg_avg_height_diff_diff_diff,
    1.0 * t2.avg_avg_height_diff_diff / t3.avg_avg_height_diff_diff AS avg_avg_height_diff_diff_ratio,
    t2.avg_avg_opp_age_days_diff - t3.avg_avg_opp_age_days_diff AS avg_avg_opp_age_days_diff_diff,
    1.0 * t2.avg_avg_opp_age_days_diff / t3.avg_avg_opp_age_days_diff AS avg_avg_opp_age_days_diff_ratio,
    t2.avg_avg_age_diff_diff - t3.avg_avg_age_diff_diff AS avg_avg_age_diff_diff_diff,
    1.0 * t2.avg_avg_age_diff_diff / t3.avg_avg_age_diff_diff AS avg_avg_age_diff_diff_ratio,
    t2.reach_inches - t3.reach_inches AS reach_diff,
    1.0 * t2.reach_inches / t3.reach_inches AS reach_ratio,
    t2.leg_reach_inches - t3.leg_reach_inches AS leg_reach_diff,
    1.0 * t2.leg_reach_inches / t3.leg_reach_inches AS leg_reach_ratio,
    t2.avg_opp_reach_inches - t3.avg_opp_reach_inches AS avg_opp_reach_inches_diff,
    1.0 * t2.avg_opp_reach_inches / t3.avg_opp_reach_inches AS avg_opp_reach_inches_ratio,
    t2.avg_reach_diff - t3.avg_reach_diff AS avg_reach_diff_diff,
    1.0 * t2.avg_reach_diff / t3.avg_reach_diff AS avg_reach_diff_ratio,
    t2.avg_opp_leg_reach_inches - t3.avg_opp_leg_reach_inches AS avg_opp_leg_reach_inches_diff,
    1.0 * t2.avg_opp_leg_reach_inches / t3.avg_opp_leg_reach_inches AS avg_opp_leg_reach_inches_ratio,
    t2.avg_leg_reach_diff - t3.avg_leg_reach_diff AS avg_leg_reach_diff_diff,
    1.0 * t2.avg_leg_reach_diff / t3.avg_leg_reach_diff AS avg_leg_reach_diff_ratio,
    t2.avg_avg_opp_reach_inches_diff - t3.avg_avg_opp_reach_inches_diff AS avg_avg_opp_reach_inches_diff_diff,
    1.0 * t2.avg_avg_opp_reach_inches_diff / t3.avg_avg_opp_reach_inches_diff AS avg_avg_opp_reach_inches_diff_ratio,
    t2.avg_avg_reach_diff_diff - t3.avg_avg_reach_diff_diff AS avg_avg_reach_diff_diff_diff,
    1.0 * t2.avg_avg_reach_diff_diff / t3.avg_avg_reach_diff_diff AS avg_avg_reach_diff_diff_ratio,
    t2.avg_avg_opp_leg_reach_inches_diff - t3.avg_avg_opp_leg_reach_inches_diff AS avg_avg_opp_leg_reach_inches_diff_diff,
    1.0 * t2.avg_avg_opp_leg_reach_inches_diff / t3.avg_avg_opp_leg_reach_inches_diff AS avg_avg_opp_leg_reach_inches_diff_ratio,
    t2.avg_avg_leg_reach_diff_diff - t3.avg_avg_leg_reach_diff_diff AS avg_avg_leg_reach_diff_diff_diff,
    1.0 * t2.avg_avg_leg_reach_diff_diff / t3.avg_avg_leg_reach_diff_diff AS avg_avg_leg_reach_diff_diff_ratio,
    t2.weight_lbs - t3.weight_lbs AS weight_diff,
    1.0 * t2.weight_lbs / t3.weight_lbs AS weight_ratio,
    t2.avg_weight_lbs - t3.avg_weight_lbs AS avg_weight_lbs_diff,
    1.0 * t2.avg_weight_lbs / t3.avg_weight_lbs AS avg_weight_lbs_ratio,
    t2.avg_weight_lbs_change - t3.avg_weight_lbs_change AS avg_weight_lbs_change_diff,
    1.0 * t2.avg_weight_lbs_change / t3.avg_weight_lbs_change AS avg_weight_lbs_change_ratio,
    t2.avg_opp_weight_lbs - t3.avg_opp_weight_lbs AS avg_opp_weight_lbs_diff,
    1.0 * t2.avg_opp_weight_lbs / t3.avg_opp_weight_lbs AS avg_opp_weight_lbs_ratio,
    t2.opp_weight_lbs_change - t3.opp_weight_lbs_change AS opp_weight_lbs_change_diff,
    1.0 * t2.opp_weight_lbs_change / t3.opp_weight_lbs_change AS opp_weight_lbs_change_ratio,
    t2.avg_opp_weight_lbs_change - t3.avg_opp_weight_lbs_change AS avg_opp_weight_lbs_change_diff,
    1.0 * t2.avg_opp_weight_lbs_change / t3.avg_opp_weight_lbs_change AS avg_opp_weight_lbs_change_ratio,
    t2.avg_weight_lbs_diff - t3.avg_weight_lbs_diff AS avg_weight_lbs_diff_diff,
    1.0 * t2.avg_weight_lbs_diff / t3.avg_weight_lbs_diff AS avg_weight_lbs_diff_ratio,
    t2.avg_avg_weight_lbs_diff - t3.avg_avg_weight_lbs_diff AS avg_avg_weight_lbs_diff_diff,
    1.0 * t2.avg_avg_weight_lbs_diff / t3.avg_avg_weight_lbs_diff AS avg_avg_weight_lbs_diff_ratio,
    t2.avg_avg_weight_lbs_change_diff - t3.avg_avg_weight_lbs_change_diff AS avg_avg_weight_lbs_change_diff_diff,
    1.0 * t2.avg_avg_weight_lbs_change_diff / t3.avg_avg_weight_lbs_change_diff AS avg_avg_weight_lbs_change_diff_ratio,
    t2.avg_avg_opp_weight_lbs_diff - t3.avg_avg_opp_weight_lbs_diff AS avg_avg_opp_weight_lbs_diff_diff,
    1.0 * t2.avg_avg_opp_weight_lbs_diff / t3.avg_avg_opp_weight_lbs_diff AS avg_avg_opp_weight_lbs_diff_ratio,
    t2.avg_opp_avg_weight_lbs_change_diff - t3.avg_opp_avg_weight_lbs_change_diff AS avg_opp_avg_weight_lbs_change_diff_diff,
    1.0 * t2.avg_opp_avg_weight_lbs_change_diff / t3.avg_opp_avg_weight_lbs_change_diff AS avg_opp_avg_weight_lbs_change_diff_ratio,
    t2.avg_avg_opp_weight_lbs_change_diff - t3.avg_avg_opp_weight_lbs_change_diff AS avg_avg_opp_weight_lbs_change_diff_diff,
    1.0 * t2.avg_avg_opp_weight_lbs_change_diff / t3.avg_avg_opp_weight_lbs_change_diff AS avg_avg_opp_weight_lbs_change_diff_ratio,
    t2.avg_avg_weight_lbs_diff_diff - t3.avg_avg_weight_lbs_diff_diff AS avg_avg_weight_lbs_diff_diff_diff,
    1.0 * t2.avg_avg_weight_lbs_diff_diff / t3.avg_avg_weight_lbs_diff_diff AS avg_avg_weight_lbs_diff_diff_ratio,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN feats_all AS t2 ON t1.red_fighter_id = t2.fighter_id
    AND t1.id = t2.bout_id
    LEFT JOIN feats_all AS t3 ON t1.blue_fighter_id = t3.fighter_id
    AND t1.id = t3.bout_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );