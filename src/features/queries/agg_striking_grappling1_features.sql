WITH cte1 AS (
    SELECT
        bout_id,
        fighter_id,
        SUM(knockdowns_scored) AS knockdowns_scored,
        SUM(total_strikes_landed) AS total_strikes_landed,
        SUM(total_strikes_attempted) AS total_strikes_attempted,
        SUM(takedowns_landed) AS takedowns_landed,
        SUM(takedowns_attempted) AS takedowns_attempted,
        SUM(submissions_attempted) AS submissions_attempted,
        SUM(reversals_scored) AS reversals_scored,
        SUM(control_time_seconds) AS control_time_seconds,
        SUM(significant_strikes_landed) AS significant_strikes_landed,
        SUM(significant_strikes_attempted) AS significant_strikes_attempted,
        SUM(significant_strikes_head_landed) AS significant_strikes_head_landed,
        SUM(significant_strikes_head_attempted) AS significant_strikes_head_attempted,
        SUM(significant_strikes_body_landed) AS significant_strikes_body_landed,
        SUM(significant_strikes_body_attempted) AS significant_strikes_body_attempted,
        SUM(significant_strikes_leg_landed) AS significant_strikes_leg_landed,
        SUM(significant_strikes_leg_attempted) AS significant_strikes_leg_attempted,
        SUM(significant_strikes_distance_landed) AS significant_strikes_distance_landed,
        SUM(significant_strikes_distance_attempted) AS significant_strikes_distance_attempted,
        SUM(significant_strikes_clinch_landed) AS significant_strikes_clinch_landed,
        SUM(significant_strikes_clinch_attempted) AS significant_strikes_clinch_attempted,
        SUM(significant_strikes_ground_landed) AS significant_strikes_ground_landed,
        SUM(significant_strikes_ground_attempted) AS significant_strikes_ground_attempted
    FROM
        ufcstats_round_stats
    GROUP BY
        bout_id,
        fighter_id
),
cte2 AS (
    SELECT
        id AS bout_id,
        red_fighter_id AS fighter_id,
        CASE
            WHEN red_outcome = 'W' AND outcome_method IN ('KO/TKO', 'TKO - Doctor''s Stoppage') THEN 1
            ELSE 0
        END AS ko_tko_landed,
        CASE
            WHEN red_outcome = 'W' AND outcome_method = 'Submission' THEN 1
            ELSE 0
        END AS submissions_landed
    FROM
        ufcstats_bouts
    UNION
    SELECT
        id AS bout_id,
        blue_fighter_id AS fighter_id,
        CASE
            WHEN blue_outcome = 'W' AND outcome_method IN ('KO/TKO', 'TKO - Doctor''s Stoppage') THEN 1
            ELSE 0
        END AS ko_tko_landed,
        CASE
            WHEN blue_outcome = 'W' AND outcome_method = 'Submission' THEN 1
            ELSE 0
        END AS submissions_landed
    FROM
        ufcstats_bouts
),
totals AS (
    SELECT
        t1.bout_id,
        t1.fighter_id,
        t1.knockdowns_scored,
        t2.ko_tko_landed,
        t1.total_strikes_landed,
        t1.total_strikes_attempted,
        t1.significant_strikes_landed,
        t1.significant_strikes_attempted,
        t1.significant_strikes_head_landed,
        t1.significant_strikes_head_attempted,
        t1.significant_strikes_body_landed,
        t1.significant_strikes_body_attempted,
        t1.significant_strikes_leg_landed,
        t1.significant_strikes_leg_attempted,
        t1.significant_strikes_distance_landed,
        t1.significant_strikes_distance_attempted,
        t1.significant_strikes_clinch_landed,
        t1.significant_strikes_clinch_attempted,
        t1.significant_strikes_ground_landed,
        t1.significant_strikes_ground_attempted,
        t5.significant_strikes_distance_head_landed,
        t5.significant_strikes_distance_head_attempted,
        t5.significant_strikes_distance_body_landed,
        t5.significant_strikes_distance_body_attempted,
        t5.significant_strikes_distance_leg_landed,
        t5.significant_strikes_distance_leg_attempted,
        t5.significant_strikes_clinch_head_landed,
        t5.significant_strikes_clinch_head_attempted,
        t5.significant_strikes_clinch_body_landed,
        t5.significant_strikes_clinch_body_attempted,
        t5.significant_strikes_clinch_leg_landed,
        t5.significant_strikes_clinch_leg_attempted,
        t5.significant_strikes_ground_head_landed,
        t5.significant_strikes_ground_head_attempted,
        t5.significant_strikes_ground_body_landed,
        t5.significant_strikes_ground_body_attempted,
        t5.significant_strikes_ground_leg_landed,
        t5.significant_strikes_ground_leg_attempted,
        t1.takedowns_landed,
        t5.takedowns_slams_landed,
        t1.takedowns_attempted,
        t5.advances,
        t5.advances_to_back,
        t5.advances_to_half_guard,
        t5.advances_to_mount,
        t5.advances_to_side,
        t1.reversals_scored,
        t2.submissions_landed,
        t1.submissions_attempted,
        t1.control_time_seconds,
        t6.total_time_seconds
    FROM
        cte1 AS t1
    LEFT JOIN
        cte2 AS t2 ON t1.bout_id = t2.bout_id AND t1.fighter_id = t2.fighter_id
    LEFT JOIN
        bout_mapping AS t3 ON t1.bout_id = t3.ufcstats_id
    LEFT JOIN
        fighter_mapping AS t4 ON t1.fighter_id = t4.ufcstats_id
    LEFT JOIN
        espn_bout_stats AS t5 ON t3.espn_id = t5.bout_id AND t4.espn_id = t5.fighter_id
    LEFT JOIN
        ufcstats_bouts AS t6 ON t1.bout_id = t6.id
),
cte3 AS (
    SELECT
        t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.opponent_id,
        t2.knockdowns_scored,
        t2.ko_tko_landed,
        t2.total_strikes_landed,
        t2.total_strikes_attempted,
        t2.significant_strikes_landed,
        t2.significant_strikes_attempted,
        t2.significant_strikes_head_landed,
        t2.significant_strikes_head_attempted,
        t2.significant_strikes_body_landed,
        t2.significant_strikes_body_attempted,
        t2.significant_strikes_leg_landed,
        t2.significant_strikes_leg_attempted,
        t2.significant_strikes_distance_landed,
        t2.significant_strikes_distance_attempted,
        t2.significant_strikes_clinch_landed,
        t2.significant_strikes_clinch_attempted,
        t2.significant_strikes_ground_landed,
        t2.significant_strikes_ground_attempted,
        t2.significant_strikes_distance_head_landed,
        t2.significant_strikes_distance_head_attempted,
        t2.significant_strikes_distance_body_landed,
        t2.significant_strikes_distance_body_attempted,
        t2.significant_strikes_distance_leg_landed,
        t2.significant_strikes_distance_leg_attempted,
        t2.significant_strikes_clinch_head_landed,
        t2.significant_strikes_clinch_head_attempted,
        t2.significant_strikes_clinch_body_landed,
        t2.significant_strikes_clinch_body_attempted,
        t2.significant_strikes_clinch_leg_landed,
        t2.significant_strikes_clinch_leg_attempted,
        t2.significant_strikes_ground_head_landed,
        t2.significant_strikes_ground_head_attempted,
        t2.significant_strikes_ground_body_landed,
        t2.significant_strikes_ground_body_attempted,
        t2.significant_strikes_ground_leg_landed,
        t2.significant_strikes_ground_leg_attempted,
        t2.takedowns_landed,
        t2.takedowns_slams_landed,
        t2.takedowns_attempted,
        t2.advances,
        t2.advances_to_back,
        t2.advances_to_half_guard,
        t2.advances_to_mount,
        t2.advances_to_side,
        t2.reversals_scored,
        t2.submissions_landed,
        t2.submissions_attempted,
        t2.control_time_seconds,
        t3.knockdowns_scored AS opp_knockdowns_scored,
        t3.ko_tko_landed AS opp_ko_tko_landed,
        t3.total_strikes_landed AS opp_total_strikes_landed,
        t3.total_strikes_attempted AS opp_total_strikes_attempted,
        t3.significant_strikes_landed AS opp_significant_strikes_landed,
        t3.significant_strikes_attempted AS opp_significant_strikes_attempted,
        t3.significant_strikes_head_landed AS opp_significant_strikes_head_landed,
        t3.significant_strikes_head_attempted AS opp_significant_strikes_head_attempted,
        t3.significant_strikes_body_landed AS opp_significant_strikes_body_landed,
        t3.significant_strikes_body_attempted AS opp_significant_strikes_body_attempted,
        t3.significant_strikes_leg_landed AS opp_significant_strikes_leg_landed,
        t3.significant_strikes_leg_attempted AS opp_significant_strikes_leg_attempted,
        t3.significant_strikes_distance_landed AS opp_significant_strikes_distance_landed,
        t3.significant_strikes_distance_attempted AS opp_significant_strikes_distance_attempted,
        t3.significant_strikes_clinch_landed AS opp_significant_strikes_clinch_landed,
        t3.significant_strikes_clinch_attempted AS opp_significant_strikes_clinch_attempted,
        t3.significant_strikes_ground_landed AS opp_significant_strikes_ground_landed,
        t3.significant_strikes_ground_attempted AS opp_significant_strikes_ground_attempted,
        t3.significant_strikes_distance_head_landed AS opp_significant_strikes_distance_head_landed,
        t3.significant_strikes_distance_head_attempted AS opp_significant_strikes_distance_head_attempted,
        t3.significant_strikes_distance_body_landed AS opp_significant_strikes_distance_body_landed,
        t3.significant_strikes_distance_body_attempted AS opp_significant_strikes_distance_body_attempted,
        t3.significant_strikes_distance_leg_landed AS opp_significant_strikes_distance_leg_landed,
        t3.significant_strikes_distance_leg_attempted AS opp_significant_strikes_distance_leg_attempted,
        t3.significant_strikes_clinch_head_landed AS opp_significant_strikes_clinch_head_landed,
        t3.significant_strikes_clinch_head_attempted AS opp_significant_strikes_clinch_head_attempted,
        t3.significant_strikes_clinch_body_landed AS opp_significant_strikes_clinch_body_landed,
        t3.significant_strikes_clinch_body_attempted AS opp_significant_strikes_clinch_body_attempted,
        t3.significant_strikes_clinch_leg_landed AS opp_significant_strikes_clinch_leg_landed,
        t3.significant_strikes_clinch_leg_attempted AS opp_significant_strikes_clinch_leg_attempted,
        t3.significant_strikes_ground_head_landed AS opp_significant_strikes_ground_head_landed,
        t3.significant_strikes_ground_head_attempted AS opp_significant_strikes_ground_head_attempted,
        t3.significant_strikes_ground_body_landed AS opp_significant_strikes_ground_body_landed,
        t3.significant_strikes_ground_body_attempted AS opp_significant_strikes_ground_body_attempted,
        t3.significant_strikes_ground_leg_landed AS opp_significant_strikes_ground_leg_landed,
        t3.significant_strikes_ground_leg_attempted AS opp_significant_strikes_ground_leg_attempted,
        t3.takedowns_landed AS opp_takedowns_landed,
        t3.takedowns_slams_landed AS opp_takedowns_slams_landed,
        t3.takedowns_attempted AS opp_takedowns_attempted,
        t3.advances AS opp_advances,
        t3.advances_to_back AS opp_advances_to_back,
        t3.advances_to_half_guard AS opp_advances_to_half_guard,
        t3.advances_to_mount AS opp_advances_to_mount,
        t3.advances_to_side AS opp_advances_to_side,
        t3.reversals_scored AS opp_reversals_scored,
        t3.submissions_landed AS opp_submissions_landed,
        t3.submissions_attempted AS opp_submissions_attempted,
        t3.control_time_seconds AS opp_control_time_seconds,
        t2.total_time_seconds
    FROM
        ufcstats_fighter_histories AS t1
    LEFT JOIN
        totals AS t2 ON t1.bout_id = t2.bout_id AND t1.fighter_id = t2.fighter_id
    LEFT JOIN
        totals AS t3 ON t1.bout_id = t3.bout_id AND t1.opponent_id = t3.fighter_id
),
cte4 AS (
    SELECT
        *
    FROM
        cte3
    WHERE
        bout_id IN (
            SELECT
                ufcstats_id
            FROM
                bout_mapping
        )
),
cte5 AS (
    SELECT
        *,
        COALESCE(SUM(knockdowns_scored) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_knockdowns_scored,
        COALESCE(SUM(ko_tko_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_ko_tko_landed,
        COALESCE(SUM(total_strikes_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_total_strikes_landed,
        COALESCE(SUM(total_strikes_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_total_strikes_attempted,
        COALESCE(SUM(significant_strikes_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_landed,
        COALESCE(SUM(significant_strikes_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_attempted,
        COALESCE(SUM(significant_strikes_head_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_head_landed,
        COALESCE(SUM(significant_strikes_head_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_head_attempted,
        COALESCE(SUM(significant_strikes_body_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_body_landed,
        COALESCE(SUM(significant_strikes_body_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_body_attempted,
        COALESCE(SUM(significant_strikes_leg_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_leg_landed,
        COALESCE(SUM(significant_strikes_leg_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_leg_attempted,
        COALESCE(SUM(significant_strikes_distance_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_distance_landed,
        COALESCE(SUM(significant_strikes_distance_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_distance_attempted,
        COALESCE(SUM(significant_strikes_clinch_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_clinch_landed,
        COALESCE(SUM(significant_strikes_clinch_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_clinch_attempted,
        COALESCE(SUM(significant_strikes_ground_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_ground_landed,
        COALESCE(SUM(significant_strikes_ground_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_ground_attempted,
        COALESCE(SUM(significant_strikes_distance_head_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_distance_head_landed,
        COALESCE(SUM(significant_strikes_distance_head_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_distance_head_attempted,
        COALESCE(SUM(significant_strikes_distance_body_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_distance_body_landed,
        COALESCE(SUM(significant_strikes_distance_body_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_distance_body_attempted,
        COALESCE(SUM(significant_strikes_distance_leg_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_distance_leg_landed,
        COALESCE(SUM(significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_distance_leg_attempted,
        COALESCE(SUM(significant_strikes_clinch_head_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_clinch_head_landed,
        COALESCE(SUM(significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_clinch_head_attempted,
        COALESCE(SUM(significant_strikes_clinch_body_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_clinch_body_landed,
        COALESCE(SUM(significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_clinch_body_attempted,
        COALESCE(SUM(significant_strikes_clinch_leg_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_clinch_leg_landed,
        COALESCE(SUM(significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_clinch_leg_attempted,
        COALESCE(SUM(significant_strikes_ground_head_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_ground_head_landed,
        COALESCE(SUM(significant_strikes_ground_head_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_ground_head_attempted,
        COALESCE(SUM(significant_strikes_ground_body_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_ground_body_landed,
        COALESCE(SUM(significant_strikes_ground_body_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_ground_body_attempted,
        COALESCE(SUM(significant_strikes_ground_leg_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_ground_leg_landed,
        COALESCE(SUM(significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_significant_strikes_ground_leg_attempted,
        COALESCE(SUM(takedowns_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_takedowns_landed,
        COALESCE(SUM(takedowns_slams_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_takedowns_slams_landed,
        COALESCE(SUM(takedowns_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_takedowns_attempted,
        COALESCE(SUM(advances) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_advances,
        COALESCE(SUM(advances_to_back) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_advances_to_back,
        COALESCE(SUM(advances_to_half_guard) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_advances_to_half_guard,
        COALESCE(SUM(advances_to_mount) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_advances_to_mount,
        COALESCE(SUM(advances_to_side) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_advances_to_side,
        COALESCE(SUM(reversals_scored) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_reversals_scored,
        COALESCE(SUM(submissions_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_submissions_landed,
        COALESCE(SUM(submissions_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_submissions_attempted,
        COALESCE(SUM(control_time_seconds) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_control_time_seconds,
        COALESCE(SUM(opp_knockdowns_scored) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_knockdowns_scored,
        COALESCE(SUM(opp_ko_tko_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_ko_tko_landed,
        COALESCE(SUM(opp_total_strikes_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_total_strikes_landed,
        COALESCE(SUM(opp_total_strikes_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_total_strikes_attempted,
        COALESCE(SUM(opp_significant_strikes_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_landed,
        COALESCE(SUM(opp_significant_strikes_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_attempted,
        COALESCE(SUM(opp_significant_strikes_head_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_head_landed,
        COALESCE(SUM(opp_significant_strikes_head_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_head_attempted,
        COALESCE(SUM(opp_significant_strikes_body_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_body_landed,
        COALESCE(SUM(opp_significant_strikes_body_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_body_attempted,
        COALESCE(SUM(opp_significant_strikes_leg_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_leg_landed,
        COALESCE(SUM(opp_significant_strikes_leg_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_leg_attempted,
        COALESCE(SUM(opp_significant_strikes_distance_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_distance_landed,
        COALESCE(SUM(opp_significant_strikes_distance_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_distance_attempted,
        COALESCE(SUM(opp_significant_strikes_clinch_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_clinch_landed,
        COALESCE(SUM(opp_significant_strikes_clinch_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_clinch_attempted,
        COALESCE(SUM(opp_significant_strikes_ground_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_ground_landed,
        COALESCE(SUM(opp_significant_strikes_ground_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_ground_attempted,
        COALESCE(SUM(opp_significant_strikes_distance_head_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_distance_head_landed,
        COALESCE(SUM(opp_significant_strikes_distance_head_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_distance_head_attempted,
        COALESCE(SUM(opp_significant_strikes_distance_body_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_distance_body_landed,
        COALESCE(SUM(opp_significant_strikes_distance_body_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_distance_body_attempted,
        COALESCE(SUM(opp_significant_strikes_distance_leg_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_distance_leg_landed,
        COALESCE(SUM(opp_significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_distance_leg_attempted,
        COALESCE(SUM(opp_significant_strikes_clinch_head_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_clinch_head_landed,
        COALESCE(SUM(opp_significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_clinch_head_attempted,
        COALESCE(SUM(opp_significant_strikes_clinch_body_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_clinch_body_landed,
        COALESCE(SUM(opp_significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_clinch_body_attempted,
        COALESCE(SUM(opp_significant_strikes_clinch_leg_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_clinch_leg_landed,
        COALESCE(SUM(opp_significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_clinch_leg_attempted,
        COALESCE(SUM(opp_significant_strikes_ground_head_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_ground_head_landed,
        COALESCE(SUM(opp_significant_strikes_ground_head_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_ground_head_attempted,
        COALESCE(SUM(opp_significant_strikes_ground_body_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_ground_body_landed,
        COALESCE(SUM(opp_significant_strikes_ground_body_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_ground_body_attempted,
        COALESCE(SUM(opp_significant_strikes_ground_leg_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_ground_leg_landed,
        COALESCE(SUM(opp_significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_significant_strikes_ground_leg_attempted,
        COALESCE(SUM(opp_takedowns_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_takedowns_landed,
        COALESCE(SUM(opp_takedowns_slams_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_takedowns_slams_landed,
        COALESCE(SUM(opp_takedowns_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_takedowns_attempted,
        COALESCE(SUM(opp_advances) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_advances,
        COALESCE(SUM(opp_advances_to_back) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_advances_to_back,
        COALESCE(SUM(opp_advances_to_half_guard) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_advances_to_half_guard,
        COALESCE(SUM(opp_advances_to_mount) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_advances_to_mount,
        COALESCE(SUM(opp_advances_to_side) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_advances_to_side,
        COALESCE(SUM(opp_reversals_scored) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_reversals_scored,
        COALESCE(SUM(opp_submissions_landed) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_submissions_landed,
        COALESCE(SUM(opp_submissions_attempted) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_submissions_attempted,
        COALESCE(SUM(opp_control_time_seconds) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_opp_control_time_seconds,
        COALESCE(SUM(total_time_seconds) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ), 0) AS cumulative_total_time_seconds
    FROM
        cte4 t1
),
cte6 AS (
    SELECT
        fighter_id,
        t1.'order',
        bout_id,
        opponent_id,
        AVG(knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_knockdowns_scored,
        cumulative_knockdowns_scored,
        AVG(1.0 * knockdowns_scored / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_knockdowns_scored_per_second,
        1.0 * cumulative_knockdowns_scored / cumulative_total_time_seconds AS cumulative_knockdowns_scored_per_second,
        AVG(1.0 * knockdowns_scored / total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_knockdowns_scored_per_strike_landed,
        1.0 * cumulative_knockdowns_scored / cumulative_total_strikes_landed AS cumulative_knockdowns_scored_per_strike_landed,
        AVG(1.0 * knockdowns_scored / total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_knockdowns_scored_per_strike_attempted,
        1.0 * cumulative_knockdowns_scored / cumulative_total_strikes_attempted AS cumulative_knockdowns_scored_per_strike_attempted,
        AVG(1.0 * knockdowns_scored / significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_knockdowns_scored_per_significant_strike_landed,
        1.0 * cumulative_knockdowns_scored / cumulative_significant_strikes_landed AS cumulative_knockdowns_scored_per_significant_strike_landed,
        AVG(1.0 * knockdowns_scored / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_knockdowns_scored_per_significant_strike_attempted,
        1.0 * cumulative_knockdowns_scored / cumulative_significant_strikes_attempted AS cumulative_knockdowns_scored_per_significant_strike_attempted,
        AVG(1.0 * knockdowns_scored / significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_knockdowns_scored_per_significant_strike_head_landed,
        1.0 * cumulative_knockdowns_scored / cumulative_significant_strikes_head_landed AS cumulative_knockdowns_scored_per_significant_strike_head_landed,
        AVG(1.0 * knockdowns_scored / significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_knockdowns_scored_per_significant_strike_head_attempted,
        1.0 * cumulative_knockdowns_scored / cumulative_significant_strikes_head_attempted AS cumulative_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(ko_tko_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_landed,
        cumulative_ko_tko_landed,
        AVG(1.0 * ko_tko_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_landed_per_second,
        1.0 * cumulative_ko_tko_landed / cumulative_total_time_seconds AS cumulative_ko_tko_landed_per_second,
        AVG(1.0 * ko_tko_landed / total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_landed_per_strike_landed,
        1.0 * cumulative_ko_tko_landed / cumulative_total_strikes_landed AS cumulative_ko_tko_landed_per_strike_landed,
        AVG(1.0 * ko_tko_landed / total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_landed_per_strike_attempted,
        1.0 * cumulative_ko_tko_landed / cumulative_total_strikes_attempted AS cumulative_ko_tko_landed_per_strike_attempted,
        AVG(1.0 * ko_tko_landed / significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_landed_per_significant_strike_landed,
        1.0 * cumulative_ko_tko_landed / cumulative_significant_strikes_landed AS cumulative_ko_tko_landed_per_significant_strike_landed,
        AVG(1.0 * ko_tko_landed / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_landed_per_significant_strike_attempted,
        1.0 * cumulative_ko_tko_landed / cumulative_significant_strikes_attempted AS cumulative_ko_tko_landed_per_significant_strike_attempted,
        AVG(1.0 * ko_tko_landed / significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_landed_per_significant_strike_head_landed,
        1.0 * cumulative_ko_tko_landed / cumulative_significant_strikes_head_landed AS cumulative_ko_tko_landed_per_significant_strike_head_landed,
        AVG(1.0 * ko_tko_landed / significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_landed_per_significant_strike_head_attempted,
        1.0 * cumulative_ko_tko_landed / cumulative_significant_strikes_head_attempted AS cumulative_ko_tko_landed_per_significant_strike_head_attempted,
        AVG(total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_total_strikes_landed,
        cumulative_total_strikes_landed,
        AVG(1.0 * total_strikes_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_total_strikes_landed_per_second,
        1.0 * cumulative_total_strikes_landed / cumulative_total_time_seconds AS cumulative_total_strikes_landed_per_second,
        AVG(1.0 * total_strikes_landed / total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_total_strikes_accuracy,
        1.0 * cumulative_total_strikes_landed / cumulative_total_strikes_attempted AS cumulative_total_strikes_accuracy,
        AVG(total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_total_strikes_attempted,
        cumulative_total_strikes_attempted,
        AVG(1.0 * total_strikes_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_total_strikes_attempted_per_second,
        1.0 * cumulative_total_strikes_attempted / cumulative_total_time_seconds AS cumulative_total_strikes_attempted_per_second,
        AVG(significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_landed,
        cumulative_significant_strikes_landed,
        AVG(1.0 * significant_strikes_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_landed_per_second,
        1.0 * cumulative_significant_strikes_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_landed_per_second,
        AVG(1.0 * significant_strikes_landed / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_accuracy,
        1.0 * cumulative_significant_strikes_landed / cumulative_significant_strikes_attempted AS cumulative_significant_strikes_accuracy,
        AVG(1.0 * significant_strikes_landed / total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_landed_per_strike_landed,
        1.0 * cumulative_significant_strikes_landed / cumulative_total_strikes_landed AS cumulative_significant_strikes_landed_per_strike_landed,
        AVG(significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_attempted,
        cumulative_significant_strikes_attempted,
        AVG(1.0 * significant_strikes_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_attempted_per_second,
        1.0 * cumulative_significant_strikes_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_attempted_per_second,
        AVG(1.0 * significant_strikes_attempted / total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_attempted_per_strike_attempted,
        1.0 * cumulative_significant_strikes_attempted / cumulative_total_strikes_attempted AS cumulative_significant_strikes_attempted_per_strike_attempted,
        AVG(significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_head_landed,
        cumulative_significant_strikes_head_landed,
        AVG(1.0 * significant_strikes_head_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_head_landed_per_second,
        1.0 * cumulative_significant_strikes_head_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_head_landed_per_second,
        AVG(1.0 * significant_strikes_head_landed / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_head_accuracy,
        1.0 * cumulative_significant_strikes_head_landed / cumulative_significant_strikes_attempted AS cumulative_significant_strikes_head_accuracy,
        AVG(1.0 * significant_strikes_head_landed / significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_head_landed_per_significant_strike_landed,
        1.0 * cumulative_significant_strikes_head_landed / cumulative_significant_strikes_landed AS cumulative_significant_strikes_head_landed_per_significant_strike_landed,
        AVG(significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_head_attempted,
        cumulative_significant_strikes_head_attempted,
        AVG(1.0 * significant_strikes_head_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_head_attempted_per_second,
        1.0 * cumulative_significant_strikes_head_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_head_attempted_per_second,
        AVG(1.0 * significant_strikes_head_attempted / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_head_attempted_per_significant_strike_attempted,
        1.0 * cumulative_significant_strikes_head_attempted / cumulative_significant_strikes_attempted AS cumulative_significant_strikes_head_attempted_per_significant_strike_attempted,
        AVG(significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_body_landed,
        cumulative_significant_strikes_body_landed,
        AVG(1.0 * significant_strikes_body_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_body_landed_per_second,
        1.0 * cumulative_significant_strikes_body_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_body_landed_per_second,
        AVG(1.0 * significant_strikes_body_landed / significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_body_accuracy,
        1.0 * cumulative_significant_strikes_body_landed / cumulative_significant_strikes_body_attempted AS cumulative_significant_strikes_body_accuracy,
        AVG(1.0 * significant_strikes_body_landed / significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_body_landed_per_significant_strike_landed,
        1.0 * cumulative_significant_strikes_body_landed / cumulative_significant_strikes_landed AS cumulative_significant_strikes_body_landed_per_significant_strike_landed,
        AVG(significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_body_attempted,
        cumulative_significant_strikes_body_attempted,
        AVG(1.0 * significant_strikes_body_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_body_attempted_per_second,
        1.0 * cumulative_significant_strikes_body_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_body_attempted_per_second,
        AVG(1.0 * significant_strikes_body_attempted / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_body_attempted_per_significant_strike_attempted,
        1.0 * cumulative_significant_strikes_body_attempted / cumulative_significant_strikes_attempted AS cumulative_significant_strikes_body_attempted_per_significant_strike_attempted,
        AVG(significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_leg_landed,
        cumulative_significant_strikes_leg_landed,
        AVG(1.0 * significant_strikes_leg_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_leg_landed_per_second,
        1.0 * cumulative_significant_strikes_leg_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_leg_landed_per_second,
        AVG(1.0 * significant_strikes_leg_landed / significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_leg_accuracy,
        1.0 * cumulative_significant_strikes_leg_landed / cumulative_significant_strikes_leg_attempted AS cumulative_significant_strikes_leg_accuracy,
        AVG(1.0 * significant_strikes_leg_landed / significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_leg_landed_per_significant_strike_landed,
        1.0 * cumulative_significant_strikes_leg_landed / cumulative_significant_strikes_landed AS cumulative_significant_strikes_leg_landed_per_significant_strike_landed,
        AVG(significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_leg_attempted,
        cumulative_significant_strikes_leg_attempted,
        AVG(1.0 * significant_strikes_leg_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_leg_attempted_per_second,
        1.0 * cumulative_significant_strikes_leg_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_leg_attempted_per_second,
        AVG(1.0 * significant_strikes_leg_attempted / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_leg_attempted_per_significant_strike_attempted,
        1.0 * cumulative_significant_strikes_leg_attempted / cumulative_significant_strikes_attempted AS cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted,
        AVG(significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_landed,
        cumulative_significant_strikes_distance_landed,
        AVG(1.0 * significant_strikes_distance_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_landed_per_second,
        1.0 * cumulative_significant_strikes_distance_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_distance_landed_per_second,
        AVG(1.0 * significant_strikes_distance_landed / significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_accuracy,
        1.0 * cumulative_significant_strikes_distance_landed / cumulative_significant_strikes_distance_attempted AS cumulative_significant_strikes_distance_accuracy,
        AVG(1.0 * significant_strikes_distance_landed / significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_landed_per_significant_strike_landed,
        1.0 * cumulative_significant_strikes_distance_landed / cumulative_significant_strikes_landed AS cumulative_significant_strikes_distance_landed_per_significant_strike_landed,
        AVG(significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_attempted,
        cumulative_significant_strikes_distance_attempted,
        AVG(1.0 * significant_strikes_distance_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_attempted_per_second,
        1.0 * cumulative_significant_strikes_distance_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_distance_attempted_per_second,
        AVG(1.0 * significant_strikes_distance_attempted / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_attempted_per_significant_strike_attempted,
        1.0 * cumulative_significant_strikes_distance_attempted / cumulative_significant_strikes_attempted AS cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted,
        AVG(significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_landed,
        cumulative_significant_strikes_clinch_landed,
        AVG(1.0 * significant_strikes_clinch_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_landed_per_second,
        1.0 * cumulative_significant_strikes_clinch_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_clinch_landed_per_second,
        AVG(1.0 * significant_strikes_clinch_landed / significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_accuracy,
        1.0 * cumulative_significant_strikes_clinch_landed / cumulative_significant_strikes_clinch_attempted AS cumulative_significant_strikes_clinch_accuracy,
        AVG(1.0 * significant_strikes_clinch_landed / significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_landed_per_significant_strike_landed,
        1.0 * cumulative_significant_strikes_clinch_landed / cumulative_significant_strikes_landed AS cumulative_significant_strikes_clinch_landed_per_significant_strike_landed,
        AVG(significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_attempted,
        cumulative_significant_strikes_clinch_attempted,
        AVG(1.0 * significant_strikes_clinch_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_attempted_per_second,
        1.0 * cumulative_significant_strikes_clinch_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_clinch_attempted_per_second,
        AVG(1.0 * significant_strikes_clinch_attempted / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_attempted_per_significant_strike_attempted,
        1.0 * cumulative_significant_strikes_clinch_attempted / cumulative_significant_strikes_attempted AS cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted,
        AVG(significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_landed,
        cumulative_significant_strikes_ground_landed,
        AVG(1.0 * significant_strikes_ground_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_landed_per_second,
        1.0 * cumulative_significant_strikes_ground_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_ground_landed_per_second,
        AVG(1.0 * significant_strikes_ground_landed / significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_accuracy,
        1.0 * cumulative_significant_strikes_ground_landed / cumulative_significant_strikes_ground_attempted AS cumulative_significant_strikes_ground_accuracy,
        AVG(1.0 * significant_strikes_ground_landed / significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_landed_per_significant_strike_landed,
        1.0 * cumulative_significant_strikes_ground_landed / cumulative_significant_strikes_landed AS cumulative_significant_strikes_ground_landed_per_significant_strike_landed,
        AVG(significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_attempted,
        cumulative_significant_strikes_ground_attempted,
        AVG(1.0 * significant_strikes_ground_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_attempted_per_second,
        1.0 * cumulative_significant_strikes_ground_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_ground_attempted_per_second,
        AVG(1.0 * significant_strikes_ground_attempted / significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_attempted_per_strike_attempted,
        1.0 * cumulative_significant_strikes_ground_attempted / cumulative_significant_strikes_attempted AS cumulative_significant_strikes_ground_attempted_per_strike_attempted,
        AVG(significant_strikes_distance_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_head_landed,
        cumulative_significant_strikes_distance_head_landed,
        AVG(1.0 * significant_strikes_distance_head_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_head_landed_per_second,
        1.0 * cumulative_significant_strikes_distance_head_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_distance_head_landed_per_second,
        AVG(1.0 * significant_strikes_distance_head_landed / significant_strikes_distance_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_head_accuracy,
        1.0 * cumulative_significant_strikes_distance_head_landed / cumulative_significant_strikes_distance_head_attempted AS cumulative_significant_strikes_distance_head_accuracy,
        AVG(1.0 * significant_strikes_distance_head_landed / significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed,
        1.0 * cumulative_significant_strikes_distance_head_landed / cumulative_significant_strikes_distance_landed AS cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed,
        AVG(1.0 * significant_strikes_distance_head_landed / significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed,
        1.0 * cumulative_significant_strikes_distance_head_landed / cumulative_significant_strikes_head_landed AS cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed,
        AVG(significant_strikes_distance_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_head_attempted,
        cumulative_significant_strikes_distance_head_attempted,
        AVG(1.0 * significant_strikes_distance_head_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_head_attempted_per_second,
        1.0 * cumulative_significant_strikes_distance_head_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_distance_head_attempted_per_second,
        AVG(1.0 * significant_strikes_distance_head_attempted / significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted,
        1.0 * cumulative_significant_strikes_distance_head_attempted / cumulative_significant_strikes_distance_attempted AS cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted,
        AVG(1.0 * significant_strikes_distance_head_attempted / significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted,
        1.0 * cumulative_significant_strikes_distance_head_attempted / cumulative_significant_strikes_head_attempted AS cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted,
        AVG(significant_strikes_distance_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_body_landed,
        cumulative_significant_strikes_distance_body_landed,
        AVG(1.0 * significant_strikes_distance_body_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_body_landed_per_second,
        1.0 * cumulative_significant_strikes_distance_body_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_distance_body_landed_per_second,
        AVG(1.0 * significant_strikes_distance_body_landed / significant_strikes_distance_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_body_accuracy,
        1.0 * cumulative_significant_strikes_distance_body_landed / cumulative_significant_strikes_distance_body_attempted AS cumulative_significant_strikes_distance_body_accuracy,
        AVG(1.0 * significant_strikes_distance_body_landed / significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed,
        1.0 * cumulative_significant_strikes_distance_body_landed / cumulative_significant_strikes_distance_landed AS cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed,
        AVG(1.0 * significant_strikes_distance_body_landed / significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed,
        1.0 * cumulative_significant_strikes_distance_body_landed / cumulative_significant_strikes_body_landed AS cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed,
        AVG(significant_strikes_distance_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_body_attempted,
        cumulative_significant_strikes_distance_body_attempted,
        AVG(1.0 * significant_strikes_distance_body_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_body_attempted_per_second,
        1.0 * cumulative_significant_strikes_distance_body_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_distance_body_attempted_per_second,
        AVG(1.0 * significant_strikes_distance_body_attempted / significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted,
        1.0 * cumulative_significant_strikes_distance_body_attempted / cumulative_significant_strikes_distance_attempted AS cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted,
        AVG(1.0 * significant_strikes_distance_body_attempted / significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted,
        1.0 * cumulative_significant_strikes_distance_body_attempted / cumulative_significant_strikes_body_attempted AS cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted,
        AVG(significant_strikes_distance_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_leg_landed,
        cumulative_significant_strikes_distance_leg_landed,
        AVG(1.0 * significant_strikes_distance_leg_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_leg_landed_per_second,
        1.0 * cumulative_significant_strikes_distance_leg_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_distance_leg_landed_per_second,
        AVG(1.0 * significant_strikes_distance_leg_landed / significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_leg_accuracy,
        1.0 * cumulative_significant_strikes_distance_leg_landed / cumulative_significant_strikes_distance_leg_attempted AS cumulative_significant_strikes_distance_leg_accuracy,
        AVG(1.0 * significant_strikes_distance_leg_landed / significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed,
        1.0 * cumulative_significant_strikes_distance_leg_landed / cumulative_significant_strikes_distance_landed AS cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed,
        AVG(1.0 * significant_strikes_distance_leg_landed / significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed,
        AVG(significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_leg_attempted,
        cumulative_significant_strikes_distance_leg_attempted,
        AVG(1.0 * significant_strikes_distance_leg_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_leg_attempted_per_second,
        1.0 * cumulative_significant_strikes_distance_leg_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_distance_leg_attempted_per_second,
        AVG(1.0 * significant_strikes_distance_leg_attempted / significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted,
        1.0 * cumulative_significant_strikes_distance_leg_attempted / cumulative_significant_strikes_distance_attempted AS cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted,
        AVG(1.0 * significant_strikes_distance_leg_attempted / significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted,
        1.0 * cumulative_significant_strikes_distance_leg_attempted / cumulative_significant_strikes_leg_attempted AS cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted,
        AVG(significant_strikes_clinch_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_head_landed,
        cumulative_significant_strikes_clinch_head_landed,
        AVG(1.0 * significant_strikes_clinch_head_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_head_landed_per_second,
        1.0 * cumulative_significant_strikes_clinch_head_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_clinch_head_landed_per_second,
        AVG(1.0 * significant_strikes_clinch_head_landed / significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_head_accuracy,
        1.0 * cumulative_significant_strikes_clinch_head_landed / cumulative_significant_strikes_clinch_head_attempted AS cumulative_significant_strikes_clinch_head_accuracy,
        AVG(1.0 * significant_strikes_clinch_head_landed / significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed,
        1.0 * cumulative_significant_strikes_clinch_head_landed / cumulative_significant_strikes_clinch_landed AS cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed,
        AVG(1.0 * significant_strikes_clinch_head_landed / significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed,
        1.0 * cumulative_significant_strikes_clinch_head_landed / cumulative_significant_strikes_head_landed AS cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed,
        AVG(significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_head_attempted,
        cumulative_significant_strikes_clinch_head_attempted,
        AVG(1.0 * significant_strikes_clinch_head_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_head_attempted_per_second,
        1.0 * cumulative_significant_strikes_clinch_head_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_clinch_head_attempted_per_second,
        AVG(1.0 * significant_strikes_clinch_head_attempted / significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted,
        1.0 * cumulative_significant_strikes_clinch_head_attempted / cumulative_significant_strikes_clinch_attempted AS cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted,
        AVG(1.0 * significant_strikes_clinch_head_attempted / significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted,
        1.0 * cumulative_significant_strikes_clinch_head_attempted / cumulative_significant_strikes_head_attempted AS cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted,
        AVG(significant_strikes_clinch_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_body_landed,
        cumulative_significant_strikes_clinch_body_landed,
        AVG(1.0 * significant_strikes_clinch_body_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_body_landed_per_second,
        1.0 * cumulative_significant_strikes_clinch_body_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_clinch_body_landed_per_second,
        AVG(1.0 * significant_strikes_clinch_body_landed / significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_body_accuracy,
        1.0 * cumulative_significant_strikes_clinch_body_landed / cumulative_significant_strikes_clinch_body_attempted AS cumulative_significant_strikes_clinch_body_accuracy,
        AVG(1.0 * significant_strikes_clinch_body_landed / significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed,
        1.0 * cumulative_significant_strikes_clinch_body_landed / cumulative_significant_strikes_clinch_landed AS cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed,
        AVG(1.0 * significant_strikes_clinch_body_landed / significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed,
        1.0 * cumulative_significant_strikes_clinch_body_landed / cumulative_significant_strikes_body_landed AS cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed,
        AVG(significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_body_attempted,
        cumulative_significant_strikes_clinch_body_attempted,
        AVG(1.0 * significant_strikes_clinch_body_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_body_attempted_per_second,
        1.0 * cumulative_significant_strikes_clinch_body_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_clinch_body_attempted_per_second,
        AVG(1.0 * significant_strikes_clinch_body_attempted / significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted,
        1.0 * cumulative_significant_strikes_clinch_body_attempted / cumulative_significant_strikes_clinch_attempted AS cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted,
        AVG(1.0 * significant_strikes_clinch_body_attempted / significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted,
        1.0 * cumulative_significant_strikes_clinch_body_attempted / cumulative_significant_strikes_body_attempted AS cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted,
        AVG(significant_strikes_clinch_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_leg_landed,
        1.0 * cumulative_significant_strikes_clinch_leg_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_clinch_leg_landed_per_second,
        AVG(1.0 * significant_strikes_clinch_leg_landed / significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_leg_accuracy,
        1.0 * cumulative_significant_strikes_clinch_leg_landed / cumulative_significant_strikes_clinch_leg_attempted AS cumulative_significant_strikes_clinch_leg_accuracy,
        AVG(1.0 * significant_strikes_clinch_leg_landed / significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed,
        1.0 * cumulative_significant_strikes_clinch_leg_landed / cumulative_significant_strikes_clinch_landed AS cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed,
        AVG(1.0 * significant_strikes_clinch_leg_landed / significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed,
        1.0 * cumulative_significant_strikes_clinch_leg_landed / cumulative_significant_strikes_leg_landed AS cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed,
        AVG(significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_leg_attempted,
        cumulative_significant_strikes_clinch_leg_attempted,
        AVG(1.0 * significant_strikes_clinch_leg_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_leg_attempted_per_second,
        1.0 * cumulative_significant_strikes_clinch_leg_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_clinch_leg_attempted_per_second,
        AVG(1.0 * significant_strikes_clinch_leg_attempted / significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted,
        1.0 * cumulative_significant_strikes_clinch_leg_attempted / cumulative_significant_strikes_clinch_attempted AS cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted,
        AVG(1.0 * significant_strikes_clinch_leg_attempted / significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted,
        1.0 * cumulative_significant_strikes_clinch_leg_attempted / cumulative_significant_strikes_leg_attempted AS cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted,
        AVG(significant_strikes_ground_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_head_landed,
        cumulative_significant_strikes_ground_head_landed,
        AVG(1.0 * significant_strikes_ground_head_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_head_landed_per_second,
        1.0 * cumulative_significant_strikes_ground_head_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_ground_head_landed_per_second,
        AVG(1.0 * significant_strikes_ground_head_landed / significant_strikes_ground_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_head_accuracy,
        1.0 * cumulative_significant_strikes_ground_head_landed / cumulative_significant_strikes_ground_head_attempted AS cumulative_significant_strikes_ground_head_accuracy,
        AVG(1.0 * significant_strikes_ground_head_landed / significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed,
        1.0 * cumulative_significant_strikes_ground_head_landed / cumulative_significant_strikes_ground_landed AS cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed,
        AVG(1.0 * significant_strikes_ground_head_landed / significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed,
        1.0 * cumulative_significant_strikes_ground_head_landed / cumulative_significant_strikes_head_landed AS cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed,
        AVG(significant_strikes_ground_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_head_attempted,
        cumulative_significant_strikes_ground_head_attempted,
        AVG(1.0 * significant_strikes_ground_head_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_head_attempted_per_second,
        1.0 * cumulative_significant_strikes_ground_head_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_ground_head_attempted_per_second,
        AVG(1.0 * significant_strikes_ground_head_attempted / significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted,
        1.0 * cumulative_significant_strikes_ground_head_attempted / cumulative_significant_strikes_ground_attempted AS cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted,
        AVG(1.0 * significant_strikes_ground_head_attempted / significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted,
        1.0 * cumulative_significant_strikes_ground_head_attempted / cumulative_significant_strikes_head_attempted AS cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted,
        AVG(significant_strikes_ground_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_body_landed,
        cumulative_significant_strikes_ground_body_landed,
        AVG(1.0 * significant_strikes_ground_body_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_body_landed_per_second,
        1.0 * cumulative_significant_strikes_ground_body_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_ground_body_landed_per_second,
        AVG(1.0 * significant_strikes_ground_body_landed / significant_strikes_ground_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_body_accuracy,
        1.0 * cumulative_significant_strikes_ground_body_landed / cumulative_significant_strikes_ground_body_attempted AS cumulative_significant_strikes_ground_body_accuracy,
        AVG(1.0 * significant_strikes_ground_body_landed / significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed,
        1.0 * cumulative_significant_strikes_ground_body_landed / cumulative_significant_strikes_ground_landed AS cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed,
        AVG(1.0 * significant_strikes_ground_body_landed / significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed,
        1.0 * cumulative_significant_strikes_ground_body_landed / cumulative_significant_strikes_body_landed AS cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed,
        AVG(significant_strikes_ground_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_body_attempted,
        cumulative_significant_strikes_ground_body_attempted,
        AVG(1.0 * significant_strikes_ground_body_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_body_attempted_per_second,
        1.0 * cumulative_significant_strikes_ground_body_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_ground_body_attempted_per_second,
        AVG(1.0 * significant_strikes_ground_body_attempted / significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted,
        1.0 * cumulative_significant_strikes_ground_body_attempted / cumulative_significant_strikes_ground_attempted AS cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted,
        AVG(1.0 * significant_strikes_ground_body_attempted / significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted,
        1.0 * cumulative_significant_strikes_ground_body_attempted / cumulative_significant_strikes_body_attempted AS cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted,
        AVG(significant_strikes_ground_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_leg_landed,
        cumulative_significant_strikes_ground_leg_landed,
        AVG(1.0 * significant_strikes_ground_leg_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_leg_landed_per_second,
        1.0 * cumulative_significant_strikes_ground_leg_landed / cumulative_total_time_seconds AS cumulative_significant_strikes_ground_leg_landed_per_second,
        AVG(1.0 * significant_strikes_ground_leg_landed / significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_leg_accuracy,
        1.0 * cumulative_significant_strikes_ground_leg_landed / cumulative_significant_strikes_ground_leg_attempted AS cumulative_significant_strikes_ground_leg_accuracy,
        AVG(1.0 * significant_strikes_ground_leg_landed / significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed,
        1.0 * cumulative_significant_strikes_ground_leg_landed / cumulative_significant_strikes_ground_landed AS cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed,
        AVG(1.0 * significant_strikes_ground_leg_landed / significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed,
        1.0 * cumulative_significant_strikes_ground_leg_landed / cumulative_significant_strikes_leg_landed AS cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed,
        AVG(significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_leg_attempted,
        cumulative_significant_strikes_ground_leg_attempted,
        AVG(1.0 * significant_strikes_ground_leg_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_leg_attempted_per_second,
        1.0 * cumulative_significant_strikes_ground_leg_attempted / cumulative_total_time_seconds AS cumulative_significant_strikes_ground_leg_attempted_per_second,
        AVG(1.0 * significant_strikes_ground_leg_attempted / significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted,
        1.0 * cumulative_significant_strikes_ground_leg_attempted / cumulative_significant_strikes_ground_attempted AS cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted,
        AVG(1.0 * significant_strikes_ground_leg_attempted / significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted,
        1.0 * cumulative_significant_strikes_ground_leg_attempted / cumulative_significant_strikes_leg_attempted AS cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted,
        AVG(takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_takedowns_landed,
        cumulative_takedowns_landed,
        AVG(1.0 * takedowns_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_takedowns_landed_per_second,
        1.0 * cumulative_takedowns_landed / cumulative_total_time_seconds AS cumulative_takedowns_landed_per_second,
        AVG(1.0 * takedowns_landed / takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_takedowns_accuracy,
        1.0 * cumulative_takedowns_landed / cumulative_takedowns_attempted AS cumulative_takedowns_accuracy,
        AVG(takedowns_slams_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_takedowns_slams_landed,
        cumulative_takedowns_slams_landed,
        AVG(1.0 * takedowns_slams_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_takedowns_slams_landed_per_second,
        1.0 * cumulative_takedowns_slams_landed / cumulative_total_time_seconds AS cumulative_takedowns_slams_landed_per_second,
        AVG(1.0 * takedowns_slams_landed / takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_takedowns_slams_landed_per_takedowns_landed,
        1.0 * cumulative_takedowns_slams_landed / cumulative_takedowns_landed AS cumulative_takedowns_slams_landed_per_takedowns_landed,
        AVG(takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_takedowns_attempted,
        cumulative_takedowns_attempted,
        AVG(1.0 * takedowns_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_takedowns_attempted_per_second,
        1.0 * cumulative_takedowns_attempted / cumulative_total_time_seconds AS cumulative_takedowns_attempted_per_second,
        AVG(advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances,
        cumulative_advances,
        AVG(1.0 * advances / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_per_second,
        1.0 * cumulative_advances / cumulative_total_time_seconds AS cumulative_advances_per_second,
        AVG(advances_to_back) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_back,
        cumulative_advances_to_back,
        AVG(1.0 * advances_to_back / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_back_per_second,
        1.0 * cumulative_advances_to_back / cumulative_total_time_seconds AS cumulative_advances_to_back_per_second,
        AVG(1.0 * advances_to_back / advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_back_per_advances,
        1.0 * cumulative_advances_to_back / cumulative_advances AS cumulative_advances_to_back_per_advances,
        AVG(advances_to_half_guard) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_half_guard,
        cumulative_advances_to_half_guard,
        AVG(1.0 * advances_to_half_guard / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_half_guard_per_second,
        1.0 * cumulative_advances_to_half_guard / cumulative_total_time_seconds AS cumulative_advances_to_half_guard_per_second,
        AVG(1.0 * advances_to_half_guard / advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_half_guard_per_advances,
        1.0 * cumulative_advances_to_half_guard / cumulative_advances AS cumulative_advances_to_half_guard_per_advances,
        AVG(advances_to_mount) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_mount,
        cumulative_advances_to_mount,
        AVG(1.0 * advances_to_mount / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_mount_per_second,
        1.0 * cumulative_advances_to_mount / cumulative_total_time_seconds AS cumulative_advances_to_mount_per_second,
        AVG(1.0 * advances_to_mount / advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_mount_per_advances,
        1.0 * cumulative_advances_to_mount / cumulative_advances AS cumulative_advances_to_mount_per_advances,
        AVG(advances_to_side) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_side,
        cumulative_advances_to_side,
        AVG(1.0 * advances_to_side / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_side_per_second,
        1.0 * cumulative_advances_to_side / cumulative_total_time_seconds AS cumulative_advances_to_side_per_second,
        AVG(1.0 * advances_to_side / advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_advances_to_side_per_advances,
        1.0 * cumulative_advances_to_side / cumulative_advances AS cumulative_advances_to_side_per_advances,
        AVG(reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_reversals_scored,
        cumulative_reversals_scored,
        AVG(1.0 * reversals_scored / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_reversals_scored_per_second,
        1.0 * cumulative_reversals_scored / cumulative_total_time_seconds AS cumulative_reversals_scored_per_second,
        AVG(submissions_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_submissions_landed,
        cumulative_submissions_landed,
        AVG(1.0 * submissions_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_submissions_landed_per_second,
        1.0 * cumulative_submissions_landed / cumulative_total_time_seconds AS cumulative_submissions_landed_per_second,
        AVG(1.0 * submissions_landed / submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_submissions_accuracy,
        1.0 * cumulative_submissions_landed / cumulative_submissions_attempted AS cumulative_submissions_accuracy,
        AVG(submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_submissions_attempted,
        cumulative_submissions_attempted,
        AVG(1.0 * submissions_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_submissions_attempted_per_second,
        1.0 * cumulative_submissions_attempted / cumulative_total_time_seconds AS cumulative_submissions_attempted_per_second,
        AVG(control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_control_time_seconds,
        cumulative_control_time_seconds,
        AVG(1.0 * control_time_seconds / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_control_time_seconds_per_second,
        1.0 * cumulative_control_time_seconds / cumulative_total_time_seconds AS cumulative_control_time_seconds_per_second,
        AVG(opp_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_knockdowns_scored,
        cumulative_opp_knockdowns_scored,
        AVG(1.0 * opp_knockdowns_scored / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_knockdowns_scored_per_second,
        1.0 * cumulative_opp_knockdowns_scored / cumulative_total_time_seconds AS cumulative_opp_knockdowns_scored_per_second,
        AVG(1.0 * opp_knockdowns_scored / opp_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_knockdowns_scored_per_strike_landed,
        1.0 * cumulative_opp_knockdowns_scored / cumulative_opp_total_strikes_landed AS cumulative_opp_knockdowns_scored_per_strike_landed,
        AVG(1.0 * opp_knockdowns_scored / opp_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_knockdowns_scored_per_strike_attempted,
        1.0 * cumulative_opp_knockdowns_scored / cumulative_opp_total_strikes_attempted AS cumulative_opp_knockdowns_scored_per_strike_attempted,
        AVG(1.0 * opp_knockdowns_scored / opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_knockdowns_scored_per_significant_strike_landed,
        1.0 * cumulative_opp_knockdowns_scored / cumulative_opp_significant_strikes_landed AS cumulative_opp_knockdowns_scored_per_significant_strike_landed,
        AVG(1.0 * opp_knockdowns_scored / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_knockdowns_scored_per_significant_strike_attempted,
        1.0 * cumulative_opp_knockdowns_scored / cumulative_opp_significant_strikes_attempted AS cumulative_opp_knockdowns_scored_per_significant_strike_attempted,
        AVG(1.0 * opp_knockdowns_scored / opp_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_knockdowns_scored_per_significant_strike_head_landed,
        1.0 * cumulative_opp_knockdowns_scored / cumulative_opp_significant_strikes_head_landed AS cumulative_opp_knockdowns_scored_per_significant_strike_head_landed,
        AVG(1.0 * opp_knockdowns_scored / opp_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_knockdowns_scored_per_significant_strike_head_attempted,
        1.0 * cumulative_opp_knockdowns_scored / cumulative_opp_significant_strikes_head_attempted AS cumulative_opp_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(opp_ko_tko_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_landed,
        cumulative_opp_ko_tko_landed,
        AVG(1.0 * opp_ko_tko_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_landed_per_second,
        1.0 * cumulative_opp_ko_tko_landed / cumulative_total_time_seconds AS cumulative_opp_ko_tko_landed_per_second,
        AVG(1.0 * opp_ko_tko_landed / opp_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_landed_per_strike_landed,
        1.0 * cumulative_opp_ko_tko_landed / cumulative_opp_total_strikes_landed AS cumulative_opp_ko_tko_landed_per_strike_landed,
        AVG(1.0 * opp_ko_tko_landed / opp_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_landed_per_strike_attempted,
        1.0 * cumulative_opp_ko_tko_landed / cumulative_opp_total_strikes_attempted AS cumulative_opp_ko_tko_landed_per_strike_attempted,
        AVG(1.0 * opp_ko_tko_landed / opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_landed_per_significant_strike_landed,
        1.0 * cumulative_opp_ko_tko_landed / cumulative_opp_significant_strikes_landed AS cumulative_opp_ko_tko_landed_per_significant_strike_landed,
        AVG(1.0 * opp_ko_tko_landed / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_landed_per_significant_strike_attempted,
        1.0 * cumulative_opp_ko_tko_landed / cumulative_opp_significant_strikes_attempted AS cumulative_opp_ko_tko_landed_per_significant_strike_attempted,
        AVG(1.0 * opp_ko_tko_landed / opp_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_landed_per_significant_strike_head_landed,
        1.0 * cumulative_opp_ko_tko_landed / cumulative_opp_significant_strikes_head_landed AS cumulative_opp_ko_tko_landed_per_significant_strike_head_landed,
        AVG(1.0 * opp_ko_tko_landed / opp_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_landed_per_significant_strike_head_attempted,
        1.0 * cumulative_opp_ko_tko_landed / cumulative_opp_significant_strikes_head_attempted AS cumulative_opp_ko_tko_landed_per_significant_strike_head_attempted,
        AVG(opp_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_total_strikes_landed,
        cumulative_opp_total_strikes_landed,
        AVG(1.0 * opp_total_strikes_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_total_strikes_landed_per_second,
        1.0 * cumulative_opp_total_strikes_landed / cumulative_total_time_seconds AS cumulative_opp_total_strikes_landed_per_second,
        AVG(1.0 * opp_total_strikes_landed / opp_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_total_strikes_accuracy,
        1.0 * cumulative_opp_total_strikes_landed / cumulative_opp_total_strikes_attempted AS cumulative_opp_total_strikes_accuracy,
        AVG(opp_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_total_strikes_attempted,
        cumulative_opp_total_strikes_attempted,
        AVG(1.0 * opp_total_strikes_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_total_strikes_attempted_per_second,
        1.0 * cumulative_opp_total_strikes_attempted / cumulative_total_time_seconds AS cumulative_opp_total_strikes_attempted_per_second,
        AVG(opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_landed,
        cumulative_opp_significant_strikes_landed,
        AVG(1.0 * opp_significant_strikes_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_landed_per_second,
        AVG(1.0 * opp_significant_strikes_landed / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_accuracy,
        1.0 * cumulative_opp_significant_strikes_landed / cumulative_opp_significant_strikes_attempted AS cumulative_opp_significant_strikes_accuracy,
        AVG(1.0 * opp_significant_strikes_landed / opp_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_landed_per_strike_landed,
        1.0 * cumulative_opp_significant_strikes_landed / cumulative_opp_total_strikes_landed AS cumulative_opp_significant_strikes_landed_per_strike_landed,
        AVG(opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_attempted,
        cumulative_opp_significant_strikes_attempted,
        AVG(1.0 * opp_significant_strikes_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_attempted / opp_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_attempted_per_strike_attempted,
        1.0 * cumulative_opp_significant_strikes_attempted / cumulative_opp_total_strikes_attempted AS cumulative_opp_significant_strikes_attempted_per_strike_attempted,
        AVG(opp_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_head_landed,
        cumulative_opp_significant_strikes_head_landed,
        AVG(1.0 * opp_significant_strikes_head_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_head_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_head_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_head_landed_per_second,
        AVG(1.0 * opp_significant_strikes_head_landed / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_head_accuracy,
        1.0 * cumulative_opp_significant_strikes_head_landed / cumulative_opp_significant_strikes_attempted AS cumulative_opp_significant_strikes_head_accuracy,
        AVG(1.0 * opp_significant_strikes_head_landed / opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_head_landed_per_significant_strike_landed,
        1.0 * cumulative_opp_significant_strikes_head_landed / cumulative_opp_significant_strikes_landed AS cumulative_opp_significant_strikes_head_landed_per_significant_strike_landed,
        AVG(opp_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_head_attempted,
        cumulative_opp_significant_strikes_head_attempted,
        AVG(1.0 * opp_significant_strikes_head_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_head_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_head_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_head_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_head_attempted / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_head_attempted_per_significant_strike_attempted,
        1.0 * cumulative_opp_significant_strikes_head_attempted / cumulative_opp_significant_strikes_attempted AS cumulative_opp_significant_strikes_head_attempted_per_significant_strike_attempted,
        AVG(opp_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_body_landed,
        cumulative_opp_significant_strikes_body_landed,
        AVG(1.0 * opp_significant_strikes_body_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_body_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_body_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_body_landed_per_second,
        AVG(1.0 * opp_significant_strikes_body_landed / opp_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_body_accuracy,
        1.0 * cumulative_opp_significant_strikes_body_landed / cumulative_opp_significant_strikes_body_attempted AS cumulative_opp_significant_strikes_body_accuracy,
        AVG(1.0 * opp_significant_strikes_body_landed / opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_body_landed_per_significant_strike_landed,
        1.0 * cumulative_opp_significant_strikes_body_landed / cumulative_opp_significant_strikes_landed AS cumulative_opp_significant_strikes_body_landed_per_significant_strike_landed,
        AVG(opp_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_body_attempted,
        cumulative_opp_significant_strikes_body_attempted,
        AVG(1.0 * opp_significant_strikes_body_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_body_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_body_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_body_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_body_attempted / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_body_attempted_per_significant_strike_attempted,
        1.0 * cumulative_opp_significant_strikes_body_attempted / cumulative_opp_significant_strikes_attempted AS cumulative_opp_significant_strikes_body_attempted_per_significant_strike_attempted,
        AVG(opp_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_leg_landed,
        cumulative_opp_significant_strikes_leg_landed,
        AVG(1.0 * opp_significant_strikes_leg_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_leg_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_leg_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_leg_landed_per_second,
        AVG(1.0 * opp_significant_strikes_leg_landed / opp_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_leg_accuracy,
        1.0 * cumulative_opp_significant_strikes_leg_landed / cumulative_opp_significant_strikes_leg_attempted AS cumulative_opp_significant_strikes_leg_accuracy,
        AVG(1.0 * opp_significant_strikes_leg_landed / opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_leg_landed_per_significant_strike_landed,
        1.0 * cumulative_opp_significant_strikes_leg_landed / cumulative_opp_significant_strikes_landed AS cumulative_opp_significant_strikes_leg_landed_per_significant_strike_landed,
        AVG(opp_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_leg_attempted,
        cumulative_opp_significant_strikes_leg_attempted,
        AVG(1.0 * opp_significant_strikes_leg_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_leg_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_leg_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_leg_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_leg_attempted / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_leg_attempted_per_significant_strike_attempted,
        1.0 * cumulative_opp_significant_strikes_leg_attempted / cumulative_opp_significant_strikes_attempted AS cumulative_opp_significant_strikes_leg_attempted_per_significant_strike_attempted,
        AVG(opp_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_landed,
        cumulative_opp_significant_strikes_distance_landed,
        AVG(1.0 * opp_significant_strikes_distance_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_distance_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_distance_landed_per_second,
        AVG(1.0 * opp_significant_strikes_distance_landed / opp_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_accuracy,
        1.0 * cumulative_opp_significant_strikes_distance_landed / cumulative_opp_significant_strikes_distance_attempted AS cumulative_opp_significant_strikes_distance_accuracy,
        AVG(1.0 * opp_significant_strikes_distance_landed / opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_landed_per_significant_strike_landed,
        1.0 * cumulative_opp_significant_strikes_distance_landed / cumulative_opp_significant_strikes_landed AS cumulative_opp_significant_strikes_distance_landed_per_significant_strike_landed,
        AVG(opp_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_attempted,
        cumulative_opp_significant_strikes_distance_attempted,
        AVG(1.0 * opp_significant_strikes_distance_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_distance_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_distance_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_distance_attempted / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_attempted_per_significant_strike_attempted,
        1.0 * cumulative_opp_significant_strikes_distance_attempted / cumulative_opp_significant_strikes_attempted AS cumulative_opp_significant_strikes_distance_attempted_per_significant_strike_attempted,
        AVG(opp_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_landed,
        cumulative_opp_significant_strikes_clinch_landed,
        AVG(1.0 * opp_significant_strikes_clinch_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_clinch_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_clinch_landed_per_second,
        AVG(1.0 * opp_significant_strikes_clinch_landed / opp_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_accuracy,
        1.0 * cumulative_opp_significant_strikes_clinch_landed / cumulative_opp_significant_strikes_clinch_attempted AS cumulative_opp_significant_strikes_clinch_accuracy,
        AVG(1.0 * opp_significant_strikes_clinch_landed / opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_landed_per_significant_strike_landed,
        1.0 * cumulative_opp_significant_strikes_clinch_landed / cumulative_opp_significant_strikes_landed AS cumulative_opp_significant_strikes_clinch_landed_per_significant_strike_landed,
        AVG(opp_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_attempted,
        cumulative_opp_significant_strikes_clinch_attempted,
        AVG(1.0 * opp_significant_strikes_clinch_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_clinch_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_clinch_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_clinch_attempted / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_attempted_per_significant_strike_attempted,
        1.0 * cumulative_opp_significant_strikes_clinch_attempted / cumulative_opp_significant_strikes_attempted AS cumulative_opp_significant_strikes_clinch_attempted_per_significant_strike_attempted,
        AVG(opp_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_landed,
        cumulative_opp_significant_strikes_ground_landed,
        AVG(1.0 * opp_significant_strikes_ground_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_ground_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_ground_landed_per_second,
        AVG(1.0 * opp_significant_strikes_ground_landed / opp_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_accuracy,
        1.0 * cumulative_opp_significant_strikes_ground_landed / cumulative_opp_significant_strikes_ground_attempted AS cumulative_opp_significant_strikes_ground_accuracy,
        AVG(1.0 * opp_significant_strikes_ground_landed / opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_landed_per_significant_strike_landed,
        1.0 * cumulative_opp_significant_strikes_ground_landed / cumulative_opp_significant_strikes_landed AS cumulative_opp_significant_strikes_ground_landed_per_significant_strike_landed,
        AVG(opp_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_attempted,
        cumulative_opp_significant_strikes_ground_attempted,
        AVG(1.0 * opp_significant_strikes_ground_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_ground_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_ground_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_ground_attempted / opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_attempted_per_strike_attempted,
        1.0 * cumulative_opp_significant_strikes_ground_attempted / cumulative_opp_significant_strikes_attempted AS cumulative_opp_significant_strikes_ground_attempted_per_strike_attempted,
        AVG(opp_significant_strikes_distance_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_head_landed,
        cumulative_opp_significant_strikes_distance_head_landed,
        AVG(1.0 * opp_significant_strikes_distance_head_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_head_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_distance_head_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_distance_head_landed_per_second,
        AVG(1.0 * opp_significant_strikes_distance_head_landed / opp_significant_strikes_distance_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_head_accuracy,
        1.0 * cumulative_opp_significant_strikes_distance_head_landed / cumulative_opp_significant_strikes_distance_head_attempted AS cumulative_opp_significant_strikes_distance_head_accuracy,
        AVG(1.0 * opp_significant_strikes_distance_head_landed / opp_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_head_landed_per_significant_strike_distance_landed,
        1.0 * cumulative_opp_significant_strikes_distance_head_landed / cumulative_opp_significant_strikes_distance_landed AS cumulative_opp_significant_strikes_distance_head_landed_per_significant_strike_distance_landed,
        AVG(1.0 * opp_significant_strikes_distance_head_landed / opp_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_head_landed_per_significant_strike_head_landed,
        1.0 * cumulative_opp_significant_strikes_distance_head_landed / cumulative_opp_significant_strikes_head_landed AS cumulative_opp_significant_strikes_distance_head_landed_per_significant_strike_head_landed,
        AVG(opp_significant_strikes_distance_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_head_attempted,
        cumulative_opp_significant_strikes_distance_head_attempted,
        AVG(1.0 * opp_significant_strikes_distance_head_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_head_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_distance_head_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_distance_head_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_distance_head_attempted / opp_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted,
        1.0 * cumulative_opp_significant_strikes_distance_head_attempted / cumulative_opp_significant_strikes_distance_attempted AS cumulative_opp_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted,
        AVG(1.0 * opp_significant_strikes_distance_head_attempted / opp_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted,
        1.0 * cumulative_opp_significant_strikes_distance_head_attempted / cumulative_opp_significant_strikes_head_attempted AS cumulative_opp_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted,
        AVG(opp_significant_strikes_distance_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_body_landed,
        cumulative_opp_significant_strikes_distance_body_landed,
        AVG(1.0 * opp_significant_strikes_distance_body_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_body_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_distance_body_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_distance_body_landed_per_second,
        AVG(1.0 * opp_significant_strikes_distance_body_landed / opp_significant_strikes_distance_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_body_accuracy,
        1.0 * cumulative_opp_significant_strikes_distance_body_landed / cumulative_opp_significant_strikes_distance_body_attempted AS cumulative_opp_significant_strikes_distance_body_accuracy,
        AVG(1.0 * opp_significant_strikes_distance_body_landed / opp_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_body_landed_per_significant_strike_distance_landed,
        1.0 * cumulative_opp_significant_strikes_distance_body_landed / cumulative_opp_significant_strikes_distance_landed AS cumulative_opp_significant_strikes_distance_body_landed_per_significant_strike_distance_landed,
        AVG(1.0 * opp_significant_strikes_distance_body_landed / opp_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_body_landed_per_significant_strike_body_landed,
        1.0 * cumulative_opp_significant_strikes_distance_body_landed / cumulative_opp_significant_strikes_body_landed AS cumulative_opp_significant_strikes_distance_body_landed_per_significant_strike_body_landed,
        AVG(opp_significant_strikes_distance_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_body_attempted,
        cumulative_opp_significant_strikes_distance_body_attempted,
        AVG(1.0 * opp_significant_strikes_distance_body_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_body_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_distance_body_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_distance_body_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_distance_body_attempted / opp_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted,
        1.0 * cumulative_opp_significant_strikes_distance_body_attempted / cumulative_opp_significant_strikes_distance_attempted AS cumulative_opp_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted,
        AVG(1.0 * opp_significant_strikes_distance_body_attempted / opp_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted,
        1.0 * cumulative_opp_significant_strikes_distance_body_attempted / cumulative_opp_significant_strikes_body_attempted AS cumulative_opp_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted,
        AVG(opp_significant_strikes_distance_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_leg_landed,
        cumulative_opp_significant_strikes_distance_leg_landed,
        AVG(1.0 * opp_significant_strikes_distance_leg_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_leg_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_distance_leg_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_distance_leg_landed_per_second,
        AVG(1.0 * opp_significant_strikes_distance_leg_landed / opp_significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_leg_accuracy,
        1.0 * cumulative_opp_significant_strikes_distance_leg_landed / cumulative_opp_significant_strikes_distance_leg_attempted AS cumulative_opp_significant_strikes_distance_leg_accuracy,
        AVG(1.0 * opp_significant_strikes_distance_leg_landed / opp_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed,
        1.0 * cumulative_opp_significant_strikes_distance_leg_landed / cumulative_opp_significant_strikes_distance_landed AS cumulative_opp_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed,
        AVG(1.0 * opp_significant_strikes_distance_leg_landed / opp_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed,
        AVG(opp_significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_leg_attempted,
        cumulative_opp_significant_strikes_distance_leg_attempted,
        AVG(1.0 * opp_significant_strikes_distance_leg_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_leg_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_distance_leg_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_distance_leg_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_distance_leg_attempted / opp_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted,
        1.0 * cumulative_opp_significant_strikes_distance_leg_attempted / cumulative_opp_significant_strikes_distance_attempted AS cumulative_opp_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted,
        AVG(1.0 * opp_significant_strikes_distance_leg_attempted / opp_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted,
        1.0 * cumulative_opp_significant_strikes_distance_leg_attempted / cumulative_opp_significant_strikes_leg_attempted AS cumulative_opp_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted,
        AVG(opp_significant_strikes_clinch_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_head_landed,
        cumulative_opp_significant_strikes_clinch_head_landed,
        AVG(1.0 * opp_significant_strikes_clinch_head_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_head_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_clinch_head_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_clinch_head_landed_per_second,
        AVG(1.0 * opp_significant_strikes_clinch_head_landed / opp_significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_head_accuracy,
        1.0 * cumulative_opp_significant_strikes_clinch_head_landed / cumulative_opp_significant_strikes_clinch_head_attempted AS cumulative_opp_significant_strikes_clinch_head_accuracy,
        AVG(1.0 * opp_significant_strikes_clinch_head_landed / opp_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed,
        1.0 * cumulative_opp_significant_strikes_clinch_head_landed / cumulative_opp_significant_strikes_clinch_landed AS cumulative_opp_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed,
        AVG(1.0 * opp_significant_strikes_clinch_head_landed / opp_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_head_landed_per_significant_strike_head_landed,
        1.0 * cumulative_opp_significant_strikes_clinch_head_landed / cumulative_opp_significant_strikes_head_landed AS cumulative_opp_significant_strikes_clinch_head_landed_per_significant_strike_head_landed,
        AVG(opp_significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_head_attempted,
        cumulative_opp_significant_strikes_clinch_head_attempted,
        AVG(1.0 * opp_significant_strikes_clinch_head_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_head_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_clinch_head_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_clinch_head_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_clinch_head_attempted / opp_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted,
        1.0 * cumulative_opp_significant_strikes_clinch_head_attempted / cumulative_opp_significant_strikes_clinch_attempted AS cumulative_opp_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted,
        AVG(1.0 * opp_significant_strikes_clinch_head_attempted / opp_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted,
        1.0 * cumulative_opp_significant_strikes_clinch_head_attempted / cumulative_opp_significant_strikes_head_attempted AS cumulative_opp_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted,
        AVG(opp_significant_strikes_clinch_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_body_landed,
        cumulative_opp_significant_strikes_clinch_body_landed,
        AVG(1.0 * opp_significant_strikes_clinch_body_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_body_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_clinch_body_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_clinch_body_landed_per_second,
        AVG(1.0 * opp_significant_strikes_clinch_body_landed / opp_significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_body_accuracy,
        1.0 * cumulative_opp_significant_strikes_clinch_body_landed / cumulative_opp_significant_strikes_clinch_body_attempted AS cumulative_opp_significant_strikes_clinch_body_accuracy,
        AVG(1.0 * opp_significant_strikes_clinch_body_landed / opp_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed,
        1.0 * cumulative_opp_significant_strikes_clinch_body_landed / cumulative_opp_significant_strikes_clinch_landed AS cumulative_opp_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed,
        AVG(1.0 * opp_significant_strikes_clinch_body_landed / opp_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_body_landed_per_significant_strike_body_landed,
        1.0 * cumulative_opp_significant_strikes_clinch_body_landed / cumulative_opp_significant_strikes_body_landed AS cumulative_opp_significant_strikes_clinch_body_landed_per_significant_strike_body_landed,
        AVG(opp_significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_body_attempted,
        cumulative_opp_significant_strikes_clinch_body_attempted,
        AVG(1.0 * opp_significant_strikes_clinch_body_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_body_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_clinch_body_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_clinch_body_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_clinch_body_attempted / opp_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted,
        1.0 * cumulative_opp_significant_strikes_clinch_body_attempted / cumulative_opp_significant_strikes_clinch_attempted AS cumulative_opp_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted,
        AVG(1.0 * opp_significant_strikes_clinch_body_attempted / opp_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted,
        1.0 * cumulative_opp_significant_strikes_clinch_body_attempted / cumulative_opp_significant_strikes_body_attempted AS cumulative_opp_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted,
        AVG(opp_significant_strikes_clinch_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_leg_landed,
        1.0 * cumulative_opp_significant_strikes_clinch_leg_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_clinch_leg_landed_per_second,
        AVG(1.0 * opp_significant_strikes_clinch_leg_landed / opp_significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_leg_accuracy,
        1.0 * cumulative_opp_significant_strikes_clinch_leg_landed / cumulative_opp_significant_strikes_clinch_leg_attempted AS cumulative_opp_significant_strikes_clinch_leg_accuracy,
        AVG(1.0 * opp_significant_strikes_clinch_leg_landed / opp_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed,
        1.0 * cumulative_opp_significant_strikes_clinch_leg_landed / cumulative_opp_significant_strikes_clinch_landed AS cumulative_opp_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed,
        AVG(1.0 * opp_significant_strikes_clinch_leg_landed / opp_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed,
        1.0 * cumulative_opp_significant_strikes_clinch_leg_landed / cumulative_opp_significant_strikes_leg_landed AS cumulative_opp_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed,
        AVG(opp_significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_leg_attempted,
        cumulative_opp_significant_strikes_clinch_leg_attempted,
        AVG(1.0 * opp_significant_strikes_clinch_leg_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_leg_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_clinch_leg_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_clinch_leg_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_clinch_leg_attempted / opp_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted,
        1.0 * cumulative_opp_significant_strikes_clinch_leg_attempted / cumulative_opp_significant_strikes_clinch_attempted AS cumulative_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted,
        AVG(1.0 * opp_significant_strikes_clinch_leg_attempted / opp_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted,
        1.0 * cumulative_opp_significant_strikes_clinch_leg_attempted / cumulative_opp_significant_strikes_leg_attempted AS cumulative_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted,
        AVG(opp_significant_strikes_ground_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_head_landed,
        cumulative_opp_significant_strikes_ground_head_landed,
        AVG(1.0 * opp_significant_strikes_ground_head_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_head_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_ground_head_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_ground_head_landed_per_second,
        AVG(1.0 * opp_significant_strikes_ground_head_landed / opp_significant_strikes_ground_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_head_accuracy,
        1.0 * cumulative_opp_significant_strikes_ground_head_landed / cumulative_opp_significant_strikes_ground_head_attempted AS cumulative_opp_significant_strikes_ground_head_accuracy,
        AVG(1.0 * opp_significant_strikes_ground_head_landed / opp_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_head_landed_per_significant_strike_ground_landed,
        1.0 * cumulative_opp_significant_strikes_ground_head_landed / cumulative_opp_significant_strikes_ground_landed AS cumulative_opp_significant_strikes_ground_head_landed_per_significant_strike_ground_landed,
        AVG(1.0 * opp_significant_strikes_ground_head_landed / opp_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_head_landed_per_significant_strike_head_landed,
        1.0 * cumulative_opp_significant_strikes_ground_head_landed / cumulative_opp_significant_strikes_head_landed AS cumulative_opp_significant_strikes_ground_head_landed_per_significant_strike_head_landed,
        AVG(opp_significant_strikes_ground_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_head_attempted,
        cumulative_opp_significant_strikes_ground_head_attempted,
        AVG(1.0 * opp_significant_strikes_ground_head_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_head_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_ground_head_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_ground_head_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_ground_head_attempted / opp_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted,
        1.0 * cumulative_opp_significant_strikes_ground_head_attempted / cumulative_opp_significant_strikes_ground_attempted AS cumulative_opp_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted,
        AVG(1.0 * opp_significant_strikes_ground_head_attempted / opp_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted,
        1.0 * cumulative_opp_significant_strikes_ground_head_attempted / cumulative_opp_significant_strikes_head_attempted AS cumulative_opp_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted,
        AVG(opp_significant_strikes_ground_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_body_landed,
        cumulative_opp_significant_strikes_ground_body_landed,
        AVG(1.0 * opp_significant_strikes_ground_body_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_body_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_ground_body_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_ground_body_landed_per_second,
        AVG(1.0 * opp_significant_strikes_ground_body_landed / opp_significant_strikes_ground_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_body_accuracy,
        1.0 * cumulative_opp_significant_strikes_ground_body_landed / cumulative_opp_significant_strikes_ground_body_attempted AS cumulative_opp_significant_strikes_ground_body_accuracy,
        AVG(1.0 * opp_significant_strikes_ground_body_landed / opp_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_body_landed_per_significant_strike_ground_landed,
        1.0 * cumulative_opp_significant_strikes_ground_body_landed / cumulative_opp_significant_strikes_ground_landed AS cumulative_opp_significant_strikes_ground_body_landed_per_significant_strike_ground_landed,
        AVG(1.0 * opp_significant_strikes_ground_body_landed / opp_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_body_landed_per_significant_strike_body_landed,
        1.0 * cumulative_opp_significant_strikes_ground_body_landed / cumulative_opp_significant_strikes_body_landed AS cumulative_opp_significant_strikes_ground_body_landed_per_significant_strike_body_landed,
        AVG(opp_significant_strikes_ground_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_body_attempted,
        cumulative_opp_significant_strikes_ground_body_attempted,
        AVG(1.0 * opp_significant_strikes_ground_body_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_body_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_ground_body_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_ground_body_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_ground_body_attempted / opp_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted,
        1.0 * cumulative_opp_significant_strikes_ground_body_attempted / cumulative_opp_significant_strikes_ground_attempted AS cumulative_opp_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted,
        AVG(1.0 * opp_significant_strikes_ground_body_attempted / opp_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted,
        1.0 * cumulative_opp_significant_strikes_ground_body_attempted / cumulative_opp_significant_strikes_body_attempted AS cumulative_opp_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted,
        AVG(opp_significant_strikes_ground_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_leg_landed,
        cumulative_opp_significant_strikes_ground_leg_landed,
        AVG(1.0 * opp_significant_strikes_ground_leg_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_leg_landed_per_second,
        1.0 * cumulative_opp_significant_strikes_ground_leg_landed / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_ground_leg_landed_per_second,
        AVG(1.0 * opp_significant_strikes_ground_leg_landed / opp_significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_leg_accuracy,
        1.0 * cumulative_opp_significant_strikes_ground_leg_landed / cumulative_opp_significant_strikes_ground_leg_attempted AS cumulative_opp_significant_strikes_ground_leg_accuracy,
        AVG(1.0 * opp_significant_strikes_ground_leg_landed / opp_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed,
        1.0 * cumulative_opp_significant_strikes_ground_leg_landed / cumulative_opp_significant_strikes_ground_landed AS cumulative_opp_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed,
        AVG(1.0 * opp_significant_strikes_ground_leg_landed / opp_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed,
        1.0 * cumulative_opp_significant_strikes_ground_leg_landed / cumulative_opp_significant_strikes_leg_landed AS cumulative_opp_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed,
        AVG(opp_significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_leg_attempted,
        cumulative_opp_significant_strikes_ground_leg_attempted,
        AVG(1.0 * opp_significant_strikes_ground_leg_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_leg_attempted_per_second,
        1.0 * cumulative_opp_significant_strikes_ground_leg_attempted / cumulative_total_time_seconds AS cumulative_opp_significant_strikes_ground_leg_attempted_per_second,
        AVG(1.0 * opp_significant_strikes_ground_leg_attempted / opp_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted,
        1.0 * cumulative_opp_significant_strikes_ground_leg_attempted / cumulative_opp_significant_strikes_ground_attempted AS cumulative_opp_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted,
        AVG(1.0 * opp_significant_strikes_ground_leg_attempted / opp_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted,
        1.0 * cumulative_opp_significant_strikes_ground_leg_attempted / cumulative_opp_significant_strikes_leg_attempted AS cumulative_opp_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted,
        AVG(opp_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_takedowns_landed,
        cumulative_opp_takedowns_landed,
        AVG(1.0 * opp_takedowns_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_takedowns_landed_per_second,
        1.0 * cumulative_opp_takedowns_landed / cumulative_total_time_seconds AS cumulative_opp_takedowns_landed_per_second,
        AVG(1.0 * opp_takedowns_landed / opp_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_takedowns_accuracy,
        1.0 * cumulative_opp_takedowns_landed / cumulative_opp_takedowns_attempted AS cumulative_opp_takedowns_accuracy,
        AVG(opp_takedowns_slams_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_takedowns_slams_landed,
        cumulative_opp_takedowns_slams_landed,
        AVG(1.0 * opp_takedowns_slams_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_takedowns_slams_landed_per_second,
        1.0 * cumulative_opp_takedowns_slams_landed / cumulative_total_time_seconds AS cumulative_opp_takedowns_slams_landed_per_second,
        AVG(1.0 * opp_takedowns_slams_landed / opp_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_takedowns_slams_landed_per_takedowns_landed,
        1.0 * cumulative_opp_takedowns_slams_landed / cumulative_opp_takedowns_landed AS cumulative_opp_takedowns_slams_landed_per_takedowns_landed,
        AVG(opp_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_takedowns_attempted,
        cumulative_opp_takedowns_attempted,
        AVG(1.0 * opp_takedowns_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_takedowns_attempted_per_second,
        1.0 * cumulative_opp_takedowns_attempted / cumulative_total_time_seconds AS cumulative_opp_takedowns_attempted_per_second,
        AVG(opp_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances,
        cumulative_opp_advances,
        AVG(1.0 * opp_advances / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_per_second,
        1.0 * cumulative_opp_advances / cumulative_total_time_seconds AS cumulative_opp_advances_per_second,
        AVG(opp_advances_to_back) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_back,
        cumulative_opp_advances_to_back,
        AVG(1.0 * opp_advances_to_back / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_back_per_second,
        1.0 * cumulative_opp_advances_to_back / cumulative_total_time_seconds AS cumulative_opp_advances_to_back_per_second,
        AVG(1.0 * opp_advances_to_back / opp_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_back_per_advances,
        1.0 * cumulative_opp_advances_to_back / cumulative_opp_advances AS cumulative_opp_advances_to_back_per_advances,
        AVG(opp_advances_to_half_guard) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_half_guard,
        cumulative_opp_advances_to_half_guard,
        AVG(1.0 * opp_advances_to_half_guard / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_half_guard_per_second,
        1.0 * cumulative_opp_advances_to_half_guard / cumulative_total_time_seconds AS cumulative_opp_advances_to_half_guard_per_second,
        AVG(1.0 * opp_advances_to_half_guard / opp_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_half_guard_per_advances,
        1.0 * cumulative_opp_advances_to_half_guard / cumulative_opp_advances AS cumulative_opp_advances_to_half_guard_per_advances,
        AVG(opp_advances_to_mount) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_mount,
        cumulative_opp_advances_to_mount,
        AVG(1.0 * opp_advances_to_mount / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_mount_per_second,
        1.0 * cumulative_opp_advances_to_mount / cumulative_total_time_seconds AS cumulative_opp_advances_to_mount_per_second,
        AVG(1.0 * opp_advances_to_mount / opp_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_mount_per_advances,
        1.0 * cumulative_opp_advances_to_mount / cumulative_opp_advances AS cumulative_opp_advances_to_mount_per_advances,
        AVG(opp_advances_to_side) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_side,
        cumulative_opp_advances_to_side,
        AVG(1.0 * opp_advances_to_side / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_side_per_second,
        1.0 * cumulative_opp_advances_to_side / cumulative_total_time_seconds AS cumulative_opp_advances_to_side_per_second,
        AVG(1.0 * opp_advances_to_side / opp_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_advances_to_side_per_advances,
        1.0 * cumulative_opp_advances_to_side / cumulative_opp_advances AS cumulative_opp_advances_to_side_per_advances,
        AVG(opp_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_reversals_scored,
        cumulative_opp_reversals_scored,
        AVG(1.0 * opp_reversals_scored / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_reversals_scored_per_second,
        1.0 * cumulative_opp_reversals_scored / cumulative_total_time_seconds AS cumulative_opp_reversals_scored_per_second,
        AVG(opp_submissions_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_submissions_landed,
        cumulative_opp_submissions_landed,
        AVG(1.0 * opp_submissions_landed / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_submissions_landed_per_second,
        1.0 * cumulative_opp_submissions_landed / cumulative_total_time_seconds AS cumulative_opp_submissions_landed_per_second,
        AVG(1.0 * opp_submissions_landed / opp_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_submissions_accuracy,
        1.0 * cumulative_opp_submissions_landed / cumulative_opp_submissions_attempted AS cumulative_opp_submissions_accuracy,
        AVG(opp_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_submissions_attempted,
        cumulative_opp_submissions_attempted,
        AVG(1.0 * opp_submissions_attempted / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_submissions_attempted_per_second,
        1.0 * cumulative_opp_submissions_attempted / cumulative_total_time_seconds AS cumulative_opp_submissions_attempted_per_second,
        AVG(opp_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_control_time_seconds,
        cumulative_opp_control_time_seconds,
        AVG(1.0 * opp_control_time_seconds / total_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_control_time_seconds_per_second,
        1.0 * cumulative_opp_control_time_seconds / cumulative_total_time_seconds AS cumulative_opp_control_time_seconds_per_second
    FROM
        cte5 AS t1
),
cte7 AS (
    SELECT
        t1.*,
        AVG(t2.avg_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_knockdowns_scored,
        AVG(t1.avg_knockdowns_scored - t2.avg_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_knockdowns_scored_diff,
        AVG(t2.cumulative_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_knockdowns_scored,
        AVG(t1.cumulative_knockdowns_scored - t2.cumulative_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_knockdowns_scored_diff,
        AVG(t2.avg_knockdowns_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_knockdowns_scored_per_second,
        AVG(t1.avg_knockdowns_scored_per_second - t2.avg_knockdowns_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_knockdowns_scored_per_second_diff,
        AVG(t2.cumulative_knockdowns_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_knockdowns_scored_per_second,
        AVG(t1.cumulative_knockdowns_scored_per_second - t2.cumulative_knockdowns_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_knockdowns_scored_per_second_diff,
        AVG(t2.avg_knockdowns_scored_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_knockdowns_scored_per_strike_landed,
        AVG(t1.avg_knockdowns_scored_per_strike_landed - t2.avg_knockdowns_scored_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_knockdowns_scored_per_strike_landed_diff,
        AVG(t2.cumulative_knockdowns_scored_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_knockdowns_scored_per_strike_landed,
        AVG(t1.cumulative_knockdowns_scored_per_strike_landed - t2.cumulative_knockdowns_scored_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_knockdowns_scored_per_strike_landed_diff,
        AVG(t2.avg_knockdowns_scored_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_knockdowns_scored_per_strike_attempted,
        AVG(t1.avg_knockdowns_scored_per_strike_attempted - t2.avg_knockdowns_scored_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_knockdowns_scored_per_strike_attempted_diff,
        AVG(t2.cumulative_knockdowns_scored_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_knockdowns_scored_per_strike_attempted,
        AVG(t1.cumulative_knockdowns_scored_per_strike_attempted - t2.cumulative_knockdowns_scored_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_knockdowns_scored_per_strike_attempted_diff,
        AVG(t2.avg_knockdowns_scored_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_knockdowns_scored_per_significant_strike_landed,
        AVG(t1.avg_knockdowns_scored_per_significant_strike_landed - t2.avg_knockdowns_scored_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_knockdowns_scored_per_significant_strike_landed_diff,
        AVG(t2.cumulative_knockdowns_scored_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_knockdowns_scored_per_significant_strike_landed,
        AVG(t1.cumulative_knockdowns_scored_per_significant_strike_landed - t2.cumulative_knockdowns_scored_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_knockdowns_scored_per_significant_strike_landed_diff,
        AVG(t2.avg_knockdowns_scored_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_knockdowns_scored_per_significant_strike_attempted,
        AVG(t1.avg_knockdowns_scored_per_significant_strike_attempted - t2.avg_knockdowns_scored_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_knockdowns_scored_per_significant_strike_attempted_diff,
        AVG(t2.cumulative_knockdowns_scored_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_knockdowns_scored_per_significant_strike_attempted,
        AVG(t1.cumulative_knockdowns_scored_per_significant_strike_attempted - t2.cumulative_knockdowns_scored_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_knockdowns_scored_per_significant_strike_attempted_diff,
        AVG(t2.avg_knockdowns_scored_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_knockdowns_scored_per_significant_strike_head_landed,
        AVG(t1.avg_knockdowns_scored_per_significant_strike_head_landed - t2.avg_knockdowns_scored_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_knockdowns_scored_per_significant_strike_head_landed_diff,
        AVG(t2.cumulative_knockdowns_scored_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_knockdowns_scored_per_significant_strike_head_landed,
        AVG(t1.cumulative_knockdowns_scored_per_significant_strike_head_landed - t2.cumulative_knockdowns_scored_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_knockdowns_scored_per_significant_strike_head_landed_diff,
        AVG(t2.avg_knockdowns_scored_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(t1.avg_knockdowns_scored_per_significant_strike_head_attempted - t2.avg_knockdowns_scored_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_knockdowns_scored_per_significant_strike_head_attempted_diff,
        AVG(t2.cumulative_knockdowns_scored_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(t1.cumulative_knockdowns_scored_per_significant_strike_head_attempted - t2.cumulative_knockdowns_scored_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_knockdowns_scored_per_significant_strike_head_attempted_diff,
        AVG(t2.avg_ko_tko_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ko_tko_landed,
        AVG(t1.avg_ko_tko_landed - t2.avg_ko_tko_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ko_tko_landed_diff,
        AVG(t2.cumulative_ko_tko_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_ko_tko_landed,
        AVG(t1.cumulative_ko_tko_landed - t2.cumulative_ko_tko_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_ko_tko_landed_diff,
        AVG(t2.avg_ko_tko_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ko_tko_landed_per_second,
        AVG(t1.avg_ko_tko_landed_per_second - t2.avg_ko_tko_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ko_tko_landed_per_second_diff,
        AVG(t2.cumulative_ko_tko_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_ko_tko_landed_per_second,
        AVG(t1.cumulative_ko_tko_landed_per_second - t2.cumulative_ko_tko_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_ko_tko_landed_per_second_diff,
        AVG(t2.avg_ko_tko_landed_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ko_tko_landed_per_strike_landed,
        AVG(t1.avg_ko_tko_landed_per_strike_landed - t2.avg_ko_tko_landed_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ko_tko_landed_per_strike_landed_diff,
        AVG(t2.cumulative_ko_tko_landed_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_ko_tko_landed_per_strike_landed,
        AVG(t1.cumulative_ko_tko_landed_per_strike_landed - t2.cumulative_ko_tko_landed_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_ko_tko_landed_per_strike_landed_diff,
        AVG(t2.avg_ko_tko_landed_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ko_tko_landed_per_strike_attempted,
        AVG(t1.avg_ko_tko_landed_per_strike_attempted - t2.avg_ko_tko_landed_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ko_tko_landed_per_strike_attempted_diff,
        AVG(t2.cumulative_ko_tko_landed_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_ko_tko_landed_per_strike_attempted,
        AVG(t1.cumulative_ko_tko_landed_per_strike_attempted - t2.cumulative_ko_tko_landed_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_ko_tko_landed_per_strike_attempted_diff,
        AVG(t2.avg_ko_tko_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ko_tko_landed_per_significant_strike_landed,
        AVG(t1.avg_ko_tko_landed_per_significant_strike_landed - t2.avg_ko_tko_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ko_tko_landed_per_significant_strike_landed_diff,
        AVG(t2.cumulative_ko_tko_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_ko_tko_landed_per_significant_strike_landed,
        AVG(t1.cumulative_ko_tko_landed_per_significant_strike_landed - t2.cumulative_ko_tko_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_ko_tko_landed_per_significant_strike_landed_diff,
        AVG(t2.avg_ko_tko_landed_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ko_tko_landed_per_significant_strike_attempted,
        AVG(t1.avg_ko_tko_landed_per_significant_strike_attempted - t2.avg_ko_tko_landed_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ko_tko_landed_per_significant_strike_attempted_diff,
        AVG(t2.cumulative_ko_tko_landed_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_ko_tko_landed_per_significant_strike_attempted,
        AVG(t1.cumulative_ko_tko_landed_per_significant_strike_attempted - t2.cumulative_ko_tko_landed_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_ko_tko_landed_per_significant_strike_attempted_diff,
        AVG(t2.avg_ko_tko_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ko_tko_landed_per_significant_strike_head_landed,
        AVG(t1.avg_ko_tko_landed_per_significant_strike_head_landed - t2.avg_ko_tko_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ko_tko_landed_per_significant_strike_head_landed_diff,
        AVG(t2.cumulative_ko_tko_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_ko_tko_landed_per_significant_strike_head_landed,
        AVG(t1.cumulative_ko_tko_landed_per_significant_strike_head_landed - t2.cumulative_ko_tko_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_ko_tko_landed_per_significant_strike_head_landed_diff,
        AVG(t2.avg_ko_tko_landed_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ko_tko_landed_per_significant_strike_head_attempted,
        AVG(t1.avg_ko_tko_landed_per_significant_strike_head_attempted - t2.avg_ko_tko_landed_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ko_tko_landed_per_significant_strike_head_attempted_diff,
        AVG(t2.cumulative_ko_tko_landed_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_ko_tko_landed_per_significant_strike_head_attempted,
        AVG(t1.cumulative_ko_tko_landed_per_significant_strike_head_attempted - t2.cumulative_ko_tko_landed_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_ko_tko_landed_per_significant_strike_head_attempted_diff,
        AVG(t2.avg_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_total_strikes_landed,
        AVG(t1.avg_total_strikes_landed - t2.avg_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_total_strikes_landed_diff,
        AVG(t2.cumulative_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_total_strikes_landed,
        AVG(t1.cumulative_total_strikes_landed - t2.cumulative_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_total_strikes_landed_diff,
        AVG(t2.avg_total_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_total_strikes_landed_per_second,
        AVG(t1.avg_total_strikes_landed_per_second - t2.avg_total_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_total_strikes_landed_per_second_diff,
        AVG(t2.cumulative_total_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_total_strikes_landed_per_second,
        AVG(t1.cumulative_total_strikes_landed_per_second - t2.cumulative_total_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_total_strikes_landed_per_second_diff,
        AVG(t2.avg_total_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_total_strikes_accuracy,
        AVG(t1.avg_total_strikes_accuracy - t2.avg_total_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_total_strikes_accuracy_diff,
        AVG(t2.cumulative_total_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_total_strikes_accuracy,
        AVG(t1.cumulative_total_strikes_accuracy - t2.cumulative_total_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_total_strikes_accuracy_diff,
        AVG(t2.avg_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_total_strikes_attempted,
        AVG(t1.avg_total_strikes_attempted - t2.avg_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_total_strikes_attempted_diff,
        AVG(t2.cumulative_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_total_strikes_attempted,
        AVG(t1.cumulative_total_strikes_attempted - t2.cumulative_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_total_strikes_attempted_diff,
        AVG(t2.avg_total_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_total_strikes_attempted_per_second,
        AVG(t1.avg_total_strikes_attempted_per_second - t2.avg_total_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_total_strikes_attempted_per_second_diff,
        AVG(t2.cumulative_total_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_total_strikes_attempted_per_second,
        AVG(t1.cumulative_total_strikes_attempted_per_second - t2.cumulative_total_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_total_strikes_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_landed,
        AVG(t1.avg_significant_strikes_landed - t2.avg_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_landed_diff,
        AVG(t2.cumulative_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_landed,
        AVG(t1.cumulative_significant_strikes_landed - t2.cumulative_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_landed_diff,
        AVG(t2.avg_significant_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_landed_per_second,
        AVG(t1.avg_significant_strikes_landed_per_second - t2.avg_significant_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_landed_per_second,
        AVG(t1.cumulative_significant_strikes_landed_per_second - t2.cumulative_significant_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_accuracy,
        AVG(t1.avg_significant_strikes_accuracy - t2.avg_significant_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_accuracy,
        AVG(t1.cumulative_significant_strikes_accuracy - t2.cumulative_significant_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_accuracy_diff,
        AVG(t2.avg_significant_strikes_landed_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_landed_per_strike_landed,
        AVG(t1.avg_significant_strikes_landed_per_strike_landed - t2.avg_significant_strikes_landed_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_landed_per_strike_landed_diff,
        AVG(t2.cumulative_significant_strikes_landed_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_landed_per_strike_landed,
        AVG(t1.cumulative_significant_strikes_landed_per_strike_landed - t2.cumulative_significant_strikes_landed_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_landed_per_strike_landed_diff,
        AVG(t2.avg_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_attempted,
        AVG(t1.avg_significant_strikes_attempted - t2.avg_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_attempted_diff,
        AVG(t2.cumulative_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_attempted,
        AVG(t1.cumulative_significant_strikes_attempted - t2.cumulative_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_attempted_diff,
        AVG(t2.avg_significant_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_attempted_per_second,
        AVG(t1.avg_significant_strikes_attempted_per_second - t2.avg_significant_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_attempted_per_second - t2.cumulative_significant_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_attempted_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_attempted_per_strike_attempted,
        AVG(t1.avg_significant_strikes_attempted_per_strike_attempted - t2.avg_significant_strikes_attempted_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_attempted_per_strike_attempted_diff,
        AVG(t2.cumulative_significant_strikes_attempted_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_attempted_per_strike_attempted,
        AVG(t1.cumulative_significant_strikes_attempted_per_strike_attempted - t2.cumulative_significant_strikes_attempted_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_attempted_per_strike_attempted_diff,
        AVG(t2.avg_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_head_landed,
        AVG(t1.avg_significant_strikes_head_landed - t2.avg_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_head_landed_diff,
        AVG(t2.cumulative_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_head_landed,
        AVG(t1.cumulative_significant_strikes_head_landed - t2.cumulative_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_head_landed_diff,
        AVG(t2.avg_significant_strikes_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_head_landed_per_second,
        AVG(t1.avg_significant_strikes_head_landed_per_second - t2.avg_significant_strikes_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_head_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_head_landed_per_second,
        AVG(t1.cumulative_significant_strikes_head_landed_per_second - t2.cumulative_significant_strikes_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_head_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_head_accuracy,
        AVG(t1.avg_significant_strikes_head_accuracy - t2.avg_significant_strikes_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_head_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_head_accuracy,
        AVG(t1.cumulative_significant_strikes_head_accuracy - t2.cumulative_significant_strikes_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_head_accuracy_diff,
        AVG(t2.avg_significant_strikes_head_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_head_landed_per_significant_strike_landed,
        AVG(t1.avg_significant_strikes_head_landed_per_significant_strike_landed - t2.avg_significant_strikes_head_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_head_landed_per_significant_strike_landed_diff,
        AVG(t2.cumulative_significant_strikes_head_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_head_landed_per_significant_strike_landed,
        AVG(t1.cumulative_significant_strikes_head_landed_per_significant_strike_landed - t2.cumulative_significant_strikes_head_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_head_landed_per_significant_strike_landed_diff,
        AVG(t2.avg_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_head_attempted,
        AVG(t1.avg_significant_strikes_head_attempted - t2.avg_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_head_attempted_diff,
        AVG(t2.cumulative_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_head_attempted,
        AVG(t1.cumulative_significant_strikes_head_attempted - t2.cumulative_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_head_attempted_diff,
        AVG(t2.avg_significant_strikes_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_head_attempted_per_second,
        AVG(t1.avg_significant_strikes_head_attempted_per_second - t2.avg_significant_strikes_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_head_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_head_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_head_attempted_per_second - t2.cumulative_significant_strikes_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_head_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_head_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_head_attempted_per_significant_strike_attempted,
        AVG(t1.avg_significant_strikes_head_attempted_per_significant_strike_attempted - t2.avg_significant_strikes_head_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_head_attempted_per_significant_strike_attempted_diff,
        AVG(t2.cumulative_significant_strikes_head_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_head_attempted_per_significant_strike_attempted,
        AVG(t1.cumulative_significant_strikes_head_attempted_per_significant_strike_attempted - t2.cumulative_significant_strikes_head_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_head_attempted_per_significant_strike_attempted_diff,
        AVG(t2.avg_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_body_landed,
        AVG(t1.avg_significant_strikes_body_landed - t2.avg_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_body_landed_diff,
        AVG(t2.cumulative_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_body_landed,
        AVG(t1.cumulative_significant_strikes_body_landed - t2.cumulative_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_body_landed_diff,
        AVG(t2.avg_significant_strikes_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_body_landed_per_second,
        AVG(t1.avg_significant_strikes_body_landed_per_second - t2.avg_significant_strikes_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_body_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_body_landed_per_second,
        AVG(t1.cumulative_significant_strikes_body_landed_per_second - t2.cumulative_significant_strikes_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_body_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_body_accuracy,
        AVG(t1.avg_significant_strikes_body_accuracy - t2.avg_significant_strikes_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_body_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_body_accuracy,
        AVG(t1.cumulative_significant_strikes_body_accuracy - t2.cumulative_significant_strikes_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_body_accuracy_diff,
        AVG(t2.avg_significant_strikes_body_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_body_landed_per_significant_strike_landed,
        AVG(t1.avg_significant_strikes_body_landed_per_significant_strike_landed - t2.avg_significant_strikes_body_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_body_landed_per_significant_strike_landed_diff,
        AVG(t2.cumulative_significant_strikes_body_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_body_landed_per_significant_strike_landed,
        AVG(t1.cumulative_significant_strikes_body_landed_per_significant_strike_landed - t2.cumulative_significant_strikes_body_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_body_landed_per_significant_strike_landed_diff,
        AVG(t2.avg_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_body_attempted,
        AVG(t1.avg_significant_strikes_body_attempted - t2.avg_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_body_attempted_diff,
        AVG(t2.cumulative_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_body_attempted,
        AVG(t1.cumulative_significant_strikes_body_attempted - t2.cumulative_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_body_attempted_diff,
        AVG(t2.avg_significant_strikes_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_body_attempted_per_second,
        AVG(t1.avg_significant_strikes_body_attempted_per_second - t2.avg_significant_strikes_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_body_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_body_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_body_attempted_per_second - t2.cumulative_significant_strikes_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_body_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_body_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_body_attempted_per_significant_strike_attempted,
        AVG(t1.avg_significant_strikes_body_attempted_per_significant_strike_attempted - t2.avg_significant_strikes_body_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_body_attempted_per_significant_strike_attempted_diff,
        AVG(t2.cumulative_significant_strikes_body_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_body_attempted_per_significant_strike_attempted,
        AVG(t1.cumulative_significant_strikes_body_attempted_per_significant_strike_attempted - t2.cumulative_significant_strikes_body_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_body_attempted_per_significant_strike_attempted_diff,
        AVG(t2.avg_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_leg_landed,
        AVG(t1.avg_significant_strikes_leg_landed - t2.avg_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_leg_landed_diff,
        AVG(t2.cumulative_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_leg_landed,
        AVG(t1.cumulative_significant_strikes_leg_landed - t2.cumulative_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_leg_landed_diff,
        AVG(t2.avg_significant_strikes_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_leg_landed_per_second,
        AVG(t1.avg_significant_strikes_leg_landed_per_second - t2.avg_significant_strikes_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_leg_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_leg_landed_per_second,
        AVG(t1.cumulative_significant_strikes_leg_landed_per_second - t2.cumulative_significant_strikes_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_leg_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_leg_accuracy,
        AVG(t1.avg_significant_strikes_leg_accuracy - t2.avg_significant_strikes_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_leg_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_leg_accuracy,
        AVG(t1.cumulative_significant_strikes_leg_accuracy - t2.cumulative_significant_strikes_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_leg_accuracy_diff,
        AVG(t2.avg_significant_strikes_leg_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_leg_landed_per_significant_strike_landed,
        AVG(t1.avg_significant_strikes_leg_landed_per_significant_strike_landed - t2.avg_significant_strikes_leg_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_leg_landed_per_significant_strike_landed_diff,
        AVG(t2.cumulative_significant_strikes_leg_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_leg_landed_per_significant_strike_landed,
        AVG(t1.cumulative_significant_strikes_leg_landed_per_significant_strike_landed - t2.cumulative_significant_strikes_leg_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_leg_landed_per_significant_strike_landed_diff,
        AVG(t2.avg_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_leg_attempted,
        AVG(t1.avg_significant_strikes_leg_attempted - t2.avg_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_leg_attempted_diff,
        AVG(t2.cumulative_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_leg_attempted,
        AVG(t1.cumulative_significant_strikes_leg_attempted - t2.cumulative_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_leg_attempted_diff,
        AVG(t2.avg_significant_strikes_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_leg_attempted_per_second,
        AVG(t1.avg_significant_strikes_leg_attempted_per_second - t2.avg_significant_strikes_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_leg_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_leg_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_leg_attempted_per_second - t2.cumulative_significant_strikes_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_leg_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_leg_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_leg_attempted_per_significant_strike_attempted,
        AVG(t1.avg_significant_strikes_leg_attempted_per_significant_strike_attempted - t2.avg_significant_strikes_leg_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_leg_attempted_per_significant_strike_attempted_diff,
        AVG(t2.cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted,
        AVG(t1.cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted - t2.cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_landed,
        AVG(t1.avg_significant_strikes_distance_landed - t2.avg_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_landed,
        AVG(t1.cumulative_significant_strikes_distance_landed - t2.cumulative_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_landed_diff,
        AVG(t2.avg_significant_strikes_distance_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_landed_per_second,
        AVG(t1.avg_significant_strikes_distance_landed_per_second - t2.avg_significant_strikes_distance_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_distance_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_landed_per_second,
        AVG(t1.cumulative_significant_strikes_distance_landed_per_second - t2.cumulative_significant_strikes_distance_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_distance_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_accuracy,
        AVG(t1.avg_significant_strikes_distance_accuracy - t2.avg_significant_strikes_distance_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_distance_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_accuracy,
        AVG(t1.cumulative_significant_strikes_distance_accuracy - t2.cumulative_significant_strikes_distance_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_accuracy_diff,
        AVG(t2.avg_significant_strikes_distance_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_landed_per_significant_strike_landed,
        AVG(t1.avg_significant_strikes_distance_landed_per_significant_strike_landed - t2.avg_significant_strikes_distance_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_landed_per_significant_strike_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_landed_per_significant_strike_landed,
        AVG(t1.cumulative_significant_strikes_distance_landed_per_significant_strike_landed - t2.cumulative_significant_strikes_distance_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_landed_per_significant_strike_landed_diff,
        AVG(t2.avg_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_attempted,
        AVG(t1.avg_significant_strikes_distance_attempted - t2.avg_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_attempted,
        AVG(t1.cumulative_significant_strikes_distance_attempted - t2.cumulative_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_attempted_per_second,
        AVG(t1.avg_significant_strikes_distance_attempted_per_second - t2.avg_significant_strikes_distance_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_distance_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_distance_attempted_per_second - t2.cumulative_significant_strikes_distance_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_distance_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_attempted_per_significant_strike_attempted,
        AVG(t1.avg_significant_strikes_distance_attempted_per_significant_strike_attempted - t2.avg_significant_strikes_distance_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_attempted_per_significant_strike_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted,
        AVG(t1.cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted - t2.cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_landed,
        AVG(t1.avg_significant_strikes_clinch_landed - t2.avg_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_landed,
        AVG(t1.cumulative_significant_strikes_clinch_landed - t2.cumulative_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_landed_per_second,
        AVG(t1.avg_significant_strikes_clinch_landed_per_second - t2.avg_significant_strikes_clinch_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_clinch_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_landed_per_second,
        AVG(t1.cumulative_significant_strikes_clinch_landed_per_second - t2.cumulative_significant_strikes_clinch_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_clinch_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_accuracy,
        AVG(t1.avg_significant_strikes_clinch_accuracy - t2.avg_significant_strikes_clinch_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_clinch_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_accuracy,
        AVG(t1.cumulative_significant_strikes_clinch_accuracy - t2.cumulative_significant_strikes_clinch_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_accuracy_diff,
        AVG(t2.avg_significant_strikes_clinch_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_landed_per_significant_strike_landed,
        AVG(t1.avg_significant_strikes_clinch_landed_per_significant_strike_landed - t2.avg_significant_strikes_clinch_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_landed_per_significant_strike_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_landed_per_significant_strike_landed,
        AVG(t1.cumulative_significant_strikes_clinch_landed_per_significant_strike_landed - t2.cumulative_significant_strikes_clinch_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_landed_per_significant_strike_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_attempted,
        AVG(t1.avg_significant_strikes_clinch_attempted - t2.avg_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_attempted - t2.cumulative_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_attempted_per_second,
        AVG(t1.avg_significant_strikes_clinch_attempted_per_second - t2.avg_significant_strikes_clinch_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_clinch_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_clinch_attempted_per_second - t2.cumulative_significant_strikes_clinch_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_clinch_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_attempted_per_significant_strike_attempted,
        AVG(t1.avg_significant_strikes_clinch_attempted_per_significant_strike_attempted - t2.avg_significant_strikes_clinch_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted - t2.cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_landed,
        AVG(t1.avg_significant_strikes_ground_landed - t2.avg_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_landed,
        AVG(t1.cumulative_significant_strikes_ground_landed - t2.cumulative_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_landed_diff,
        AVG(t2.avg_significant_strikes_ground_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_landed_per_second,
        AVG(t1.avg_significant_strikes_ground_landed_per_second - t2.avg_significant_strikes_ground_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_ground_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_landed_per_second,
        AVG(t1.cumulative_significant_strikes_ground_landed_per_second - t2.cumulative_significant_strikes_ground_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_ground_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_accuracy,
        AVG(t1.avg_significant_strikes_ground_accuracy - t2.avg_significant_strikes_ground_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_ground_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_accuracy,
        AVG(t1.cumulative_significant_strikes_ground_accuracy - t2.cumulative_significant_strikes_ground_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_accuracy_diff,
        AVG(t2.avg_significant_strikes_ground_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_landed_per_significant_strike_landed,
        AVG(t1.avg_significant_strikes_ground_landed_per_significant_strike_landed - t2.avg_significant_strikes_ground_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_landed_per_significant_strike_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_landed_per_significant_strike_landed,
        AVG(t1.cumulative_significant_strikes_ground_landed_per_significant_strike_landed - t2.cumulative_significant_strikes_ground_landed_per_significant_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_landed_per_significant_strike_landed_diff,
        AVG(t2.avg_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_attempted,
        AVG(t1.avg_significant_strikes_ground_attempted - t2.avg_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_attempted,
        AVG(t1.cumulative_significant_strikes_ground_attempted - t2.cumulative_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_attempted_per_second,
        AVG(t1.avg_significant_strikes_ground_attempted_per_second - t2.avg_significant_strikes_ground_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_ground_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_ground_attempted_per_second - t2.cumulative_significant_strikes_ground_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_ground_attempted_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_attempted_per_strike_attempted,
        AVG(t1.avg_significant_strikes_ground_attempted_per_strike_attempted - t2.avg_significant_strikes_ground_attempted_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_attempted_per_strike_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_attempted_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_attempted_per_strike_attempted,
        AVG(t1.cumulative_significant_strikes_ground_attempted_per_strike_attempted - t2.cumulative_significant_strikes_ground_attempted_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_attempted_per_strike_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_head_landed,
        AVG(t1.avg_significant_strikes_distance_head_landed - t2.avg_significant_strikes_distance_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_head_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_head_landed,
        AVG(t1.cumulative_significant_strikes_distance_head_landed - t2.cumulative_significant_strikes_distance_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_head_landed_diff,
        AVG(t2.avg_significant_strikes_distance_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_head_landed_per_second,
        AVG(t1.avg_significant_strikes_distance_head_landed_per_second - t2.avg_significant_strikes_distance_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_head_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_distance_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_head_landed_per_second,
        AVG(t1.cumulative_significant_strikes_distance_head_landed_per_second - t2.cumulative_significant_strikes_distance_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_head_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_distance_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_head_accuracy,
        AVG(t1.avg_significant_strikes_distance_head_accuracy - t2.avg_significant_strikes_distance_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_head_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_distance_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_head_accuracy,
        AVG(t1.cumulative_significant_strikes_distance_head_accuracy - t2.cumulative_significant_strikes_distance_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_head_accuracy_diff,
        AVG(t2.avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed,
        AVG(t1.avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed - t2.avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed,
        AVG(t1.cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed - t2.cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff,
        AVG(t2.avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed,
        AVG(t1.avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed - t2.avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed,
        AVG(t1.cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed - t2.cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff,
        AVG(t2.avg_significant_strikes_distance_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_head_attempted,
        AVG(t1.avg_significant_strikes_distance_head_attempted - t2.avg_significant_strikes_distance_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_head_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_head_attempted,
        AVG(t1.cumulative_significant_strikes_distance_head_attempted - t2.cumulative_significant_strikes_distance_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_head_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_head_attempted_per_second,
        AVG(t1.avg_significant_strikes_distance_head_attempted_per_second - t2.avg_significant_strikes_distance_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_head_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_distance_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_head_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_distance_head_attempted_per_second - t2.cumulative_significant_strikes_distance_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_head_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted,
        AVG(t1.avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted - t2.avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted,
        AVG(t1.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted - t2.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted,
        AVG(t1.avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted - t2.avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted,
        AVG(t1.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted - t2.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_body_landed,
        AVG(t1.avg_significant_strikes_distance_body_landed - t2.avg_significant_strikes_distance_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_body_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_body_landed,
        AVG(t1.cumulative_significant_strikes_distance_body_landed - t2.cumulative_significant_strikes_distance_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_body_landed_diff,
        AVG(t2.avg_significant_strikes_distance_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_body_landed_per_second,
        AVG(t1.avg_significant_strikes_distance_body_landed_per_second - t2.avg_significant_strikes_distance_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_body_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_distance_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_body_landed_per_second,
        AVG(t1.cumulative_significant_strikes_distance_body_landed_per_second - t2.cumulative_significant_strikes_distance_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_body_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_distance_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_body_accuracy,
        AVG(t1.avg_significant_strikes_distance_body_accuracy - t2.avg_significant_strikes_distance_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_body_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_distance_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_body_accuracy,
        AVG(t1.cumulative_significant_strikes_distance_body_accuracy - t2.cumulative_significant_strikes_distance_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_body_accuracy_diff,
        AVG(t2.avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed,
        AVG(t1.avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed - t2.avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed,
        AVG(t1.cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed - t2.cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff,
        AVG(t2.avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed,
        AVG(t1.avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed - t2.avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed,
        AVG(t1.cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed - t2.cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff,
        AVG(t2.avg_significant_strikes_distance_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_body_attempted,
        AVG(t1.avg_significant_strikes_distance_body_attempted - t2.avg_significant_strikes_distance_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_body_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_body_attempted,
        AVG(t1.cumulative_significant_strikes_distance_body_attempted - t2.cumulative_significant_strikes_distance_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_body_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_body_attempted_per_second,
        AVG(t1.avg_significant_strikes_distance_body_attempted_per_second - t2.avg_significant_strikes_distance_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_body_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_distance_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_body_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_distance_body_attempted_per_second - t2.cumulative_significant_strikes_distance_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_body_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted,
        AVG(t1.avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted - t2.avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted,
        AVG(t1.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted - t2.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted,
        AVG(t1.avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted - t2.avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted,
        AVG(t1.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted - t2.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_leg_landed,
        AVG(t1.avg_significant_strikes_distance_leg_landed - t2.avg_significant_strikes_distance_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_leg_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_leg_landed,
        AVG(t1.cumulative_significant_strikes_distance_leg_landed - t2.cumulative_significant_strikes_distance_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_leg_landed_diff,
        AVG(t2.avg_significant_strikes_distance_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_leg_landed_per_second,
        AVG(t1.avg_significant_strikes_distance_leg_landed_per_second - t2.avg_significant_strikes_distance_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_leg_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_distance_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_leg_landed_per_second,
        AVG(t1.cumulative_significant_strikes_distance_leg_landed_per_second - t2.cumulative_significant_strikes_distance_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_leg_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_distance_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_leg_accuracy,
        AVG(t1.avg_significant_strikes_distance_leg_accuracy - t2.avg_significant_strikes_distance_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_leg_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_distance_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_leg_accuracy,
        AVG(t1.cumulative_significant_strikes_distance_leg_accuracy - t2.cumulative_significant_strikes_distance_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_leg_accuracy_diff,
        AVG(t2.avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed,
        AVG(t1.avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed - t2.avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff,
        AVG(t2.cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed,
        AVG(t1.cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed - t2.cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff,
        AVG(t2.avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed,
        AVG(t1.avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed - t2.avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed_diff,
        AVG(t2.avg_significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_leg_attempted,
        AVG(t1.avg_significant_strikes_distance_leg_attempted - t2.avg_significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_leg_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_leg_attempted,
        AVG(t1.cumulative_significant_strikes_distance_leg_attempted - t2.cumulative_significant_strikes_distance_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_leg_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_leg_attempted_per_second,
        AVG(t1.avg_significant_strikes_distance_leg_attempted_per_second - t2.avg_significant_strikes_distance_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_leg_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_distance_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_distance_leg_attempted_per_second - t2.cumulative_significant_strikes_distance_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_leg_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted,
        AVG(t1.avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted - t2.avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted,
        AVG(t1.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted - t2.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff,
        AVG(t2.avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted,
        AVG(t1.avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted - t2.avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff,
        AVG(t2.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted,
        AVG(t1.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted - t2.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_head_landed,
        AVG(t1.avg_significant_strikes_clinch_head_landed - t2.avg_significant_strikes_clinch_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_head_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_head_landed,
        AVG(t1.cumulative_significant_strikes_clinch_head_landed - t2.cumulative_significant_strikes_clinch_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_head_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_head_landed_per_second,
        AVG(t1.avg_significant_strikes_clinch_head_landed_per_second - t2.avg_significant_strikes_clinch_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_head_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_clinch_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_head_landed_per_second,
        AVG(t1.cumulative_significant_strikes_clinch_head_landed_per_second - t2.cumulative_significant_strikes_clinch_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_head_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_clinch_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_head_accuracy,
        AVG(t1.avg_significant_strikes_clinch_head_accuracy - t2.avg_significant_strikes_clinch_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_head_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_clinch_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_head_accuracy,
        AVG(t1.cumulative_significant_strikes_clinch_head_accuracy - t2.cumulative_significant_strikes_clinch_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_head_accuracy_diff,
        AVG(t2.avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed,
        AVG(t1.avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed - t2.avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed,
        AVG(t1.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed - t2.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed,
        AVG(t1.avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed - t2.avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed,
        AVG(t1.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed - t2.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_head_attempted,
        AVG(t1.avg_significant_strikes_clinch_head_attempted - t2.avg_significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_head_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_head_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_head_attempted - t2.cumulative_significant_strikes_clinch_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_head_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_head_attempted_per_second,
        AVG(t1.avg_significant_strikes_clinch_head_attempted_per_second - t2.avg_significant_strikes_clinch_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_head_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_clinch_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_clinch_head_attempted_per_second - t2.cumulative_significant_strikes_clinch_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_head_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted,
        AVG(t1.avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted - t2.avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted - t2.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted,
        AVG(t1.avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted - t2.avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted - t2.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_body_landed,
        AVG(t1.avg_significant_strikes_clinch_body_landed - t2.avg_significant_strikes_clinch_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_body_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_body_landed,
        AVG(t1.cumulative_significant_strikes_clinch_body_landed - t2.cumulative_significant_strikes_clinch_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_body_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_body_landed_per_second,
        AVG(t1.avg_significant_strikes_clinch_body_landed_per_second - t2.avg_significant_strikes_clinch_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_body_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_clinch_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_body_landed_per_second,
        AVG(t1.cumulative_significant_strikes_clinch_body_landed_per_second - t2.cumulative_significant_strikes_clinch_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_body_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_clinch_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_body_accuracy,
        AVG(t1.avg_significant_strikes_clinch_body_accuracy - t2.avg_significant_strikes_clinch_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_body_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_clinch_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_body_accuracy,
        AVG(t1.cumulative_significant_strikes_clinch_body_accuracy - t2.cumulative_significant_strikes_clinch_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_body_accuracy_diff,
        AVG(t2.avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed,
        AVG(t1.avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed - t2.avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed,
        AVG(t1.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed - t2.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed,
        AVG(t1.avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed - t2.avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed,
        AVG(t1.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed - t2.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_body_attempted,
        AVG(t1.avg_significant_strikes_clinch_body_attempted - t2.avg_significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_body_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_body_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_body_attempted - t2.cumulative_significant_strikes_clinch_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_body_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_body_attempted_per_second,
        AVG(t1.avg_significant_strikes_clinch_body_attempted_per_second - t2.avg_significant_strikes_clinch_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_body_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_clinch_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_clinch_body_attempted_per_second - t2.cumulative_significant_strikes_clinch_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_body_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted,
        AVG(t1.avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted - t2.avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted - t2.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted,
        AVG(t1.avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted - t2.avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted - t2.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_leg_landed,
        AVG(t1.avg_significant_strikes_clinch_leg_landed - t2.avg_significant_strikes_clinch_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_leg_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_second,
        AVG(t1.cumulative_significant_strikes_clinch_leg_landed_per_second - t2.cumulative_significant_strikes_clinch_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_leg_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_clinch_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_leg_accuracy,
        AVG(t1.avg_significant_strikes_clinch_leg_accuracy - t2.avg_significant_strikes_clinch_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_leg_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_clinch_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_leg_accuracy,
        AVG(t1.cumulative_significant_strikes_clinch_leg_accuracy - t2.cumulative_significant_strikes_clinch_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_leg_accuracy_diff,
        AVG(t2.avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed,
        AVG(t1.avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed - t2.avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed,
        AVG(t1.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed - t2.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed,
        AVG(t1.avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed - t2.avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff,
        AVG(t2.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed,
        AVG(t1.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed - t2.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff,
        AVG(t2.avg_significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_leg_attempted,
        AVG(t1.avg_significant_strikes_clinch_leg_attempted - t2.avg_significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_leg_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_leg_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_leg_attempted - t2.cumulative_significant_strikes_clinch_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_leg_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_leg_attempted_per_second,
        AVG(t1.avg_significant_strikes_clinch_leg_attempted_per_second - t2.avg_significant_strikes_clinch_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_leg_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_clinch_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_clinch_leg_attempted_per_second - t2.cumulative_significant_strikes_clinch_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_leg_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted,
        AVG(t1.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted - t2.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted - t2.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff,
        AVG(t2.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted,
        AVG(t1.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted - t2.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff,
        AVG(t2.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted,
        AVG(t1.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted - t2.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_head_landed,
        AVG(t1.avg_significant_strikes_ground_head_landed - t2.avg_significant_strikes_ground_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_head_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_head_landed,
        AVG(t1.cumulative_significant_strikes_ground_head_landed - t2.cumulative_significant_strikes_ground_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_head_landed_diff,
        AVG(t2.avg_significant_strikes_ground_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_head_landed_per_second,
        AVG(t1.avg_significant_strikes_ground_head_landed_per_second - t2.avg_significant_strikes_ground_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_head_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_ground_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_head_landed_per_second,
        AVG(t1.cumulative_significant_strikes_ground_head_landed_per_second - t2.cumulative_significant_strikes_ground_head_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_head_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_ground_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_head_accuracy,
        AVG(t1.avg_significant_strikes_ground_head_accuracy - t2.avg_significant_strikes_ground_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_head_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_ground_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_head_accuracy,
        AVG(t1.cumulative_significant_strikes_ground_head_accuracy - t2.cumulative_significant_strikes_ground_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_head_accuracy_diff,
        AVG(t2.avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed,
        AVG(t1.avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed - t2.avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed,
        AVG(t1.cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed - t2.cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff,
        AVG(t2.avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed,
        AVG(t1.avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed - t2.avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed,
        AVG(t1.cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed - t2.cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff,
        AVG(t2.avg_significant_strikes_ground_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_head_attempted,
        AVG(t1.avg_significant_strikes_ground_head_attempted - t2.avg_significant_strikes_ground_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_head_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_head_attempted,
        AVG(t1.cumulative_significant_strikes_ground_head_attempted - t2.cumulative_significant_strikes_ground_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_head_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_head_attempted_per_second,
        AVG(t1.avg_significant_strikes_ground_head_attempted_per_second - t2.avg_significant_strikes_ground_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_head_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_ground_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_head_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_ground_head_attempted_per_second - t2.cumulative_significant_strikes_ground_head_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_head_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted,
        AVG(t1.avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted - t2.avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted,
        AVG(t1.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted - t2.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted,
        AVG(t1.avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted - t2.avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted,
        AVG(t1.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted - t2.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_body_landed,
        AVG(t1.avg_significant_strikes_ground_body_landed - t2.avg_significant_strikes_ground_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_body_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_body_landed,
        AVG(t1.cumulative_significant_strikes_ground_body_landed - t2.cumulative_significant_strikes_ground_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_body_landed_diff,
        AVG(t2.avg_significant_strikes_ground_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_body_landed_per_second,
        AVG(t1.avg_significant_strikes_ground_body_landed_per_second - t2.avg_significant_strikes_ground_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_body_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_ground_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_body_landed_per_second,
        AVG(t1.cumulative_significant_strikes_ground_body_landed_per_second - t2.cumulative_significant_strikes_ground_body_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_body_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_ground_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_body_accuracy,
        AVG(t1.avg_significant_strikes_ground_body_accuracy - t2.avg_significant_strikes_ground_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_body_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_ground_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_body_accuracy,
        AVG(t1.cumulative_significant_strikes_ground_body_accuracy - t2.cumulative_significant_strikes_ground_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_body_accuracy_diff,
        AVG(t2.avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed,
        AVG(t1.avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed - t2.avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed,
        AVG(t1.cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed - t2.cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff,
        AVG(t2.avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed,
        AVG(t1.avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed - t2.avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed,
        AVG(t1.cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed - t2.cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff,
        AVG(t2.avg_significant_strikes_ground_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_body_attempted,
        AVG(t1.avg_significant_strikes_ground_body_attempted - t2.avg_significant_strikes_ground_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_body_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_body_attempted,
        AVG(t1.cumulative_significant_strikes_ground_body_attempted - t2.cumulative_significant_strikes_ground_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_body_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_body_attempted_per_second,
        AVG(t1.avg_significant_strikes_ground_body_attempted_per_second - t2.avg_significant_strikes_ground_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_body_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_ground_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_body_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_ground_body_attempted_per_second - t2.cumulative_significant_strikes_ground_body_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_body_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted,
        AVG(t1.avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted - t2.avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted,
        AVG(t1.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted - t2.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted,
        AVG(t1.avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted - t2.avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted,
        AVG(t1.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted - t2.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_leg_landed,
        AVG(t1.avg_significant_strikes_ground_leg_landed - t2.avg_significant_strikes_ground_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_leg_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_leg_landed,
        AVG(t1.cumulative_significant_strikes_ground_leg_landed - t2.cumulative_significant_strikes_ground_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_leg_landed_diff,
        AVG(t2.avg_significant_strikes_ground_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_leg_landed_per_second,
        AVG(t1.avg_significant_strikes_ground_leg_landed_per_second - t2.avg_significant_strikes_ground_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_leg_landed_per_second_diff,
        AVG(t2.cumulative_significant_strikes_ground_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_leg_landed_per_second,
        AVG(t1.cumulative_significant_strikes_ground_leg_landed_per_second - t2.cumulative_significant_strikes_ground_leg_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_leg_landed_per_second_diff,
        AVG(t2.avg_significant_strikes_ground_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_leg_accuracy,
        AVG(t1.avg_significant_strikes_ground_leg_accuracy - t2.avg_significant_strikes_ground_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_leg_accuracy_diff,
        AVG(t2.cumulative_significant_strikes_ground_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_leg_accuracy,
        AVG(t1.cumulative_significant_strikes_ground_leg_accuracy - t2.cumulative_significant_strikes_ground_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_leg_accuracy_diff,
        AVG(t2.avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed,
        AVG(t1.avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed - t2.avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed,
        AVG(t1.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed - t2.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff,
        AVG(t2.avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed,
        AVG(t1.avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed - t2.avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff,
        AVG(t2.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed,
        AVG(t1.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed - t2.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff,
        AVG(t2.avg_significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_leg_attempted,
        AVG(t1.avg_significant_strikes_ground_leg_attempted - t2.avg_significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_leg_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_leg_attempted,
        AVG(t1.cumulative_significant_strikes_ground_leg_attempted - t2.cumulative_significant_strikes_ground_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_leg_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_leg_attempted_per_second,
        AVG(t1.avg_significant_strikes_ground_leg_attempted_per_second - t2.avg_significant_strikes_ground_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_leg_attempted_per_second_diff,
        AVG(t2.cumulative_significant_strikes_ground_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_second,
        AVG(t1.cumulative_significant_strikes_ground_leg_attempted_per_second - t2.cumulative_significant_strikes_ground_leg_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_leg_attempted_per_second_diff,
        AVG(t2.avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted,
        AVG(t1.avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted - t2.avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted,
        AVG(t1.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted - t2.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff,
        AVG(t2.avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted,
        AVG(t1.avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted - t2.avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff,
        AVG(t2.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted,
        AVG(t1.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted - t2.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff,
        AVG(t2.avg_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_takedowns_landed,
        AVG(t1.avg_takedowns_landed - t2.avg_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_takedowns_landed_diff,
        AVG(t2.cumulative_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_takedowns_landed,
        AVG(t1.cumulative_takedowns_landed - t2.cumulative_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_takedowns_landed_diff,
        AVG(t2.avg_takedowns_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_takedowns_landed_per_second,
        AVG(t1.avg_takedowns_landed_per_second - t2.avg_takedowns_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_takedowns_landed_per_second_diff,
        AVG(t2.cumulative_takedowns_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_takedowns_landed_per_second,
        AVG(t1.cumulative_takedowns_landed_per_second - t2.cumulative_takedowns_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_takedowns_landed_per_second_diff,
        AVG(t2.avg_takedowns_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_takedowns_accuracy,
        AVG(t1.avg_takedowns_accuracy - t2.avg_takedowns_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_takedowns_accuracy_diff,
        AVG(t2.cumulative_takedowns_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_takedowns_accuracy,
        AVG(t1.cumulative_takedowns_accuracy - t2.cumulative_takedowns_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_takedowns_accuracy_diff,
        AVG(t2.avg_takedowns_slams_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_takedowns_slams_landed,
        AVG(t1.avg_takedowns_slams_landed - t2.avg_takedowns_slams_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_takedowns_slams_landed_diff,
        AVG(t2.cumulative_takedowns_slams_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_takedowns_slams_landed,
        AVG(t1.cumulative_takedowns_slams_landed - t2.cumulative_takedowns_slams_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_takedowns_slams_landed_diff,
        AVG(t2.avg_takedowns_slams_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_takedowns_slams_landed_per_second,
        AVG(t1.avg_takedowns_slams_landed_per_second - t2.avg_takedowns_slams_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_takedowns_slams_landed_per_second_diff,
        AVG(t2.cumulative_takedowns_slams_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_takedowns_slams_landed_per_second,
        AVG(t1.cumulative_takedowns_slams_landed_per_second - t2.cumulative_takedowns_slams_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_takedowns_slams_landed_per_second_diff,
        AVG(t2.avg_takedowns_slams_landed_per_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_takedowns_slams_landed_per_takedowns_landed,
        AVG(t1.avg_takedowns_slams_landed_per_takedowns_landed - t2.avg_takedowns_slams_landed_per_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_takedowns_slams_landed_per_takedowns_landed_diff,
        AVG(t2.cumulative_takedowns_slams_landed_per_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_takedowns_slams_landed_per_takedowns_landed,
        AVG(t1.cumulative_takedowns_slams_landed_per_takedowns_landed - t2.cumulative_takedowns_slams_landed_per_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_takedowns_slams_landed_per_takedowns_landed_diff,
        AVG(t2.avg_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_takedowns_attempted,
        AVG(t1.avg_takedowns_attempted - t2.avg_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_takedowns_attempted_diff,
        AVG(t2.cumulative_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_takedowns_attempted,
        AVG(t1.cumulative_takedowns_attempted - t2.cumulative_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_takedowns_attempted_diff,
        AVG(t2.avg_takedowns_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_takedowns_attempted_per_second,
        AVG(t1.avg_takedowns_attempted_per_second - t2.avg_takedowns_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_takedowns_attempted_per_second_diff,
        AVG(t2.cumulative_takedowns_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_takedowns_attempted_per_second,
        AVG(t1.cumulative_takedowns_attempted_per_second - t2.cumulative_takedowns_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_takedowns_attempted_per_second_diff,
        AVG(t2.avg_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances,
        AVG(t1.avg_advances - t2.avg_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_diff,
        AVG(t2.cumulative_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances,
        AVG(t1.cumulative_advances - t2.cumulative_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_diff,
        AVG(t2.avg_advances_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_per_second,
        AVG(t1.avg_advances_per_second - t2.avg_advances_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_per_second_diff,
        AVG(t2.cumulative_advances_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_per_second,
        AVG(t1.cumulative_advances_per_second - t2.cumulative_advances_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_per_second_diff,
        AVG(t2.avg_advances_to_back) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_back,
        AVG(t1.avg_advances_to_back - t2.avg_advances_to_back) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_back_diff,
        AVG(t2.cumulative_advances_to_back) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_back,
        AVG(t1.cumulative_advances_to_back - t2.cumulative_advances_to_back) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_back_diff,
        AVG(t2.avg_advances_to_back_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_back_per_second,
        AVG(t1.avg_advances_to_back_per_second - t2.avg_advances_to_back_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_back_per_second_diff,
        AVG(t2.cumulative_advances_to_back_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_back_per_second,
        AVG(t1.cumulative_advances_to_back_per_second - t2.cumulative_advances_to_back_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_back_per_second_diff,
        AVG(t2.avg_advances_to_back_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_back_per_advances,
        AVG(t1.avg_advances_to_back_per_advances - t2.avg_advances_to_back_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_back_per_advances_diff,
        AVG(t2.cumulative_advances_to_back_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_back_per_advances,
        AVG(t1.cumulative_advances_to_back_per_advances - t2.cumulative_advances_to_back_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_back_per_advances_diff,
        AVG(t2.avg_advances_to_half_guard) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_half_guard,
        AVG(t1.avg_advances_to_half_guard - t2.avg_advances_to_half_guard) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_half_guard_diff,
        AVG(t2.cumulative_advances_to_half_guard) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_half_guard,
        AVG(t1.cumulative_advances_to_half_guard - t2.cumulative_advances_to_half_guard) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_half_guard_diff,
        AVG(t2.avg_advances_to_half_guard_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_half_guard_per_second,
        AVG(t1.avg_advances_to_half_guard_per_second - t2.avg_advances_to_half_guard_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_half_guard_per_second_diff,
        AVG(t2.cumulative_advances_to_half_guard_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_half_guard_per_second,
        AVG(t1.cumulative_advances_to_half_guard_per_second - t2.cumulative_advances_to_half_guard_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_half_guard_per_second_diff,
        AVG(t2.avg_advances_to_half_guard_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_half_guard_per_advances,
        AVG(t1.avg_advances_to_half_guard_per_advances - t2.avg_advances_to_half_guard_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_half_guard_per_advances_diff,
        AVG(t2.cumulative_advances_to_half_guard_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_half_guard_per_advances,
        AVG(t1.cumulative_advances_to_half_guard_per_advances - t2.cumulative_advances_to_half_guard_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_half_guard_per_advances_diff,
        AVG(t2.avg_advances_to_mount) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_mount,
        AVG(t1.avg_advances_to_mount - t2.avg_advances_to_mount) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_mount_diff,
        AVG(t2.cumulative_advances_to_mount) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_mount,
        AVG(t1.cumulative_advances_to_mount - t2.cumulative_advances_to_mount) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_mount_diff,
        AVG(t2.avg_advances_to_mount_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_mount_per_second,
        AVG(t1.avg_advances_to_mount_per_second - t2.avg_advances_to_mount_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_mount_per_second_diff,
        AVG(t2.cumulative_advances_to_mount_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_mount_per_second,
        AVG(t1.cumulative_advances_to_mount_per_second - t2.cumulative_advances_to_mount_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_mount_per_second_diff,
        AVG(t2.avg_advances_to_mount_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_mount_per_advances,
        AVG(t1.avg_advances_to_mount_per_advances - t2.avg_advances_to_mount_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_mount_per_advances_diff,
        AVG(t2.cumulative_advances_to_mount_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_mount_per_advances,
        AVG(t1.cumulative_advances_to_mount_per_advances - t2.cumulative_advances_to_mount_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_mount_per_advances_diff,
        AVG(t2.avg_advances_to_side) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_side,
        AVG(t1.avg_advances_to_side - t2.avg_advances_to_side) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_side_diff,
        AVG(t2.cumulative_advances_to_side) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_side,
        AVG(t1.cumulative_advances_to_side - t2.cumulative_advances_to_side) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_side_diff,
        AVG(t2.avg_advances_to_side_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_side_per_second,
        AVG(t1.avg_advances_to_side_per_second - t2.avg_advances_to_side_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_side_per_second_diff,
        AVG(t2.cumulative_advances_to_side_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_side_per_second,
        AVG(t1.cumulative_advances_to_side_per_second - t2.cumulative_advances_to_side_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_side_per_second_diff,
        AVG(t2.avg_advances_to_side_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_advances_to_side_per_advances,
        AVG(t1.avg_advances_to_side_per_advances - t2.avg_advances_to_side_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_advances_to_side_per_advances_diff,
        AVG(t2.cumulative_advances_to_side_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_advances_to_side_per_advances,
        AVG(t1.cumulative_advances_to_side_per_advances - t2.cumulative_advances_to_side_per_advances) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_advances_to_side_per_advances_diff,
        AVG(t2.avg_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_reversals_scored,
        AVG(t1.avg_reversals_scored - t2.avg_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_reversals_scored_diff,
        AVG(t2.cumulative_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_reversals_scored,
        AVG(t1.cumulative_reversals_scored - t2.cumulative_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_reversals_scored_diff,
        AVG(t2.avg_reversals_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_reversals_scored_per_second,
        AVG(t1.avg_reversals_scored_per_second - t2.avg_reversals_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_reversals_scored_per_second_diff,
        AVG(t2.cumulative_reversals_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_reversals_scored_per_second,
        AVG(t1.cumulative_reversals_scored_per_second - t2.cumulative_reversals_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_reversals_scored_per_second_diff,
        AVG(t2.avg_submissions_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_submissions_landed,
        AVG(t1.avg_submissions_landed - t2.avg_submissions_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_submissions_landed_diff,
        AVG(t2.cumulative_submissions_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_submissions_landed,
        AVG(t1.cumulative_submissions_landed - t2.cumulative_submissions_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_submissions_landed_diff,
        AVG(t2.avg_submissions_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_submissions_landed_per_second,
        AVG(t1.avg_submissions_landed_per_second - t2.avg_submissions_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_submissions_landed_per_second_diff,
        AVG(t2.cumulative_submissions_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_submissions_landed_per_second,
        AVG(t1.cumulative_submissions_landed_per_second - t2.cumulative_submissions_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_submissions_landed_per_second_diff,
        AVG(t2.avg_submissions_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_submissions_accuracy,
        AVG(t1.avg_submissions_accuracy - t2.avg_submissions_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_submissions_accuracy_diff,
        AVG(t2.cumulative_submissions_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_submissions_accuracy,
        AVG(t1.cumulative_submissions_accuracy - t2.cumulative_submissions_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_submissions_accuracy_diff,
        AVG(t2.avg_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_submissions_attempted,
        AVG(t1.avg_submissions_attempted - t2.avg_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_submissions_attempted_diff,
        AVG(t2.cumulative_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_submissions_attempted,
        AVG(t1.cumulative_submissions_attempted - t2.cumulative_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_submissions_attempted_diff,
        AVG(t2.avg_submissions_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_submissions_attempted_per_second,
        AVG(t1.avg_submissions_attempted_per_second - t2.avg_submissions_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_submissions_attempted_per_second_diff,
        AVG(t2.cumulative_submissions_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_submissions_attempted_per_second,
        AVG(t1.cumulative_submissions_attempted_per_second - t2.cumulative_submissions_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_submissions_attempted_per_second_diff,
        AVG(t2.avg_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_control_time_seconds,
        AVG(t1.avg_control_time_seconds - t2.avg_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_control_time_seconds_diff,
        AVG(t2.cumulative_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_control_time_seconds,
        AVG(t1.cumulative_control_time_seconds - t2.cumulative_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_control_time_seconds_diff,
        AVG(t2.avg_control_time_seconds_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_control_time_seconds_per_second,
        AVG(t1.avg_control_time_seconds_per_second - t2.avg_control_time_seconds_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_control_time_seconds_per_second_diff,
        AVG(t2.cumulative_control_time_seconds_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_control_time_seconds_per_second,
        AVG(t1.cumulative_control_time_seconds_per_second - t2.cumulative_control_time_seconds_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
            ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_control_time_seconds_per_second_diff     
    FROM
        cte6 AS t1
    LEFT JOIN
        cte6 AS t2 ON t1.fighter_id = t2.opponent_id AND t1.bout_id = t2.bout_id AND t1.opponent_id = t2.fighter_id
)
SELECT
    id,
    t2.avg_knockdowns_scored - t3.avg_knockdowns_scored AS avg_knockdowns_scored_diff,
    t2.cumulative_knockdowns_scored - t3.cumulative_knockdowns_scored AS cumulative_knockdowns_scored_diff,
    t2.avg_knockdowns_scored_per_second - t3.avg_knockdowns_scored_per_second AS avg_knockdowns_scored_per_second_diff,
    t2.cumulative_knockdowns_scored_per_second - t3.cumulative_knockdowns_scored_per_second AS cumulative_knockdowns_scored_per_second_diff,
    t2.avg_knockdowns_scored_per_strike_landed - t3.avg_knockdowns_scored_per_strike_landed AS avg_knockdowns_scored_per_strike_landed_diff,
    t2.cumulative_knockdowns_scored_per_strike_landed - t3.cumulative_knockdowns_scored_per_strike_landed AS cumulative_knockdowns_scored_per_strike_landed_diff,
    t2.avg_knockdowns_scored_per_strike_attempted - t3.avg_knockdowns_scored_per_strike_attempted AS avg_knockdowns_scored_per_strike_attempted_diff,
    t2.cumulative_knockdowns_scored_per_strike_attempted - t3.cumulative_knockdowns_scored_per_strike_attempted AS cumulative_knockdowns_scored_per_strike_attempted_diff,
    t2.avg_knockdowns_scored_per_significant_strike_landed - t3.avg_knockdowns_scored_per_significant_strike_landed AS avg_knockdowns_scored_per_significant_strike_landed_diff,
    t2.cumulative_knockdowns_scored_per_significant_strike_landed - t3.cumulative_knockdowns_scored_per_significant_strike_landed AS cumulative_knockdowns_scored_per_significant_strike_landed_diff,
    t2.avg_knockdowns_scored_per_significant_strike_attempted - t3.avg_knockdowns_scored_per_significant_strike_attempted AS avg_knockdowns_scored_per_significant_strike_attempted_diff,
    t2.cumulative_knockdowns_scored_per_significant_strike_attempted - t3.cumulative_knockdowns_scored_per_significant_strike_attempted AS cumulative_knockdowns_scored_per_significant_strike_attempted_diff,
    t2.avg_knockdowns_scored_per_significant_strike_head_landed - t3.avg_knockdowns_scored_per_significant_strike_head_landed AS avg_knockdowns_scored_per_significant_strike_head_landed_diff,
    t2.cumulative_knockdowns_scored_per_significant_strike_head_landed - t3.cumulative_knockdowns_scored_per_significant_strike_head_landed AS cumulative_knockdowns_scored_per_significant_strike_head_landed_diff,
    t2.avg_knockdowns_scored_per_significant_strike_head_attempted - t3.avg_knockdowns_scored_per_significant_strike_head_attempted AS avg_knockdowns_scored_per_significant_strike_head_attempted_diff,
    t2.cumulative_knockdowns_scored_per_significant_strike_head_attempted - t3.cumulative_knockdowns_scored_per_significant_strike_head_attempted AS cumulative_knockdowns_scored_per_significant_strike_head_attempted_diff,
    t2.avg_ko_tko_landed - t3.avg_ko_tko_landed AS avg_ko_tko_landed_diff,
    t2.cumulative_ko_tko_landed - t3.cumulative_ko_tko_landed AS cumulative_ko_tko_landed_diff,
    t2.avg_ko_tko_landed_per_second - t3.avg_ko_tko_landed_per_second AS avg_ko_tko_landed_per_second_diff,
    t2.cumulative_ko_tko_landed_per_second - t3.cumulative_ko_tko_landed_per_second AS cumulative_ko_tko_landed_per_second_diff,
    t2.avg_ko_tko_landed_per_strike_landed - t3.avg_ko_tko_landed_per_strike_landed AS avg_ko_tko_landed_per_strike_landed_diff,
    t2.cumulative_ko_tko_landed_per_strike_landed - t3.cumulative_ko_tko_landed_per_strike_landed AS cumulative_ko_tko_landed_per_strike_landed_diff,
    t2.avg_ko_tko_landed_per_strike_attempted - t3.avg_ko_tko_landed_per_strike_attempted AS avg_ko_tko_landed_per_strike_attempted_diff,
    t2.cumulative_ko_tko_landed_per_strike_attempted - t3.cumulative_ko_tko_landed_per_strike_attempted AS cumulative_ko_tko_landed_per_strike_attempted_diff,
    t2.avg_ko_tko_landed_per_significant_strike_landed - t3.avg_ko_tko_landed_per_significant_strike_landed AS avg_ko_tko_landed_per_significant_strike_landed_diff,
    t2.cumulative_ko_tko_landed_per_significant_strike_landed - t3.cumulative_ko_tko_landed_per_significant_strike_landed AS cumulative_ko_tko_landed_per_significant_strike_landed_diff,
    t2.avg_ko_tko_landed_per_significant_strike_attempted - t3.avg_ko_tko_landed_per_significant_strike_attempted AS avg_ko_tko_landed_per_significant_strike_attempted_diff,
    t2.cumulative_ko_tko_landed_per_significant_strike_attempted - t3.cumulative_ko_tko_landed_per_significant_strike_attempted AS cumulative_ko_tko_landed_per_significant_strike_attempted_diff,
    t2.avg_ko_tko_landed_per_significant_strike_head_landed - t3.avg_ko_tko_landed_per_significant_strike_head_landed AS avg_ko_tko_landed_per_significant_strike_head_landed_diff,
    t2.cumulative_ko_tko_landed_per_significant_strike_head_landed - t3.cumulative_ko_tko_landed_per_significant_strike_head_landed AS cumulative_ko_tko_landed_per_significant_strike_head_landed_diff,
    t2.avg_ko_tko_landed_per_significant_strike_head_attempted - t3.avg_ko_tko_landed_per_significant_strike_head_attempted AS avg_ko_tko_landed_per_significant_strike_head_attempted_diff,
    t2.cumulative_ko_tko_landed_per_significant_strike_head_attempted - t3.cumulative_ko_tko_landed_per_significant_strike_head_attempted AS cumulative_ko_tko_landed_per_significant_strike_head_attempted_diff,
    t2.avg_total_strikes_landed - t3.avg_total_strikes_landed AS avg_total_strikes_landed_diff,
    t2.cumulative_total_strikes_landed - t3.cumulative_total_strikes_landed AS cumulative_total_strikes_landed_diff,
    t2.avg_total_strikes_landed_per_second - t3.avg_total_strikes_landed_per_second AS avg_total_strikes_landed_per_second_diff,
    t2.cumulative_total_strikes_landed_per_second - t3.cumulative_total_strikes_landed_per_second AS cumulative_total_strikes_landed_per_second_diff,
    t2.avg_total_strikes_accuracy - t3.avg_total_strikes_accuracy AS avg_total_strikes_accuracy_diff,
    t2.cumulative_total_strikes_accuracy - t3.cumulative_total_strikes_accuracy AS cumulative_total_strikes_accuracy_diff,
    t2.avg_total_strikes_attempted - t3.avg_total_strikes_attempted AS avg_total_strikes_attempted_diff,
    t2.cumulative_total_strikes_attempted - t3.cumulative_total_strikes_attempted AS cumulative_total_strikes_attempted_diff,
    t2.avg_total_strikes_attempted_per_second - t3.avg_total_strikes_attempted_per_second AS avg_total_strikes_attempted_per_second_diff,
    t2.cumulative_total_strikes_attempted_per_second - t3.cumulative_total_strikes_attempted_per_second AS cumulative_total_strikes_attempted_per_second_diff,
    t2.avg_significant_strikes_landed - t3.avg_significant_strikes_landed AS avg_significant_strikes_landed_diff,
    t2.cumulative_significant_strikes_landed - t3.cumulative_significant_strikes_landed AS cumulative_significant_strikes_landed_diff,
    t2.avg_significant_strikes_landed_per_second - t3.avg_significant_strikes_landed_per_second AS avg_significant_strikes_landed_per_second_diff,
    t2.cumulative_significant_strikes_landed_per_second - t3.cumulative_significant_strikes_landed_per_second AS cumulative_significant_strikes_landed_per_second_diff,
    t2.avg_significant_strikes_accuracy - t3.avg_significant_strikes_accuracy AS avg_significant_strikes_accuracy_diff,
    t2.cumulative_significant_strikes_accuracy - t3.cumulative_significant_strikes_accuracy AS cumulative_significant_strikes_accuracy_diff,
    t2.avg_significant_strikes_landed_per_strike_landed - t3.avg_significant_strikes_landed_per_strike_landed AS avg_significant_strikes_landed_per_strike_landed_diff,
    t2.cumulative_significant_strikes_landed_per_strike_landed - t3.cumulative_significant_strikes_landed_per_strike_landed AS cumulative_significant_strikes_landed_per_strike_landed_diff,
    t2.avg_significant_strikes_attempted - t3.avg_significant_strikes_attempted AS avg_significant_strikes_attempted_diff,
    t2.cumulative_significant_strikes_attempted - t3.cumulative_significant_strikes_attempted AS cumulative_significant_strikes_attempted_diff,
    t2.avg_significant_strikes_attempted_per_second - t3.avg_significant_strikes_attempted_per_second AS avg_significant_strikes_attempted_per_second_diff,
    t2.cumulative_significant_strikes_attempted_per_second - t3.cumulative_significant_strikes_attempted_per_second AS cumulative_significant_strikes_attempted_per_second_diff,
    t2.avg_significant_strikes_attempted_per_strike_attempted - t3.avg_significant_strikes_attempted_per_strike_attempted AS avg_significant_strikes_attempted_per_strike_attempted_diff,
    t2.cumulative_significant_strikes_attempted_per_strike_attempted - t3.cumulative_significant_strikes_attempted_per_strike_attempted AS cumulative_significant_strikes_attempted_per_strike_attempted_diff,
    t2.avg_significant_strikes_head_landed - t3.avg_significant_strikes_head_landed AS avg_significant_strikes_head_landed_diff,
    t2.cumulative_significant_strikes_head_landed - t3.cumulative_significant_strikes_head_landed AS cumulative_significant_strikes_head_landed_diff,
    t2.avg_significant_strikes_head_landed_per_second - t3.avg_significant_strikes_head_landed_per_second AS avg_significant_strikes_head_landed_per_second_diff,
    t2.cumulative_significant_strikes_head_landed_per_second - t3.cumulative_significant_strikes_head_landed_per_second AS cumulative_significant_strikes_head_landed_per_second_diff,
    t2.avg_significant_strikes_head_accuracy - t3.avg_significant_strikes_head_accuracy AS avg_significant_strikes_head_accuracy_diff,
    t2.cumulative_significant_strikes_head_accuracy - t3.cumulative_significant_strikes_head_accuracy AS cumulative_significant_strikes_head_accuracy_diff,
    t2.avg_significant_strikes_head_landed_per_significant_strike_landed - t3.avg_significant_strikes_head_landed_per_significant_strike_landed AS avg_significant_strikes_head_landed_per_significant_strike_landed_diff,
    t2.cumulative_significant_strikes_head_landed_per_significant_strike_landed - t3.cumulative_significant_strikes_head_landed_per_significant_strike_landed AS cumulative_significant_strikes_head_landed_per_significant_strike_landed_diff,
    t2.avg_significant_strikes_head_attempted - t3.avg_significant_strikes_head_attempted AS avg_significant_strikes_head_attempted_diff,
    t2.cumulative_significant_strikes_head_attempted - t3.cumulative_significant_strikes_head_attempted AS cumulative_significant_strikes_head_attempted_diff,
    t2.avg_significant_strikes_head_attempted_per_second - t3.avg_significant_strikes_head_attempted_per_second AS avg_significant_strikes_head_attempted_per_second_diff,
    t2.cumulative_significant_strikes_head_attempted_per_second - t3.cumulative_significant_strikes_head_attempted_per_second AS cumulative_significant_strikes_head_attempted_per_second_diff,
    t2.avg_significant_strikes_head_attempted_per_significant_strike_attempted - t3.avg_significant_strikes_head_attempted_per_significant_strike_attempted AS avg_significant_strikes_head_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_significant_strikes_head_attempted_per_significant_strike_attempted - t3.cumulative_significant_strikes_head_attempted_per_significant_strike_attempted AS cumulative_significant_strikes_head_attempted_per_significant_strike_attempted_diff,
    t2.avg_significant_strikes_body_landed - t3.avg_significant_strikes_body_landed AS avg_significant_strikes_body_landed_diff,
    t2.cumulative_significant_strikes_body_landed - t3.cumulative_significant_strikes_body_landed AS cumulative_significant_strikes_body_landed_diff,
    t2.avg_significant_strikes_body_landed_per_second - t3.avg_significant_strikes_body_landed_per_second AS avg_significant_strikes_body_landed_per_second_diff,
    t2.cumulative_significant_strikes_body_landed_per_second - t3.cumulative_significant_strikes_body_landed_per_second AS cumulative_significant_strikes_body_landed_per_second_diff,
    t2.avg_significant_strikes_body_accuracy - t3.avg_significant_strikes_body_accuracy AS avg_significant_strikes_body_accuracy_diff,
    t2.cumulative_significant_strikes_body_accuracy - t3.cumulative_significant_strikes_body_accuracy AS cumulative_significant_strikes_body_accuracy_diff,
    t2.avg_significant_strikes_body_landed_per_significant_strike_landed - t3.avg_significant_strikes_body_landed_per_significant_strike_landed AS avg_significant_strikes_body_landed_per_significant_strike_landed_diff,
    t2.cumulative_significant_strikes_body_landed_per_significant_strike_landed - t3.cumulative_significant_strikes_body_landed_per_significant_strike_landed AS cumulative_significant_strikes_body_landed_per_significant_strike_landed_diff,
    t2.avg_significant_strikes_body_attempted - t3.avg_significant_strikes_body_attempted AS avg_significant_strikes_body_attempted_diff,
    t2.cumulative_significant_strikes_body_attempted - t3.cumulative_significant_strikes_body_attempted AS cumulative_significant_strikes_body_attempted_diff,
    t2.avg_significant_strikes_body_attempted_per_second - t3.avg_significant_strikes_body_attempted_per_second AS avg_significant_strikes_body_attempted_per_second_diff,
    t2.cumulative_significant_strikes_body_attempted_per_second - t3.cumulative_significant_strikes_body_attempted_per_second AS cumulative_significant_strikes_body_attempted_per_second_diff,
    t2.avg_significant_strikes_body_attempted_per_significant_strike_attempted - t3.avg_significant_strikes_body_attempted_per_significant_strike_attempted AS avg_significant_strikes_body_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_significant_strikes_body_attempted_per_significant_strike_attempted - t3.cumulative_significant_strikes_body_attempted_per_significant_strike_attempted AS cumulative_significant_strikes_body_attempted_per_significant_strike_attempted_diff,
    t2.avg_significant_strikes_leg_landed - t3.avg_significant_strikes_leg_landed AS avg_significant_strikes_leg_landed_diff,
    t2.cumulative_significant_strikes_leg_landed - t3.cumulative_significant_strikes_leg_landed AS cumulative_significant_strikes_leg_landed_diff,
    t2.avg_significant_strikes_leg_landed_per_second - t3.avg_significant_strikes_leg_landed_per_second AS avg_significant_strikes_leg_landed_per_second_diff,
    t2.cumulative_significant_strikes_leg_landed_per_second - t3.cumulative_significant_strikes_leg_landed_per_second AS cumulative_significant_strikes_leg_landed_per_second_diff,
    t2.avg_significant_strikes_leg_accuracy - t3.avg_significant_strikes_leg_accuracy AS avg_significant_strikes_leg_accuracy_diff,
    t2.cumulative_significant_strikes_leg_accuracy - t3.cumulative_significant_strikes_leg_accuracy AS cumulative_significant_strikes_leg_accuracy_diff,
    t2.avg_significant_strikes_leg_landed_per_significant_strike_landed - t3.avg_significant_strikes_leg_landed_per_significant_strike_landed AS avg_significant_strikes_leg_landed_per_significant_strike_landed_diff,
    t2.cumulative_significant_strikes_leg_landed_per_significant_strike_landed - t3.cumulative_significant_strikes_leg_landed_per_significant_strike_landed AS cumulative_significant_strikes_leg_landed_per_significant_strike_landed_diff,
    t2.avg_significant_strikes_leg_attempted - t3.avg_significant_strikes_leg_attempted AS avg_significant_strikes_leg_attempted_diff,
    t2.cumulative_significant_strikes_leg_attempted - t3.cumulative_significant_strikes_leg_attempted AS cumulative_significant_strikes_leg_attempted_diff,
    t2.avg_significant_strikes_leg_attempted_per_second - t3.avg_significant_strikes_leg_attempted_per_second AS avg_significant_strikes_leg_attempted_per_second_diff,
    t2.cumulative_significant_strikes_leg_attempted_per_second - t3.cumulative_significant_strikes_leg_attempted_per_second AS cumulative_significant_strikes_leg_attempted_per_second_diff,
    t2.avg_significant_strikes_leg_attempted_per_significant_strike_attempted - t3.avg_significant_strikes_leg_attempted_per_significant_strike_attempted AS avg_significant_strikes_leg_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted - t3.cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted AS cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted_diff,
    t2.avg_significant_strikes_distance_landed - t3.avg_significant_strikes_distance_landed AS avg_significant_strikes_distance_landed_diff,
    t2.cumulative_significant_strikes_distance_landed - t3.cumulative_significant_strikes_distance_landed AS cumulative_significant_strikes_distance_landed_diff,
    t2.avg_significant_strikes_distance_landed_per_second - t3.avg_significant_strikes_distance_landed_per_second AS avg_significant_strikes_distance_landed_per_second_diff,
    t2.cumulative_significant_strikes_distance_landed_per_second - t3.cumulative_significant_strikes_distance_landed_per_second AS cumulative_significant_strikes_distance_landed_per_second_diff,
    t2.avg_significant_strikes_distance_accuracy - t3.avg_significant_strikes_distance_accuracy AS avg_significant_strikes_distance_accuracy_diff,
    t2.cumulative_significant_strikes_distance_accuracy - t3.cumulative_significant_strikes_distance_accuracy AS cumulative_significant_strikes_distance_accuracy_diff,
    t2.avg_significant_strikes_distance_landed_per_significant_strike_landed - t3.avg_significant_strikes_distance_landed_per_significant_strike_landed AS avg_significant_strikes_distance_landed_per_significant_strike_landed_diff,
    t2.cumulative_significant_strikes_distance_landed_per_significant_strike_landed - t3.cumulative_significant_strikes_distance_landed_per_significant_strike_landed AS cumulative_significant_strikes_distance_landed_per_significant_strike_landed_diff,
    t2.avg_significant_strikes_distance_attempted - t3.avg_significant_strikes_distance_attempted AS avg_significant_strikes_distance_attempted_diff,
    t2.cumulative_significant_strikes_distance_attempted - t3.cumulative_significant_strikes_distance_attempted AS cumulative_significant_strikes_distance_attempted_diff,
    t2.avg_significant_strikes_distance_attempted_per_second - t3.avg_significant_strikes_distance_attempted_per_second AS avg_significant_strikes_distance_attempted_per_second_diff,
    t2.cumulative_significant_strikes_distance_attempted_per_second - t3.cumulative_significant_strikes_distance_attempted_per_second AS cumulative_significant_strikes_distance_attempted_per_second_diff,
    t2.avg_significant_strikes_distance_attempted_per_significant_strike_attempted - t3.avg_significant_strikes_distance_attempted_per_significant_strike_attempted AS avg_significant_strikes_distance_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted - t3.cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted AS cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted_diff,
    t2.avg_significant_strikes_clinch_landed - t3.avg_significant_strikes_clinch_landed AS avg_significant_strikes_clinch_landed_diff,
    t2.cumulative_significant_strikes_clinch_landed - t3.cumulative_significant_strikes_clinch_landed AS cumulative_significant_strikes_clinch_landed_diff,
    t2.avg_significant_strikes_clinch_landed_per_second - t3.avg_significant_strikes_clinch_landed_per_second AS avg_significant_strikes_clinch_landed_per_second_diff,
    t2.cumulative_significant_strikes_clinch_landed_per_second - t3.cumulative_significant_strikes_clinch_landed_per_second AS cumulative_significant_strikes_clinch_landed_per_second_diff,
    t2.avg_significant_strikes_clinch_accuracy - t3.avg_significant_strikes_clinch_accuracy AS avg_significant_strikes_clinch_accuracy_diff,
    t2.cumulative_significant_strikes_clinch_accuracy - t3.cumulative_significant_strikes_clinch_accuracy AS cumulative_significant_strikes_clinch_accuracy_diff,
    t2.avg_significant_strikes_clinch_landed_per_significant_strike_landed - t3.avg_significant_strikes_clinch_landed_per_significant_strike_landed AS avg_significant_strikes_clinch_landed_per_significant_strike_landed_diff,
    t2.cumulative_significant_strikes_clinch_landed_per_significant_strike_landed - t3.cumulative_significant_strikes_clinch_landed_per_significant_strike_landed AS cumulative_significant_strikes_clinch_landed_per_significant_strike_landed_diff,
    t2.avg_significant_strikes_clinch_attempted - t3.avg_significant_strikes_clinch_attempted AS avg_significant_strikes_clinch_attempted_diff,
    t2.cumulative_significant_strikes_clinch_attempted - t3.cumulative_significant_strikes_clinch_attempted AS cumulative_significant_strikes_clinch_attempted_diff,
    t2.avg_significant_strikes_clinch_attempted_per_second - t3.avg_significant_strikes_clinch_attempted_per_second AS avg_significant_strikes_clinch_attempted_per_second_diff,
    t2.cumulative_significant_strikes_clinch_attempted_per_second - t3.cumulative_significant_strikes_clinch_attempted_per_second AS cumulative_significant_strikes_clinch_attempted_per_second_diff,
    t2.avg_significant_strikes_clinch_attempted_per_significant_strike_attempted - t3.avg_significant_strikes_clinch_attempted_per_significant_strike_attempted AS avg_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted - t3.cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted AS cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff,
    t2.avg_significant_strikes_ground_landed - t3.avg_significant_strikes_ground_landed AS avg_significant_strikes_ground_landed_diff,
    t2.cumulative_significant_strikes_ground_landed - t3.cumulative_significant_strikes_ground_landed AS cumulative_significant_strikes_ground_landed_diff,
    t2.avg_significant_strikes_ground_landed_per_second - t3.avg_significant_strikes_ground_landed_per_second AS avg_significant_strikes_ground_landed_per_second_diff,
    t2.cumulative_significant_strikes_ground_landed_per_second - t3.cumulative_significant_strikes_ground_landed_per_second AS cumulative_significant_strikes_ground_landed_per_second_diff,
    t2.avg_significant_strikes_ground_accuracy - t3.avg_significant_strikes_ground_accuracy AS avg_significant_strikes_ground_accuracy_diff,
    t2.cumulative_significant_strikes_ground_accuracy - t3.cumulative_significant_strikes_ground_accuracy AS cumulative_significant_strikes_ground_accuracy_diff,
    t2.avg_significant_strikes_ground_landed_per_significant_strike_landed - t3.avg_significant_strikes_ground_landed_per_significant_strike_landed AS avg_significant_strikes_ground_landed_per_significant_strike_landed_diff,
    t2.cumulative_significant_strikes_ground_landed_per_significant_strike_landed - t3.cumulative_significant_strikes_ground_landed_per_significant_strike_landed AS cumulative_significant_strikes_ground_landed_per_significant_strike_landed_diff,
    t2.avg_significant_strikes_ground_attempted - t3.avg_significant_strikes_ground_attempted AS avg_significant_strikes_ground_attempted_diff,
    t2.cumulative_significant_strikes_ground_attempted - t3.cumulative_significant_strikes_ground_attempted AS cumulative_significant_strikes_ground_attempted_diff,
    t2.avg_significant_strikes_ground_attempted_per_second - t3.avg_significant_strikes_ground_attempted_per_second AS avg_significant_strikes_ground_attempted_per_second_diff,
    t2.cumulative_significant_strikes_ground_attempted_per_second - t3.cumulative_significant_strikes_ground_attempted_per_second AS cumulative_significant_strikes_ground_attempted_per_second_diff,
    t2.avg_significant_strikes_ground_attempted_per_strike_attempted - t3.avg_significant_strikes_ground_attempted_per_strike_attempted AS avg_significant_strikes_ground_attempted_per_strike_attempted_diff,
    t2.cumulative_significant_strikes_ground_attempted_per_strike_attempted - t3.cumulative_significant_strikes_ground_attempted_per_strike_attempted AS cumulative_significant_strikes_ground_attempted_per_strike_attempted_diff,
    t2.avg_significant_strikes_distance_head_landed - t3.avg_significant_strikes_distance_head_landed AS avg_significant_strikes_distance_head_landed_diff,
    t2.cumulative_significant_strikes_distance_head_landed - t3.cumulative_significant_strikes_distance_head_landed AS cumulative_significant_strikes_distance_head_landed_diff,
    t2.avg_significant_strikes_distance_head_landed_per_second - t3.avg_significant_strikes_distance_head_landed_per_second AS avg_significant_strikes_distance_head_landed_per_second_diff,
    t2.cumulative_significant_strikes_distance_head_landed_per_second - t3.cumulative_significant_strikes_distance_head_landed_per_second AS cumulative_significant_strikes_distance_head_landed_per_second_diff,
    t2.avg_significant_strikes_distance_head_accuracy - t3.avg_significant_strikes_distance_head_accuracy AS avg_significant_strikes_distance_head_accuracy_diff,
    t2.cumulative_significant_strikes_distance_head_accuracy - t3.cumulative_significant_strikes_distance_head_accuracy AS cumulative_significant_strikes_distance_head_accuracy_diff,
    t2.avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed - t3.avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed AS avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff,
    t2.cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed - t3.cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed AS cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff,
    t2.avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed - t3.avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed AS avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff,
    t2.cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed - t3.cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed AS cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_significant_strikes_distance_head_attempted - t3.avg_significant_strikes_distance_head_attempted AS avg_significant_strikes_distance_head_attempted_diff,
    t2.cumulative_significant_strikes_distance_head_attempted - t3.cumulative_significant_strikes_distance_head_attempted AS cumulative_significant_strikes_distance_head_attempted_diff,
    t2.avg_significant_strikes_distance_head_attempted_per_second - t3.avg_significant_strikes_distance_head_attempted_per_second AS avg_significant_strikes_distance_head_attempted_per_second_diff,
    t2.cumulative_significant_strikes_distance_head_attempted_per_second - t3.cumulative_significant_strikes_distance_head_attempted_per_second AS cumulative_significant_strikes_distance_head_attempted_per_second_diff,
    t2.avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted - t3.avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted AS avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff,
    t2.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted - t3.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted AS cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted - t3.avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted AS avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff,
    t2.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted - t3.cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted AS cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_significant_strikes_distance_body_landed - t3.avg_significant_strikes_distance_body_landed AS avg_significant_strikes_distance_body_landed_diff,
    t2.cumulative_significant_strikes_distance_body_landed - t3.cumulative_significant_strikes_distance_body_landed AS cumulative_significant_strikes_distance_body_landed_diff,
    t2.avg_significant_strikes_distance_body_landed_per_second - t3.avg_significant_strikes_distance_body_landed_per_second AS avg_significant_strikes_distance_body_landed_per_second_diff,
    t2.cumulative_significant_strikes_distance_body_landed_per_second - t3.cumulative_significant_strikes_distance_body_landed_per_second AS cumulative_significant_strikes_distance_body_landed_per_second_diff,
    t2.avg_significant_strikes_distance_body_accuracy - t3.avg_significant_strikes_distance_body_accuracy AS avg_significant_strikes_distance_body_accuracy_diff,
    t2.cumulative_significant_strikes_distance_body_accuracy - t3.cumulative_significant_strikes_distance_body_accuracy AS cumulative_significant_strikes_distance_body_accuracy_diff,
    t2.avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed - t3.avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed AS avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff,
    t2.cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed - t3.cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed AS cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff,
    t2.avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed - t3.avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed AS avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff,
    t2.cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed - t3.cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed AS cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_significant_strikes_distance_body_attempted - t3.avg_significant_strikes_distance_body_attempted AS avg_significant_strikes_distance_body_attempted_diff,
    t2.cumulative_significant_strikes_distance_body_attempted - t3.cumulative_significant_strikes_distance_body_attempted AS cumulative_significant_strikes_distance_body_attempted_diff,
    t2.avg_significant_strikes_distance_body_attempted_per_second - t3.avg_significant_strikes_distance_body_attempted_per_second AS avg_significant_strikes_distance_body_attempted_per_second_diff,
    t2.cumulative_significant_strikes_distance_body_attempted_per_second - t3.cumulative_significant_strikes_distance_body_attempted_per_second AS cumulative_significant_strikes_distance_body_attempted_per_second_diff,
    t2.avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted - t3.avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted AS avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff,
    t2.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted - t3.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted AS cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted - t3.avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted AS avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff,
    t2.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted - t3.cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted AS cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_significant_strikes_distance_leg_landed - t3.avg_significant_strikes_distance_leg_landed AS avg_significant_strikes_distance_leg_landed_diff,
    t2.cumulative_significant_strikes_distance_leg_landed - t3.cumulative_significant_strikes_distance_leg_landed AS cumulative_significant_strikes_distance_leg_landed_diff,
    t2.avg_significant_strikes_distance_leg_landed_per_second - t3.avg_significant_strikes_distance_leg_landed_per_second AS avg_significant_strikes_distance_leg_landed_per_second_diff,
    t2.cumulative_significant_strikes_distance_leg_landed_per_second - t3.cumulative_significant_strikes_distance_leg_landed_per_second AS cumulative_significant_strikes_distance_leg_landed_per_second_diff,
    t2.avg_significant_strikes_distance_leg_accuracy - t3.avg_significant_strikes_distance_leg_accuracy AS avg_significant_strikes_distance_leg_accuracy_diff,
    t2.cumulative_significant_strikes_distance_leg_accuracy - t3.cumulative_significant_strikes_distance_leg_accuracy AS cumulative_significant_strikes_distance_leg_accuracy_diff,
    t2.avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed - t3.avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed AS avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff,
    t2.cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed - t3.cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed AS cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff,
    t2.avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed - t3.avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed AS avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_significant_strikes_distance_leg_attempted - t3.avg_significant_strikes_distance_leg_attempted AS avg_significant_strikes_distance_leg_attempted_diff,
    t2.cumulative_significant_strikes_distance_leg_attempted - t3.cumulative_significant_strikes_distance_leg_attempted AS cumulative_significant_strikes_distance_leg_attempted_diff,
    t2.avg_significant_strikes_distance_leg_attempted_per_second - t3.avg_significant_strikes_distance_leg_attempted_per_second AS avg_significant_strikes_distance_leg_attempted_per_second_diff,
    t2.cumulative_significant_strikes_distance_leg_attempted_per_second - t3.cumulative_significant_strikes_distance_leg_attempted_per_second AS cumulative_significant_strikes_distance_leg_attempted_per_second_diff,
    t2.avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted - t3.avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted AS avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff,
    t2.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted - t3.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted AS cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted - t3.avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted AS avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted - t3.cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted AS cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_significant_strikes_clinch_head_landed - t3.avg_significant_strikes_clinch_head_landed AS avg_significant_strikes_clinch_head_landed_diff,
    t2.cumulative_significant_strikes_clinch_head_landed - t3.cumulative_significant_strikes_clinch_head_landed AS cumulative_significant_strikes_clinch_head_landed_diff,
    t2.avg_significant_strikes_clinch_head_landed_per_second - t3.avg_significant_strikes_clinch_head_landed_per_second AS avg_significant_strikes_clinch_head_landed_per_second_diff,
    t2.cumulative_significant_strikes_clinch_head_landed_per_second - t3.cumulative_significant_strikes_clinch_head_landed_per_second AS cumulative_significant_strikes_clinch_head_landed_per_second_diff,
    t2.avg_significant_strikes_clinch_head_accuracy - t3.avg_significant_strikes_clinch_head_accuracy AS avg_significant_strikes_clinch_head_accuracy_diff,
    t2.cumulative_significant_strikes_clinch_head_accuracy - t3.cumulative_significant_strikes_clinch_head_accuracy AS cumulative_significant_strikes_clinch_head_accuracy_diff,
    t2.avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed - t3.avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed AS avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff,
    t2.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed - t3.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed AS cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed - t3.avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed AS avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff,
    t2.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed - t3.cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed AS cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_significant_strikes_clinch_head_attempted - t3.avg_significant_strikes_clinch_head_attempted AS avg_significant_strikes_clinch_head_attempted_diff,
    t2.cumulative_significant_strikes_clinch_head_attempted - t3.cumulative_significant_strikes_clinch_head_attempted AS cumulative_significant_strikes_clinch_head_attempted_diff,
    t2.avg_significant_strikes_clinch_head_attempted_per_second - t3.avg_significant_strikes_clinch_head_attempted_per_second AS avg_significant_strikes_clinch_head_attempted_per_second_diff,
    t2.cumulative_significant_strikes_clinch_head_attempted_per_second - t3.cumulative_significant_strikes_clinch_head_attempted_per_second AS cumulative_significant_strikes_clinch_head_attempted_per_second_diff,
    t2.avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted - t3.avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted AS avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff,
    t2.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted - t3.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted AS cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted - t3.avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted AS avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff,
    t2.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted - t3.cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted AS cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_significant_strikes_clinch_body_landed - t3.avg_significant_strikes_clinch_body_landed AS avg_significant_strikes_clinch_body_landed_diff,
    t2.cumulative_significant_strikes_clinch_body_landed - t3.cumulative_significant_strikes_clinch_body_landed AS cumulative_significant_strikes_clinch_body_landed_diff,
    t2.avg_significant_strikes_clinch_body_landed_per_second - t3.avg_significant_strikes_clinch_body_landed_per_second AS avg_significant_strikes_clinch_body_landed_per_second_diff,
    t2.cumulative_significant_strikes_clinch_body_landed_per_second - t3.cumulative_significant_strikes_clinch_body_landed_per_second AS cumulative_significant_strikes_clinch_body_landed_per_second_diff,
    t2.avg_significant_strikes_clinch_body_accuracy - t3.avg_significant_strikes_clinch_body_accuracy AS avg_significant_strikes_clinch_body_accuracy_diff,
    t2.cumulative_significant_strikes_clinch_body_accuracy - t3.cumulative_significant_strikes_clinch_body_accuracy AS cumulative_significant_strikes_clinch_body_accuracy_diff,
    t2.avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed - t3.avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed AS avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff,
    t2.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed - t3.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed AS cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed - t3.avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed AS avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff,
    t2.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed - t3.cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed AS cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_significant_strikes_clinch_body_attempted - t3.avg_significant_strikes_clinch_body_attempted AS avg_significant_strikes_clinch_body_attempted_diff,
    t2.cumulative_significant_strikes_clinch_body_attempted - t3.cumulative_significant_strikes_clinch_body_attempted AS cumulative_significant_strikes_clinch_body_attempted_diff,
    t2.avg_significant_strikes_clinch_body_attempted_per_second - t3.avg_significant_strikes_clinch_body_attempted_per_second AS avg_significant_strikes_clinch_body_attempted_per_second_diff,
    t2.cumulative_significant_strikes_clinch_body_attempted_per_second - t3.cumulative_significant_strikes_clinch_body_attempted_per_second AS cumulative_significant_strikes_clinch_body_attempted_per_second_diff,
    t2.avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted - t3.avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted AS avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff,
    t2.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted - t3.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted AS cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted - t3.avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted AS avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff,
    t2.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted - t3.cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted AS cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_significant_strikes_clinch_leg_landed - t3.avg_significant_strikes_clinch_leg_landed AS avg_significant_strikes_clinch_leg_landed_diff,
    t2.cumulative_significant_strikes_clinch_leg_landed_per_second - t3.cumulative_significant_strikes_clinch_leg_landed_per_second AS cumulative_significant_strikes_clinch_leg_landed_per_second_diff,
    t2.avg_significant_strikes_clinch_leg_accuracy - t3.avg_significant_strikes_clinch_leg_accuracy AS avg_significant_strikes_clinch_leg_accuracy_diff,
    t2.cumulative_significant_strikes_clinch_leg_accuracy - t3.cumulative_significant_strikes_clinch_leg_accuracy AS cumulative_significant_strikes_clinch_leg_accuracy_diff,
    t2.avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed - t3.avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed AS avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff,
    t2.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed - t3.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed AS cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed - t3.avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed AS avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff,
    t2.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed - t3.cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed AS cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_significant_strikes_clinch_leg_attempted - t3.avg_significant_strikes_clinch_leg_attempted AS avg_significant_strikes_clinch_leg_attempted_diff,
    t2.cumulative_significant_strikes_clinch_leg_attempted - t3.cumulative_significant_strikes_clinch_leg_attempted AS cumulative_significant_strikes_clinch_leg_attempted_diff,
    t2.avg_significant_strikes_clinch_leg_attempted_per_second - t3.avg_significant_strikes_clinch_leg_attempted_per_second AS avg_significant_strikes_clinch_leg_attempted_per_second_diff,
    t2.cumulative_significant_strikes_clinch_leg_attempted_per_second - t3.cumulative_significant_strikes_clinch_leg_attempted_per_second AS cumulative_significant_strikes_clinch_leg_attempted_per_second_diff,
    t2.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted - t3.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted AS avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff,
    t2.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted - t3.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted AS cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted - t3.avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted AS avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted - t3.cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted AS cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_significant_strikes_ground_head_landed - t3.avg_significant_strikes_ground_head_landed AS avg_significant_strikes_ground_head_landed_diff,
    t2.cumulative_significant_strikes_ground_head_landed - t3.cumulative_significant_strikes_ground_head_landed AS cumulative_significant_strikes_ground_head_landed_diff,
    t2.avg_significant_strikes_ground_head_landed_per_second - t3.avg_significant_strikes_ground_head_landed_per_second AS avg_significant_strikes_ground_head_landed_per_second_diff,
    t2.cumulative_significant_strikes_ground_head_landed_per_second - t3.cumulative_significant_strikes_ground_head_landed_per_second AS cumulative_significant_strikes_ground_head_landed_per_second_diff,
    t2.avg_significant_strikes_ground_head_accuracy - t3.avg_significant_strikes_ground_head_accuracy AS avg_significant_strikes_ground_head_accuracy_diff,
    t2.cumulative_significant_strikes_ground_head_accuracy - t3.cumulative_significant_strikes_ground_head_accuracy AS cumulative_significant_strikes_ground_head_accuracy_diff,
    t2.avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed - t3.avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed AS avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff,
    t2.cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed - t3.cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed AS cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff,
    t2.avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed - t3.avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed AS avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff,
    t2.cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed - t3.cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed AS cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_significant_strikes_ground_head_attempted - t3.avg_significant_strikes_ground_head_attempted AS avg_significant_strikes_ground_head_attempted_diff,
    t2.cumulative_significant_strikes_ground_head_attempted - t3.cumulative_significant_strikes_ground_head_attempted AS cumulative_significant_strikes_ground_head_attempted_diff,
    t2.avg_significant_strikes_ground_head_attempted_per_second - t3.avg_significant_strikes_ground_head_attempted_per_second AS avg_significant_strikes_ground_head_attempted_per_second_diff,
    t2.cumulative_significant_strikes_ground_head_attempted_per_second - t3.cumulative_significant_strikes_ground_head_attempted_per_second AS cumulative_significant_strikes_ground_head_attempted_per_second_diff,
    t2.avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted - t3.avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted AS avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff,
    t2.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted - t3.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted AS cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted - t3.avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted AS avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff,
    t2.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted - t3.cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted AS cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_significant_strikes_ground_body_landed - t3.avg_significant_strikes_ground_body_landed AS avg_significant_strikes_ground_body_landed_diff,
    t2.cumulative_significant_strikes_ground_body_landed - t3.cumulative_significant_strikes_ground_body_landed AS cumulative_significant_strikes_ground_body_landed_diff,
    t2.avg_significant_strikes_ground_body_landed_per_second - t3.avg_significant_strikes_ground_body_landed_per_second AS avg_significant_strikes_ground_body_landed_per_second_diff,
    t2.cumulative_significant_strikes_ground_body_landed_per_second - t3.cumulative_significant_strikes_ground_body_landed_per_second AS cumulative_significant_strikes_ground_body_landed_per_second_diff,
    t2.avg_significant_strikes_ground_body_accuracy - t3.avg_significant_strikes_ground_body_accuracy AS avg_significant_strikes_ground_body_accuracy_diff,
    t2.cumulative_significant_strikes_ground_body_accuracy - t3.cumulative_significant_strikes_ground_body_accuracy AS cumulative_significant_strikes_ground_body_accuracy_diff,
    t2.avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed - t3.avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed AS avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff,
    t2.cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed - t3.cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed AS cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff,
    t2.avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed - t3.avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed AS avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff,
    t2.cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed - t3.cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed AS cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_significant_strikes_ground_body_attempted - t3.avg_significant_strikes_ground_body_attempted AS avg_significant_strikes_ground_body_attempted_diff,
    t2.cumulative_significant_strikes_ground_body_attempted - t3.cumulative_significant_strikes_ground_body_attempted AS cumulative_significant_strikes_ground_body_attempted_diff,
    t2.avg_significant_strikes_ground_body_attempted_per_second - t3.avg_significant_strikes_ground_body_attempted_per_second AS avg_significant_strikes_ground_body_attempted_per_second_diff,
    t2.cumulative_significant_strikes_ground_body_attempted_per_second - t3.cumulative_significant_strikes_ground_body_attempted_per_second AS cumulative_significant_strikes_ground_body_attempted_per_second_diff,
    t2.avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted - t3.avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted AS avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff,
    t2.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted - t3.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted AS cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted - t3.avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted AS avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff,
    t2.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted - t3.cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted AS cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_significant_strikes_ground_leg_landed - t3.avg_significant_strikes_ground_leg_landed AS avg_significant_strikes_ground_leg_landed_diff,
    t2.cumulative_significant_strikes_ground_leg_landed - t3.cumulative_significant_strikes_ground_leg_landed AS cumulative_significant_strikes_ground_leg_landed_diff,
    t2.avg_significant_strikes_ground_leg_landed_per_second - t3.avg_significant_strikes_ground_leg_landed_per_second AS avg_significant_strikes_ground_leg_landed_per_second_diff,
    t2.cumulative_significant_strikes_ground_leg_landed_per_second - t3.cumulative_significant_strikes_ground_leg_landed_per_second AS cumulative_significant_strikes_ground_leg_landed_per_second_diff,
    t2.avg_significant_strikes_ground_leg_accuracy - t3.avg_significant_strikes_ground_leg_accuracy AS avg_significant_strikes_ground_leg_accuracy_diff,
    t2.cumulative_significant_strikes_ground_leg_accuracy - t3.cumulative_significant_strikes_ground_leg_accuracy AS cumulative_significant_strikes_ground_leg_accuracy_diff,
    t2.avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed - t3.avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed AS avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff,
    t2.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed - t3.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed AS cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff,
    t2.avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed - t3.avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed AS avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff,
    t2.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed - t3.cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed AS cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_significant_strikes_ground_leg_attempted - t3.avg_significant_strikes_ground_leg_attempted AS avg_significant_strikes_ground_leg_attempted_diff,
    t2.cumulative_significant_strikes_ground_leg_attempted - t3.cumulative_significant_strikes_ground_leg_attempted AS cumulative_significant_strikes_ground_leg_attempted_diff,
    t2.avg_significant_strikes_ground_leg_attempted_per_second - t3.avg_significant_strikes_ground_leg_attempted_per_second AS avg_significant_strikes_ground_leg_attempted_per_second_diff,
    t2.cumulative_significant_strikes_ground_leg_attempted_per_second - t3.cumulative_significant_strikes_ground_leg_attempted_per_second AS cumulative_significant_strikes_ground_leg_attempted_per_second_diff,
    t2.avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted - t3.avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted AS avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff,
    t2.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted - t3.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted AS cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted - t3.avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted AS avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted - t3.cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted AS cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_takedowns_landed - t3.avg_takedowns_landed AS avg_takedowns_landed_diff,
    t2.cumulative_takedowns_landed - t3.cumulative_takedowns_landed AS cumulative_takedowns_landed_diff,
    t2.avg_takedowns_landed_per_second - t3.avg_takedowns_landed_per_second AS avg_takedowns_landed_per_second_diff,
    t2.cumulative_takedowns_landed_per_second - t3.cumulative_takedowns_landed_per_second AS cumulative_takedowns_landed_per_second_diff,
    t2.avg_takedowns_accuracy - t3.avg_takedowns_accuracy AS avg_takedowns_accuracy_diff,
    t2.cumulative_takedowns_accuracy - t3.cumulative_takedowns_accuracy AS cumulative_takedowns_accuracy_diff,
    t2.avg_takedowns_slams_landed - t3.avg_takedowns_slams_landed AS avg_takedowns_slams_landed_diff,
    t2.cumulative_takedowns_slams_landed - t3.cumulative_takedowns_slams_landed AS cumulative_takedowns_slams_landed_diff,
    t2.avg_takedowns_slams_landed_per_second - t3.avg_takedowns_slams_landed_per_second AS avg_takedowns_slams_landed_per_second_diff,
    t2.cumulative_takedowns_slams_landed_per_second - t3.cumulative_takedowns_slams_landed_per_second AS cumulative_takedowns_slams_landed_per_second_diff,
    t2.avg_takedowns_slams_landed_per_takedowns_landed - t3.avg_takedowns_slams_landed_per_takedowns_landed AS avg_takedowns_slams_landed_per_takedowns_landed_diff,
    t2.cumulative_takedowns_slams_landed_per_takedowns_landed - t3.cumulative_takedowns_slams_landed_per_takedowns_landed AS cumulative_takedowns_slams_landed_per_takedowns_landed_diff,
    t2.avg_takedowns_attempted - t3.avg_takedowns_attempted AS avg_takedowns_attempted_diff,
    t2.cumulative_takedowns_attempted - t3.cumulative_takedowns_attempted AS cumulative_takedowns_attempted_diff,
    t2.avg_takedowns_attempted_per_second - t3.avg_takedowns_attempted_per_second AS avg_takedowns_attempted_per_second_diff,
    t2.cumulative_takedowns_attempted_per_second - t3.cumulative_takedowns_attempted_per_second AS cumulative_takedowns_attempted_per_second_diff,
    t2.avg_advances - t3.avg_advances AS avg_advances_diff,
    t2.cumulative_advances - t3.cumulative_advances AS cumulative_advances_diff,
    t2.avg_advances_per_second - t3.avg_advances_per_second AS avg_advances_per_second_diff,
    t2.cumulative_advances_per_second - t3.cumulative_advances_per_second AS cumulative_advances_per_second_diff,
    t2.avg_advances_to_back - t3.avg_advances_to_back AS avg_advances_to_back_diff,
    t2.cumulative_advances_to_back - t3.cumulative_advances_to_back AS cumulative_advances_to_back_diff,
    t2.avg_advances_to_back_per_second - t3.avg_advances_to_back_per_second AS avg_advances_to_back_per_second_diff,
    t2.cumulative_advances_to_back_per_second - t3.cumulative_advances_to_back_per_second AS cumulative_advances_to_back_per_second_diff,
    t2.avg_advances_to_back_per_advances - t3.avg_advances_to_back_per_advances AS avg_advances_to_back_per_advances_diff,
    t2.cumulative_advances_to_back_per_advances - t3.cumulative_advances_to_back_per_advances AS cumulative_advances_to_back_per_advances_diff,
    t2.avg_advances_to_half_guard - t3.avg_advances_to_half_guard AS avg_advances_to_half_guard_diff,
    t2.cumulative_advances_to_half_guard - t3.cumulative_advances_to_half_guard AS cumulative_advances_to_half_guard_diff,
    t2.avg_advances_to_half_guard_per_second - t3.avg_advances_to_half_guard_per_second AS avg_advances_to_half_guard_per_second_diff,
    t2.cumulative_advances_to_half_guard_per_second - t3.cumulative_advances_to_half_guard_per_second AS cumulative_advances_to_half_guard_per_second_diff,
    t2.avg_advances_to_half_guard_per_advances - t3.avg_advances_to_half_guard_per_advances AS avg_advances_to_half_guard_per_advances_diff,
    t2.cumulative_advances_to_half_guard_per_advances - t3.cumulative_advances_to_half_guard_per_advances AS cumulative_advances_to_half_guard_per_advances_diff,
    t2.avg_advances_to_mount - t3.avg_advances_to_mount AS avg_advances_to_mount_diff,
    t2.cumulative_advances_to_mount - t3.cumulative_advances_to_mount AS cumulative_advances_to_mount_diff,
    t2.avg_advances_to_mount_per_second - t3.avg_advances_to_mount_per_second AS avg_advances_to_mount_per_second_diff,
    t2.cumulative_advances_to_mount_per_second - t3.cumulative_advances_to_mount_per_second AS cumulative_advances_to_mount_per_second_diff,
    t2.avg_advances_to_mount_per_advances - t3.avg_advances_to_mount_per_advances AS avg_advances_to_mount_per_advances_diff,
    t2.cumulative_advances_to_mount_per_advances - t3.cumulative_advances_to_mount_per_advances AS cumulative_advances_to_mount_per_advances_diff,
    t2.avg_advances_to_side - t3.avg_advances_to_side AS avg_advances_to_side_diff,
    t2.cumulative_advances_to_side - t3.cumulative_advances_to_side AS cumulative_advances_to_side_diff,
    t2.avg_advances_to_side_per_second - t3.avg_advances_to_side_per_second AS avg_advances_to_side_per_second_diff,
    t2.cumulative_advances_to_side_per_second - t3.cumulative_advances_to_side_per_second AS cumulative_advances_to_side_per_second_diff,
    t2.avg_advances_to_side_per_advances - t3.avg_advances_to_side_per_advances AS avg_advances_to_side_per_advances_diff,
    t2.cumulative_advances_to_side_per_advances - t3.cumulative_advances_to_side_per_advances AS cumulative_advances_to_side_per_advances_diff,
    t2.avg_reversals_scored - t3.avg_reversals_scored AS avg_reversals_scored_diff,
    t2.cumulative_reversals_scored - t3.cumulative_reversals_scored AS cumulative_reversals_scored_diff,
    t2.avg_reversals_scored_per_second - t3.avg_reversals_scored_per_second AS avg_reversals_scored_per_second_diff,
    t2.cumulative_reversals_scored_per_second - t3.cumulative_reversals_scored_per_second AS cumulative_reversals_scored_per_second_diff,
    t2.avg_submissions_landed - t3.avg_submissions_landed AS avg_submissions_landed_diff,
    t2.cumulative_submissions_landed - t3.cumulative_submissions_landed AS cumulative_submissions_landed_diff,
    t2.avg_submissions_landed_per_second - t3.avg_submissions_landed_per_second AS avg_submissions_landed_per_second_diff,
    t2.cumulative_submissions_landed_per_second - t3.cumulative_submissions_landed_per_second AS cumulative_submissions_landed_per_second_diff,
    t2.avg_submissions_accuracy - t3.avg_submissions_accuracy AS avg_submissions_accuracy_diff,
    t2.cumulative_submissions_accuracy - t3.cumulative_submissions_accuracy AS cumulative_submissions_accuracy_diff,
    t2.avg_submissions_attempted - t3.avg_submissions_attempted AS avg_submissions_attempted_diff,
    t2.cumulative_submissions_attempted - t3.cumulative_submissions_attempted AS cumulative_submissions_attempted_diff,
    t2.avg_submissions_attempted_per_second - t3.avg_submissions_attempted_per_second AS avg_submissions_attempted_per_second_diff,
    t2.cumulative_submissions_attempted_per_second - t3.cumulative_submissions_attempted_per_second AS cumulative_submissions_attempted_per_second_diff,
    t2.avg_control_time_seconds - t3.avg_control_time_seconds AS avg_control_time_seconds_diff,
    t2.cumulative_control_time_seconds - t3.cumulative_control_time_seconds AS cumulative_control_time_seconds_diff,
    t2.avg_control_time_seconds_per_second - t3.avg_control_time_seconds_per_second AS avg_control_time_seconds_per_second_diff,
    t2.cumulative_control_time_seconds_per_second - t3.cumulative_control_time_seconds_per_second AS cumulative_control_time_seconds_per_second_diff,
    t2.avg_opp_knockdowns_scored - t3.avg_opp_knockdowns_scored AS avg_opp_knockdowns_scored_diff,
    t2.cumulative_opp_knockdowns_scored - t3.cumulative_opp_knockdowns_scored AS cumulative_opp_knockdowns_scored_diff,
    t2.avg_opp_knockdowns_scored_per_second - t3.avg_opp_knockdowns_scored_per_second AS avg_opp_knockdowns_scored_per_second_diff,
    t2.cumulative_opp_knockdowns_scored_per_second - t3.cumulative_opp_knockdowns_scored_per_second AS cumulative_opp_knockdowns_scored_per_second_diff,
    t2.avg_opp_knockdowns_scored_per_strike_landed - t3.avg_opp_knockdowns_scored_per_strike_landed AS avg_opp_knockdowns_scored_per_strike_landed_diff,
    t2.cumulative_opp_knockdowns_scored_per_strike_landed - t3.cumulative_opp_knockdowns_scored_per_strike_landed AS cumulative_opp_knockdowns_scored_per_strike_landed_diff,
    t2.avg_opp_knockdowns_scored_per_strike_attempted - t3.avg_opp_knockdowns_scored_per_strike_attempted AS avg_opp_knockdowns_scored_per_strike_attempted_diff,
    t2.cumulative_opp_knockdowns_scored_per_strike_attempted - t3.cumulative_opp_knockdowns_scored_per_strike_attempted AS cumulative_opp_knockdowns_scored_per_strike_attempted_diff,
    t2.avg_opp_knockdowns_scored_per_significant_strike_landed - t3.avg_opp_knockdowns_scored_per_significant_strike_landed AS avg_opp_knockdowns_scored_per_significant_strike_landed_diff,
    t2.cumulative_opp_knockdowns_scored_per_significant_strike_landed - t3.cumulative_opp_knockdowns_scored_per_significant_strike_landed AS cumulative_opp_knockdowns_scored_per_significant_strike_landed_diff,
    t2.avg_opp_knockdowns_scored_per_significant_strike_attempted - t3.avg_opp_knockdowns_scored_per_significant_strike_attempted AS avg_opp_knockdowns_scored_per_significant_strike_attempted_diff,
    t2.cumulative_opp_knockdowns_scored_per_significant_strike_attempted - t3.cumulative_opp_knockdowns_scored_per_significant_strike_attempted AS cumulative_opp_knockdowns_scored_per_significant_strike_attempted_diff,
    t2.avg_opp_knockdowns_scored_per_significant_strike_head_landed - t3.avg_opp_knockdowns_scored_per_significant_strike_head_landed AS avg_opp_knockdowns_scored_per_significant_strike_head_landed_diff,
    t2.cumulative_opp_knockdowns_scored_per_significant_strike_head_landed - t3.cumulative_opp_knockdowns_scored_per_significant_strike_head_landed AS cumulative_opp_knockdowns_scored_per_significant_strike_head_landed_diff,
    t2.avg_opp_knockdowns_scored_per_significant_strike_head_attempted - t3.avg_opp_knockdowns_scored_per_significant_strike_head_attempted AS avg_opp_knockdowns_scored_per_significant_strike_head_attempted_diff,
    t2.cumulative_opp_knockdowns_scored_per_significant_strike_head_attempted - t3.cumulative_opp_knockdowns_scored_per_significant_strike_head_attempted AS cumulative_opp_knockdowns_scored_per_significant_strike_head_attempted_diff,
    t2.avg_opp_ko_tko_landed - t3.avg_opp_ko_tko_landed AS avg_opp_ko_tko_landed_diff,
    t2.cumulative_opp_ko_tko_landed - t3.cumulative_opp_ko_tko_landed AS cumulative_opp_ko_tko_landed_diff,
    t2.avg_opp_ko_tko_landed_per_second - t3.avg_opp_ko_tko_landed_per_second AS avg_opp_ko_tko_landed_per_second_diff,
    t2.cumulative_opp_ko_tko_landed_per_second - t3.cumulative_opp_ko_tko_landed_per_second AS cumulative_opp_ko_tko_landed_per_second_diff,
    t2.avg_opp_ko_tko_landed_per_strike_landed - t3.avg_opp_ko_tko_landed_per_strike_landed AS avg_opp_ko_tko_landed_per_strike_landed_diff,
    t2.cumulative_opp_ko_tko_landed_per_strike_landed - t3.cumulative_opp_ko_tko_landed_per_strike_landed AS cumulative_opp_ko_tko_landed_per_strike_landed_diff,
    t2.avg_opp_ko_tko_landed_per_strike_attempted - t3.avg_opp_ko_tko_landed_per_strike_attempted AS avg_opp_ko_tko_landed_per_strike_attempted_diff,
    t2.cumulative_opp_ko_tko_landed_per_strike_attempted - t3.cumulative_opp_ko_tko_landed_per_strike_attempted AS cumulative_opp_ko_tko_landed_per_strike_attempted_diff,
    t2.avg_opp_ko_tko_landed_per_significant_strike_landed - t3.avg_opp_ko_tko_landed_per_significant_strike_landed AS avg_opp_ko_tko_landed_per_significant_strike_landed_diff,
    t2.cumulative_opp_ko_tko_landed_per_significant_strike_landed - t3.cumulative_opp_ko_tko_landed_per_significant_strike_landed AS cumulative_opp_ko_tko_landed_per_significant_strike_landed_diff,
    t2.avg_opp_ko_tko_landed_per_significant_strike_attempted - t3.avg_opp_ko_tko_landed_per_significant_strike_attempted AS avg_opp_ko_tko_landed_per_significant_strike_attempted_diff,
    t2.cumulative_opp_ko_tko_landed_per_significant_strike_attempted - t3.cumulative_opp_ko_tko_landed_per_significant_strike_attempted AS cumulative_opp_ko_tko_landed_per_significant_strike_attempted_diff,
    t2.avg_opp_ko_tko_landed_per_significant_strike_head_landed - t3.avg_opp_ko_tko_landed_per_significant_strike_head_landed AS avg_opp_ko_tko_landed_per_significant_strike_head_landed_diff,
    t2.cumulative_opp_ko_tko_landed_per_significant_strike_head_landed - t3.cumulative_opp_ko_tko_landed_per_significant_strike_head_landed AS cumulative_opp_ko_tko_landed_per_significant_strike_head_landed_diff,
    t2.avg_opp_ko_tko_landed_per_significant_strike_head_attempted - t3.avg_opp_ko_tko_landed_per_significant_strike_head_attempted AS avg_opp_ko_tko_landed_per_significant_strike_head_attempted_diff,
    t2.cumulative_opp_ko_tko_landed_per_significant_strike_head_attempted - t3.cumulative_opp_ko_tko_landed_per_significant_strike_head_attempted AS cumulative_opp_ko_tko_landed_per_significant_strike_head_attempted_diff,
    t2.avg_opp_total_strikes_landed - t3.avg_opp_total_strikes_landed AS avg_opp_total_strikes_landed_diff,
    t2.cumulative_opp_total_strikes_landed - t3.cumulative_opp_total_strikes_landed AS cumulative_opp_total_strikes_landed_diff,
    t2.avg_opp_total_strikes_landed_per_second - t3.avg_opp_total_strikes_landed_per_second AS avg_opp_total_strikes_landed_per_second_diff,
    t2.cumulative_opp_total_strikes_landed_per_second - t3.cumulative_opp_total_strikes_landed_per_second AS cumulative_opp_total_strikes_landed_per_second_diff,
    t2.avg_opp_total_strikes_accuracy - t3.avg_opp_total_strikes_accuracy AS avg_opp_total_strikes_accuracy_diff,
    t2.cumulative_opp_total_strikes_accuracy - t3.cumulative_opp_total_strikes_accuracy AS cumulative_opp_total_strikes_accuracy_diff,
    t2.avg_opp_total_strikes_attempted - t3.avg_opp_total_strikes_attempted AS avg_opp_total_strikes_attempted_diff,
    t2.cumulative_opp_total_strikes_attempted - t3.cumulative_opp_total_strikes_attempted AS cumulative_opp_total_strikes_attempted_diff,
    t2.avg_opp_total_strikes_attempted_per_second - t3.avg_opp_total_strikes_attempted_per_second AS avg_opp_total_strikes_attempted_per_second_diff,
    t2.cumulative_opp_total_strikes_attempted_per_second - t3.cumulative_opp_total_strikes_attempted_per_second AS cumulative_opp_total_strikes_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_landed - t3.avg_opp_significant_strikes_landed AS avg_opp_significant_strikes_landed_diff,
    t2.cumulative_opp_significant_strikes_landed - t3.cumulative_opp_significant_strikes_landed AS cumulative_opp_significant_strikes_landed_diff,
    t2.avg_opp_significant_strikes_landed_per_second - t3.avg_opp_significant_strikes_landed_per_second AS avg_opp_significant_strikes_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_landed_per_second - t3.cumulative_opp_significant_strikes_landed_per_second AS cumulative_opp_significant_strikes_landed_per_second_diff,
    t2.avg_opp_significant_strikes_accuracy - t3.avg_opp_significant_strikes_accuracy AS avg_opp_significant_strikes_accuracy_diff,
    t2.cumulative_opp_significant_strikes_accuracy - t3.cumulative_opp_significant_strikes_accuracy AS cumulative_opp_significant_strikes_accuracy_diff,
    t2.avg_opp_significant_strikes_landed_per_strike_landed - t3.avg_opp_significant_strikes_landed_per_strike_landed AS avg_opp_significant_strikes_landed_per_strike_landed_diff,
    t2.cumulative_opp_significant_strikes_landed_per_strike_landed - t3.cumulative_opp_significant_strikes_landed_per_strike_landed AS cumulative_opp_significant_strikes_landed_per_strike_landed_diff,
    t2.avg_opp_significant_strikes_attempted - t3.avg_opp_significant_strikes_attempted AS avg_opp_significant_strikes_attempted_diff,
    t2.cumulative_opp_significant_strikes_attempted - t3.cumulative_opp_significant_strikes_attempted AS cumulative_opp_significant_strikes_attempted_diff,
    t2.avg_opp_significant_strikes_attempted_per_second - t3.avg_opp_significant_strikes_attempted_per_second AS avg_opp_significant_strikes_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_attempted_per_second - t3.cumulative_opp_significant_strikes_attempted_per_second AS cumulative_opp_significant_strikes_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_attempted_per_strike_attempted - t3.avg_opp_significant_strikes_attempted_per_strike_attempted AS avg_opp_significant_strikes_attempted_per_strike_attempted_diff,
    t2.cumulative_opp_significant_strikes_attempted_per_strike_attempted - t3.cumulative_opp_significant_strikes_attempted_per_strike_attempted AS cumulative_opp_significant_strikes_attempted_per_strike_attempted_diff,
    t2.avg_opp_significant_strikes_head_landed - t3.avg_opp_significant_strikes_head_landed AS avg_opp_significant_strikes_head_landed_diff,
    t2.cumulative_opp_significant_strikes_head_landed - t3.cumulative_opp_significant_strikes_head_landed AS cumulative_opp_significant_strikes_head_landed_diff,
    t2.avg_opp_significant_strikes_head_landed_per_second - t3.avg_opp_significant_strikes_head_landed_per_second AS avg_opp_significant_strikes_head_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_head_landed_per_second - t3.cumulative_opp_significant_strikes_head_landed_per_second AS cumulative_opp_significant_strikes_head_landed_per_second_diff,
    t2.avg_opp_significant_strikes_head_accuracy - t3.avg_opp_significant_strikes_head_accuracy AS avg_opp_significant_strikes_head_accuracy_diff,
    t2.cumulative_opp_significant_strikes_head_accuracy - t3.cumulative_opp_significant_strikes_head_accuracy AS cumulative_opp_significant_strikes_head_accuracy_diff,
    t2.avg_opp_significant_strikes_head_landed_per_significant_strike_landed - t3.avg_opp_significant_strikes_head_landed_per_significant_strike_landed AS avg_opp_significant_strikes_head_landed_per_significant_strike_landed_diff,
    t2.cumulative_opp_significant_strikes_head_landed_per_significant_strike_landed - t3.cumulative_opp_significant_strikes_head_landed_per_significant_strike_landed AS cumulative_opp_significant_strikes_head_landed_per_significant_strike_landed_diff,
    t2.avg_opp_significant_strikes_head_attempted - t3.avg_opp_significant_strikes_head_attempted AS avg_opp_significant_strikes_head_attempted_diff,
    t2.cumulative_opp_significant_strikes_head_attempted - t3.cumulative_opp_significant_strikes_head_attempted AS cumulative_opp_significant_strikes_head_attempted_diff,
    t2.avg_opp_significant_strikes_head_attempted_per_second - t3.avg_opp_significant_strikes_head_attempted_per_second AS avg_opp_significant_strikes_head_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_head_attempted_per_second - t3.cumulative_opp_significant_strikes_head_attempted_per_second AS cumulative_opp_significant_strikes_head_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_head_attempted_per_significant_strike_attempted - t3.avg_opp_significant_strikes_head_attempted_per_significant_strike_attempted AS avg_opp_significant_strikes_head_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_opp_significant_strikes_head_attempted_per_significant_strike_attempted - t3.cumulative_opp_significant_strikes_head_attempted_per_significant_strike_attempted AS cumulative_opp_significant_strikes_head_attempted_per_significant_strike_attempted_diff,
    t2.avg_opp_significant_strikes_body_landed - t3.avg_opp_significant_strikes_body_landed AS avg_opp_significant_strikes_body_landed_diff,
    t2.cumulative_opp_significant_strikes_body_landed - t3.cumulative_opp_significant_strikes_body_landed AS cumulative_opp_significant_strikes_body_landed_diff,
    t2.avg_opp_significant_strikes_body_landed_per_second - t3.avg_opp_significant_strikes_body_landed_per_second AS avg_opp_significant_strikes_body_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_body_landed_per_second - t3.cumulative_opp_significant_strikes_body_landed_per_second AS cumulative_opp_significant_strikes_body_landed_per_second_diff,
    t2.avg_opp_significant_strikes_body_accuracy - t3.avg_opp_significant_strikes_body_accuracy AS avg_opp_significant_strikes_body_accuracy_diff,
    t2.cumulative_opp_significant_strikes_body_accuracy - t3.cumulative_opp_significant_strikes_body_accuracy AS cumulative_opp_significant_strikes_body_accuracy_diff,
    t2.avg_opp_significant_strikes_body_landed_per_significant_strike_landed - t3.avg_opp_significant_strikes_body_landed_per_significant_strike_landed AS avg_opp_significant_strikes_body_landed_per_significant_strike_landed_diff,
    t2.cumulative_opp_significant_strikes_body_landed_per_significant_strike_landed - t3.cumulative_opp_significant_strikes_body_landed_per_significant_strike_landed AS cumulative_opp_significant_strikes_body_landed_per_significant_strike_landed_diff,
    t2.avg_opp_significant_strikes_body_attempted - t3.avg_opp_significant_strikes_body_attempted AS avg_opp_significant_strikes_body_attempted_diff,
    t2.cumulative_opp_significant_strikes_body_attempted - t3.cumulative_opp_significant_strikes_body_attempted AS cumulative_opp_significant_strikes_body_attempted_diff,
    t2.avg_opp_significant_strikes_body_attempted_per_second - t3.avg_opp_significant_strikes_body_attempted_per_second AS avg_opp_significant_strikes_body_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_body_attempted_per_second - t3.cumulative_opp_significant_strikes_body_attempted_per_second AS cumulative_opp_significant_strikes_body_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_body_attempted_per_significant_strike_attempted - t3.avg_opp_significant_strikes_body_attempted_per_significant_strike_attempted AS avg_opp_significant_strikes_body_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_opp_significant_strikes_body_attempted_per_significant_strike_attempted - t3.cumulative_opp_significant_strikes_body_attempted_per_significant_strike_attempted AS cumulative_opp_significant_strikes_body_attempted_per_significant_strike_attempted_diff,
    t2.avg_opp_significant_strikes_leg_landed - t3.avg_opp_significant_strikes_leg_landed AS avg_opp_significant_strikes_leg_landed_diff,
    t2.cumulative_opp_significant_strikes_leg_landed - t3.cumulative_opp_significant_strikes_leg_landed AS cumulative_opp_significant_strikes_leg_landed_diff,
    t2.avg_opp_significant_strikes_leg_landed_per_second - t3.avg_opp_significant_strikes_leg_landed_per_second AS avg_opp_significant_strikes_leg_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_leg_landed_per_second - t3.cumulative_opp_significant_strikes_leg_landed_per_second AS cumulative_opp_significant_strikes_leg_landed_per_second_diff,
    t2.avg_opp_significant_strikes_leg_accuracy - t3.avg_opp_significant_strikes_leg_accuracy AS avg_opp_significant_strikes_leg_accuracy_diff,
    t2.cumulative_opp_significant_strikes_leg_accuracy - t3.cumulative_opp_significant_strikes_leg_accuracy AS cumulative_opp_significant_strikes_leg_accuracy_diff,
    t2.avg_opp_significant_strikes_leg_landed_per_significant_strike_landed - t3.avg_opp_significant_strikes_leg_landed_per_significant_strike_landed AS avg_opp_significant_strikes_leg_landed_per_significant_strike_landed_diff,
    t2.cumulative_opp_significant_strikes_leg_landed_per_significant_strike_landed - t3.cumulative_opp_significant_strikes_leg_landed_per_significant_strike_landed AS cumulative_opp_significant_strikes_leg_landed_per_significant_strike_landed_diff,
    t2.avg_opp_significant_strikes_leg_attempted - t3.avg_opp_significant_strikes_leg_attempted AS avg_opp_significant_strikes_leg_attempted_diff,
    t2.cumulative_opp_significant_strikes_leg_attempted - t3.cumulative_opp_significant_strikes_leg_attempted AS cumulative_opp_significant_strikes_leg_attempted_diff,
    t2.avg_opp_significant_strikes_leg_attempted_per_second - t3.avg_opp_significant_strikes_leg_attempted_per_second AS avg_opp_significant_strikes_leg_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_leg_attempted_per_second - t3.cumulative_opp_significant_strikes_leg_attempted_per_second AS cumulative_opp_significant_strikes_leg_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_leg_attempted_per_significant_strike_attempted - t3.avg_opp_significant_strikes_leg_attempted_per_significant_strike_attempted AS avg_opp_significant_strikes_leg_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_opp_significant_strikes_leg_attempted_per_significant_strike_attempted - t3.cumulative_opp_significant_strikes_leg_attempted_per_significant_strike_attempted AS cumulative_opp_significant_strikes_leg_attempted_per_significant_strike_attempted_diff,
    t2.avg_opp_significant_strikes_distance_landed - t3.avg_opp_significant_strikes_distance_landed AS avg_opp_significant_strikes_distance_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_landed - t3.cumulative_opp_significant_strikes_distance_landed AS cumulative_opp_significant_strikes_distance_landed_diff,
    t2.avg_opp_significant_strikes_distance_landed_per_second - t3.avg_opp_significant_strikes_distance_landed_per_second AS avg_opp_significant_strikes_distance_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_distance_landed_per_second - t3.cumulative_opp_significant_strikes_distance_landed_per_second AS cumulative_opp_significant_strikes_distance_landed_per_second_diff,
    t2.avg_opp_significant_strikes_distance_accuracy - t3.avg_opp_significant_strikes_distance_accuracy AS avg_opp_significant_strikes_distance_accuracy_diff,
    t2.cumulative_opp_significant_strikes_distance_accuracy - t3.cumulative_opp_significant_strikes_distance_accuracy AS cumulative_opp_significant_strikes_distance_accuracy_diff,
    t2.avg_opp_significant_strikes_distance_landed_per_significant_strike_landed - t3.avg_opp_significant_strikes_distance_landed_per_significant_strike_landed AS avg_opp_significant_strikes_distance_landed_per_significant_strike_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_landed_per_significant_strike_landed - t3.cumulative_opp_significant_strikes_distance_landed_per_significant_strike_landed AS cumulative_opp_significant_strikes_distance_landed_per_significant_strike_landed_diff,
    t2.avg_opp_significant_strikes_distance_attempted - t3.avg_opp_significant_strikes_distance_attempted AS avg_opp_significant_strikes_distance_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_attempted - t3.cumulative_opp_significant_strikes_distance_attempted AS cumulative_opp_significant_strikes_distance_attempted_diff,
    t2.avg_opp_significant_strikes_distance_attempted_per_second - t3.avg_opp_significant_strikes_distance_attempted_per_second AS avg_opp_significant_strikes_distance_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_distance_attempted_per_second - t3.cumulative_opp_significant_strikes_distance_attempted_per_second AS cumulative_opp_significant_strikes_distance_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_distance_attempted_per_significant_strike_attempted - t3.avg_opp_significant_strikes_distance_attempted_per_significant_strike_attempted AS avg_opp_significant_strikes_distance_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_attempted_per_significant_strike_attempted - t3.cumulative_opp_significant_strikes_distance_attempted_per_significant_strike_attempted AS cumulative_opp_significant_strikes_distance_attempted_per_significant_strike_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_landed - t3.avg_opp_significant_strikes_clinch_landed AS avg_opp_significant_strikes_clinch_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_landed - t3.cumulative_opp_significant_strikes_clinch_landed AS cumulative_opp_significant_strikes_clinch_landed_diff,
    t2.avg_opp_significant_strikes_clinch_landed_per_second - t3.avg_opp_significant_strikes_clinch_landed_per_second AS avg_opp_significant_strikes_clinch_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_clinch_landed_per_second - t3.cumulative_opp_significant_strikes_clinch_landed_per_second AS cumulative_opp_significant_strikes_clinch_landed_per_second_diff,
    t2.avg_opp_significant_strikes_clinch_accuracy - t3.avg_opp_significant_strikes_clinch_accuracy AS avg_opp_significant_strikes_clinch_accuracy_diff,
    t2.cumulative_opp_significant_strikes_clinch_accuracy - t3.cumulative_opp_significant_strikes_clinch_accuracy AS cumulative_opp_significant_strikes_clinch_accuracy_diff,
    t2.avg_opp_significant_strikes_clinch_landed_per_significant_strike_landed - t3.avg_opp_significant_strikes_clinch_landed_per_significant_strike_landed AS avg_opp_significant_strikes_clinch_landed_per_significant_strike_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_landed_per_significant_strike_landed - t3.cumulative_opp_significant_strikes_clinch_landed_per_significant_strike_landed AS cumulative_opp_significant_strikes_clinch_landed_per_significant_strike_landed_diff,
    t2.avg_opp_significant_strikes_clinch_attempted - t3.avg_opp_significant_strikes_clinch_attempted AS avg_opp_significant_strikes_clinch_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_attempted - t3.cumulative_opp_significant_strikes_clinch_attempted AS cumulative_opp_significant_strikes_clinch_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_attempted_per_second - t3.avg_opp_significant_strikes_clinch_attempted_per_second AS avg_opp_significant_strikes_clinch_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_clinch_attempted_per_second - t3.cumulative_opp_significant_strikes_clinch_attempted_per_second AS cumulative_opp_significant_strikes_clinch_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_clinch_attempted_per_significant_strike_attempted - t3.avg_opp_significant_strikes_clinch_attempted_per_significant_strike_attempted AS avg_opp_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_attempted_per_significant_strike_attempted - t3.cumulative_opp_significant_strikes_clinch_attempted_per_significant_strike_attempted AS cumulative_opp_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff,
    t2.avg_opp_significant_strikes_ground_landed - t3.avg_opp_significant_strikes_ground_landed AS avg_opp_significant_strikes_ground_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_landed - t3.cumulative_opp_significant_strikes_ground_landed AS cumulative_opp_significant_strikes_ground_landed_diff,
    t2.avg_opp_significant_strikes_ground_landed_per_second - t3.avg_opp_significant_strikes_ground_landed_per_second AS avg_opp_significant_strikes_ground_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_ground_landed_per_second - t3.cumulative_opp_significant_strikes_ground_landed_per_second AS cumulative_opp_significant_strikes_ground_landed_per_second_diff,
    t2.avg_opp_significant_strikes_ground_accuracy - t3.avg_opp_significant_strikes_ground_accuracy AS avg_opp_significant_strikes_ground_accuracy_diff,
    t2.cumulative_opp_significant_strikes_ground_accuracy - t3.cumulative_opp_significant_strikes_ground_accuracy AS cumulative_opp_significant_strikes_ground_accuracy_diff,
    t2.avg_opp_significant_strikes_ground_landed_per_significant_strike_landed - t3.avg_opp_significant_strikes_ground_landed_per_significant_strike_landed AS avg_opp_significant_strikes_ground_landed_per_significant_strike_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_landed_per_significant_strike_landed - t3.cumulative_opp_significant_strikes_ground_landed_per_significant_strike_landed AS cumulative_opp_significant_strikes_ground_landed_per_significant_strike_landed_diff,
    t2.avg_opp_significant_strikes_ground_attempted - t3.avg_opp_significant_strikes_ground_attempted AS avg_opp_significant_strikes_ground_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_attempted - t3.cumulative_opp_significant_strikes_ground_attempted AS cumulative_opp_significant_strikes_ground_attempted_diff,
    t2.avg_opp_significant_strikes_ground_attempted_per_second - t3.avg_opp_significant_strikes_ground_attempted_per_second AS avg_opp_significant_strikes_ground_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_ground_attempted_per_second - t3.cumulative_opp_significant_strikes_ground_attempted_per_second AS cumulative_opp_significant_strikes_ground_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_ground_attempted_per_strike_attempted - t3.avg_opp_significant_strikes_ground_attempted_per_strike_attempted AS avg_opp_significant_strikes_ground_attempted_per_strike_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_attempted_per_strike_attempted - t3.cumulative_opp_significant_strikes_ground_attempted_per_strike_attempted AS cumulative_opp_significant_strikes_ground_attempted_per_strike_attempted_diff,
    t2.avg_opp_significant_strikes_distance_head_landed - t3.avg_opp_significant_strikes_distance_head_landed AS avg_opp_significant_strikes_distance_head_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_head_landed - t3.cumulative_opp_significant_strikes_distance_head_landed AS cumulative_opp_significant_strikes_distance_head_landed_diff,
    t2.avg_opp_significant_strikes_distance_head_landed_per_second - t3.avg_opp_significant_strikes_distance_head_landed_per_second AS avg_opp_significant_strikes_distance_head_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_distance_head_landed_per_second - t3.cumulative_opp_significant_strikes_distance_head_landed_per_second AS cumulative_opp_significant_strikes_distance_head_landed_per_second_diff,
    t2.avg_opp_significant_strikes_distance_head_accuracy - t3.avg_opp_significant_strikes_distance_head_accuracy AS avg_opp_significant_strikes_distance_head_accuracy_diff,
    t2.cumulative_opp_significant_strikes_distance_head_accuracy - t3.cumulative_opp_significant_strikes_distance_head_accuracy AS cumulative_opp_significant_strikes_distance_head_accuracy_diff,
    t2.avg_opp_significant_strikes_distance_head_landed_per_significant_strike_distance_landed - t3.avg_opp_significant_strikes_distance_head_landed_per_significant_strike_distance_landed AS avg_opp_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_head_landed_per_significant_strike_distance_landed - t3.cumulative_opp_significant_strikes_distance_head_landed_per_significant_strike_distance_landed AS cumulative_opp_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff,
    t2.avg_opp_significant_strikes_distance_head_landed_per_significant_strike_head_landed - t3.avg_opp_significant_strikes_distance_head_landed_per_significant_strike_head_landed AS avg_opp_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_head_landed_per_significant_strike_head_landed - t3.cumulative_opp_significant_strikes_distance_head_landed_per_significant_strike_head_landed AS cumulative_opp_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_opp_significant_strikes_distance_head_attempted - t3.avg_opp_significant_strikes_distance_head_attempted AS avg_opp_significant_strikes_distance_head_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_head_attempted - t3.cumulative_opp_significant_strikes_distance_head_attempted AS cumulative_opp_significant_strikes_distance_head_attempted_diff,
    t2.avg_opp_significant_strikes_distance_head_attempted_per_second - t3.avg_opp_significant_strikes_distance_head_attempted_per_second AS avg_opp_significant_strikes_distance_head_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_distance_head_attempted_per_second - t3.cumulative_opp_significant_strikes_distance_head_attempted_per_second AS cumulative_opp_significant_strikes_distance_head_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted - t3.avg_opp_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted AS avg_opp_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted - t3.cumulative_opp_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted AS cumulative_opp_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_opp_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted - t3.avg_opp_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted AS avg_opp_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted - t3.cumulative_opp_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted AS cumulative_opp_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_opp_significant_strikes_distance_body_landed - t3.avg_opp_significant_strikes_distance_body_landed AS avg_opp_significant_strikes_distance_body_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_body_landed - t3.cumulative_opp_significant_strikes_distance_body_landed AS cumulative_opp_significant_strikes_distance_body_landed_diff,
    t2.avg_opp_significant_strikes_distance_body_landed_per_second - t3.avg_opp_significant_strikes_distance_body_landed_per_second AS avg_opp_significant_strikes_distance_body_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_distance_body_landed_per_second - t3.cumulative_opp_significant_strikes_distance_body_landed_per_second AS cumulative_opp_significant_strikes_distance_body_landed_per_second_diff,
    t2.avg_opp_significant_strikes_distance_body_accuracy - t3.avg_opp_significant_strikes_distance_body_accuracy AS avg_opp_significant_strikes_distance_body_accuracy_diff,
    t2.cumulative_opp_significant_strikes_distance_body_accuracy - t3.cumulative_opp_significant_strikes_distance_body_accuracy AS cumulative_opp_significant_strikes_distance_body_accuracy_diff,
    t2.avg_opp_significant_strikes_distance_body_landed_per_significant_strike_distance_landed - t3.avg_opp_significant_strikes_distance_body_landed_per_significant_strike_distance_landed AS avg_opp_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_body_landed_per_significant_strike_distance_landed - t3.cumulative_opp_significant_strikes_distance_body_landed_per_significant_strike_distance_landed AS cumulative_opp_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff,
    t2.avg_opp_significant_strikes_distance_body_landed_per_significant_strike_body_landed - t3.avg_opp_significant_strikes_distance_body_landed_per_significant_strike_body_landed AS avg_opp_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_body_landed_per_significant_strike_body_landed - t3.cumulative_opp_significant_strikes_distance_body_landed_per_significant_strike_body_landed AS cumulative_opp_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_opp_significant_strikes_distance_body_attempted - t3.avg_opp_significant_strikes_distance_body_attempted AS avg_opp_significant_strikes_distance_body_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_body_attempted - t3.cumulative_opp_significant_strikes_distance_body_attempted AS cumulative_opp_significant_strikes_distance_body_attempted_diff,
    t2.avg_opp_significant_strikes_distance_body_attempted_per_second - t3.avg_opp_significant_strikes_distance_body_attempted_per_second AS avg_opp_significant_strikes_distance_body_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_distance_body_attempted_per_second - t3.cumulative_opp_significant_strikes_distance_body_attempted_per_second AS cumulative_opp_significant_strikes_distance_body_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted - t3.avg_opp_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted AS avg_opp_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted - t3.cumulative_opp_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted AS cumulative_opp_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_opp_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted - t3.avg_opp_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted AS avg_opp_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted - t3.cumulative_opp_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted AS cumulative_opp_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_opp_significant_strikes_distance_leg_landed - t3.avg_opp_significant_strikes_distance_leg_landed AS avg_opp_significant_strikes_distance_leg_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_leg_landed - t3.cumulative_opp_significant_strikes_distance_leg_landed AS cumulative_opp_significant_strikes_distance_leg_landed_diff,
    t2.avg_opp_significant_strikes_distance_leg_landed_per_second - t3.avg_opp_significant_strikes_distance_leg_landed_per_second AS avg_opp_significant_strikes_distance_leg_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_distance_leg_landed_per_second - t3.cumulative_opp_significant_strikes_distance_leg_landed_per_second AS cumulative_opp_significant_strikes_distance_leg_landed_per_second_diff,
    t2.avg_opp_significant_strikes_distance_leg_accuracy - t3.avg_opp_significant_strikes_distance_leg_accuracy AS avg_opp_significant_strikes_distance_leg_accuracy_diff,
    t2.cumulative_opp_significant_strikes_distance_leg_accuracy - t3.cumulative_opp_significant_strikes_distance_leg_accuracy AS cumulative_opp_significant_strikes_distance_leg_accuracy_diff,
    t2.avg_opp_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed - t3.avg_opp_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed AS avg_opp_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff,
    t2.cumulative_opp_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed - t3.cumulative_opp_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed AS cumulative_opp_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff,
    t2.avg_opp_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed - t3.avg_opp_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed AS avg_opp_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_opp_significant_strikes_distance_leg_attempted - t3.avg_opp_significant_strikes_distance_leg_attempted AS avg_opp_significant_strikes_distance_leg_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_leg_attempted - t3.cumulative_opp_significant_strikes_distance_leg_attempted AS cumulative_opp_significant_strikes_distance_leg_attempted_diff,
    t2.avg_opp_significant_strikes_distance_leg_attempted_per_second - t3.avg_opp_significant_strikes_distance_leg_attempted_per_second AS avg_opp_significant_strikes_distance_leg_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_distance_leg_attempted_per_second - t3.cumulative_opp_significant_strikes_distance_leg_attempted_per_second AS cumulative_opp_significant_strikes_distance_leg_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted - t3.avg_opp_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted AS avg_opp_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted - t3.cumulative_opp_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted AS cumulative_opp_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_opp_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted - t3.avg_opp_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted AS avg_opp_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.cumulative_opp_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted - t3.cumulative_opp_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted AS cumulative_opp_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_head_landed - t3.avg_opp_significant_strikes_clinch_head_landed AS avg_opp_significant_strikes_clinch_head_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_head_landed - t3.cumulative_opp_significant_strikes_clinch_head_landed AS cumulative_opp_significant_strikes_clinch_head_landed_diff,
    t2.avg_opp_significant_strikes_clinch_head_landed_per_second - t3.avg_opp_significant_strikes_clinch_head_landed_per_second AS avg_opp_significant_strikes_clinch_head_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_clinch_head_landed_per_second - t3.cumulative_opp_significant_strikes_clinch_head_landed_per_second AS cumulative_opp_significant_strikes_clinch_head_landed_per_second_diff,
    t2.avg_opp_significant_strikes_clinch_head_accuracy - t3.avg_opp_significant_strikes_clinch_head_accuracy AS avg_opp_significant_strikes_clinch_head_accuracy_diff,
    t2.cumulative_opp_significant_strikes_clinch_head_accuracy - t3.cumulative_opp_significant_strikes_clinch_head_accuracy AS cumulative_opp_significant_strikes_clinch_head_accuracy_diff,
    t2.avg_opp_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed - t3.avg_opp_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed AS avg_opp_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed - t3.cumulative_opp_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed AS cumulative_opp_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_opp_significant_strikes_clinch_head_landed_per_significant_strike_head_landed - t3.avg_opp_significant_strikes_clinch_head_landed_per_significant_strike_head_landed AS avg_opp_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_head_landed_per_significant_strike_head_landed - t3.cumulative_opp_significant_strikes_clinch_head_landed_per_significant_strike_head_landed AS cumulative_opp_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_opp_significant_strikes_clinch_head_attempted - t3.avg_opp_significant_strikes_clinch_head_attempted AS avg_opp_significant_strikes_clinch_head_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_head_attempted - t3.cumulative_opp_significant_strikes_clinch_head_attempted AS cumulative_opp_significant_strikes_clinch_head_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_head_attempted_per_second - t3.avg_opp_significant_strikes_clinch_head_attempted_per_second AS avg_opp_significant_strikes_clinch_head_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_clinch_head_attempted_per_second - t3.cumulative_opp_significant_strikes_clinch_head_attempted_per_second AS cumulative_opp_significant_strikes_clinch_head_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted - t3.avg_opp_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted AS avg_opp_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted - t3.cumulative_opp_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted AS cumulative_opp_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted - t3.avg_opp_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted AS avg_opp_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted - t3.cumulative_opp_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted AS cumulative_opp_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_body_landed - t3.avg_opp_significant_strikes_clinch_body_landed AS avg_opp_significant_strikes_clinch_body_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_body_landed - t3.cumulative_opp_significant_strikes_clinch_body_landed AS cumulative_opp_significant_strikes_clinch_body_landed_diff,
    t2.avg_opp_significant_strikes_clinch_body_landed_per_second - t3.avg_opp_significant_strikes_clinch_body_landed_per_second AS avg_opp_significant_strikes_clinch_body_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_clinch_body_landed_per_second - t3.cumulative_opp_significant_strikes_clinch_body_landed_per_second AS cumulative_opp_significant_strikes_clinch_body_landed_per_second_diff,
    t2.avg_opp_significant_strikes_clinch_body_accuracy - t3.avg_opp_significant_strikes_clinch_body_accuracy AS avg_opp_significant_strikes_clinch_body_accuracy_diff,
    t2.cumulative_opp_significant_strikes_clinch_body_accuracy - t3.cumulative_opp_significant_strikes_clinch_body_accuracy AS cumulative_opp_significant_strikes_clinch_body_accuracy_diff,
    t2.avg_opp_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed - t3.avg_opp_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed AS avg_opp_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed - t3.cumulative_opp_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed AS cumulative_opp_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_opp_significant_strikes_clinch_body_landed_per_significant_strike_body_landed - t3.avg_opp_significant_strikes_clinch_body_landed_per_significant_strike_body_landed AS avg_opp_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_body_landed_per_significant_strike_body_landed - t3.cumulative_opp_significant_strikes_clinch_body_landed_per_significant_strike_body_landed AS cumulative_opp_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_opp_significant_strikes_clinch_body_attempted - t3.avg_opp_significant_strikes_clinch_body_attempted AS avg_opp_significant_strikes_clinch_body_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_body_attempted - t3.cumulative_opp_significant_strikes_clinch_body_attempted AS cumulative_opp_significant_strikes_clinch_body_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_body_attempted_per_second - t3.avg_opp_significant_strikes_clinch_body_attempted_per_second AS avg_opp_significant_strikes_clinch_body_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_clinch_body_attempted_per_second - t3.cumulative_opp_significant_strikes_clinch_body_attempted_per_second AS cumulative_opp_significant_strikes_clinch_body_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted - t3.avg_opp_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted AS avg_opp_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted - t3.cumulative_opp_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted AS cumulative_opp_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted - t3.avg_opp_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted AS avg_opp_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted - t3.cumulative_opp_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted AS cumulative_opp_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_leg_landed - t3.avg_opp_significant_strikes_clinch_leg_landed AS avg_opp_significant_strikes_clinch_leg_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_leg_landed_per_second - t3.cumulative_opp_significant_strikes_clinch_leg_landed_per_second AS cumulative_opp_significant_strikes_clinch_leg_landed_per_second_diff,
    t2.avg_opp_significant_strikes_clinch_leg_accuracy - t3.avg_opp_significant_strikes_clinch_leg_accuracy AS avg_opp_significant_strikes_clinch_leg_accuracy_diff,
    t2.cumulative_opp_significant_strikes_clinch_leg_accuracy - t3.cumulative_opp_significant_strikes_clinch_leg_accuracy AS cumulative_opp_significant_strikes_clinch_leg_accuracy_diff,
    t2.avg_opp_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed - t3.avg_opp_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed AS avg_opp_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed - t3.cumulative_opp_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed AS cumulative_opp_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_opp_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed - t3.avg_opp_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed AS avg_opp_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff,
    t2.cumulative_opp_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed - t3.cumulative_opp_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed AS cumulative_opp_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_opp_significant_strikes_clinch_leg_attempted - t3.avg_opp_significant_strikes_clinch_leg_attempted AS avg_opp_significant_strikes_clinch_leg_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_leg_attempted - t3.cumulative_opp_significant_strikes_clinch_leg_attempted AS cumulative_opp_significant_strikes_clinch_leg_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_leg_attempted_per_second - t3.avg_opp_significant_strikes_clinch_leg_attempted_per_second AS avg_opp_significant_strikes_clinch_leg_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_clinch_leg_attempted_per_second - t3.cumulative_opp_significant_strikes_clinch_leg_attempted_per_second AS cumulative_opp_significant_strikes_clinch_leg_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted - t3.avg_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted AS avg_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted - t3.cumulative_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted AS cumulative_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted - t3.avg_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted AS avg_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.cumulative_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted - t3.cumulative_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted AS cumulative_opp_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_opp_significant_strikes_ground_head_landed - t3.avg_opp_significant_strikes_ground_head_landed AS avg_opp_significant_strikes_ground_head_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_head_landed - t3.cumulative_opp_significant_strikes_ground_head_landed AS cumulative_opp_significant_strikes_ground_head_landed_diff,
    t2.avg_opp_significant_strikes_ground_head_landed_per_second - t3.avg_opp_significant_strikes_ground_head_landed_per_second AS avg_opp_significant_strikes_ground_head_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_ground_head_landed_per_second - t3.cumulative_opp_significant_strikes_ground_head_landed_per_second AS cumulative_opp_significant_strikes_ground_head_landed_per_second_diff,
    t2.avg_opp_significant_strikes_ground_head_accuracy - t3.avg_opp_significant_strikes_ground_head_accuracy AS avg_opp_significant_strikes_ground_head_accuracy_diff,
    t2.cumulative_opp_significant_strikes_ground_head_accuracy - t3.cumulative_opp_significant_strikes_ground_head_accuracy AS cumulative_opp_significant_strikes_ground_head_accuracy_diff,
    t2.avg_opp_significant_strikes_ground_head_landed_per_significant_strike_ground_landed - t3.avg_opp_significant_strikes_ground_head_landed_per_significant_strike_ground_landed AS avg_opp_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_head_landed_per_significant_strike_ground_landed - t3.cumulative_opp_significant_strikes_ground_head_landed_per_significant_strike_ground_landed AS cumulative_opp_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff,
    t2.avg_opp_significant_strikes_ground_head_landed_per_significant_strike_head_landed - t3.avg_opp_significant_strikes_ground_head_landed_per_significant_strike_head_landed AS avg_opp_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_head_landed_per_significant_strike_head_landed - t3.cumulative_opp_significant_strikes_ground_head_landed_per_significant_strike_head_landed AS cumulative_opp_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_opp_significant_strikes_ground_head_attempted - t3.avg_opp_significant_strikes_ground_head_attempted AS avg_opp_significant_strikes_ground_head_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_head_attempted - t3.cumulative_opp_significant_strikes_ground_head_attempted AS cumulative_opp_significant_strikes_ground_head_attempted_diff,
    t2.avg_opp_significant_strikes_ground_head_attempted_per_second - t3.avg_opp_significant_strikes_ground_head_attempted_per_second AS avg_opp_significant_strikes_ground_head_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_ground_head_attempted_per_second - t3.cumulative_opp_significant_strikes_ground_head_attempted_per_second AS cumulative_opp_significant_strikes_ground_head_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted - t3.avg_opp_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted AS avg_opp_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted - t3.cumulative_opp_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted AS cumulative_opp_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_opp_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted - t3.avg_opp_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted AS avg_opp_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted - t3.cumulative_opp_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted AS cumulative_opp_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_opp_significant_strikes_ground_body_landed - t3.avg_opp_significant_strikes_ground_body_landed AS avg_opp_significant_strikes_ground_body_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_body_landed - t3.cumulative_opp_significant_strikes_ground_body_landed AS cumulative_opp_significant_strikes_ground_body_landed_diff,
    t2.avg_opp_significant_strikes_ground_body_landed_per_second - t3.avg_opp_significant_strikes_ground_body_landed_per_second AS avg_opp_significant_strikes_ground_body_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_ground_body_landed_per_second - t3.cumulative_opp_significant_strikes_ground_body_landed_per_second AS cumulative_opp_significant_strikes_ground_body_landed_per_second_diff,
    t2.avg_opp_significant_strikes_ground_body_accuracy - t3.avg_opp_significant_strikes_ground_body_accuracy AS avg_opp_significant_strikes_ground_body_accuracy_diff,
    t2.cumulative_opp_significant_strikes_ground_body_accuracy - t3.cumulative_opp_significant_strikes_ground_body_accuracy AS cumulative_opp_significant_strikes_ground_body_accuracy_diff,
    t2.avg_opp_significant_strikes_ground_body_landed_per_significant_strike_ground_landed - t3.avg_opp_significant_strikes_ground_body_landed_per_significant_strike_ground_landed AS avg_opp_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_body_landed_per_significant_strike_ground_landed - t3.cumulative_opp_significant_strikes_ground_body_landed_per_significant_strike_ground_landed AS cumulative_opp_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff,
    t2.avg_opp_significant_strikes_ground_body_landed_per_significant_strike_body_landed - t3.avg_opp_significant_strikes_ground_body_landed_per_significant_strike_body_landed AS avg_opp_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_body_landed_per_significant_strike_body_landed - t3.cumulative_opp_significant_strikes_ground_body_landed_per_significant_strike_body_landed AS cumulative_opp_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_opp_significant_strikes_ground_body_attempted - t3.avg_opp_significant_strikes_ground_body_attempted AS avg_opp_significant_strikes_ground_body_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_body_attempted - t3.cumulative_opp_significant_strikes_ground_body_attempted AS cumulative_opp_significant_strikes_ground_body_attempted_diff,
    t2.avg_opp_significant_strikes_ground_body_attempted_per_second - t3.avg_opp_significant_strikes_ground_body_attempted_per_second AS avg_opp_significant_strikes_ground_body_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_ground_body_attempted_per_second - t3.cumulative_opp_significant_strikes_ground_body_attempted_per_second AS cumulative_opp_significant_strikes_ground_body_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted - t3.avg_opp_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted AS avg_opp_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted - t3.cumulative_opp_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted AS cumulative_opp_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_opp_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted - t3.avg_opp_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted AS avg_opp_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted - t3.cumulative_opp_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted AS cumulative_opp_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_opp_significant_strikes_ground_leg_landed - t3.avg_opp_significant_strikes_ground_leg_landed AS avg_opp_significant_strikes_ground_leg_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_leg_landed - t3.cumulative_opp_significant_strikes_ground_leg_landed AS cumulative_opp_significant_strikes_ground_leg_landed_diff,
    t2.avg_opp_significant_strikes_ground_leg_landed_per_second - t3.avg_opp_significant_strikes_ground_leg_landed_per_second AS avg_opp_significant_strikes_ground_leg_landed_per_second_diff,
    t2.cumulative_opp_significant_strikes_ground_leg_landed_per_second - t3.cumulative_opp_significant_strikes_ground_leg_landed_per_second AS cumulative_opp_significant_strikes_ground_leg_landed_per_second_diff,
    t2.avg_opp_significant_strikes_ground_leg_accuracy - t3.avg_opp_significant_strikes_ground_leg_accuracy AS avg_opp_significant_strikes_ground_leg_accuracy_diff,
    t2.cumulative_opp_significant_strikes_ground_leg_accuracy - t3.cumulative_opp_significant_strikes_ground_leg_accuracy AS cumulative_opp_significant_strikes_ground_leg_accuracy_diff,
    t2.avg_opp_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed - t3.avg_opp_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed AS avg_opp_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed - t3.cumulative_opp_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed AS cumulative_opp_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff,
    t2.avg_opp_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed - t3.avg_opp_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed AS avg_opp_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff,
    t2.cumulative_opp_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed - t3.cumulative_opp_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed AS cumulative_opp_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_opp_significant_strikes_ground_leg_attempted - t3.avg_opp_significant_strikes_ground_leg_attempted AS avg_opp_significant_strikes_ground_leg_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_leg_attempted - t3.cumulative_opp_significant_strikes_ground_leg_attempted AS cumulative_opp_significant_strikes_ground_leg_attempted_diff,
    t2.avg_opp_significant_strikes_ground_leg_attempted_per_second - t3.avg_opp_significant_strikes_ground_leg_attempted_per_second AS avg_opp_significant_strikes_ground_leg_attempted_per_second_diff,
    t2.cumulative_opp_significant_strikes_ground_leg_attempted_per_second - t3.cumulative_opp_significant_strikes_ground_leg_attempted_per_second AS cumulative_opp_significant_strikes_ground_leg_attempted_per_second_diff,
    t2.avg_opp_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted - t3.avg_opp_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted AS avg_opp_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted - t3.cumulative_opp_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted AS cumulative_opp_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_opp_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted - t3.avg_opp_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted AS avg_opp_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.cumulative_opp_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted - t3.cumulative_opp_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted AS cumulative_opp_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_opp_takedowns_landed - t3.avg_opp_takedowns_landed AS avg_opp_takedowns_landed_diff,
    t2.cumulative_opp_takedowns_landed - t3.cumulative_opp_takedowns_landed AS cumulative_opp_takedowns_landed_diff,
    t2.avg_opp_takedowns_landed_per_second - t3.avg_opp_takedowns_landed_per_second AS avg_opp_takedowns_landed_per_second_diff,
    t2.cumulative_opp_takedowns_landed_per_second - t3.cumulative_opp_takedowns_landed_per_second AS cumulative_opp_takedowns_landed_per_second_diff,
    t2.avg_opp_takedowns_accuracy - t3.avg_opp_takedowns_accuracy AS avg_opp_takedowns_accuracy_diff,
    t2.cumulative_opp_takedowns_accuracy - t3.cumulative_opp_takedowns_accuracy AS cumulative_opp_takedowns_accuracy_diff,
    t2.avg_opp_takedowns_slams_landed - t3.avg_opp_takedowns_slams_landed AS avg_opp_takedowns_slams_landed_diff,
    t2.cumulative_opp_takedowns_slams_landed - t3.cumulative_opp_takedowns_slams_landed AS cumulative_opp_takedowns_slams_landed_diff,
    t2.avg_opp_takedowns_slams_landed_per_second - t3.avg_opp_takedowns_slams_landed_per_second AS avg_opp_takedowns_slams_landed_per_second_diff,
    t2.cumulative_opp_takedowns_slams_landed_per_second - t3.cumulative_opp_takedowns_slams_landed_per_second AS cumulative_opp_takedowns_slams_landed_per_second_diff,
    t2.avg_opp_takedowns_slams_landed_per_takedowns_landed - t3.avg_opp_takedowns_slams_landed_per_takedowns_landed AS avg_opp_takedowns_slams_landed_per_takedowns_landed_diff,
    t2.cumulative_opp_takedowns_slams_landed_per_takedowns_landed - t3.cumulative_opp_takedowns_slams_landed_per_takedowns_landed AS cumulative_opp_takedowns_slams_landed_per_takedowns_landed_diff,
    t2.avg_opp_takedowns_attempted - t3.avg_opp_takedowns_attempted AS avg_opp_takedowns_attempted_diff,
    t2.cumulative_opp_takedowns_attempted - t3.cumulative_opp_takedowns_attempted AS cumulative_opp_takedowns_attempted_diff,
    t2.avg_opp_takedowns_attempted_per_second - t3.avg_opp_takedowns_attempted_per_second AS avg_opp_takedowns_attempted_per_second_diff,
    t2.cumulative_opp_takedowns_attempted_per_second - t3.cumulative_opp_takedowns_attempted_per_second AS cumulative_opp_takedowns_attempted_per_second_diff,
    t2.avg_opp_advances - t3.avg_opp_advances AS avg_opp_advances_diff,
    t2.cumulative_opp_advances - t3.cumulative_opp_advances AS cumulative_opp_advances_diff,
    t2.avg_opp_advances_per_second - t3.avg_opp_advances_per_second AS avg_opp_advances_per_second_diff,
    t2.cumulative_opp_advances_per_second - t3.cumulative_opp_advances_per_second AS cumulative_opp_advances_per_second_diff,
    t2.avg_opp_advances_to_back - t3.avg_opp_advances_to_back AS avg_opp_advances_to_back_diff,
    t2.cumulative_opp_advances_to_back - t3.cumulative_opp_advances_to_back AS cumulative_opp_advances_to_back_diff,
    t2.avg_opp_advances_to_back_per_second - t3.avg_opp_advances_to_back_per_second AS avg_opp_advances_to_back_per_second_diff,
    t2.cumulative_opp_advances_to_back_per_second - t3.cumulative_opp_advances_to_back_per_second AS cumulative_opp_advances_to_back_per_second_diff,
    t2.avg_opp_advances_to_back_per_advances - t3.avg_opp_advances_to_back_per_advances AS avg_opp_advances_to_back_per_advances_diff,
    t2.cumulative_opp_advances_to_back_per_advances - t3.cumulative_opp_advances_to_back_per_advances AS cumulative_opp_advances_to_back_per_advances_diff,
    t2.avg_opp_advances_to_half_guard - t3.avg_opp_advances_to_half_guard AS avg_opp_advances_to_half_guard_diff,
    t2.cumulative_opp_advances_to_half_guard - t3.cumulative_opp_advances_to_half_guard AS cumulative_opp_advances_to_half_guard_diff,
    t2.avg_opp_advances_to_half_guard_per_second - t3.avg_opp_advances_to_half_guard_per_second AS avg_opp_advances_to_half_guard_per_second_diff,
    t2.cumulative_opp_advances_to_half_guard_per_second - t3.cumulative_opp_advances_to_half_guard_per_second AS cumulative_opp_advances_to_half_guard_per_second_diff,
    t2.avg_opp_advances_to_half_guard_per_advances - t3.avg_opp_advances_to_half_guard_per_advances AS avg_opp_advances_to_half_guard_per_advances_diff,
    t2.cumulative_opp_advances_to_half_guard_per_advances - t3.cumulative_opp_advances_to_half_guard_per_advances AS cumulative_opp_advances_to_half_guard_per_advances_diff,
    t2.avg_opp_advances_to_mount - t3.avg_opp_advances_to_mount AS avg_opp_advances_to_mount_diff,
    t2.cumulative_opp_advances_to_mount - t3.cumulative_opp_advances_to_mount AS cumulative_opp_advances_to_mount_diff,
    t2.avg_opp_advances_to_mount_per_second - t3.avg_opp_advances_to_mount_per_second AS avg_opp_advances_to_mount_per_second_diff,
    t2.cumulative_opp_advances_to_mount_per_second - t3.cumulative_opp_advances_to_mount_per_second AS cumulative_opp_advances_to_mount_per_second_diff,
    t2.avg_opp_advances_to_mount_per_advances - t3.avg_opp_advances_to_mount_per_advances AS avg_opp_advances_to_mount_per_advances_diff,
    t2.cumulative_opp_advances_to_mount_per_advances - t3.cumulative_opp_advances_to_mount_per_advances AS cumulative_opp_advances_to_mount_per_advances_diff,
    t2.avg_opp_advances_to_side - t3.avg_opp_advances_to_side AS avg_opp_advances_to_side_diff,
    t2.cumulative_opp_advances_to_side - t3.cumulative_opp_advances_to_side AS cumulative_opp_advances_to_side_diff,
    t2.avg_opp_advances_to_side_per_second - t3.avg_opp_advances_to_side_per_second AS avg_opp_advances_to_side_per_second_diff,
    t2.cumulative_opp_advances_to_side_per_second - t3.cumulative_opp_advances_to_side_per_second AS cumulative_opp_advances_to_side_per_second_diff,
    t2.avg_opp_advances_to_side_per_advances - t3.avg_opp_advances_to_side_per_advances AS avg_opp_advances_to_side_per_advances_diff,
    t2.cumulative_opp_advances_to_side_per_advances - t3.cumulative_opp_advances_to_side_per_advances AS cumulative_opp_advances_to_side_per_advances_diff,
    t2.avg_opp_reversals_scored - t3.avg_opp_reversals_scored AS avg_opp_reversals_scored_diff,
    t2.cumulative_opp_reversals_scored - t3.cumulative_opp_reversals_scored AS cumulative_opp_reversals_scored_diff,
    t2.avg_opp_reversals_scored_per_second - t3.avg_opp_reversals_scored_per_second AS avg_opp_reversals_scored_per_second_diff,
    t2.cumulative_opp_reversals_scored_per_second - t3.cumulative_opp_reversals_scored_per_second AS cumulative_opp_reversals_scored_per_second_diff,
    t2.avg_opp_submissions_landed - t3.avg_opp_submissions_landed AS avg_opp_submissions_landed_diff,
    t2.cumulative_opp_submissions_landed - t3.cumulative_opp_submissions_landed AS cumulative_opp_submissions_landed_diff,
    t2.avg_opp_submissions_landed_per_second - t3.avg_opp_submissions_landed_per_second AS avg_opp_submissions_landed_per_second_diff,
    t2.cumulative_opp_submissions_landed_per_second - t3.cumulative_opp_submissions_landed_per_second AS cumulative_opp_submissions_landed_per_second_diff,
    t2.avg_opp_submissions_accuracy - t3.avg_opp_submissions_accuracy AS avg_opp_submissions_accuracy_diff,
    t2.cumulative_opp_submissions_accuracy - t3.cumulative_opp_submissions_accuracy AS cumulative_opp_submissions_accuracy_diff,
    t2.avg_opp_submissions_attempted - t3.avg_opp_submissions_attempted AS avg_opp_submissions_attempted_diff,
    t2.cumulative_opp_submissions_attempted - t3.cumulative_opp_submissions_attempted AS cumulative_opp_submissions_attempted_diff,
    t2.avg_opp_submissions_attempted_per_second - t3.avg_opp_submissions_attempted_per_second AS avg_opp_submissions_attempted_per_second_diff,
    t2.cumulative_opp_submissions_attempted_per_second - t3.cumulative_opp_submissions_attempted_per_second AS cumulative_opp_submissions_attempted_per_second_diff,
    t2.avg_opp_control_time_seconds - t3.avg_opp_control_time_seconds AS avg_opp_control_time_seconds_diff,
    t2.cumulative_opp_control_time_seconds - t3.cumulative_opp_control_time_seconds AS cumulative_opp_control_time_seconds_diff,
    t2.avg_opp_control_time_seconds_per_second - t3.avg_opp_control_time_seconds_per_second AS avg_opp_control_time_seconds_per_second_diff,
    t2.cumulative_opp_control_time_seconds_per_second - t3.cumulative_opp_control_time_seconds_per_second AS cumulative_opp_control_time_seconds_per_second_diff,
    t2.avg_opp_avg_knockdowns_scored - t3.avg_opp_avg_knockdowns_scored AS avg_opp_avg_knockdowns_scored_diff,
    t2.avg_avg_knockdowns_scored_diff - t3.avg_avg_knockdowns_scored_diff AS avg_avg_knockdowns_scored_diff_diff,
    t2.avg_opp_cumulative_knockdowns_scored - t3.avg_opp_cumulative_knockdowns_scored AS avg_opp_cumulative_knockdowns_scored_diff,
    t2.avg_cumulative_knockdowns_scored_diff - t3.avg_cumulative_knockdowns_scored_diff AS avg_cumulative_knockdowns_scored_diff_diff,
    t2.avg_opp_avg_knockdowns_scored_per_second - t3.avg_opp_avg_knockdowns_scored_per_second AS avg_opp_avg_knockdowns_scored_per_second_diff,
    t2.avg_avg_knockdowns_scored_per_second_diff - t3.avg_avg_knockdowns_scored_per_second_diff AS avg_avg_knockdowns_scored_per_second_diff_diff,
    t2.avg_opp_cumulative_knockdowns_scored_per_second - t3.avg_opp_cumulative_knockdowns_scored_per_second AS avg_opp_cumulative_knockdowns_scored_per_second_diff,
    t2.avg_cumulative_knockdowns_scored_per_second_diff - t3.avg_cumulative_knockdowns_scored_per_second_diff AS avg_cumulative_knockdowns_scored_per_second_diff_diff,
    t2.avg_opp_avg_knockdowns_scored_per_strike_landed - t3.avg_opp_avg_knockdowns_scored_per_strike_landed AS avg_opp_avg_knockdowns_scored_per_strike_landed_diff,
    t2.avg_avg_knockdowns_scored_per_strike_landed_diff - t3.avg_avg_knockdowns_scored_per_strike_landed_diff AS avg_avg_knockdowns_scored_per_strike_landed_diff_diff,
    t2.avg_opp_cumulative_knockdowns_scored_per_strike_landed - t3.avg_opp_cumulative_knockdowns_scored_per_strike_landed AS avg_opp_cumulative_knockdowns_scored_per_strike_landed_diff,
    t2.avg_cumulative_knockdowns_scored_per_strike_landed_diff - t3.avg_cumulative_knockdowns_scored_per_strike_landed_diff AS avg_cumulative_knockdowns_scored_per_strike_landed_diff_diff,
    t2.avg_opp_avg_knockdowns_scored_per_strike_attempted - t3.avg_opp_avg_knockdowns_scored_per_strike_attempted AS avg_opp_avg_knockdowns_scored_per_strike_attempted_diff,
    t2.avg_avg_knockdowns_scored_per_strike_attempted_diff - t3.avg_avg_knockdowns_scored_per_strike_attempted_diff AS avg_avg_knockdowns_scored_per_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_knockdowns_scored_per_strike_attempted - t3.avg_opp_cumulative_knockdowns_scored_per_strike_attempted AS avg_opp_cumulative_knockdowns_scored_per_strike_attempted_diff,
    t2.avg_cumulative_knockdowns_scored_per_strike_attempted_diff - t3.avg_cumulative_knockdowns_scored_per_strike_attempted_diff AS avg_cumulative_knockdowns_scored_per_strike_attempted_diff_diff,
    t2.avg_opp_avg_knockdowns_scored_per_significant_strike_landed - t3.avg_opp_avg_knockdowns_scored_per_significant_strike_landed AS avg_opp_avg_knockdowns_scored_per_significant_strike_landed_diff,
    t2.avg_avg_knockdowns_scored_per_significant_strike_landed_diff - t3.avg_avg_knockdowns_scored_per_significant_strike_landed_diff AS avg_avg_knockdowns_scored_per_significant_strike_landed_diff_diff,
    t2.avg_opp_cumulative_knockdowns_scored_per_significant_strike_landed - t3.avg_opp_cumulative_knockdowns_scored_per_significant_strike_landed AS avg_opp_cumulative_knockdowns_scored_per_significant_strike_landed_diff,
    t2.avg_cumulative_knockdowns_scored_per_significant_strike_landed_diff - t3.avg_cumulative_knockdowns_scored_per_significant_strike_landed_diff AS avg_cumulative_knockdowns_scored_per_significant_strike_landed_diff_diff,
    t2.avg_opp_avg_knockdowns_scored_per_significant_strike_attempted - t3.avg_opp_avg_knockdowns_scored_per_significant_strike_attempted AS avg_opp_avg_knockdowns_scored_per_significant_strike_attempted_diff,
    t2.avg_avg_knockdowns_scored_per_significant_strike_attempted_diff - t3.avg_avg_knockdowns_scored_per_significant_strike_attempted_diff AS avg_avg_knockdowns_scored_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_knockdowns_scored_per_significant_strike_attempted - t3.avg_opp_cumulative_knockdowns_scored_per_significant_strike_attempted AS avg_opp_cumulative_knockdowns_scored_per_significant_strike_attempted_diff,
    t2.avg_cumulative_knockdowns_scored_per_significant_strike_attempted_diff - t3.avg_cumulative_knockdowns_scored_per_significant_strike_attempted_diff AS avg_cumulative_knockdowns_scored_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_avg_knockdowns_scored_per_significant_strike_head_landed - t3.avg_opp_avg_knockdowns_scored_per_significant_strike_head_landed AS avg_opp_avg_knockdowns_scored_per_significant_strike_head_landed_diff,
    t2.avg_avg_knockdowns_scored_per_significant_strike_head_landed_diff - t3.avg_avg_knockdowns_scored_per_significant_strike_head_landed_diff AS avg_avg_knockdowns_scored_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_cumulative_knockdowns_scored_per_significant_strike_head_landed - t3.avg_opp_cumulative_knockdowns_scored_per_significant_strike_head_landed AS avg_opp_cumulative_knockdowns_scored_per_significant_strike_head_landed_diff,
    t2.avg_cumulative_knockdowns_scored_per_significant_strike_head_landed_diff - t3.avg_cumulative_knockdowns_scored_per_significant_strike_head_landed_diff AS avg_cumulative_knockdowns_scored_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_avg_knockdowns_scored_per_significant_strike_head_attempted - t3.avg_opp_avg_knockdowns_scored_per_significant_strike_head_attempted AS avg_opp_avg_knockdowns_scored_per_significant_strike_head_attempted_diff,
    t2.avg_avg_knockdowns_scored_per_significant_strike_head_attempted_diff - t3.avg_avg_knockdowns_scored_per_significant_strike_head_attempted_diff AS avg_avg_knockdowns_scored_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_cumulative_knockdowns_scored_per_significant_strike_head_attempted - t3.avg_opp_cumulative_knockdowns_scored_per_significant_strike_head_attempted AS avg_opp_cumulative_knockdowns_scored_per_significant_strike_head_attempted_diff,
    t2.avg_cumulative_knockdowns_scored_per_significant_strike_head_attempted_diff - t3.avg_cumulative_knockdowns_scored_per_significant_strike_head_attempted_diff AS avg_cumulative_knockdowns_scored_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_avg_ko_tko_landed - t3.avg_opp_avg_ko_tko_landed AS avg_opp_avg_ko_tko_landed_diff,
    t2.avg_avg_ko_tko_landed_diff - t3.avg_avg_ko_tko_landed_diff AS avg_avg_ko_tko_landed_diff_diff,
    t2.avg_opp_cumulative_ko_tko_landed - t3.avg_opp_cumulative_ko_tko_landed AS avg_opp_cumulative_ko_tko_landed_diff,
    t2.avg_cumulative_ko_tko_landed_diff - t3.avg_cumulative_ko_tko_landed_diff AS avg_cumulative_ko_tko_landed_diff_diff,
    t2.avg_opp_avg_ko_tko_landed_per_second - t3.avg_opp_avg_ko_tko_landed_per_second AS avg_opp_avg_ko_tko_landed_per_second_diff,
    t2.avg_avg_ko_tko_landed_per_second_diff - t3.avg_avg_ko_tko_landed_per_second_diff AS avg_avg_ko_tko_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_ko_tko_landed_per_second - t3.avg_opp_cumulative_ko_tko_landed_per_second AS avg_opp_cumulative_ko_tko_landed_per_second_diff,
    t2.avg_cumulative_ko_tko_landed_per_second_diff - t3.avg_cumulative_ko_tko_landed_per_second_diff AS avg_cumulative_ko_tko_landed_per_second_diff_diff,
    t2.avg_opp_avg_ko_tko_landed_per_strike_landed - t3.avg_opp_avg_ko_tko_landed_per_strike_landed AS avg_opp_avg_ko_tko_landed_per_strike_landed_diff,
    t2.avg_avg_ko_tko_landed_per_strike_landed_diff - t3.avg_avg_ko_tko_landed_per_strike_landed_diff AS avg_avg_ko_tko_landed_per_strike_landed_diff_diff,
    t2.avg_opp_cumulative_ko_tko_landed_per_strike_landed - t3.avg_opp_cumulative_ko_tko_landed_per_strike_landed AS avg_opp_cumulative_ko_tko_landed_per_strike_landed_diff,
    t2.avg_cumulative_ko_tko_landed_per_strike_landed_diff - t3.avg_cumulative_ko_tko_landed_per_strike_landed_diff AS avg_cumulative_ko_tko_landed_per_strike_landed_diff_diff,
    t2.avg_opp_avg_ko_tko_landed_per_strike_attempted - t3.avg_opp_avg_ko_tko_landed_per_strike_attempted AS avg_opp_avg_ko_tko_landed_per_strike_attempted_diff,
    t2.avg_avg_ko_tko_landed_per_strike_attempted_diff - t3.avg_avg_ko_tko_landed_per_strike_attempted_diff AS avg_avg_ko_tko_landed_per_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_ko_tko_landed_per_strike_attempted - t3.avg_opp_cumulative_ko_tko_landed_per_strike_attempted AS avg_opp_cumulative_ko_tko_landed_per_strike_attempted_diff,
    t2.avg_cumulative_ko_tko_landed_per_strike_attempted_diff - t3.avg_cumulative_ko_tko_landed_per_strike_attempted_diff AS avg_cumulative_ko_tko_landed_per_strike_attempted_diff_diff,
    t2.avg_opp_avg_ko_tko_landed_per_significant_strike_landed - t3.avg_opp_avg_ko_tko_landed_per_significant_strike_landed AS avg_opp_avg_ko_tko_landed_per_significant_strike_landed_diff,
    t2.avg_avg_ko_tko_landed_per_significant_strike_landed_diff - t3.avg_avg_ko_tko_landed_per_significant_strike_landed_diff AS avg_avg_ko_tko_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_cumulative_ko_tko_landed_per_significant_strike_landed - t3.avg_opp_cumulative_ko_tko_landed_per_significant_strike_landed AS avg_opp_cumulative_ko_tko_landed_per_significant_strike_landed_diff,
    t2.avg_cumulative_ko_tko_landed_per_significant_strike_landed_diff - t3.avg_cumulative_ko_tko_landed_per_significant_strike_landed_diff AS avg_cumulative_ko_tko_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_avg_ko_tko_landed_per_significant_strike_attempted - t3.avg_opp_avg_ko_tko_landed_per_significant_strike_attempted AS avg_opp_avg_ko_tko_landed_per_significant_strike_attempted_diff,
    t2.avg_avg_ko_tko_landed_per_significant_strike_attempted_diff - t3.avg_avg_ko_tko_landed_per_significant_strike_attempted_diff AS avg_avg_ko_tko_landed_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_ko_tko_landed_per_significant_strike_attempted - t3.avg_opp_cumulative_ko_tko_landed_per_significant_strike_attempted AS avg_opp_cumulative_ko_tko_landed_per_significant_strike_attempted_diff,
    t2.avg_cumulative_ko_tko_landed_per_significant_strike_attempted_diff - t3.avg_cumulative_ko_tko_landed_per_significant_strike_attempted_diff AS avg_cumulative_ko_tko_landed_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_avg_ko_tko_landed_per_significant_strike_head_landed - t3.avg_opp_avg_ko_tko_landed_per_significant_strike_head_landed AS avg_opp_avg_ko_tko_landed_per_significant_strike_head_landed_diff,
    t2.avg_avg_ko_tko_landed_per_significant_strike_head_landed_diff - t3.avg_avg_ko_tko_landed_per_significant_strike_head_landed_diff AS avg_avg_ko_tko_landed_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_cumulative_ko_tko_landed_per_significant_strike_head_landed - t3.avg_opp_cumulative_ko_tko_landed_per_significant_strike_head_landed AS avg_opp_cumulative_ko_tko_landed_per_significant_strike_head_landed_diff,
    t2.avg_cumulative_ko_tko_landed_per_significant_strike_head_landed_diff - t3.avg_cumulative_ko_tko_landed_per_significant_strike_head_landed_diff AS avg_cumulative_ko_tko_landed_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_avg_ko_tko_landed_per_significant_strike_head_attempted - t3.avg_opp_avg_ko_tko_landed_per_significant_strike_head_attempted AS avg_opp_avg_ko_tko_landed_per_significant_strike_head_attempted_diff,
    t2.avg_avg_ko_tko_landed_per_significant_strike_head_attempted_diff - t3.avg_avg_ko_tko_landed_per_significant_strike_head_attempted_diff AS avg_avg_ko_tko_landed_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_cumulative_ko_tko_landed_per_significant_strike_head_attempted - t3.avg_opp_cumulative_ko_tko_landed_per_significant_strike_head_attempted AS avg_opp_cumulative_ko_tko_landed_per_significant_strike_head_attempted_diff,
    t2.avg_cumulative_ko_tko_landed_per_significant_strike_head_attempted_diff - t3.avg_cumulative_ko_tko_landed_per_significant_strike_head_attempted_diff AS avg_cumulative_ko_tko_landed_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_avg_total_strikes_landed - t3.avg_opp_avg_total_strikes_landed AS avg_opp_avg_total_strikes_landed_diff,
    t2.avg_avg_total_strikes_landed_diff - t3.avg_avg_total_strikes_landed_diff AS avg_avg_total_strikes_landed_diff_diff,
    t2.avg_opp_cumulative_total_strikes_landed - t3.avg_opp_cumulative_total_strikes_landed AS avg_opp_cumulative_total_strikes_landed_diff,
    t2.avg_cumulative_total_strikes_landed_diff - t3.avg_cumulative_total_strikes_landed_diff AS avg_cumulative_total_strikes_landed_diff_diff,
    t2.avg_opp_avg_total_strikes_landed_per_second - t3.avg_opp_avg_total_strikes_landed_per_second AS avg_opp_avg_total_strikes_landed_per_second_diff,
    t2.avg_avg_total_strikes_landed_per_second_diff - t3.avg_avg_total_strikes_landed_per_second_diff AS avg_avg_total_strikes_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_total_strikes_landed_per_second - t3.avg_opp_cumulative_total_strikes_landed_per_second AS avg_opp_cumulative_total_strikes_landed_per_second_diff,
    t2.avg_cumulative_total_strikes_landed_per_second_diff - t3.avg_cumulative_total_strikes_landed_per_second_diff AS avg_cumulative_total_strikes_landed_per_second_diff_diff,
    t2.avg_opp_avg_total_strikes_accuracy - t3.avg_opp_avg_total_strikes_accuracy AS avg_opp_avg_total_strikes_accuracy_diff,
    t2.avg_avg_total_strikes_accuracy_diff - t3.avg_avg_total_strikes_accuracy_diff AS avg_avg_total_strikes_accuracy_diff_diff,
    t2.avg_opp_cumulative_total_strikes_accuracy - t3.avg_opp_cumulative_total_strikes_accuracy AS avg_opp_cumulative_total_strikes_accuracy_diff,
    t2.avg_cumulative_total_strikes_accuracy_diff - t3.avg_cumulative_total_strikes_accuracy_diff AS avg_cumulative_total_strikes_accuracy_diff_diff,
    t2.avg_opp_avg_total_strikes_attempted - t3.avg_opp_avg_total_strikes_attempted AS avg_opp_avg_total_strikes_attempted_diff,
    t2.avg_avg_total_strikes_attempted_diff - t3.avg_avg_total_strikes_attempted_diff AS avg_avg_total_strikes_attempted_diff_diff,
    t2.avg_opp_cumulative_total_strikes_attempted - t3.avg_opp_cumulative_total_strikes_attempted AS avg_opp_cumulative_total_strikes_attempted_diff,
    t2.avg_cumulative_total_strikes_attempted_diff - t3.avg_cumulative_total_strikes_attempted_diff AS avg_cumulative_total_strikes_attempted_diff_diff,
    t2.avg_opp_avg_total_strikes_attempted_per_second - t3.avg_opp_avg_total_strikes_attempted_per_second AS avg_opp_avg_total_strikes_attempted_per_second_diff,
    t2.avg_avg_total_strikes_attempted_per_second_diff - t3.avg_avg_total_strikes_attempted_per_second_diff AS avg_avg_total_strikes_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_total_strikes_attempted_per_second - t3.avg_opp_cumulative_total_strikes_attempted_per_second AS avg_opp_cumulative_total_strikes_attempted_per_second_diff,
    t2.avg_cumulative_total_strikes_attempted_per_second_diff - t3.avg_cumulative_total_strikes_attempted_per_second_diff AS avg_cumulative_total_strikes_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_landed - t3.avg_opp_avg_significant_strikes_landed AS avg_opp_avg_significant_strikes_landed_diff,
    t2.avg_avg_significant_strikes_landed_diff - t3.avg_avg_significant_strikes_landed_diff AS avg_avg_significant_strikes_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_landed - t3.avg_opp_cumulative_significant_strikes_landed AS avg_opp_cumulative_significant_strikes_landed_diff,
    t2.avg_cumulative_significant_strikes_landed_diff - t3.avg_cumulative_significant_strikes_landed_diff AS avg_cumulative_significant_strikes_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_landed_per_second - t3.avg_opp_avg_significant_strikes_landed_per_second AS avg_opp_avg_significant_strikes_landed_per_second_diff,
    t2.avg_avg_significant_strikes_landed_per_second_diff - t3.avg_avg_significant_strikes_landed_per_second_diff AS avg_avg_significant_strikes_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_landed_per_second - t3.avg_opp_cumulative_significant_strikes_landed_per_second AS avg_opp_cumulative_significant_strikes_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_landed_per_second_diff - t3.avg_cumulative_significant_strikes_landed_per_second_diff AS avg_cumulative_significant_strikes_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_accuracy - t3.avg_opp_avg_significant_strikes_accuracy AS avg_opp_avg_significant_strikes_accuracy_diff,
    t2.avg_avg_significant_strikes_accuracy_diff - t3.avg_avg_significant_strikes_accuracy_diff AS avg_avg_significant_strikes_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_accuracy - t3.avg_opp_cumulative_significant_strikes_accuracy AS avg_opp_cumulative_significant_strikes_accuracy_diff,
    t2.avg_cumulative_significant_strikes_accuracy_diff - t3.avg_cumulative_significant_strikes_accuracy_diff AS avg_cumulative_significant_strikes_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_landed_per_strike_landed - t3.avg_opp_avg_significant_strikes_landed_per_strike_landed AS avg_opp_avg_significant_strikes_landed_per_strike_landed_diff,
    t2.avg_avg_significant_strikes_landed_per_strike_landed_diff - t3.avg_avg_significant_strikes_landed_per_strike_landed_diff AS avg_avg_significant_strikes_landed_per_strike_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_landed_per_strike_landed - t3.avg_opp_cumulative_significant_strikes_landed_per_strike_landed AS avg_opp_cumulative_significant_strikes_landed_per_strike_landed_diff,
    t2.avg_cumulative_significant_strikes_landed_per_strike_landed_diff - t3.avg_cumulative_significant_strikes_landed_per_strike_landed_diff AS avg_cumulative_significant_strikes_landed_per_strike_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_attempted - t3.avg_opp_avg_significant_strikes_attempted AS avg_opp_avg_significant_strikes_attempted_diff,
    t2.avg_avg_significant_strikes_attempted_diff - t3.avg_avg_significant_strikes_attempted_diff AS avg_avg_significant_strikes_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_attempted - t3.avg_opp_cumulative_significant_strikes_attempted AS avg_opp_cumulative_significant_strikes_attempted_diff,
    t2.avg_cumulative_significant_strikes_attempted_diff - t3.avg_cumulative_significant_strikes_attempted_diff AS avg_cumulative_significant_strikes_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_attempted_per_second - t3.avg_opp_avg_significant_strikes_attempted_per_second AS avg_opp_avg_significant_strikes_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_attempted_per_second_diff - t3.avg_avg_significant_strikes_attempted_per_second_diff AS avg_avg_significant_strikes_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_attempted_per_second AS avg_opp_cumulative_significant_strikes_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_attempted_per_second_diff AS avg_cumulative_significant_strikes_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_attempted_per_strike_attempted - t3.avg_opp_avg_significant_strikes_attempted_per_strike_attempted AS avg_opp_avg_significant_strikes_attempted_per_strike_attempted_diff,
    t2.avg_avg_significant_strikes_attempted_per_strike_attempted_diff - t3.avg_avg_significant_strikes_attempted_per_strike_attempted_diff AS avg_avg_significant_strikes_attempted_per_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_attempted_per_strike_attempted - t3.avg_opp_cumulative_significant_strikes_attempted_per_strike_attempted AS avg_opp_cumulative_significant_strikes_attempted_per_strike_attempted_diff,
    t2.avg_cumulative_significant_strikes_attempted_per_strike_attempted_diff - t3.avg_cumulative_significant_strikes_attempted_per_strike_attempted_diff AS avg_cumulative_significant_strikes_attempted_per_strike_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_head_landed - t3.avg_opp_avg_significant_strikes_head_landed AS avg_opp_avg_significant_strikes_head_landed_diff,
    t2.avg_avg_significant_strikes_head_landed_diff - t3.avg_avg_significant_strikes_head_landed_diff AS avg_avg_significant_strikes_head_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_head_landed - t3.avg_opp_cumulative_significant_strikes_head_landed AS avg_opp_cumulative_significant_strikes_head_landed_diff,
    t2.avg_cumulative_significant_strikes_head_landed_diff - t3.avg_cumulative_significant_strikes_head_landed_diff AS avg_cumulative_significant_strikes_head_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_head_landed_per_second - t3.avg_opp_avg_significant_strikes_head_landed_per_second AS avg_opp_avg_significant_strikes_head_landed_per_second_diff,
    t2.avg_avg_significant_strikes_head_landed_per_second_diff - t3.avg_avg_significant_strikes_head_landed_per_second_diff AS avg_avg_significant_strikes_head_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_head_landed_per_second - t3.avg_opp_cumulative_significant_strikes_head_landed_per_second AS avg_opp_cumulative_significant_strikes_head_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_head_landed_per_second_diff - t3.avg_cumulative_significant_strikes_head_landed_per_second_diff AS avg_cumulative_significant_strikes_head_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_head_accuracy - t3.avg_opp_avg_significant_strikes_head_accuracy AS avg_opp_avg_significant_strikes_head_accuracy_diff,
    t2.avg_avg_significant_strikes_head_accuracy_diff - t3.avg_avg_significant_strikes_head_accuracy_diff AS avg_avg_significant_strikes_head_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_head_accuracy - t3.avg_opp_cumulative_significant_strikes_head_accuracy AS avg_opp_cumulative_significant_strikes_head_accuracy_diff,
    t2.avg_cumulative_significant_strikes_head_accuracy_diff - t3.avg_cumulative_significant_strikes_head_accuracy_diff AS avg_cumulative_significant_strikes_head_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_head_landed_per_significant_strike_landed - t3.avg_opp_avg_significant_strikes_head_landed_per_significant_strike_landed AS avg_opp_avg_significant_strikes_head_landed_per_significant_strike_landed_diff,
    t2.avg_avg_significant_strikes_head_landed_per_significant_strike_landed_diff - t3.avg_avg_significant_strikes_head_landed_per_significant_strike_landed_diff AS avg_avg_significant_strikes_head_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_head_landed_per_significant_strike_landed - t3.avg_opp_cumulative_significant_strikes_head_landed_per_significant_strike_landed AS avg_opp_cumulative_significant_strikes_head_landed_per_significant_strike_landed_diff,
    t2.avg_cumulative_significant_strikes_head_landed_per_significant_strike_landed_diff - t3.avg_cumulative_significant_strikes_head_landed_per_significant_strike_landed_diff AS avg_cumulative_significant_strikes_head_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_head_attempted - t3.avg_opp_avg_significant_strikes_head_attempted AS avg_opp_avg_significant_strikes_head_attempted_diff,
    t2.avg_avg_significant_strikes_head_attempted_diff - t3.avg_avg_significant_strikes_head_attempted_diff AS avg_avg_significant_strikes_head_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_head_attempted - t3.avg_opp_cumulative_significant_strikes_head_attempted AS avg_opp_cumulative_significant_strikes_head_attempted_diff,
    t2.avg_cumulative_significant_strikes_head_attempted_diff - t3.avg_cumulative_significant_strikes_head_attempted_diff AS avg_cumulative_significant_strikes_head_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_head_attempted_per_second - t3.avg_opp_avg_significant_strikes_head_attempted_per_second AS avg_opp_avg_significant_strikes_head_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_head_attempted_per_second_diff - t3.avg_avg_significant_strikes_head_attempted_per_second_diff AS avg_avg_significant_strikes_head_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_head_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_head_attempted_per_second AS avg_opp_cumulative_significant_strikes_head_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_head_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_head_attempted_per_second_diff AS avg_cumulative_significant_strikes_head_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_head_attempted_per_significant_strike_attempted - t3.avg_opp_avg_significant_strikes_head_attempted_per_significant_strike_attempted AS avg_opp_avg_significant_strikes_head_attempted_per_significant_strike_attempted_diff,
    t2.avg_avg_significant_strikes_head_attempted_per_significant_strike_attempted_diff - t3.avg_avg_significant_strikes_head_attempted_per_significant_strike_attempted_diff AS avg_avg_significant_strikes_head_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_head_attempted_per_significant_strike_attempted - t3.avg_opp_cumulative_significant_strikes_head_attempted_per_significant_strike_attempted AS avg_opp_cumulative_significant_strikes_head_attempted_per_significant_strike_attempted_diff,
    t2.avg_cumulative_significant_strikes_head_attempted_per_significant_strike_attempted_diff - t3.avg_cumulative_significant_strikes_head_attempted_per_significant_strike_attempted_diff AS avg_cumulative_significant_strikes_head_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_body_landed - t3.avg_opp_avg_significant_strikes_body_landed AS avg_opp_avg_significant_strikes_body_landed_diff,
    t2.avg_avg_significant_strikes_body_landed_diff - t3.avg_avg_significant_strikes_body_landed_diff AS avg_avg_significant_strikes_body_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_body_landed - t3.avg_opp_cumulative_significant_strikes_body_landed AS avg_opp_cumulative_significant_strikes_body_landed_diff,
    t2.avg_cumulative_significant_strikes_body_landed_diff - t3.avg_cumulative_significant_strikes_body_landed_diff AS avg_cumulative_significant_strikes_body_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_body_landed_per_second - t3.avg_opp_avg_significant_strikes_body_landed_per_second AS avg_opp_avg_significant_strikes_body_landed_per_second_diff,
    t2.avg_avg_significant_strikes_body_landed_per_second_diff - t3.avg_avg_significant_strikes_body_landed_per_second_diff AS avg_avg_significant_strikes_body_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_body_landed_per_second - t3.avg_opp_cumulative_significant_strikes_body_landed_per_second AS avg_opp_cumulative_significant_strikes_body_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_body_landed_per_second_diff - t3.avg_cumulative_significant_strikes_body_landed_per_second_diff AS avg_cumulative_significant_strikes_body_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_body_accuracy - t3.avg_opp_avg_significant_strikes_body_accuracy AS avg_opp_avg_significant_strikes_body_accuracy_diff,
    t2.avg_avg_significant_strikes_body_accuracy_diff - t3.avg_avg_significant_strikes_body_accuracy_diff AS avg_avg_significant_strikes_body_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_body_accuracy - t3.avg_opp_cumulative_significant_strikes_body_accuracy AS avg_opp_cumulative_significant_strikes_body_accuracy_diff,
    t2.avg_cumulative_significant_strikes_body_accuracy_diff - t3.avg_cumulative_significant_strikes_body_accuracy_diff AS avg_cumulative_significant_strikes_body_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_body_landed_per_significant_strike_landed - t3.avg_opp_avg_significant_strikes_body_landed_per_significant_strike_landed AS avg_opp_avg_significant_strikes_body_landed_per_significant_strike_landed_diff,
    t2.avg_avg_significant_strikes_body_landed_per_significant_strike_landed_diff - t3.avg_avg_significant_strikes_body_landed_per_significant_strike_landed_diff AS avg_avg_significant_strikes_body_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_body_landed_per_significant_strike_landed - t3.avg_opp_cumulative_significant_strikes_body_landed_per_significant_strike_landed AS avg_opp_cumulative_significant_strikes_body_landed_per_significant_strike_landed_diff,
    t2.avg_cumulative_significant_strikes_body_landed_per_significant_strike_landed_diff - t3.avg_cumulative_significant_strikes_body_landed_per_significant_strike_landed_diff AS avg_cumulative_significant_strikes_body_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_body_attempted - t3.avg_opp_avg_significant_strikes_body_attempted AS avg_opp_avg_significant_strikes_body_attempted_diff,
    t2.avg_avg_significant_strikes_body_attempted_diff - t3.avg_avg_significant_strikes_body_attempted_diff AS avg_avg_significant_strikes_body_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_body_attempted - t3.avg_opp_cumulative_significant_strikes_body_attempted AS avg_opp_cumulative_significant_strikes_body_attempted_diff,
    t2.avg_cumulative_significant_strikes_body_attempted_diff - t3.avg_cumulative_significant_strikes_body_attempted_diff AS avg_cumulative_significant_strikes_body_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_body_attempted_per_second - t3.avg_opp_avg_significant_strikes_body_attempted_per_second AS avg_opp_avg_significant_strikes_body_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_body_attempted_per_second_diff - t3.avg_avg_significant_strikes_body_attempted_per_second_diff AS avg_avg_significant_strikes_body_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_body_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_body_attempted_per_second AS avg_opp_cumulative_significant_strikes_body_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_body_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_body_attempted_per_second_diff AS avg_cumulative_significant_strikes_body_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_body_attempted_per_significant_strike_attempted - t3.avg_opp_avg_significant_strikes_body_attempted_per_significant_strike_attempted AS avg_opp_avg_significant_strikes_body_attempted_per_significant_strike_attempted_diff,
    t2.avg_avg_significant_strikes_body_attempted_per_significant_strike_attempted_diff - t3.avg_avg_significant_strikes_body_attempted_per_significant_strike_attempted_diff AS avg_avg_significant_strikes_body_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_body_attempted_per_significant_strike_attempted - t3.avg_opp_cumulative_significant_strikes_body_attempted_per_significant_strike_attempted AS avg_opp_cumulative_significant_strikes_body_attempted_per_significant_strike_attempted_diff,
    t2.avg_cumulative_significant_strikes_body_attempted_per_significant_strike_attempted_diff - t3.avg_cumulative_significant_strikes_body_attempted_per_significant_strike_attempted_diff AS avg_cumulative_significant_strikes_body_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_leg_landed - t3.avg_opp_avg_significant_strikes_leg_landed AS avg_opp_avg_significant_strikes_leg_landed_diff,
    t2.avg_avg_significant_strikes_leg_landed_diff - t3.avg_avg_significant_strikes_leg_landed_diff AS avg_avg_significant_strikes_leg_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_leg_landed - t3.avg_opp_cumulative_significant_strikes_leg_landed AS avg_opp_cumulative_significant_strikes_leg_landed_diff,
    t2.avg_cumulative_significant_strikes_leg_landed_diff - t3.avg_cumulative_significant_strikes_leg_landed_diff AS avg_cumulative_significant_strikes_leg_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_leg_landed_per_second - t3.avg_opp_avg_significant_strikes_leg_landed_per_second AS avg_opp_avg_significant_strikes_leg_landed_per_second_diff,
    t2.avg_avg_significant_strikes_leg_landed_per_second_diff - t3.avg_avg_significant_strikes_leg_landed_per_second_diff AS avg_avg_significant_strikes_leg_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_leg_landed_per_second - t3.avg_opp_cumulative_significant_strikes_leg_landed_per_second AS avg_opp_cumulative_significant_strikes_leg_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_leg_landed_per_second_diff - t3.avg_cumulative_significant_strikes_leg_landed_per_second_diff AS avg_cumulative_significant_strikes_leg_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_leg_accuracy - t3.avg_opp_avg_significant_strikes_leg_accuracy AS avg_opp_avg_significant_strikes_leg_accuracy_diff,
    t2.avg_avg_significant_strikes_leg_accuracy_diff - t3.avg_avg_significant_strikes_leg_accuracy_diff AS avg_avg_significant_strikes_leg_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_leg_accuracy - t3.avg_opp_cumulative_significant_strikes_leg_accuracy AS avg_opp_cumulative_significant_strikes_leg_accuracy_diff,
    t2.avg_cumulative_significant_strikes_leg_accuracy_diff - t3.avg_cumulative_significant_strikes_leg_accuracy_diff AS avg_cumulative_significant_strikes_leg_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_leg_landed_per_significant_strike_landed - t3.avg_opp_avg_significant_strikes_leg_landed_per_significant_strike_landed AS avg_opp_avg_significant_strikes_leg_landed_per_significant_strike_landed_diff,
    t2.avg_avg_significant_strikes_leg_landed_per_significant_strike_landed_diff - t3.avg_avg_significant_strikes_leg_landed_per_significant_strike_landed_diff AS avg_avg_significant_strikes_leg_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_leg_landed_per_significant_strike_landed - t3.avg_opp_cumulative_significant_strikes_leg_landed_per_significant_strike_landed AS avg_opp_cumulative_significant_strikes_leg_landed_per_significant_strike_landed_diff,
    t2.avg_cumulative_significant_strikes_leg_landed_per_significant_strike_landed_diff - t3.avg_cumulative_significant_strikes_leg_landed_per_significant_strike_landed_diff AS avg_cumulative_significant_strikes_leg_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_leg_attempted - t3.avg_opp_avg_significant_strikes_leg_attempted AS avg_opp_avg_significant_strikes_leg_attempted_diff,
    t2.avg_avg_significant_strikes_leg_attempted_diff - t3.avg_avg_significant_strikes_leg_attempted_diff AS avg_avg_significant_strikes_leg_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_leg_attempted - t3.avg_opp_cumulative_significant_strikes_leg_attempted AS avg_opp_cumulative_significant_strikes_leg_attempted_diff,
    t2.avg_cumulative_significant_strikes_leg_attempted_diff - t3.avg_cumulative_significant_strikes_leg_attempted_diff AS avg_cumulative_significant_strikes_leg_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_leg_attempted_per_second - t3.avg_opp_avg_significant_strikes_leg_attempted_per_second AS avg_opp_avg_significant_strikes_leg_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_leg_attempted_per_second_diff - t3.avg_avg_significant_strikes_leg_attempted_per_second_diff AS avg_avg_significant_strikes_leg_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_leg_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_leg_attempted_per_second AS avg_opp_cumulative_significant_strikes_leg_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_leg_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_leg_attempted_per_second_diff AS avg_cumulative_significant_strikes_leg_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_leg_attempted_per_significant_strike_attempted - t3.avg_opp_avg_significant_strikes_leg_attempted_per_significant_strike_attempted AS avg_opp_avg_significant_strikes_leg_attempted_per_significant_strike_attempted_diff,
    t2.avg_avg_significant_strikes_leg_attempted_per_significant_strike_attempted_diff - t3.avg_avg_significant_strikes_leg_attempted_per_significant_strike_attempted_diff AS avg_avg_significant_strikes_leg_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted - t3.avg_opp_cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted AS avg_opp_cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted_diff,
    t2.avg_cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted_diff - t3.avg_cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted_diff AS avg_cumulative_significant_strikes_leg_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_landed - t3.avg_opp_avg_significant_strikes_distance_landed AS avg_opp_avg_significant_strikes_distance_landed_diff,
    t2.avg_avg_significant_strikes_distance_landed_diff - t3.avg_avg_significant_strikes_distance_landed_diff AS avg_avg_significant_strikes_distance_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_landed - t3.avg_opp_cumulative_significant_strikes_distance_landed AS avg_opp_cumulative_significant_strikes_distance_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_landed_diff - t3.avg_cumulative_significant_strikes_distance_landed_diff AS avg_cumulative_significant_strikes_distance_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_landed_per_second - t3.avg_opp_avg_significant_strikes_distance_landed_per_second AS avg_opp_avg_significant_strikes_distance_landed_per_second_diff,
    t2.avg_avg_significant_strikes_distance_landed_per_second_diff - t3.avg_avg_significant_strikes_distance_landed_per_second_diff AS avg_avg_significant_strikes_distance_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_landed_per_second - t3.avg_opp_cumulative_significant_strikes_distance_landed_per_second AS avg_opp_cumulative_significant_strikes_distance_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_distance_landed_per_second_diff - t3.avg_cumulative_significant_strikes_distance_landed_per_second_diff AS avg_cumulative_significant_strikes_distance_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_accuracy - t3.avg_opp_avg_significant_strikes_distance_accuracy AS avg_opp_avg_significant_strikes_distance_accuracy_diff,
    t2.avg_avg_significant_strikes_distance_accuracy_diff - t3.avg_avg_significant_strikes_distance_accuracy_diff AS avg_avg_significant_strikes_distance_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_accuracy - t3.avg_opp_cumulative_significant_strikes_distance_accuracy AS avg_opp_cumulative_significant_strikes_distance_accuracy_diff,
    t2.avg_cumulative_significant_strikes_distance_accuracy_diff - t3.avg_cumulative_significant_strikes_distance_accuracy_diff AS avg_cumulative_significant_strikes_distance_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_landed_per_significant_strike_landed - t3.avg_opp_avg_significant_strikes_distance_landed_per_significant_strike_landed AS avg_opp_avg_significant_strikes_distance_landed_per_significant_strike_landed_diff,
    t2.avg_avg_significant_strikes_distance_landed_per_significant_strike_landed_diff - t3.avg_avg_significant_strikes_distance_landed_per_significant_strike_landed_diff AS avg_avg_significant_strikes_distance_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_landed_per_significant_strike_landed - t3.avg_opp_cumulative_significant_strikes_distance_landed_per_significant_strike_landed AS avg_opp_cumulative_significant_strikes_distance_landed_per_significant_strike_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_landed_per_significant_strike_landed_diff - t3.avg_cumulative_significant_strikes_distance_landed_per_significant_strike_landed_diff AS avg_cumulative_significant_strikes_distance_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_attempted - t3.avg_opp_avg_significant_strikes_distance_attempted AS avg_opp_avg_significant_strikes_distance_attempted_diff,
    t2.avg_avg_significant_strikes_distance_attempted_diff - t3.avg_avg_significant_strikes_distance_attempted_diff AS avg_avg_significant_strikes_distance_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_attempted - t3.avg_opp_cumulative_significant_strikes_distance_attempted AS avg_opp_cumulative_significant_strikes_distance_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_attempted_diff - t3.avg_cumulative_significant_strikes_distance_attempted_diff AS avg_cumulative_significant_strikes_distance_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_attempted_per_second - t3.avg_opp_avg_significant_strikes_distance_attempted_per_second AS avg_opp_avg_significant_strikes_distance_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_distance_attempted_per_second_diff - t3.avg_avg_significant_strikes_distance_attempted_per_second_diff AS avg_avg_significant_strikes_distance_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_distance_attempted_per_second AS avg_opp_cumulative_significant_strikes_distance_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_distance_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_distance_attempted_per_second_diff AS avg_cumulative_significant_strikes_distance_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_attempted_per_significant_strike_attempted - t3.avg_opp_avg_significant_strikes_distance_attempted_per_significant_strike_attempted AS avg_opp_avg_significant_strikes_distance_attempted_per_significant_strike_attempted_diff,
    t2.avg_avg_significant_strikes_distance_attempted_per_significant_strike_attempted_diff - t3.avg_avg_significant_strikes_distance_attempted_per_significant_strike_attempted_diff AS avg_avg_significant_strikes_distance_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted - t3.avg_opp_cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted AS avg_opp_cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted_diff - t3.avg_cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted_diff AS avg_cumulative_significant_strikes_distance_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_landed - t3.avg_opp_avg_significant_strikes_clinch_landed AS avg_opp_avg_significant_strikes_clinch_landed_diff,
    t2.avg_avg_significant_strikes_clinch_landed_diff - t3.avg_avg_significant_strikes_clinch_landed_diff AS avg_avg_significant_strikes_clinch_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_landed - t3.avg_opp_cumulative_significant_strikes_clinch_landed AS avg_opp_cumulative_significant_strikes_clinch_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_landed_diff - t3.avg_cumulative_significant_strikes_clinch_landed_diff AS avg_cumulative_significant_strikes_clinch_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_landed_per_second - t3.avg_opp_avg_significant_strikes_clinch_landed_per_second AS avg_opp_avg_significant_strikes_clinch_landed_per_second_diff,
    t2.avg_avg_significant_strikes_clinch_landed_per_second_diff - t3.avg_avg_significant_strikes_clinch_landed_per_second_diff AS avg_avg_significant_strikes_clinch_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_landed_per_second - t3.avg_opp_cumulative_significant_strikes_clinch_landed_per_second AS avg_opp_cumulative_significant_strikes_clinch_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_clinch_landed_per_second_diff - t3.avg_cumulative_significant_strikes_clinch_landed_per_second_diff AS avg_cumulative_significant_strikes_clinch_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_accuracy - t3.avg_opp_avg_significant_strikes_clinch_accuracy AS avg_opp_avg_significant_strikes_clinch_accuracy_diff,
    t2.avg_avg_significant_strikes_clinch_accuracy_diff - t3.avg_avg_significant_strikes_clinch_accuracy_diff AS avg_avg_significant_strikes_clinch_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_accuracy - t3.avg_opp_cumulative_significant_strikes_clinch_accuracy AS avg_opp_cumulative_significant_strikes_clinch_accuracy_diff,
    t2.avg_cumulative_significant_strikes_clinch_accuracy_diff - t3.avg_cumulative_significant_strikes_clinch_accuracy_diff AS avg_cumulative_significant_strikes_clinch_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_landed_per_significant_strike_landed - t3.avg_opp_avg_significant_strikes_clinch_landed_per_significant_strike_landed AS avg_opp_avg_significant_strikes_clinch_landed_per_significant_strike_landed_diff,
    t2.avg_avg_significant_strikes_clinch_landed_per_significant_strike_landed_diff - t3.avg_avg_significant_strikes_clinch_landed_per_significant_strike_landed_diff AS avg_avg_significant_strikes_clinch_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_landed_per_significant_strike_landed - t3.avg_opp_cumulative_significant_strikes_clinch_landed_per_significant_strike_landed AS avg_opp_cumulative_significant_strikes_clinch_landed_per_significant_strike_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_landed_per_significant_strike_landed_diff - t3.avg_cumulative_significant_strikes_clinch_landed_per_significant_strike_landed_diff AS avg_cumulative_significant_strikes_clinch_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_attempted - t3.avg_opp_avg_significant_strikes_clinch_attempted AS avg_opp_avg_significant_strikes_clinch_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_attempted_diff - t3.avg_avg_significant_strikes_clinch_attempted_diff AS avg_avg_significant_strikes_clinch_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_attempted AS avg_opp_cumulative_significant_strikes_clinch_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_attempted_diff AS avg_cumulative_significant_strikes_clinch_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_attempted_per_second - t3.avg_opp_avg_significant_strikes_clinch_attempted_per_second AS avg_opp_avg_significant_strikes_clinch_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_clinch_attempted_per_second_diff - t3.avg_avg_significant_strikes_clinch_attempted_per_second_diff AS avg_avg_significant_strikes_clinch_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_clinch_attempted_per_second AS avg_opp_cumulative_significant_strikes_clinch_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_clinch_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_clinch_attempted_per_second_diff AS avg_cumulative_significant_strikes_clinch_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_attempted_per_significant_strike_attempted - t3.avg_opp_avg_significant_strikes_clinch_attempted_per_significant_strike_attempted AS avg_opp_avg_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff - t3.avg_avg_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff AS avg_avg_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted AS avg_opp_cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff AS avg_cumulative_significant_strikes_clinch_attempted_per_significant_strike_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_landed - t3.avg_opp_avg_significant_strikes_ground_landed AS avg_opp_avg_significant_strikes_ground_landed_diff,
    t2.avg_avg_significant_strikes_ground_landed_diff - t3.avg_avg_significant_strikes_ground_landed_diff AS avg_avg_significant_strikes_ground_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_landed - t3.avg_opp_cumulative_significant_strikes_ground_landed AS avg_opp_cumulative_significant_strikes_ground_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_landed_diff - t3.avg_cumulative_significant_strikes_ground_landed_diff AS avg_cumulative_significant_strikes_ground_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_landed_per_second - t3.avg_opp_avg_significant_strikes_ground_landed_per_second AS avg_opp_avg_significant_strikes_ground_landed_per_second_diff,
    t2.avg_avg_significant_strikes_ground_landed_per_second_diff - t3.avg_avg_significant_strikes_ground_landed_per_second_diff AS avg_avg_significant_strikes_ground_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_landed_per_second - t3.avg_opp_cumulative_significant_strikes_ground_landed_per_second AS avg_opp_cumulative_significant_strikes_ground_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_ground_landed_per_second_diff - t3.avg_cumulative_significant_strikes_ground_landed_per_second_diff AS avg_cumulative_significant_strikes_ground_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_accuracy - t3.avg_opp_avg_significant_strikes_ground_accuracy AS avg_opp_avg_significant_strikes_ground_accuracy_diff,
    t2.avg_avg_significant_strikes_ground_accuracy_diff - t3.avg_avg_significant_strikes_ground_accuracy_diff AS avg_avg_significant_strikes_ground_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_accuracy - t3.avg_opp_cumulative_significant_strikes_ground_accuracy AS avg_opp_cumulative_significant_strikes_ground_accuracy_diff,
    t2.avg_cumulative_significant_strikes_ground_accuracy_diff - t3.avg_cumulative_significant_strikes_ground_accuracy_diff AS avg_cumulative_significant_strikes_ground_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_landed_per_significant_strike_landed - t3.avg_opp_avg_significant_strikes_ground_landed_per_significant_strike_landed AS avg_opp_avg_significant_strikes_ground_landed_per_significant_strike_landed_diff,
    t2.avg_avg_significant_strikes_ground_landed_per_significant_strike_landed_diff - t3.avg_avg_significant_strikes_ground_landed_per_significant_strike_landed_diff AS avg_avg_significant_strikes_ground_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_landed_per_significant_strike_landed - t3.avg_opp_cumulative_significant_strikes_ground_landed_per_significant_strike_landed AS avg_opp_cumulative_significant_strikes_ground_landed_per_significant_strike_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_landed_per_significant_strike_landed_diff - t3.avg_cumulative_significant_strikes_ground_landed_per_significant_strike_landed_diff AS avg_cumulative_significant_strikes_ground_landed_per_significant_strike_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_attempted - t3.avg_opp_avg_significant_strikes_ground_attempted AS avg_opp_avg_significant_strikes_ground_attempted_diff,
    t2.avg_avg_significant_strikes_ground_attempted_diff - t3.avg_avg_significant_strikes_ground_attempted_diff AS avg_avg_significant_strikes_ground_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_attempted - t3.avg_opp_cumulative_significant_strikes_ground_attempted AS avg_opp_cumulative_significant_strikes_ground_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_attempted_diff - t3.avg_cumulative_significant_strikes_ground_attempted_diff AS avg_cumulative_significant_strikes_ground_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_attempted_per_second - t3.avg_opp_avg_significant_strikes_ground_attempted_per_second AS avg_opp_avg_significant_strikes_ground_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_ground_attempted_per_second_diff - t3.avg_avg_significant_strikes_ground_attempted_per_second_diff AS avg_avg_significant_strikes_ground_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_ground_attempted_per_second AS avg_opp_cumulative_significant_strikes_ground_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_ground_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_ground_attempted_per_second_diff AS avg_cumulative_significant_strikes_ground_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_attempted_per_strike_attempted - t3.avg_opp_avg_significant_strikes_ground_attempted_per_strike_attempted AS avg_opp_avg_significant_strikes_ground_attempted_per_strike_attempted_diff,
    t2.avg_avg_significant_strikes_ground_attempted_per_strike_attempted_diff - t3.avg_avg_significant_strikes_ground_attempted_per_strike_attempted_diff AS avg_avg_significant_strikes_ground_attempted_per_strike_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_attempted_per_strike_attempted - t3.avg_opp_cumulative_significant_strikes_ground_attempted_per_strike_attempted AS avg_opp_cumulative_significant_strikes_ground_attempted_per_strike_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_attempted_per_strike_attempted_diff - t3.avg_cumulative_significant_strikes_ground_attempted_per_strike_attempted_diff AS avg_cumulative_significant_strikes_ground_attempted_per_strike_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_head_landed - t3.avg_opp_avg_significant_strikes_distance_head_landed AS avg_opp_avg_significant_strikes_distance_head_landed_diff,
    t2.avg_avg_significant_strikes_distance_head_landed_diff - t3.avg_avg_significant_strikes_distance_head_landed_diff AS avg_avg_significant_strikes_distance_head_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_head_landed - t3.avg_opp_cumulative_significant_strikes_distance_head_landed AS avg_opp_cumulative_significant_strikes_distance_head_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_head_landed_diff - t3.avg_cumulative_significant_strikes_distance_head_landed_diff AS avg_cumulative_significant_strikes_distance_head_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_head_landed_per_second - t3.avg_opp_avg_significant_strikes_distance_head_landed_per_second AS avg_opp_avg_significant_strikes_distance_head_landed_per_second_diff,
    t2.avg_avg_significant_strikes_distance_head_landed_per_second_diff - t3.avg_avg_significant_strikes_distance_head_landed_per_second_diff AS avg_avg_significant_strikes_distance_head_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_head_landed_per_second - t3.avg_opp_cumulative_significant_strikes_distance_head_landed_per_second AS avg_opp_cumulative_significant_strikes_distance_head_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_distance_head_landed_per_second_diff - t3.avg_cumulative_significant_strikes_distance_head_landed_per_second_diff AS avg_cumulative_significant_strikes_distance_head_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_head_accuracy - t3.avg_opp_avg_significant_strikes_distance_head_accuracy AS avg_opp_avg_significant_strikes_distance_head_accuracy_diff,
    t2.avg_avg_significant_strikes_distance_head_accuracy_diff - t3.avg_avg_significant_strikes_distance_head_accuracy_diff AS avg_avg_significant_strikes_distance_head_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_head_accuracy - t3.avg_opp_cumulative_significant_strikes_distance_head_accuracy AS avg_opp_cumulative_significant_strikes_distance_head_accuracy_diff,
    t2.avg_cumulative_significant_strikes_distance_head_accuracy_diff - t3.avg_cumulative_significant_strikes_distance_head_accuracy_diff AS avg_cumulative_significant_strikes_distance_head_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed - t3.avg_opp_avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed AS avg_opp_avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff,
    t2.avg_avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff - t3.avg_avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff AS avg_avg_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed - t3.avg_opp_cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed AS avg_opp_cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff - t3.avg_cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff AS avg_cumulative_significant_strikes_distance_head_landed_per_significant_strike_distance_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed - t3.avg_opp_avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed AS avg_opp_avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff - t3.avg_avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff AS avg_avg_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed - t3.avg_opp_cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed AS avg_opp_cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff - t3.avg_cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff AS avg_cumulative_significant_strikes_distance_head_landed_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_head_attempted - t3.avg_opp_avg_significant_strikes_distance_head_attempted AS avg_opp_avg_significant_strikes_distance_head_attempted_diff,
    t2.avg_avg_significant_strikes_distance_head_attempted_diff - t3.avg_avg_significant_strikes_distance_head_attempted_diff AS avg_avg_significant_strikes_distance_head_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_head_attempted - t3.avg_opp_cumulative_significant_strikes_distance_head_attempted AS avg_opp_cumulative_significant_strikes_distance_head_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_head_attempted_diff - t3.avg_cumulative_significant_strikes_distance_head_attempted_diff AS avg_cumulative_significant_strikes_distance_head_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_head_attempted_per_second - t3.avg_opp_avg_significant_strikes_distance_head_attempted_per_second AS avg_opp_avg_significant_strikes_distance_head_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_distance_head_attempted_per_second_diff - t3.avg_avg_significant_strikes_distance_head_attempted_per_second_diff AS avg_avg_significant_strikes_distance_head_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_head_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_distance_head_attempted_per_second AS avg_opp_cumulative_significant_strikes_distance_head_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_distance_head_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_distance_head_attempted_per_second_diff AS avg_cumulative_significant_strikes_distance_head_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted - t3.avg_opp_avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted AS avg_opp_avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff - t3.avg_avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff AS avg_avg_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted - t3.avg_opp_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted AS avg_opp_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff - t3.avg_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff AS avg_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_distance_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted - t3.avg_opp_avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted AS avg_opp_avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff - t3.avg_avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff AS avg_avg_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted - t3.avg_opp_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted AS avg_opp_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff - t3.avg_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff AS avg_cumulative_significant_strikes_distance_head_attempted_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_body_landed - t3.avg_opp_avg_significant_strikes_distance_body_landed AS avg_opp_avg_significant_strikes_distance_body_landed_diff,
    t2.avg_avg_significant_strikes_distance_body_landed_diff - t3.avg_avg_significant_strikes_distance_body_landed_diff AS avg_avg_significant_strikes_distance_body_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_body_landed - t3.avg_opp_cumulative_significant_strikes_distance_body_landed AS avg_opp_cumulative_significant_strikes_distance_body_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_body_landed_diff - t3.avg_cumulative_significant_strikes_distance_body_landed_diff AS avg_cumulative_significant_strikes_distance_body_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_body_landed_per_second - t3.avg_opp_avg_significant_strikes_distance_body_landed_per_second AS avg_opp_avg_significant_strikes_distance_body_landed_per_second_diff,
    t2.avg_avg_significant_strikes_distance_body_landed_per_second_diff - t3.avg_avg_significant_strikes_distance_body_landed_per_second_diff AS avg_avg_significant_strikes_distance_body_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_body_landed_per_second - t3.avg_opp_cumulative_significant_strikes_distance_body_landed_per_second AS avg_opp_cumulative_significant_strikes_distance_body_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_distance_body_landed_per_second_diff - t3.avg_cumulative_significant_strikes_distance_body_landed_per_second_diff AS avg_cumulative_significant_strikes_distance_body_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_body_accuracy - t3.avg_opp_avg_significant_strikes_distance_body_accuracy AS avg_opp_avg_significant_strikes_distance_body_accuracy_diff,
    t2.avg_avg_significant_strikes_distance_body_accuracy_diff - t3.avg_avg_significant_strikes_distance_body_accuracy_diff AS avg_avg_significant_strikes_distance_body_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_body_accuracy - t3.avg_opp_cumulative_significant_strikes_distance_body_accuracy AS avg_opp_cumulative_significant_strikes_distance_body_accuracy_diff,
    t2.avg_cumulative_significant_strikes_distance_body_accuracy_diff - t3.avg_cumulative_significant_strikes_distance_body_accuracy_diff AS avg_cumulative_significant_strikes_distance_body_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed - t3.avg_opp_avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed AS avg_opp_avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff,
    t2.avg_avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff - t3.avg_avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff AS avg_avg_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed - t3.avg_opp_cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed AS avg_opp_cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff - t3.avg_cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff AS avg_cumulative_significant_strikes_distance_body_landed_per_significant_strike_distance_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed - t3.avg_opp_avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed AS avg_opp_avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff - t3.avg_avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff AS avg_avg_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed - t3.avg_opp_cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed AS avg_opp_cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff - t3.avg_cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff AS avg_cumulative_significant_strikes_distance_body_landed_per_significant_strike_body_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_body_attempted - t3.avg_opp_avg_significant_strikes_distance_body_attempted AS avg_opp_avg_significant_strikes_distance_body_attempted_diff,
    t2.avg_avg_significant_strikes_distance_body_attempted_diff - t3.avg_avg_significant_strikes_distance_body_attempted_diff AS avg_avg_significant_strikes_distance_body_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_body_attempted - t3.avg_opp_cumulative_significant_strikes_distance_body_attempted AS avg_opp_cumulative_significant_strikes_distance_body_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_body_attempted_diff - t3.avg_cumulative_significant_strikes_distance_body_attempted_diff AS avg_cumulative_significant_strikes_distance_body_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_body_attempted_per_second - t3.avg_opp_avg_significant_strikes_distance_body_attempted_per_second AS avg_opp_avg_significant_strikes_distance_body_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_distance_body_attempted_per_second_diff - t3.avg_avg_significant_strikes_distance_body_attempted_per_second_diff AS avg_avg_significant_strikes_distance_body_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_body_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_distance_body_attempted_per_second AS avg_opp_cumulative_significant_strikes_distance_body_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_distance_body_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_distance_body_attempted_per_second_diff AS avg_cumulative_significant_strikes_distance_body_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted - t3.avg_opp_avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted AS avg_opp_avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff - t3.avg_avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff AS avg_avg_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted - t3.avg_opp_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted AS avg_opp_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff - t3.avg_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff AS avg_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_distance_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted - t3.avg_opp_avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted AS avg_opp_avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff - t3.avg_avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff AS avg_avg_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted - t3.avg_opp_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted AS avg_opp_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff - t3.avg_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff AS avg_cumulative_significant_strikes_distance_body_attempted_per_significant_strike_body_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_leg_landed - t3.avg_opp_avg_significant_strikes_distance_leg_landed AS avg_opp_avg_significant_strikes_distance_leg_landed_diff,
    t2.avg_avg_significant_strikes_distance_leg_landed_diff - t3.avg_avg_significant_strikes_distance_leg_landed_diff AS avg_avg_significant_strikes_distance_leg_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_leg_landed - t3.avg_opp_cumulative_significant_strikes_distance_leg_landed AS avg_opp_cumulative_significant_strikes_distance_leg_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_leg_landed_diff - t3.avg_cumulative_significant_strikes_distance_leg_landed_diff AS avg_cumulative_significant_strikes_distance_leg_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_leg_landed_per_second - t3.avg_opp_avg_significant_strikes_distance_leg_landed_per_second AS avg_opp_avg_significant_strikes_distance_leg_landed_per_second_diff,
    t2.avg_avg_significant_strikes_distance_leg_landed_per_second_diff - t3.avg_avg_significant_strikes_distance_leg_landed_per_second_diff AS avg_avg_significant_strikes_distance_leg_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_leg_landed_per_second - t3.avg_opp_cumulative_significant_strikes_distance_leg_landed_per_second AS avg_opp_cumulative_significant_strikes_distance_leg_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_distance_leg_landed_per_second_diff - t3.avg_cumulative_significant_strikes_distance_leg_landed_per_second_diff AS avg_cumulative_significant_strikes_distance_leg_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_leg_accuracy - t3.avg_opp_avg_significant_strikes_distance_leg_accuracy AS avg_opp_avg_significant_strikes_distance_leg_accuracy_diff,
    t2.avg_avg_significant_strikes_distance_leg_accuracy_diff - t3.avg_avg_significant_strikes_distance_leg_accuracy_diff AS avg_avg_significant_strikes_distance_leg_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_leg_accuracy - t3.avg_opp_cumulative_significant_strikes_distance_leg_accuracy AS avg_opp_cumulative_significant_strikes_distance_leg_accuracy_diff,
    t2.avg_cumulative_significant_strikes_distance_leg_accuracy_diff - t3.avg_cumulative_significant_strikes_distance_leg_accuracy_diff AS avg_cumulative_significant_strikes_distance_leg_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed - t3.avg_opp_avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed AS avg_opp_avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff,
    t2.avg_avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff - t3.avg_avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff AS avg_avg_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed - t3.avg_opp_cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed AS avg_opp_cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff,
    t2.avg_cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff - t3.avg_cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff AS avg_cumulative_significant_strikes_distance_leg_landed_per_significant_strike_distance_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed - t3.avg_opp_avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed AS avg_opp_avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed_diff - t3.avg_avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed_diff AS avg_avg_significant_strikes_distance_leg_landed_per_significant_strike_leg_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_leg_attempted - t3.avg_opp_avg_significant_strikes_distance_leg_attempted AS avg_opp_avg_significant_strikes_distance_leg_attempted_diff,
    t2.avg_avg_significant_strikes_distance_leg_attempted_diff - t3.avg_avg_significant_strikes_distance_leg_attempted_diff AS avg_avg_significant_strikes_distance_leg_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_leg_attempted - t3.avg_opp_cumulative_significant_strikes_distance_leg_attempted AS avg_opp_cumulative_significant_strikes_distance_leg_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_leg_attempted_diff - t3.avg_cumulative_significant_strikes_distance_leg_attempted_diff AS avg_cumulative_significant_strikes_distance_leg_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_leg_attempted_per_second - t3.avg_opp_avg_significant_strikes_distance_leg_attempted_per_second AS avg_opp_avg_significant_strikes_distance_leg_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_distance_leg_attempted_per_second_diff - t3.avg_avg_significant_strikes_distance_leg_attempted_per_second_diff AS avg_avg_significant_strikes_distance_leg_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_second AS avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_distance_leg_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_distance_leg_attempted_per_second_diff AS avg_cumulative_significant_strikes_distance_leg_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted - t3.avg_opp_avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted AS avg_opp_avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff - t3.avg_avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff AS avg_avg_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted - t3.avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted AS avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff - t3.avg_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff AS avg_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_distance_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted - t3.avg_opp_avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted AS avg_opp_avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff - t3.avg_avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff AS avg_avg_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted - t3.avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted AS avg_opp_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff - t3.avg_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff AS avg_cumulative_significant_strikes_distance_leg_attempted_per_significant_strike_leg_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_head_landed - t3.avg_opp_avg_significant_strikes_clinch_head_landed AS avg_opp_avg_significant_strikes_clinch_head_landed_diff,
    t2.avg_avg_significant_strikes_clinch_head_landed_diff - t3.avg_avg_significant_strikes_clinch_head_landed_diff AS avg_avg_significant_strikes_clinch_head_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_head_landed - t3.avg_opp_cumulative_significant_strikes_clinch_head_landed AS avg_opp_cumulative_significant_strikes_clinch_head_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_head_landed_diff - t3.avg_cumulative_significant_strikes_clinch_head_landed_diff AS avg_cumulative_significant_strikes_clinch_head_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_head_landed_per_second - t3.avg_opp_avg_significant_strikes_clinch_head_landed_per_second AS avg_opp_avg_significant_strikes_clinch_head_landed_per_second_diff,
    t2.avg_avg_significant_strikes_clinch_head_landed_per_second_diff - t3.avg_avg_significant_strikes_clinch_head_landed_per_second_diff AS avg_avg_significant_strikes_clinch_head_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_head_landed_per_second - t3.avg_opp_cumulative_significant_strikes_clinch_head_landed_per_second AS avg_opp_cumulative_significant_strikes_clinch_head_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_clinch_head_landed_per_second_diff - t3.avg_cumulative_significant_strikes_clinch_head_landed_per_second_diff AS avg_cumulative_significant_strikes_clinch_head_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_head_accuracy - t3.avg_opp_avg_significant_strikes_clinch_head_accuracy AS avg_opp_avg_significant_strikes_clinch_head_accuracy_diff,
    t2.avg_avg_significant_strikes_clinch_head_accuracy_diff - t3.avg_avg_significant_strikes_clinch_head_accuracy_diff AS avg_avg_significant_strikes_clinch_head_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_head_accuracy - t3.avg_opp_cumulative_significant_strikes_clinch_head_accuracy AS avg_opp_cumulative_significant_strikes_clinch_head_accuracy_diff,
    t2.avg_cumulative_significant_strikes_clinch_head_accuracy_diff - t3.avg_cumulative_significant_strikes_clinch_head_accuracy_diff AS avg_cumulative_significant_strikes_clinch_head_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed - t3.avg_opp_avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed AS avg_opp_avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff - t3.avg_avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff AS avg_avg_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed - t3.avg_opp_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed AS avg_opp_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff - t3.avg_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff AS avg_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_clinch_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed - t3.avg_opp_avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed AS avg_opp_avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff - t3.avg_avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff AS avg_avg_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed - t3.avg_opp_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed AS avg_opp_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff - t3.avg_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff AS avg_cumulative_significant_strikes_clinch_head_landed_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_head_attempted - t3.avg_opp_avg_significant_strikes_clinch_head_attempted AS avg_opp_avg_significant_strikes_clinch_head_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_head_attempted_diff - t3.avg_avg_significant_strikes_clinch_head_attempted_diff AS avg_avg_significant_strikes_clinch_head_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_head_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_head_attempted AS avg_opp_cumulative_significant_strikes_clinch_head_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_head_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_head_attempted_diff AS avg_cumulative_significant_strikes_clinch_head_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_head_attempted_per_second - t3.avg_opp_avg_significant_strikes_clinch_head_attempted_per_second AS avg_opp_avg_significant_strikes_clinch_head_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_clinch_head_attempted_per_second_diff - t3.avg_avg_significant_strikes_clinch_head_attempted_per_second_diff AS avg_avg_significant_strikes_clinch_head_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_second AS avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_clinch_head_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_clinch_head_attempted_per_second_diff AS avg_cumulative_significant_strikes_clinch_head_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted - t3.avg_opp_avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted AS avg_opp_avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff - t3.avg_avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff AS avg_avg_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted AS avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff AS avg_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_clinch_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted - t3.avg_opp_avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted AS avg_opp_avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff - t3.avg_avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff AS avg_avg_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted AS avg_opp_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff AS avg_cumulative_significant_strikes_clinch_head_attempted_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_body_landed - t3.avg_opp_avg_significant_strikes_clinch_body_landed AS avg_opp_avg_significant_strikes_clinch_body_landed_diff,
    t2.avg_avg_significant_strikes_clinch_body_landed_diff - t3.avg_avg_significant_strikes_clinch_body_landed_diff AS avg_avg_significant_strikes_clinch_body_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_body_landed - t3.avg_opp_cumulative_significant_strikes_clinch_body_landed AS avg_opp_cumulative_significant_strikes_clinch_body_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_body_landed_diff - t3.avg_cumulative_significant_strikes_clinch_body_landed_diff AS avg_cumulative_significant_strikes_clinch_body_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_body_landed_per_second - t3.avg_opp_avg_significant_strikes_clinch_body_landed_per_second AS avg_opp_avg_significant_strikes_clinch_body_landed_per_second_diff,
    t2.avg_avg_significant_strikes_clinch_body_landed_per_second_diff - t3.avg_avg_significant_strikes_clinch_body_landed_per_second_diff AS avg_avg_significant_strikes_clinch_body_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_body_landed_per_second - t3.avg_opp_cumulative_significant_strikes_clinch_body_landed_per_second AS avg_opp_cumulative_significant_strikes_clinch_body_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_clinch_body_landed_per_second_diff - t3.avg_cumulative_significant_strikes_clinch_body_landed_per_second_diff AS avg_cumulative_significant_strikes_clinch_body_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_body_accuracy - t3.avg_opp_avg_significant_strikes_clinch_body_accuracy AS avg_opp_avg_significant_strikes_clinch_body_accuracy_diff,
    t2.avg_avg_significant_strikes_clinch_body_accuracy_diff - t3.avg_avg_significant_strikes_clinch_body_accuracy_diff AS avg_avg_significant_strikes_clinch_body_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_body_accuracy - t3.avg_opp_cumulative_significant_strikes_clinch_body_accuracy AS avg_opp_cumulative_significant_strikes_clinch_body_accuracy_diff,
    t2.avg_cumulative_significant_strikes_clinch_body_accuracy_diff - t3.avg_cumulative_significant_strikes_clinch_body_accuracy_diff AS avg_cumulative_significant_strikes_clinch_body_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed - t3.avg_opp_avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed AS avg_opp_avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff - t3.avg_avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff AS avg_avg_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed - t3.avg_opp_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed AS avg_opp_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff - t3.avg_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff AS avg_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_clinch_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed - t3.avg_opp_avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed AS avg_opp_avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff - t3.avg_avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff AS avg_avg_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed - t3.avg_opp_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed AS avg_opp_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff - t3.avg_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff AS avg_cumulative_significant_strikes_clinch_body_landed_per_significant_strike_body_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_body_attempted - t3.avg_opp_avg_significant_strikes_clinch_body_attempted AS avg_opp_avg_significant_strikes_clinch_body_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_body_attempted_diff - t3.avg_avg_significant_strikes_clinch_body_attempted_diff AS avg_avg_significant_strikes_clinch_body_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_body_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_body_attempted AS avg_opp_cumulative_significant_strikes_clinch_body_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_body_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_body_attempted_diff AS avg_cumulative_significant_strikes_clinch_body_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_body_attempted_per_second - t3.avg_opp_avg_significant_strikes_clinch_body_attempted_per_second AS avg_opp_avg_significant_strikes_clinch_body_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_clinch_body_attempted_per_second_diff - t3.avg_avg_significant_strikes_clinch_body_attempted_per_second_diff AS avg_avg_significant_strikes_clinch_body_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_second AS avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_clinch_body_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_clinch_body_attempted_per_second_diff AS avg_cumulative_significant_strikes_clinch_body_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted - t3.avg_opp_avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted AS avg_opp_avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff - t3.avg_avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff AS avg_avg_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted AS avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff AS avg_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_clinch_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted - t3.avg_opp_avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted AS avg_opp_avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff - t3.avg_avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff AS avg_avg_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted AS avg_opp_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff AS avg_cumulative_significant_strikes_clinch_body_attempted_per_significant_strike_body_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_leg_landed - t3.avg_opp_avg_significant_strikes_clinch_leg_landed AS avg_opp_avg_significant_strikes_clinch_leg_landed_diff,
    t2.avg_avg_significant_strikes_clinch_leg_landed_diff - t3.avg_avg_significant_strikes_clinch_leg_landed_diff AS avg_avg_significant_strikes_clinch_leg_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_second - t3.avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_second AS avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_clinch_leg_landed_per_second_diff - t3.avg_cumulative_significant_strikes_clinch_leg_landed_per_second_diff AS avg_cumulative_significant_strikes_clinch_leg_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_leg_accuracy - t3.avg_opp_avg_significant_strikes_clinch_leg_accuracy AS avg_opp_avg_significant_strikes_clinch_leg_accuracy_diff,
    t2.avg_avg_significant_strikes_clinch_leg_accuracy_diff - t3.avg_avg_significant_strikes_clinch_leg_accuracy_diff AS avg_avg_significant_strikes_clinch_leg_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_leg_accuracy - t3.avg_opp_cumulative_significant_strikes_clinch_leg_accuracy AS avg_opp_cumulative_significant_strikes_clinch_leg_accuracy_diff,
    t2.avg_cumulative_significant_strikes_clinch_leg_accuracy_diff - t3.avg_cumulative_significant_strikes_clinch_leg_accuracy_diff AS avg_cumulative_significant_strikes_clinch_leg_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed - t3.avg_opp_avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed AS avg_opp_avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff - t3.avg_avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff AS avg_avg_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed - t3.avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed AS avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff - t3.avg_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff AS avg_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_clinch_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed - t3.avg_opp_avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed AS avg_opp_avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff - t3.avg_avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff AS avg_avg_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed - t3.avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed AS avg_opp_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff - t3.avg_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff AS avg_cumulative_significant_strikes_clinch_leg_landed_per_significant_strike_leg_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_leg_attempted - t3.avg_opp_avg_significant_strikes_clinch_leg_attempted AS avg_opp_avg_significant_strikes_clinch_leg_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_leg_attempted_diff - t3.avg_avg_significant_strikes_clinch_leg_attempted_diff AS avg_avg_significant_strikes_clinch_leg_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_leg_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_leg_attempted AS avg_opp_cumulative_significant_strikes_clinch_leg_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_leg_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_leg_attempted_diff AS avg_cumulative_significant_strikes_clinch_leg_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_leg_attempted_per_second - t3.avg_opp_avg_significant_strikes_clinch_leg_attempted_per_second AS avg_opp_avg_significant_strikes_clinch_leg_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_clinch_leg_attempted_per_second_diff - t3.avg_avg_significant_strikes_clinch_leg_attempted_per_second_diff AS avg_avg_significant_strikes_clinch_leg_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_second AS avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_clinch_leg_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_clinch_leg_attempted_per_second_diff AS avg_cumulative_significant_strikes_clinch_leg_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted - t3.avg_opp_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted AS avg_opp_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff - t3.avg_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff AS avg_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted AS avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff AS avg_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_clinch_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted - t3.avg_opp_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted AS avg_opp_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff - t3.avg_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff AS avg_avg_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted - t3.avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted AS avg_opp_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff - t3.avg_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff AS avg_cumulative_significant_strikes_clinch_leg_attempted_per_significant_strike_leg_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_head_landed - t3.avg_opp_avg_significant_strikes_ground_head_landed AS avg_opp_avg_significant_strikes_ground_head_landed_diff,
    t2.avg_avg_significant_strikes_ground_head_landed_diff - t3.avg_avg_significant_strikes_ground_head_landed_diff AS avg_avg_significant_strikes_ground_head_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_head_landed - t3.avg_opp_cumulative_significant_strikes_ground_head_landed AS avg_opp_cumulative_significant_strikes_ground_head_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_head_landed_diff - t3.avg_cumulative_significant_strikes_ground_head_landed_diff AS avg_cumulative_significant_strikes_ground_head_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_head_landed_per_second - t3.avg_opp_avg_significant_strikes_ground_head_landed_per_second AS avg_opp_avg_significant_strikes_ground_head_landed_per_second_diff,
    t2.avg_avg_significant_strikes_ground_head_landed_per_second_diff - t3.avg_avg_significant_strikes_ground_head_landed_per_second_diff AS avg_avg_significant_strikes_ground_head_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_head_landed_per_second - t3.avg_opp_cumulative_significant_strikes_ground_head_landed_per_second AS avg_opp_cumulative_significant_strikes_ground_head_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_ground_head_landed_per_second_diff - t3.avg_cumulative_significant_strikes_ground_head_landed_per_second_diff AS avg_cumulative_significant_strikes_ground_head_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_head_accuracy - t3.avg_opp_avg_significant_strikes_ground_head_accuracy AS avg_opp_avg_significant_strikes_ground_head_accuracy_diff,
    t2.avg_avg_significant_strikes_ground_head_accuracy_diff - t3.avg_avg_significant_strikes_ground_head_accuracy_diff AS avg_avg_significant_strikes_ground_head_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_head_accuracy - t3.avg_opp_cumulative_significant_strikes_ground_head_accuracy AS avg_opp_cumulative_significant_strikes_ground_head_accuracy_diff,
    t2.avg_cumulative_significant_strikes_ground_head_accuracy_diff - t3.avg_cumulative_significant_strikes_ground_head_accuracy_diff AS avg_cumulative_significant_strikes_ground_head_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed - t3.avg_opp_avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed AS avg_opp_avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff,
    t2.avg_avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff - t3.avg_avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff AS avg_avg_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed - t3.avg_opp_cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed AS avg_opp_cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff - t3.avg_cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff AS avg_cumulative_significant_strikes_ground_head_landed_per_significant_strike_ground_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed - t3.avg_opp_avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed AS avg_opp_avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff - t3.avg_avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff AS avg_avg_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed - t3.avg_opp_cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed AS avg_opp_cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff - t3.avg_cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff AS avg_cumulative_significant_strikes_ground_head_landed_per_significant_strike_head_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_head_attempted - t3.avg_opp_avg_significant_strikes_ground_head_attempted AS avg_opp_avg_significant_strikes_ground_head_attempted_diff,
    t2.avg_avg_significant_strikes_ground_head_attempted_diff - t3.avg_avg_significant_strikes_ground_head_attempted_diff AS avg_avg_significant_strikes_ground_head_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_head_attempted - t3.avg_opp_cumulative_significant_strikes_ground_head_attempted AS avg_opp_cumulative_significant_strikes_ground_head_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_head_attempted_diff - t3.avg_cumulative_significant_strikes_ground_head_attempted_diff AS avg_cumulative_significant_strikes_ground_head_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_head_attempted_per_second - t3.avg_opp_avg_significant_strikes_ground_head_attempted_per_second AS avg_opp_avg_significant_strikes_ground_head_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_ground_head_attempted_per_second_diff - t3.avg_avg_significant_strikes_ground_head_attempted_per_second_diff AS avg_avg_significant_strikes_ground_head_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_head_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_ground_head_attempted_per_second AS avg_opp_cumulative_significant_strikes_ground_head_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_ground_head_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_ground_head_attempted_per_second_diff AS avg_cumulative_significant_strikes_ground_head_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted - t3.avg_opp_avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted AS avg_opp_avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff - t3.avg_avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff AS avg_avg_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted - t3.avg_opp_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted AS avg_opp_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff - t3.avg_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff AS avg_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_ground_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted - t3.avg_opp_avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted AS avg_opp_avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff - t3.avg_avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff AS avg_avg_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted - t3.avg_opp_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted AS avg_opp_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff - t3.avg_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff AS avg_cumulative_significant_strikes_ground_head_attempted_per_significant_strike_head_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_body_landed - t3.avg_opp_avg_significant_strikes_ground_body_landed AS avg_opp_avg_significant_strikes_ground_body_landed_diff,
    t2.avg_avg_significant_strikes_ground_body_landed_diff - t3.avg_avg_significant_strikes_ground_body_landed_diff AS avg_avg_significant_strikes_ground_body_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_body_landed - t3.avg_opp_cumulative_significant_strikes_ground_body_landed AS avg_opp_cumulative_significant_strikes_ground_body_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_body_landed_diff - t3.avg_cumulative_significant_strikes_ground_body_landed_diff AS avg_cumulative_significant_strikes_ground_body_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_body_landed_per_second - t3.avg_opp_avg_significant_strikes_ground_body_landed_per_second AS avg_opp_avg_significant_strikes_ground_body_landed_per_second_diff,
    t2.avg_avg_significant_strikes_ground_body_landed_per_second_diff - t3.avg_avg_significant_strikes_ground_body_landed_per_second_diff AS avg_avg_significant_strikes_ground_body_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_body_landed_per_second - t3.avg_opp_cumulative_significant_strikes_ground_body_landed_per_second AS avg_opp_cumulative_significant_strikes_ground_body_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_ground_body_landed_per_second_diff - t3.avg_cumulative_significant_strikes_ground_body_landed_per_second_diff AS avg_cumulative_significant_strikes_ground_body_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_body_accuracy - t3.avg_opp_avg_significant_strikes_ground_body_accuracy AS avg_opp_avg_significant_strikes_ground_body_accuracy_diff,
    t2.avg_avg_significant_strikes_ground_body_accuracy_diff - t3.avg_avg_significant_strikes_ground_body_accuracy_diff AS avg_avg_significant_strikes_ground_body_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_body_accuracy - t3.avg_opp_cumulative_significant_strikes_ground_body_accuracy AS avg_opp_cumulative_significant_strikes_ground_body_accuracy_diff,
    t2.avg_cumulative_significant_strikes_ground_body_accuracy_diff - t3.avg_cumulative_significant_strikes_ground_body_accuracy_diff AS avg_cumulative_significant_strikes_ground_body_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed - t3.avg_opp_avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed AS avg_opp_avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff,
    t2.avg_avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff - t3.avg_avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff AS avg_avg_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed - t3.avg_opp_cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed AS avg_opp_cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff - t3.avg_cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff AS avg_cumulative_significant_strikes_ground_body_landed_per_significant_strike_ground_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed - t3.avg_opp_avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed AS avg_opp_avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff - t3.avg_avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff AS avg_avg_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed - t3.avg_opp_cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed AS avg_opp_cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff - t3.avg_cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff AS avg_cumulative_significant_strikes_ground_body_landed_per_significant_strike_body_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_body_attempted - t3.avg_opp_avg_significant_strikes_ground_body_attempted AS avg_opp_avg_significant_strikes_ground_body_attempted_diff,
    t2.avg_avg_significant_strikes_ground_body_attempted_diff - t3.avg_avg_significant_strikes_ground_body_attempted_diff AS avg_avg_significant_strikes_ground_body_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_body_attempted - t3.avg_opp_cumulative_significant_strikes_ground_body_attempted AS avg_opp_cumulative_significant_strikes_ground_body_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_body_attempted_diff - t3.avg_cumulative_significant_strikes_ground_body_attempted_diff AS avg_cumulative_significant_strikes_ground_body_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_body_attempted_per_second - t3.avg_opp_avg_significant_strikes_ground_body_attempted_per_second AS avg_opp_avg_significant_strikes_ground_body_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_ground_body_attempted_per_second_diff - t3.avg_avg_significant_strikes_ground_body_attempted_per_second_diff AS avg_avg_significant_strikes_ground_body_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_body_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_ground_body_attempted_per_second AS avg_opp_cumulative_significant_strikes_ground_body_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_ground_body_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_ground_body_attempted_per_second_diff AS avg_cumulative_significant_strikes_ground_body_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted - t3.avg_opp_avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted AS avg_opp_avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff - t3.avg_avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff AS avg_avg_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted - t3.avg_opp_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted AS avg_opp_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff - t3.avg_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff AS avg_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_ground_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted - t3.avg_opp_avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted AS avg_opp_avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff - t3.avg_avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff AS avg_avg_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted - t3.avg_opp_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted AS avg_opp_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff - t3.avg_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff AS avg_cumulative_significant_strikes_ground_body_attempted_per_significant_strike_body_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_leg_landed - t3.avg_opp_avg_significant_strikes_ground_leg_landed AS avg_opp_avg_significant_strikes_ground_leg_landed_diff,
    t2.avg_avg_significant_strikes_ground_leg_landed_diff - t3.avg_avg_significant_strikes_ground_leg_landed_diff AS avg_avg_significant_strikes_ground_leg_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_leg_landed - t3.avg_opp_cumulative_significant_strikes_ground_leg_landed AS avg_opp_cumulative_significant_strikes_ground_leg_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_leg_landed_diff - t3.avg_cumulative_significant_strikes_ground_leg_landed_diff AS avg_cumulative_significant_strikes_ground_leg_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_leg_landed_per_second - t3.avg_opp_avg_significant_strikes_ground_leg_landed_per_second AS avg_opp_avg_significant_strikes_ground_leg_landed_per_second_diff,
    t2.avg_avg_significant_strikes_ground_leg_landed_per_second_diff - t3.avg_avg_significant_strikes_ground_leg_landed_per_second_diff AS avg_avg_significant_strikes_ground_leg_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_leg_landed_per_second - t3.avg_opp_cumulative_significant_strikes_ground_leg_landed_per_second AS avg_opp_cumulative_significant_strikes_ground_leg_landed_per_second_diff,
    t2.avg_cumulative_significant_strikes_ground_leg_landed_per_second_diff - t3.avg_cumulative_significant_strikes_ground_leg_landed_per_second_diff AS avg_cumulative_significant_strikes_ground_leg_landed_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_leg_accuracy - t3.avg_opp_avg_significant_strikes_ground_leg_accuracy AS avg_opp_avg_significant_strikes_ground_leg_accuracy_diff,
    t2.avg_avg_significant_strikes_ground_leg_accuracy_diff - t3.avg_avg_significant_strikes_ground_leg_accuracy_diff AS avg_avg_significant_strikes_ground_leg_accuracy_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_leg_accuracy - t3.avg_opp_cumulative_significant_strikes_ground_leg_accuracy AS avg_opp_cumulative_significant_strikes_ground_leg_accuracy_diff,
    t2.avg_cumulative_significant_strikes_ground_leg_accuracy_diff - t3.avg_cumulative_significant_strikes_ground_leg_accuracy_diff AS avg_cumulative_significant_strikes_ground_leg_accuracy_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed - t3.avg_opp_avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed AS avg_opp_avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff,
    t2.avg_avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff - t3.avg_avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff AS avg_avg_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed - t3.avg_opp_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed AS avg_opp_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff - t3.avg_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff AS avg_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_ground_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed - t3.avg_opp_avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed AS avg_opp_avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff - t3.avg_avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff AS avg_avg_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed - t3.avg_opp_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed AS avg_opp_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff,
    t2.avg_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff - t3.avg_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff AS avg_cumulative_significant_strikes_ground_leg_landed_per_significant_strike_leg_landed_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_leg_attempted - t3.avg_opp_avg_significant_strikes_ground_leg_attempted AS avg_opp_avg_significant_strikes_ground_leg_attempted_diff,
    t2.avg_avg_significant_strikes_ground_leg_attempted_diff - t3.avg_avg_significant_strikes_ground_leg_attempted_diff AS avg_avg_significant_strikes_ground_leg_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_leg_attempted - t3.avg_opp_cumulative_significant_strikes_ground_leg_attempted AS avg_opp_cumulative_significant_strikes_ground_leg_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_leg_attempted_diff - t3.avg_cumulative_significant_strikes_ground_leg_attempted_diff AS avg_cumulative_significant_strikes_ground_leg_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_leg_attempted_per_second - t3.avg_opp_avg_significant_strikes_ground_leg_attempted_per_second AS avg_opp_avg_significant_strikes_ground_leg_attempted_per_second_diff,
    t2.avg_avg_significant_strikes_ground_leg_attempted_per_second_diff - t3.avg_avg_significant_strikes_ground_leg_attempted_per_second_diff AS avg_avg_significant_strikes_ground_leg_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_second - t3.avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_second AS avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_second_diff,
    t2.avg_cumulative_significant_strikes_ground_leg_attempted_per_second_diff - t3.avg_cumulative_significant_strikes_ground_leg_attempted_per_second_diff AS avg_cumulative_significant_strikes_ground_leg_attempted_per_second_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted - t3.avg_opp_avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted AS avg_opp_avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff - t3.avg_avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff AS avg_avg_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted - t3.avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted AS avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff - t3.avg_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff AS avg_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_ground_attempted_diff_diff,
    t2.avg_opp_avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted - t3.avg_opp_avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted AS avg_opp_avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff - t3.avg_avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff AS avg_avg_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff_diff,
    t2.avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted - t3.avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted AS avg_opp_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff,
    t2.avg_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff - t3.avg_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff AS avg_cumulative_significant_strikes_ground_leg_attempted_per_significant_strike_leg_attempted_diff_diff,
    t2.avg_opp_avg_takedowns_landed - t3.avg_opp_avg_takedowns_landed AS avg_opp_avg_takedowns_landed_diff,
    t2.avg_avg_takedowns_landed_diff - t3.avg_avg_takedowns_landed_diff AS avg_avg_takedowns_landed_diff_diff,
    t2.avg_opp_cumulative_takedowns_landed - t3.avg_opp_cumulative_takedowns_landed AS avg_opp_cumulative_takedowns_landed_diff,
    t2.avg_cumulative_takedowns_landed_diff - t3.avg_cumulative_takedowns_landed_diff AS avg_cumulative_takedowns_landed_diff_diff,
    t2.avg_opp_avg_takedowns_landed_per_second - t3.avg_opp_avg_takedowns_landed_per_second AS avg_opp_avg_takedowns_landed_per_second_diff,
    t2.avg_avg_takedowns_landed_per_second_diff - t3.avg_avg_takedowns_landed_per_second_diff AS avg_avg_takedowns_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_takedowns_landed_per_second - t3.avg_opp_cumulative_takedowns_landed_per_second AS avg_opp_cumulative_takedowns_landed_per_second_diff,
    t2.avg_cumulative_takedowns_landed_per_second_diff - t3.avg_cumulative_takedowns_landed_per_second_diff AS avg_cumulative_takedowns_landed_per_second_diff_diff,
    t2.avg_opp_avg_takedowns_accuracy - t3.avg_opp_avg_takedowns_accuracy AS avg_opp_avg_takedowns_accuracy_diff,
    t2.avg_avg_takedowns_accuracy_diff - t3.avg_avg_takedowns_accuracy_diff AS avg_avg_takedowns_accuracy_diff_diff,
    t2.avg_opp_cumulative_takedowns_accuracy - t3.avg_opp_cumulative_takedowns_accuracy AS avg_opp_cumulative_takedowns_accuracy_diff,
    t2.avg_cumulative_takedowns_accuracy_diff - t3.avg_cumulative_takedowns_accuracy_diff AS avg_cumulative_takedowns_accuracy_diff_diff,
    t2.avg_opp_avg_takedowns_slams_landed - t3.avg_opp_avg_takedowns_slams_landed AS avg_opp_avg_takedowns_slams_landed_diff,
    t2.avg_avg_takedowns_slams_landed_diff - t3.avg_avg_takedowns_slams_landed_diff AS avg_avg_takedowns_slams_landed_diff_diff,
    t2.avg_opp_cumulative_takedowns_slams_landed - t3.avg_opp_cumulative_takedowns_slams_landed AS avg_opp_cumulative_takedowns_slams_landed_diff,
    t2.avg_cumulative_takedowns_slams_landed_diff - t3.avg_cumulative_takedowns_slams_landed_diff AS avg_cumulative_takedowns_slams_landed_diff_diff,
    t2.avg_opp_avg_takedowns_slams_landed_per_second - t3.avg_opp_avg_takedowns_slams_landed_per_second AS avg_opp_avg_takedowns_slams_landed_per_second_diff,
    t2.avg_avg_takedowns_slams_landed_per_second_diff - t3.avg_avg_takedowns_slams_landed_per_second_diff AS avg_avg_takedowns_slams_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_takedowns_slams_landed_per_second - t3.avg_opp_cumulative_takedowns_slams_landed_per_second AS avg_opp_cumulative_takedowns_slams_landed_per_second_diff,
    t2.avg_cumulative_takedowns_slams_landed_per_second_diff - t3.avg_cumulative_takedowns_slams_landed_per_second_diff AS avg_cumulative_takedowns_slams_landed_per_second_diff_diff,
    t2.avg_opp_avg_takedowns_slams_landed_per_takedowns_landed - t3.avg_opp_avg_takedowns_slams_landed_per_takedowns_landed AS avg_opp_avg_takedowns_slams_landed_per_takedowns_landed_diff,
    t2.avg_avg_takedowns_slams_landed_per_takedowns_landed_diff - t3.avg_avg_takedowns_slams_landed_per_takedowns_landed_diff AS avg_avg_takedowns_slams_landed_per_takedowns_landed_diff_diff,
    t2.avg_opp_cumulative_takedowns_slams_landed_per_takedowns_landed - t3.avg_opp_cumulative_takedowns_slams_landed_per_takedowns_landed AS avg_opp_cumulative_takedowns_slams_landed_per_takedowns_landed_diff,
    t2.avg_cumulative_takedowns_slams_landed_per_takedowns_landed_diff - t3.avg_cumulative_takedowns_slams_landed_per_takedowns_landed_diff AS avg_cumulative_takedowns_slams_landed_per_takedowns_landed_diff_diff,
    t2.avg_opp_avg_takedowns_attempted - t3.avg_opp_avg_takedowns_attempted AS avg_opp_avg_takedowns_attempted_diff,
    t2.avg_avg_takedowns_attempted_diff - t3.avg_avg_takedowns_attempted_diff AS avg_avg_takedowns_attempted_diff_diff,
    t2.avg_opp_cumulative_takedowns_attempted - t3.avg_opp_cumulative_takedowns_attempted AS avg_opp_cumulative_takedowns_attempted_diff,
    t2.avg_cumulative_takedowns_attempted_diff - t3.avg_cumulative_takedowns_attempted_diff AS avg_cumulative_takedowns_attempted_diff_diff,
    t2.avg_opp_avg_takedowns_attempted_per_second - t3.avg_opp_avg_takedowns_attempted_per_second AS avg_opp_avg_takedowns_attempted_per_second_diff,
    t2.avg_avg_takedowns_attempted_per_second_diff - t3.avg_avg_takedowns_attempted_per_second_diff AS avg_avg_takedowns_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_takedowns_attempted_per_second - t3.avg_opp_cumulative_takedowns_attempted_per_second AS avg_opp_cumulative_takedowns_attempted_per_second_diff,
    t2.avg_cumulative_takedowns_attempted_per_second_diff - t3.avg_cumulative_takedowns_attempted_per_second_diff AS avg_cumulative_takedowns_attempted_per_second_diff_diff,
    t2.avg_opp_avg_advances - t3.avg_opp_avg_advances AS avg_opp_avg_advances_diff,
    t2.avg_avg_advances_diff - t3.avg_avg_advances_diff AS avg_avg_advances_diff_diff,
    t2.avg_opp_cumulative_advances - t3.avg_opp_cumulative_advances AS avg_opp_cumulative_advances_diff,
    t2.avg_cumulative_advances_diff - t3.avg_cumulative_advances_diff AS avg_cumulative_advances_diff_diff,
    t2.avg_opp_avg_advances_per_second - t3.avg_opp_avg_advances_per_second AS avg_opp_avg_advances_per_second_diff,
    t2.avg_avg_advances_per_second_diff - t3.avg_avg_advances_per_second_diff AS avg_avg_advances_per_second_diff_diff,
    t2.avg_opp_cumulative_advances_per_second - t3.avg_opp_cumulative_advances_per_second AS avg_opp_cumulative_advances_per_second_diff,
    t2.avg_cumulative_advances_per_second_diff - t3.avg_cumulative_advances_per_second_diff AS avg_cumulative_advances_per_second_diff_diff,
    t2.avg_opp_avg_advances_to_back - t3.avg_opp_avg_advances_to_back AS avg_opp_avg_advances_to_back_diff,
    t2.avg_avg_advances_to_back_diff - t3.avg_avg_advances_to_back_diff AS avg_avg_advances_to_back_diff_diff,
    t2.avg_opp_cumulative_advances_to_back - t3.avg_opp_cumulative_advances_to_back AS avg_opp_cumulative_advances_to_back_diff,
    t2.avg_cumulative_advances_to_back_diff - t3.avg_cumulative_advances_to_back_diff AS avg_cumulative_advances_to_back_diff_diff,
    t2.avg_opp_avg_advances_to_back_per_second - t3.avg_opp_avg_advances_to_back_per_second AS avg_opp_avg_advances_to_back_per_second_diff,
    t2.avg_avg_advances_to_back_per_second_diff - t3.avg_avg_advances_to_back_per_second_diff AS avg_avg_advances_to_back_per_second_diff_diff,
    t2.avg_opp_cumulative_advances_to_back_per_second - t3.avg_opp_cumulative_advances_to_back_per_second AS avg_opp_cumulative_advances_to_back_per_second_diff,
    t2.avg_cumulative_advances_to_back_per_second_diff - t3.avg_cumulative_advances_to_back_per_second_diff AS avg_cumulative_advances_to_back_per_second_diff_diff,
    t2.avg_opp_avg_advances_to_back_per_advances - t3.avg_opp_avg_advances_to_back_per_advances AS avg_opp_avg_advances_to_back_per_advances_diff,
    t2.avg_avg_advances_to_back_per_advances_diff - t3.avg_avg_advances_to_back_per_advances_diff AS avg_avg_advances_to_back_per_advances_diff_diff,
    t2.avg_opp_cumulative_advances_to_back_per_advances - t3.avg_opp_cumulative_advances_to_back_per_advances AS avg_opp_cumulative_advances_to_back_per_advances_diff,
    t2.avg_cumulative_advances_to_back_per_advances_diff - t3.avg_cumulative_advances_to_back_per_advances_diff AS avg_cumulative_advances_to_back_per_advances_diff_diff,
    t2.avg_opp_avg_advances_to_half_guard - t3.avg_opp_avg_advances_to_half_guard AS avg_opp_avg_advances_to_half_guard_diff,
    t2.avg_avg_advances_to_half_guard_diff - t3.avg_avg_advances_to_half_guard_diff AS avg_avg_advances_to_half_guard_diff_diff,
    t2.avg_opp_cumulative_advances_to_half_guard - t3.avg_opp_cumulative_advances_to_half_guard AS avg_opp_cumulative_advances_to_half_guard_diff,
    t2.avg_cumulative_advances_to_half_guard_diff - t3.avg_cumulative_advances_to_half_guard_diff AS avg_cumulative_advances_to_half_guard_diff_diff,
    t2.avg_opp_avg_advances_to_half_guard_per_second - t3.avg_opp_avg_advances_to_half_guard_per_second AS avg_opp_avg_advances_to_half_guard_per_second_diff,
    t2.avg_avg_advances_to_half_guard_per_second_diff - t3.avg_avg_advances_to_half_guard_per_second_diff AS avg_avg_advances_to_half_guard_per_second_diff_diff,
    t2.avg_opp_cumulative_advances_to_half_guard_per_second - t3.avg_opp_cumulative_advances_to_half_guard_per_second AS avg_opp_cumulative_advances_to_half_guard_per_second_diff,
    t2.avg_cumulative_advances_to_half_guard_per_second_diff - t3.avg_cumulative_advances_to_half_guard_per_second_diff AS avg_cumulative_advances_to_half_guard_per_second_diff_diff,
    t2.avg_opp_avg_advances_to_half_guard_per_advances - t3.avg_opp_avg_advances_to_half_guard_per_advances AS avg_opp_avg_advances_to_half_guard_per_advances_diff,
    t2.avg_avg_advances_to_half_guard_per_advances_diff - t3.avg_avg_advances_to_half_guard_per_advances_diff AS avg_avg_advances_to_half_guard_per_advances_diff_diff,
    t2.avg_opp_cumulative_advances_to_half_guard_per_advances - t3.avg_opp_cumulative_advances_to_half_guard_per_advances AS avg_opp_cumulative_advances_to_half_guard_per_advances_diff,
    t2.avg_cumulative_advances_to_half_guard_per_advances_diff - t3.avg_cumulative_advances_to_half_guard_per_advances_diff AS avg_cumulative_advances_to_half_guard_per_advances_diff_diff,
    t2.avg_opp_avg_advances_to_mount - t3.avg_opp_avg_advances_to_mount AS avg_opp_avg_advances_to_mount_diff,
    t2.avg_avg_advances_to_mount_diff - t3.avg_avg_advances_to_mount_diff AS avg_avg_advances_to_mount_diff_diff,
    t2.avg_opp_cumulative_advances_to_mount - t3.avg_opp_cumulative_advances_to_mount AS avg_opp_cumulative_advances_to_mount_diff,
    t2.avg_cumulative_advances_to_mount_diff - t3.avg_cumulative_advances_to_mount_diff AS avg_cumulative_advances_to_mount_diff_diff,
    t2.avg_opp_avg_advances_to_mount_per_second - t3.avg_opp_avg_advances_to_mount_per_second AS avg_opp_avg_advances_to_mount_per_second_diff,
    t2.avg_avg_advances_to_mount_per_second_diff - t3.avg_avg_advances_to_mount_per_second_diff AS avg_avg_advances_to_mount_per_second_diff_diff,
    t2.avg_opp_cumulative_advances_to_mount_per_second - t3.avg_opp_cumulative_advances_to_mount_per_second AS avg_opp_cumulative_advances_to_mount_per_second_diff,
    t2.avg_cumulative_advances_to_mount_per_second_diff - t3.avg_cumulative_advances_to_mount_per_second_diff AS avg_cumulative_advances_to_mount_per_second_diff_diff,
    t2.avg_opp_avg_advances_to_mount_per_advances - t3.avg_opp_avg_advances_to_mount_per_advances AS avg_opp_avg_advances_to_mount_per_advances_diff,
    t2.avg_avg_advances_to_mount_per_advances_diff - t3.avg_avg_advances_to_mount_per_advances_diff AS avg_avg_advances_to_mount_per_advances_diff_diff,
    t2.avg_opp_cumulative_advances_to_mount_per_advances - t3.avg_opp_cumulative_advances_to_mount_per_advances AS avg_opp_cumulative_advances_to_mount_per_advances_diff,
    t2.avg_cumulative_advances_to_mount_per_advances_diff - t3.avg_cumulative_advances_to_mount_per_advances_diff AS avg_cumulative_advances_to_mount_per_advances_diff_diff,
    t2.avg_opp_avg_advances_to_side - t3.avg_opp_avg_advances_to_side AS avg_opp_avg_advances_to_side_diff,
    t2.avg_avg_advances_to_side_diff - t3.avg_avg_advances_to_side_diff AS avg_avg_advances_to_side_diff_diff,
    t2.avg_opp_cumulative_advances_to_side - t3.avg_opp_cumulative_advances_to_side AS avg_opp_cumulative_advances_to_side_diff,
    t2.avg_cumulative_advances_to_side_diff - t3.avg_cumulative_advances_to_side_diff AS avg_cumulative_advances_to_side_diff_diff,
    t2.avg_opp_avg_advances_to_side_per_second - t3.avg_opp_avg_advances_to_side_per_second AS avg_opp_avg_advances_to_side_per_second_diff,
    t2.avg_avg_advances_to_side_per_second_diff - t3.avg_avg_advances_to_side_per_second_diff AS avg_avg_advances_to_side_per_second_diff_diff,
    t2.avg_opp_cumulative_advances_to_side_per_second - t3.avg_opp_cumulative_advances_to_side_per_second AS avg_opp_cumulative_advances_to_side_per_second_diff,
    t2.avg_cumulative_advances_to_side_per_second_diff - t3.avg_cumulative_advances_to_side_per_second_diff AS avg_cumulative_advances_to_side_per_second_diff_diff,
    t2.avg_opp_avg_advances_to_side_per_advances - t3.avg_opp_avg_advances_to_side_per_advances AS avg_opp_avg_advances_to_side_per_advances_diff,
    t2.avg_avg_advances_to_side_per_advances_diff - t3.avg_avg_advances_to_side_per_advances_diff AS avg_avg_advances_to_side_per_advances_diff_diff,
    t2.avg_opp_cumulative_advances_to_side_per_advances - t3.avg_opp_cumulative_advances_to_side_per_advances AS avg_opp_cumulative_advances_to_side_per_advances_diff,
    t2.avg_cumulative_advances_to_side_per_advances_diff - t3.avg_cumulative_advances_to_side_per_advances_diff AS avg_cumulative_advances_to_side_per_advances_diff_diff,
    t2.avg_opp_avg_reversals_scored - t3.avg_opp_avg_reversals_scored AS avg_opp_avg_reversals_scored_diff,
    t2.avg_avg_reversals_scored_diff - t3.avg_avg_reversals_scored_diff AS avg_avg_reversals_scored_diff_diff,
    t2.avg_opp_cumulative_reversals_scored - t3.avg_opp_cumulative_reversals_scored AS avg_opp_cumulative_reversals_scored_diff,
    t2.avg_cumulative_reversals_scored_diff - t3.avg_cumulative_reversals_scored_diff AS avg_cumulative_reversals_scored_diff_diff,
    t2.avg_opp_avg_reversals_scored_per_second - t3.avg_opp_avg_reversals_scored_per_second AS avg_opp_avg_reversals_scored_per_second_diff,
    t2.avg_avg_reversals_scored_per_second_diff - t3.avg_avg_reversals_scored_per_second_diff AS avg_avg_reversals_scored_per_second_diff_diff,
    t2.avg_opp_cumulative_reversals_scored_per_second - t3.avg_opp_cumulative_reversals_scored_per_second AS avg_opp_cumulative_reversals_scored_per_second_diff,
    t2.avg_cumulative_reversals_scored_per_second_diff - t3.avg_cumulative_reversals_scored_per_second_diff AS avg_cumulative_reversals_scored_per_second_diff_diff,
    t2.avg_opp_avg_submissions_landed - t3.avg_opp_avg_submissions_landed AS avg_opp_avg_submissions_landed_diff,
    t2.avg_avg_submissions_landed_diff - t3.avg_avg_submissions_landed_diff AS avg_avg_submissions_landed_diff_diff,
    t2.avg_opp_cumulative_submissions_landed - t3.avg_opp_cumulative_submissions_landed AS avg_opp_cumulative_submissions_landed_diff,
    t2.avg_cumulative_submissions_landed_diff - t3.avg_cumulative_submissions_landed_diff AS avg_cumulative_submissions_landed_diff_diff,
    t2.avg_opp_avg_submissions_landed_per_second - t3.avg_opp_avg_submissions_landed_per_second AS avg_opp_avg_submissions_landed_per_second_diff,
    t2.avg_avg_submissions_landed_per_second_diff - t3.avg_avg_submissions_landed_per_second_diff AS avg_avg_submissions_landed_per_second_diff_diff,
    t2.avg_opp_cumulative_submissions_landed_per_second - t3.avg_opp_cumulative_submissions_landed_per_second AS avg_opp_cumulative_submissions_landed_per_second_diff,
    t2.avg_cumulative_submissions_landed_per_second_diff - t3.avg_cumulative_submissions_landed_per_second_diff AS avg_cumulative_submissions_landed_per_second_diff_diff,
    t2.avg_opp_avg_submissions_accuracy - t3.avg_opp_avg_submissions_accuracy AS avg_opp_avg_submissions_accuracy_diff,
    t2.avg_avg_submissions_accuracy_diff - t3.avg_avg_submissions_accuracy_diff AS avg_avg_submissions_accuracy_diff_diff,
    t2.avg_opp_cumulative_submissions_accuracy - t3.avg_opp_cumulative_submissions_accuracy AS avg_opp_cumulative_submissions_accuracy_diff,
    t2.avg_cumulative_submissions_accuracy_diff - t3.avg_cumulative_submissions_accuracy_diff AS avg_cumulative_submissions_accuracy_diff_diff,
    t2.avg_opp_avg_submissions_attempted - t3.avg_opp_avg_submissions_attempted AS avg_opp_avg_submissions_attempted_diff,
    t2.avg_avg_submissions_attempted_diff - t3.avg_avg_submissions_attempted_diff AS avg_avg_submissions_attempted_diff_diff,
    t2.avg_opp_cumulative_submissions_attempted - t3.avg_opp_cumulative_submissions_attempted AS avg_opp_cumulative_submissions_attempted_diff,
    t2.avg_cumulative_submissions_attempted_diff - t3.avg_cumulative_submissions_attempted_diff AS avg_cumulative_submissions_attempted_diff_diff,
    t2.avg_opp_avg_submissions_attempted_per_second - t3.avg_opp_avg_submissions_attempted_per_second AS avg_opp_avg_submissions_attempted_per_second_diff,
    t2.avg_avg_submissions_attempted_per_second_diff - t3.avg_avg_submissions_attempted_per_second_diff AS avg_avg_submissions_attempted_per_second_diff_diff,
    t2.avg_opp_cumulative_submissions_attempted_per_second - t3.avg_opp_cumulative_submissions_attempted_per_second AS avg_opp_cumulative_submissions_attempted_per_second_diff,
    t2.avg_cumulative_submissions_attempted_per_second_diff - t3.avg_cumulative_submissions_attempted_per_second_diff AS avg_cumulative_submissions_attempted_per_second_diff_diff,
    t2.avg_opp_avg_control_time_seconds - t3.avg_opp_avg_control_time_seconds AS avg_opp_avg_control_time_seconds_diff,
    t2.avg_avg_control_time_seconds_diff - t3.avg_avg_control_time_seconds_diff AS avg_avg_control_time_seconds_diff_diff,
    t2.avg_opp_cumulative_control_time_seconds - t3.avg_opp_cumulative_control_time_seconds AS avg_opp_cumulative_control_time_seconds_diff,
    t2.avg_cumulative_control_time_seconds_diff - t3.avg_cumulative_control_time_seconds_diff AS avg_cumulative_control_time_seconds_diff_diff,
    t2.avg_opp_avg_control_time_seconds_per_second - t3.avg_opp_avg_control_time_seconds_per_second AS avg_opp_avg_control_time_seconds_per_second_diff,
    t2.avg_avg_control_time_seconds_per_second_diff - t3.avg_avg_control_time_seconds_per_second_diff AS avg_avg_control_time_seconds_per_second_diff_diff,
    t2.avg_opp_cumulative_control_time_seconds_per_second - t3.avg_opp_cumulative_control_time_seconds_per_second AS avg_opp_cumulative_control_time_seconds_per_second_diff,
    t2.avg_cumulative_control_time_seconds_per_second_diff - t3.avg_cumulative_control_time_seconds_per_second_diff AS avg_cumulative_control_time_seconds_per_second_diff_diff,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
LEFT JOIN cte7 AS t2 ON t1.id = t2.bout_id AND t1.red_fighter_id = t2.fighter_id
LEFT JOIN cte7 AS t3 ON t1.id = t3.bout_id AND t1.blue_fighter_id = t3.fighter_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );