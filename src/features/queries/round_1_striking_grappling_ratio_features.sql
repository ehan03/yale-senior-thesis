WITH round_1_stats AS (
    SELECT bout_id,
        fighter_id,
        knockdowns_scored AS r1_knockdowns_scored,
        total_strikes_landed AS r1_total_strikes_landed,
        total_strikes_attempted AS r1_total_strikes_attempted,
        significant_strikes_landed AS r1_significant_strikes_landed,
        significant_strikes_attempted AS r1_significant_strikes_attempted,
        significant_strikes_head_landed AS r1_significant_strikes_head_landed,
        significant_strikes_head_attempted AS r1_significant_strikes_head_attempted,
        significant_strikes_body_landed AS r1_significant_strikes_body_landed,
        significant_strikes_body_attempted AS r1_significant_strikes_body_attempted,
        significant_strikes_leg_landed AS r1_significant_strikes_leg_landed,
        significant_strikes_leg_attempted AS r1_significant_strikes_leg_attempted,
        significant_strikes_distance_landed AS r1_significant_strikes_distance_landed,
        significant_strikes_distance_attempted AS r1_significant_strikes_distance_attempted,
        significant_strikes_clinch_landed AS r1_significant_strikes_clinch_landed,
        significant_strikes_clinch_attempted AS r1_significant_strikes_clinch_attempted,
        significant_strikes_ground_landed AS r1_significant_strikes_ground_landed,
        significant_strikes_ground_attempted AS r1_significant_strikes_ground_attempted,
        takedowns_landed AS r1_takedowns_landed,
        takedowns_attempted AS r1_takedowns_attempted,
        reversals_scored AS r1_reversals_scored,
        submissions_attempted AS r1_submissions_attempted,
        control_time_seconds AS r1_control_time_seconds,
        round_time_seconds AS r1_time_seconds
    FROM ufcstats_round_stats
    WHERE round_number = 1
),
cte1 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.opponent_id,
        t2.r1_knockdowns_scored,
        t2.r1_total_strikes_landed,
        t2.r1_total_strikes_attempted,
        t2.r1_significant_strikes_landed,
        t2.r1_significant_strikes_attempted,
        t2.r1_significant_strikes_head_landed,
        t2.r1_significant_strikes_head_attempted,
        t2.r1_significant_strikes_body_landed,
        t2.r1_significant_strikes_body_attempted,
        t2.r1_significant_strikes_leg_landed,
        t2.r1_significant_strikes_leg_attempted,
        t2.r1_significant_strikes_distance_landed,
        t2.r1_significant_strikes_distance_attempted,
        t2.r1_significant_strikes_clinch_landed,
        t2.r1_significant_strikes_clinch_attempted,
        t2.r1_significant_strikes_ground_landed,
        t2.r1_significant_strikes_ground_attempted,
        t2.r1_takedowns_landed,
        t2.r1_takedowns_attempted,
        t2.r1_reversals_scored,
        t2.r1_submissions_attempted,
        t2.r1_control_time_seconds,
        t3.r1_knockdowns_scored AS opp_r1_knockdowns_scored,
        t3.r1_total_strikes_landed AS opp_r1_total_strikes_landed,
        t3.r1_total_strikes_attempted AS opp_r1_total_strikes_attempted,
        t3.r1_significant_strikes_landed AS opp_r1_significant_strikes_landed,
        t3.r1_significant_strikes_attempted AS opp_r1_significant_strikes_attempted,
        t3.r1_significant_strikes_head_landed AS opp_r1_significant_strikes_head_landed,
        t3.r1_significant_strikes_head_attempted AS opp_r1_significant_strikes_head_attempted,
        t3.r1_significant_strikes_body_landed AS opp_r1_significant_strikes_body_landed,
        t3.r1_significant_strikes_body_attempted AS opp_r1_significant_strikes_body_attempted,
        t3.r1_significant_strikes_leg_landed AS opp_r1_significant_strikes_leg_landed,
        t3.r1_significant_strikes_leg_attempted AS opp_r1_significant_strikes_leg_attempted,
        t3.r1_significant_strikes_distance_landed AS opp_r1_significant_strikes_distance_landed,
        t3.r1_significant_strikes_distance_attempted AS opp_r1_significant_strikes_distance_attempted,
        t3.r1_significant_strikes_clinch_landed AS opp_r1_significant_strikes_clinch_landed,
        t3.r1_significant_strikes_clinch_attempted AS opp_r1_significant_strikes_clinch_attempted,
        t3.r1_significant_strikes_ground_landed AS opp_r1_significant_strikes_ground_landed,
        t3.r1_significant_strikes_ground_attempted AS opp_r1_significant_strikes_ground_attempted,
        t3.r1_takedowns_landed AS opp_r1_takedowns_landed,
        t3.r1_takedowns_attempted AS opp_r1_takedowns_attempted,
        t3.r1_reversals_scored AS opp_r1_reversals_scored,
        t3.r1_submissions_attempted AS opp_r1_submissions_attempted,
        t3.r1_control_time_seconds AS opp_r1_control_time_seconds,
        t2.r1_time_seconds AS r1_total_time_seconds
    FROM ufcstats_fighter_histories AS t1
        LEFT JOIN round_1_stats AS t2 ON t1.bout_id = t2.bout_id
        AND t1.fighter_id = t2.fighter_id
        LEFT JOIN round_1_stats AS t3 ON t1.bout_id = t3.bout_id
        AND t1.opponent_id = t3.fighter_id
),
cte1_temp AS (
    SELECT *
    FROM cte1
    WHERE bout_id IN (
            SELECT ufcstats_id
            FROM bout_mapping
        )
),
cte2 AS (
    SELECT t1.*,
        COALESCE(
            SUM(t1.r1_knockdowns_scored) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_knockdowns_scored,
        COALESCE(
            SUM(t1.r1_total_strikes_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_total_strikes_landed,
        COALESCE(
            SUM(t1.r1_total_strikes_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_total_strikes_attempted,
        COALESCE(
            SUM(t1.r1_significant_strikes_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_landed,
        COALESCE(
            SUM(t1.r1_significant_strikes_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_attempted,
        COALESCE(
            SUM(t1.r1_significant_strikes_head_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_head_landed,
        COALESCE(
            SUM(t1.r1_significant_strikes_head_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_head_attempted,
        COALESCE(
            SUM(t1.r1_significant_strikes_body_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_body_landed,
        COALESCE(
            SUM(t1.r1_significant_strikes_body_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_body_attempted,
        COALESCE(
            SUM(t1.r1_significant_strikes_leg_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_leg_landed,
        COALESCE(
            SUM(t1.r1_significant_strikes_leg_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_leg_attempted,
        COALESCE(
            SUM(t1.r1_significant_strikes_distance_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_distance_landed,
        COALESCE(
            SUM(t1.r1_significant_strikes_distance_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_distance_attempted,
        COALESCE(
            SUM(t1.r1_significant_strikes_clinch_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_clinch_landed,
        COALESCE(
            SUM(t1.r1_significant_strikes_clinch_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_clinch_attempted,
        COALESCE(
            SUM(t1.r1_significant_strikes_ground_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_ground_landed,
        COALESCE(
            SUM(t1.r1_significant_strikes_ground_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_significant_strikes_ground_attempted,
        COALESCE(
            SUM(t1.r1_takedowns_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_takedowns_landed,
        COALESCE(
            SUM(t1.r1_takedowns_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_takedowns_attempted,
        COALESCE(
            SUM(t1.r1_reversals_scored) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_reversals_scored,
        COALESCE(
            SUM(t1.r1_submissions_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_submissions_attempted,
        COALESCE(
            SUM(t1.r1_control_time_seconds) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_control_time_seconds,
        COALESCE(
            SUM(t1.opp_r1_knockdowns_scored) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_knockdowns_scored,
        COALESCE(
            SUM(t1.opp_r1_total_strikes_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_total_strikes_landed,
        COALESCE(
            SUM(t1.opp_r1_total_strikes_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_total_strikes_attempted,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_landed,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_attempted,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_head_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_head_landed,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_head_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_head_attempted,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_body_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_body_landed,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_body_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_body_attempted,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_leg_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_leg_landed,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_leg_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_leg_attempted,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_distance_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_distance_landed,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_distance_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_distance_attempted,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_clinch_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_clinch_landed,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_clinch_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_clinch_attempted,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_ground_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_ground_landed,
        COALESCE(
            SUM(t1.opp_r1_significant_strikes_ground_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_significant_strikes_ground_attempted,
        COALESCE(
            SUM(t1.opp_r1_takedowns_landed) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_takedowns_landed,
        COALESCE(
            SUM(t1.opp_r1_takedowns_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_takedowns_attempted,
        COALESCE(
            SUM(t1.opp_r1_reversals_scored) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_reversals_scored,
        COALESCE(
            SUM(t1.opp_r1_submissions_attempted) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_submissions_attempted,
        COALESCE(
            SUM(t1.opp_r1_control_time_seconds) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_opp_control_time_seconds,
        COALESCE(
            SUM(t1.r1_total_time_seconds) OVER (
                PARTITION BY t1.fighter_id
                ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
            ),
            0
        ) AS r1_cumulative_total_time_seconds
    FROM cte1_temp AS t1
),
cte3 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.opponent_id,
        AVG(r1_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored,
        r1_cumulative_knockdowns_scored AS cumulative_r1_knockdowns_scored,
        AVG(
            1.0 * r1_knockdowns_scored / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_second,
        1.0 * r1_cumulative_knockdowns_scored / r1_cumulative_total_time_seconds AS cumulative_r1_knockdowns_scored_per_second,
        AVG(
            1.0 * r1_knockdowns_scored / r1_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_strike_landed,
        1.0 * r1_cumulative_knockdowns_scored / r1_cumulative_total_strikes_landed AS cumulative_r1_knockdowns_scored_per_strike_landed,
        AVG(
            1.0 * r1_knockdowns_scored / r1_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_strike_attempted,
        1.0 * r1_cumulative_knockdowns_scored / r1_cumulative_total_strikes_attempted AS cumulative_r1_knockdowns_scored_per_strike_attempted,
        AVG(
            1.0 * r1_knockdowns_scored / r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_significant_strike_landed,
        1.0 * r1_cumulative_knockdowns_scored / r1_cumulative_significant_strikes_landed AS cumulative_r1_knockdowns_scored_per_significant_strike_landed,
        AVG(
            1.0 * r1_knockdowns_scored / r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_significant_strike_attempted,
        1.0 * r1_cumulative_knockdowns_scored / r1_cumulative_significant_strikes_attempted AS cumulative_r1_knockdowns_scored_per_significant_strike_attempted,
        AVG(
            1.0 * r1_knockdowns_scored / r1_significant_strikes_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_significant_strike_head_landed,
        1.0 * r1_cumulative_knockdowns_scored / r1_cumulative_significant_strikes_head_landed AS cumulative_r1_knockdowns_scored_per_significant_strike_head_landed,
        AVG(
            1.0 * r1_knockdowns_scored / r1_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_significant_strike_head_attempted,
        1.0 * r1_cumulative_knockdowns_scored / r1_cumulative_significant_strikes_head_attempted AS cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(r1_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_landed,
        r1_cumulative_total_strikes_landed AS cumulative_r1_total_strikes_landed,
        AVG(
            1.0 * r1_total_strikes_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_landed_per_second,
        1.0 * r1_cumulative_total_strikes_landed / r1_cumulative_total_time_seconds AS cumulative_r1_total_strikes_landed_per_second,
        AVG(
            1.0 * r1_total_strikes_landed / r1_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_accuracy,
        1.0 * r1_cumulative_total_strikes_landed / r1_cumulative_total_strikes_attempted AS cumulative_r1_total_strikes_accuracy,
        AVG(r1_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_attempted,
        r1_cumulative_total_strikes_attempted AS cumulative_r1_total_strikes_attempted,
        AVG(
            r1_total_strikes_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_attempted_per_second,
        1.0 * r1_cumulative_total_strikes_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_total_strikes_attempted_per_second,
        AVG(r1_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_landed,
        r1_cumulative_significant_strikes_landed AS cumulative_r1_significant_strikes_landed,
        AVG(
            1.0 * r1_significant_strikes_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_landed_per_second,
        1.0 * r1_cumulative_significant_strikes_landed / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_landed_per_second,
        AVG(
            1.0 * r1_significant_strikes_landed / r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_accuracy,
        1.0 * r1_cumulative_significant_strikes_landed / r1_cumulative_significant_strikes_attempted AS cumulative_r1_significant_strikes_accuracy,
        AVG(
            1.0 * r1_significant_strikes_landed / r1_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_landed_per_total_strikes_landed,
        1.0 * r1_cumulative_significant_strikes_landed / r1_cumulative_total_strikes_landed AS cumulative_r1_significant_strikes_landed_per_total_strikes_landed,
        AVG(r1_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_attempted,
        r1_cumulative_significant_strikes_attempted AS cumulative_r1_significant_strikes_attempted,
        AVG(
            r1_significant_strikes_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_attempted_per_second,
        1.0 * r1_cumulative_significant_strikes_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_attempted_per_second,
        AVG(
            1.0 * r1_significant_strikes_attempted / r1_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_attempted_per_total_strikes_attempted,
        1.0 * r1_cumulative_significant_strikes_attempted / r1_cumulative_total_strikes_attempted AS cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted,
        AVG(r1_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_landed,
        r1_cumulative_significant_strikes_head_landed AS cumulative_r1_significant_strikes_head_landed,
        AVG(
            1.0 * r1_significant_strikes_head_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_landed_per_second,
        1.0 * r1_cumulative_significant_strikes_head_landed / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_head_landed_per_second,
        AVG(
            1.0 * r1_significant_strikes_head_landed / r1_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_accuracy,
        1.0 * r1_cumulative_significant_strikes_head_landed / r1_cumulative_significant_strikes_head_attempted AS cumulative_r1_significant_strikes_head_accuracy,
        AVG(
            1.0 * r1_significant_strikes_head_landed / r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_significant_strikes_head_landed / r1_cumulative_significant_strikes_landed AS cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed,
        AVG(r1_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_attempted,
        r1_cumulative_significant_strikes_head_attempted AS cumulative_r1_significant_strikes_head_attempted,
        AVG(
            r1_significant_strikes_head_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_attempted_per_second,
        1.0 * r1_cumulative_significant_strikes_head_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_head_attempted_per_second,
        AVG(
            1.0 * r1_significant_strikes_head_attempted / r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_significant_strikes_head_attempted / r1_cumulative_significant_strikes_attempted AS cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted,
        AVG(r1_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_landed,
        r1_cumulative_significant_strikes_body_landed AS cumulative_r1_significant_strikes_body_landed,
        AVG(
            1.0 * r1_significant_strikes_body_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_landed_per_second,
        1.0 * r1_cumulative_significant_strikes_body_landed / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_body_landed_per_second,
        AVG(
            1.0 * r1_significant_strikes_body_landed / r1_significant_strikes_body_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_accuracy,
        1.0 * r1_cumulative_significant_strikes_body_landed / r1_cumulative_significant_strikes_body_attempted AS cumulative_r1_significant_strikes_body_accuracy,
        AVG(
            1.0 * r1_significant_strikes_body_landed / r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_significant_strikes_body_landed / r1_cumulative_significant_strikes_landed AS cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed,
        AVG(r1_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_attempted,
        r1_cumulative_significant_strikes_body_attempted AS cumulative_r1_significant_strikes_body_attempted,
        AVG(
            r1_significant_strikes_body_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_attempted_per_second,
        1.0 * r1_cumulative_significant_strikes_body_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_body_attempted_per_second,
        AVG(
            1.0 * r1_significant_strikes_body_attempted / r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_significant_strikes_body_attempted / r1_cumulative_significant_strikes_attempted AS cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted,
        AVG(r1_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_landed,
        r1_cumulative_significant_strikes_leg_landed AS cumulative_r1_significant_strikes_leg_landed,
        AVG(
            1.0 * r1_significant_strikes_leg_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_landed_per_second,
        1.0 * r1_cumulative_significant_strikes_leg_landed / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_leg_landed_per_second,
        AVG(
            1.0 * r1_significant_strikes_leg_landed / r1_significant_strikes_leg_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_accuracy,
        1.0 * r1_cumulative_significant_strikes_leg_landed / r1_cumulative_significant_strikes_leg_attempted AS cumulative_r1_significant_strikes_leg_accuracy,
        AVG(
            1.0 * r1_significant_strikes_leg_landed / r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_significant_strikes_leg_landed / r1_cumulative_significant_strikes_landed AS cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed,
        AVG(r1_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_attempted,
        r1_cumulative_significant_strikes_leg_attempted AS cumulative_r1_significant_strikes_leg_attempted,
        AVG(
            r1_significant_strikes_leg_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_attempted_per_second,
        1.0 * r1_cumulative_significant_strikes_leg_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_leg_attempted_per_second,
        AVG(
            1.0 * r1_significant_strikes_leg_attempted / r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_significant_strikes_leg_attempted / r1_cumulative_significant_strikes_attempted AS cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted,
        AVG(r1_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_landed,
        r1_cumulative_significant_strikes_distance_landed AS cumulative_r1_significant_strikes_distance_landed,
        AVG(
            1.0 * r1_significant_strikes_distance_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_landed_per_second,
        1.0 * r1_cumulative_significant_strikes_distance_landed / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_distance_landed_per_second,
        AVG(
            1.0 * r1_significant_strikes_distance_landed / r1_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_accuracy,
        1.0 * r1_cumulative_significant_strikes_distance_landed / r1_cumulative_significant_strikes_distance_attempted AS cumulative_r1_significant_strikes_distance_accuracy,
        AVG(
            1.0 * r1_significant_strikes_distance_landed / r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_significant_strikes_distance_landed / r1_cumulative_significant_strikes_landed AS cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed,
        AVG(r1_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_attempted,
        r1_cumulative_significant_strikes_distance_attempted AS cumulative_r1_significant_strikes_distance_attempted,
        AVG(
            r1_significant_strikes_distance_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_attempted_per_second,
        1.0 * r1_cumulative_significant_strikes_distance_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_distance_attempted_per_second,
        AVG(
            1.0 * r1_significant_strikes_distance_attempted / r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_significant_strikes_distance_attempted / r1_cumulative_significant_strikes_attempted AS cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted,
        AVG(r1_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_landed,
        r1_cumulative_significant_strikes_clinch_landed AS cumulative_r1_significant_strikes_clinch_landed,
        AVG(
            1.0 * r1_significant_strikes_clinch_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_landed_per_second,
        1.0 * r1_cumulative_significant_strikes_clinch_landed / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_clinch_landed_per_second,
        AVG(
            1.0 * r1_significant_strikes_clinch_landed / r1_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_accuracy,
        1.0 * r1_cumulative_significant_strikes_clinch_landed / r1_cumulative_significant_strikes_clinch_attempted AS cumulative_r1_significant_strikes_clinch_accuracy,
        AVG(
            1.0 * r1_significant_strikes_clinch_landed / r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_significant_strikes_clinch_landed / r1_cumulative_significant_strikes_landed AS cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed,
        AVG(r1_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_attempted,
        r1_cumulative_significant_strikes_clinch_attempted AS cumulative_r1_significant_strikes_clinch_attempted,
        AVG(
            r1_significant_strikes_clinch_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_attempted_per_second,
        1.0 * r1_cumulative_significant_strikes_clinch_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_clinch_attempted_per_second,
        AVG(
            1.0 * r1_significant_strikes_clinch_attempted / r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_significant_strikes_clinch_attempted / r1_cumulative_significant_strikes_attempted AS cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted,
        AVG(r1_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_landed,
        r1_cumulative_significant_strikes_ground_landed AS cumulative_r1_significant_strikes_ground_landed,
        AVG(
            1.0 * r1_significant_strikes_ground_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_landed_per_second,
        1.0 * r1_cumulative_significant_strikes_ground_landed / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_ground_landed_per_second,
        AVG(
            1.0 * r1_significant_strikes_ground_landed / r1_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_accuracy,
        1.0 * r1_cumulative_significant_strikes_ground_landed / r1_cumulative_significant_strikes_ground_attempted AS cumulative_r1_significant_strikes_ground_accuracy,
        AVG(
            1.0 * r1_significant_strikes_ground_landed / r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_significant_strikes_ground_landed / r1_cumulative_significant_strikes_landed AS cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed,
        AVG(r1_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_attempted,
        r1_cumulative_significant_strikes_ground_attempted AS cumulative_r1_significant_strikes_ground_attempted,
        AVG(
            r1_significant_strikes_ground_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_attempted_per_second,
        1.0 * r1_cumulative_significant_strikes_ground_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_significant_strikes_ground_attempted_per_second,
        AVG(
            1.0 * r1_significant_strikes_ground_attempted / r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_significant_strikes_ground_attempted / r1_cumulative_significant_strikes_attempted AS cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted,
        AVG(r1_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_landed,
        r1_cumulative_takedowns_landed AS cumulative_r1_takedowns_landed,
        AVG(
            1.0 * r1_takedowns_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_landed_per_second,
        1.0 * r1_cumulative_takedowns_landed / r1_cumulative_total_time_seconds AS cumulative_r1_takedowns_landed_per_second,
        AVG(
            1.0 * r1_takedowns_landed / r1_takedowns_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_accuracy,
        1.0 * r1_cumulative_takedowns_landed / r1_cumulative_takedowns_attempted AS cumulative_r1_takedowns_accuracy,
        AVG(r1_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_attempted,
        r1_cumulative_takedowns_attempted AS cumulative_r1_takedowns_attempted,
        AVG(
            1.0 * r1_takedowns_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_attempted_per_second,
        1.0 * r1_cumulative_takedowns_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_takedowns_attempted_per_second,
        AVG(r1_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_reversals_scored,
        r1_cumulative_reversals_scored AS cumulative_r1_reversals_scored,
        AVG(
            1.0 * r1_reversals_scored / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_reversals_scored_per_second,
        1.0 * r1_cumulative_reversals_scored / r1_cumulative_total_time_seconds AS cumulative_r1_reversals_scored_per_second,
        AVG(r1_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_submissions_attempted,
        r1_cumulative_submissions_attempted AS cumulative_r1_submissions_attempted,
        AVG(
            1.0 * r1_submissions_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_submissions_attempted_per_second,
        1.0 * r1_cumulative_submissions_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_submissions_attempted_per_second,
        AVG(r1_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_control_time_seconds,
        r1_cumulative_control_time_seconds AS cumulative_r1_control_time_seconds,
        AVG(
            1.0 * r1_control_time_seconds / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_control_time_seconds_per_second,
        1.0 * r1_cumulative_control_time_seconds / r1_cumulative_total_time_seconds AS cumulative_r1_control_time_seconds_per_second,
        AVG(opp_r1_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_knockdowns_scored,
        r1_cumulative_opp_knockdowns_scored AS cumulative_r1_opp_knockdowns_scored,
        AVG(
            1.0 * opp_r1_knockdowns_scored / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_knockdowns_scored_per_second,
        1.0 * r1_cumulative_opp_knockdowns_scored / r1_cumulative_total_time_seconds AS cumulative_r1_opp_knockdowns_scored_per_second,
        AVG(
            1.0 * opp_r1_knockdowns_scored / r1_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_knockdowns_scored_per_strike_landed,
        1.0 * r1_cumulative_opp_knockdowns_scored / r1_cumulative_total_strikes_landed AS cumulative_r1_opp_knockdowns_scored_per_strike_landed,
        AVG(
            1.0 * opp_r1_knockdowns_scored / r1_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_knockdowns_scored_per_strike_attempted,
        1.0 * r1_cumulative_opp_knockdowns_scored / r1_cumulative_total_strikes_attempted AS cumulative_r1_opp_knockdowns_scored_per_strike_attempted,
        AVG(
            1.0 * opp_r1_knockdowns_scored / r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_knockdowns_scored_per_significant_strike_landed,
        1.0 * r1_cumulative_opp_knockdowns_scored / r1_cumulative_significant_strikes_landed AS cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed,
        AVG(
            1.0 * opp_r1_knockdowns_scored / r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_knockdowns_scored_per_significant_strike_attempted,
        1.0 * r1_cumulative_opp_knockdowns_scored / r1_cumulative_significant_strikes_attempted AS cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted,
        AVG(
            1.0 * opp_r1_knockdowns_scored / r1_significant_strikes_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed,
        1.0 * r1_cumulative_opp_knockdowns_scored / r1_cumulative_significant_strikes_head_landed AS cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed,
        AVG(
            1.0 * opp_r1_knockdowns_scored / r1_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted,
        1.0 * r1_cumulative_opp_knockdowns_scored / r1_cumulative_significant_strikes_head_attempted AS cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(opp_r1_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_total_strikes_landed,
        r1_cumulative_opp_total_strikes_landed AS cumulative_r1_opp_total_strikes_landed,
        AVG(
            1.0 * opp_r1_total_strikes_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_total_strikes_landed_per_second,
        1.0 * r1_cumulative_opp_total_strikes_landed / r1_cumulative_total_time_seconds AS cumulative_r1_opp_total_strikes_landed_per_second,
        AVG(
            1.0 * opp_r1_total_strikes_landed / opp_r1_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_total_strikes_accuracy,
        1.0 * r1_cumulative_opp_total_strikes_landed / r1_cumulative_opp_total_strikes_attempted AS cumulative_r1_opp_total_strikes_accuracy,
        AVG(opp_r1_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_total_strikes_attempted,
        r1_cumulative_opp_total_strikes_attempted AS cumulative_r1_opp_total_strikes_attempted,
        AVG(
            opp_r1_total_strikes_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_total_strikes_attempted_per_second,
        1.0 * r1_cumulative_opp_total_strikes_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_total_strikes_attempted_per_second,
        AVG(opp_r1_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_landed,
        r1_cumulative_opp_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_landed,
        AVG(
            1.0 * opp_r1_significant_strikes_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_landed_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_landed / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_landed_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_landed / opp_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_accuracy,
        1.0 * r1_cumulative_opp_significant_strikes_landed / r1_cumulative_opp_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_accuracy,
        AVG(
            1.0 * opp_r1_significant_strikes_landed / opp_r1_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_landed_per_total_strikes_landed,
        1.0 * r1_cumulative_opp_significant_strikes_landed / r1_cumulative_opp_total_strikes_landed AS cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed,
        AVG(opp_r1_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_attempted,
        r1_cumulative_opp_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_attempted,
        AVG(
            opp_r1_significant_strikes_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_attempted_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_attempted_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_attempted / opp_r1_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted,
        1.0 * r1_cumulative_opp_significant_strikes_attempted / r1_cumulative_opp_total_strikes_attempted AS cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted,
        AVG(opp_r1_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_head_landed,
        r1_cumulative_opp_significant_strikes_head_landed AS cumulative_r1_opp_significant_strikes_head_landed,
        AVG(
            1.0 * opp_r1_significant_strikes_head_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_head_landed_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_head_landed / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_head_landed_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_head_landed / opp_r1_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_head_accuracy,
        1.0 * r1_cumulative_opp_significant_strikes_head_landed / r1_cumulative_opp_significant_strikes_head_attempted AS cumulative_r1_opp_significant_strikes_head_accuracy,
        AVG(
            1.0 * opp_r1_significant_strikes_head_landed / opp_r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_opp_significant_strikes_head_landed / r1_cumulative_opp_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed,
        AVG(opp_r1_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_head_attempted,
        r1_cumulative_opp_significant_strikes_head_attempted AS cumulative_r1_opp_significant_strikes_head_attempted,
        AVG(
            opp_r1_significant_strikes_head_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_head_attempted_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_head_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_head_attempted_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_head_attempted / opp_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_opp_significant_strikes_head_attempted / r1_cumulative_opp_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted,
        AVG(opp_r1_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_body_landed,
        r1_cumulative_opp_significant_strikes_body_landed AS cumulative_r1_opp_significant_strikes_body_landed,
        AVG(
            1.0 * opp_r1_significant_strikes_body_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_body_landed_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_body_landed / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_body_landed_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_body_landed / opp_r1_significant_strikes_body_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_body_accuracy,
        1.0 * r1_cumulative_opp_significant_strikes_body_landed / r1_cumulative_opp_significant_strikes_body_attempted AS cumulative_r1_opp_significant_strikes_body_accuracy,
        AVG(
            1.0 * opp_r1_significant_strikes_body_landed / opp_r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_opp_significant_strikes_body_landed / r1_cumulative_opp_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed,
        AVG(opp_r1_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_body_attempted,
        r1_cumulative_opp_significant_strikes_body_attempted AS cumulative_r1_opp_significant_strikes_body_attempted,
        AVG(
            opp_r1_significant_strikes_body_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_body_attempted_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_body_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_body_attempted_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_body_attempted / opp_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_opp_significant_strikes_body_attempted / r1_cumulative_opp_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted,
        AVG(opp_r1_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_leg_landed,
        r1_cumulative_opp_significant_strikes_leg_landed AS cumulative_r1_opp_significant_strikes_leg_landed,
        AVG(
            1.0 * opp_r1_significant_strikes_leg_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_leg_landed_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_leg_landed / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_leg_landed_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_leg_landed / opp_r1_significant_strikes_leg_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_leg_accuracy,
        1.0 * r1_cumulative_opp_significant_strikes_leg_landed / r1_cumulative_opp_significant_strikes_leg_attempted AS cumulative_r1_opp_significant_strikes_leg_accuracy,
        AVG(
            1.0 * opp_r1_significant_strikes_leg_landed / opp_r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_opp_significant_strikes_leg_landed / r1_cumulative_opp_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed,
        AVG(opp_r1_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_leg_attempted,
        r1_cumulative_opp_significant_strikes_leg_attempted AS cumulative_r1_opp_significant_strikes_leg_attempted,
        AVG(
            opp_r1_significant_strikes_leg_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_leg_attempted_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_leg_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_leg_attempted_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_leg_attempted / opp_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_opp_significant_strikes_leg_attempted / r1_cumulative_opp_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted,
        AVG(opp_r1_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_distance_landed,
        r1_cumulative_opp_significant_strikes_distance_landed AS cumulative_r1_opp_significant_strikes_distance_landed,
        AVG(
            1.0 * opp_r1_significant_strikes_distance_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_distance_landed_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_distance_landed / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_distance_landed_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_distance_landed / opp_r1_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_distance_accuracy,
        1.0 * r1_cumulative_opp_significant_strikes_distance_landed / r1_cumulative_opp_significant_strikes_distance_attempted AS cumulative_r1_opp_significant_strikes_distance_accuracy,
        AVG(
            1.0 * opp_r1_significant_strikes_distance_landed / opp_r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_opp_significant_strikes_distance_landed / r1_cumulative_opp_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed,
        AVG(opp_r1_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_distance_attempted,
        r1_cumulative_opp_significant_strikes_distance_attempted AS cumulative_r1_opp_significant_strikes_distance_attempted,
        AVG(
            opp_r1_significant_strikes_distance_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_distance_attempted_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_distance_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_distance_attempted_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_distance_attempted / opp_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_opp_significant_strikes_distance_attempted / r1_cumulative_opp_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted,
        AVG(opp_r1_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_clinch_landed,
        r1_cumulative_opp_significant_strikes_clinch_landed AS cumulative_r1_opp_significant_strikes_clinch_landed,
        AVG(
            1.0 * opp_r1_significant_strikes_clinch_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_clinch_landed_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_clinch_landed / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_clinch_landed_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_clinch_landed / opp_r1_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_clinch_accuracy,
        1.0 * r1_cumulative_opp_significant_strikes_clinch_landed / r1_cumulative_opp_significant_strikes_clinch_attempted AS cumulative_r1_opp_significant_strikes_clinch_accuracy,
        AVG(
            1.0 * opp_r1_significant_strikes_clinch_landed / opp_r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_opp_significant_strikes_clinch_landed / r1_cumulative_opp_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed,
        AVG(opp_r1_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_clinch_attempted,
        r1_cumulative_opp_significant_strikes_clinch_attempted AS cumulative_r1_opp_significant_strikes_clinch_attempted,
        AVG(
            opp_r1_significant_strikes_clinch_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_clinch_attempted_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_clinch_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_clinch_attempted_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_clinch_attempted / opp_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_opp_significant_strikes_clinch_attempted / r1_cumulative_opp_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted,
        AVG(opp_r1_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_ground_landed,
        r1_cumulative_opp_significant_strikes_ground_landed AS cumulative_r1_opp_significant_strikes_ground_landed,
        AVG(
            1.0 * opp_r1_significant_strikes_ground_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_ground_landed_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_ground_landed / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_ground_landed_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_ground_landed / opp_r1_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_ground_accuracy,
        1.0 * r1_cumulative_opp_significant_strikes_ground_landed / r1_cumulative_opp_significant_strikes_ground_attempted AS cumulative_r1_opp_significant_strikes_ground_accuracy,
        AVG(
            1.0 * opp_r1_significant_strikes_ground_landed / opp_r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed,
        1.0 * r1_cumulative_opp_significant_strikes_ground_landed / r1_cumulative_opp_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed,
        AVG(opp_r1_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_ground_attempted,
        r1_cumulative_opp_significant_strikes_ground_attempted AS cumulative_r1_opp_significant_strikes_ground_attempted,
        AVG(
            opp_r1_significant_strikes_ground_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_ground_attempted_per_second,
        1.0 * r1_cumulative_opp_significant_strikes_ground_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_significant_strikes_ground_attempted_per_second,
        AVG(
            1.0 * opp_r1_significant_strikes_ground_attempted / opp_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted,
        1.0 * r1_cumulative_opp_significant_strikes_ground_attempted / r1_cumulative_opp_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted,
        AVG(opp_r1_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_takedowns_landed,
        r1_cumulative_opp_takedowns_landed AS cumulative_r1_opp_takedowns_landed,
        AVG(
            1.0 * opp_r1_takedowns_landed / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_takedowns_landed_per_second,
        1.0 * r1_cumulative_opp_takedowns_landed / r1_cumulative_total_time_seconds AS cumulative_r1_opp_takedowns_landed_per_second,
        AVG(
            1.0 * opp_r1_takedowns_landed / opp_r1_takedowns_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_takedowns_accuracy,
        1.0 * r1_cumulative_opp_takedowns_landed / r1_cumulative_opp_takedowns_attempted AS cumulative_r1_opp_takedowns_accuracy,
        AVG(opp_r1_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_takedowns_attempted,
        r1_cumulative_opp_takedowns_attempted AS cumulative_r1_opp_takedowns_attempted,
        AVG(
            1.0 * opp_r1_takedowns_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_takedowns_attempted_per_second,
        1.0 * r1_cumulative_opp_takedowns_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_takedowns_attempted_per_second,
        AVG(opp_r1_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_reversals_scored,
        r1_cumulative_opp_reversals_scored AS cumulative_r1_opp_reversals_scored,
        AVG(
            1.0 * opp_r1_reversals_scored / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_reversals_scored_per_second,
        1.0 * r1_cumulative_opp_reversals_scored / r1_cumulative_total_time_seconds AS cumulative_r1_opp_reversals_scored_per_second,
        AVG(opp_r1_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_submissions_attempted,
        r1_cumulative_opp_submissions_attempted AS cumulative_r1_opp_submissions_attempted,
        AVG(
            1.0 * opp_r1_submissions_attempted / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_submissions_attempted_per_second,
        1.0 * r1_cumulative_opp_submissions_attempted / r1_cumulative_total_time_seconds AS cumulative_r1_opp_submissions_attempted_per_second,
        AVG(opp_r1_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_control_time_seconds,
        r1_cumulative_opp_control_time_seconds AS cumulative_r1_opp_control_time_seconds,
        AVG(
            1.0 * opp_r1_control_time_seconds / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_opp_control_time_seconds_per_second,
        1.0 * r1_cumulative_opp_control_time_seconds / r1_cumulative_total_time_seconds AS cumulative_r1_opp_control_time_seconds_per_second,
        AVG(r1_knockdowns_scored - opp_r1_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_diff,
        AVG(
            1.0 * (r1_knockdowns_scored - opp_r1_knockdowns_scored) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_second_diff,
        AVG(
            1.0 * (r1_knockdowns_scored / r1_total_strikes_landed) - 1.0 * (
                opp_r1_knockdowns_scored / opp_r1_total_strikes_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_strike_landed_diff,
        AVG(
            1.0 * (
                r1_knockdowns_scored / r1_total_strikes_attempted
            ) - 1.0 * (
                opp_r1_knockdowns_scored / opp_r1_total_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_strike_attempted_diff,
        AVG(
            1.0 * (
                r1_knockdowns_scored / r1_significant_strikes_landed
            ) - 1.0 * (
                opp_r1_knockdowns_scored / opp_r1_significant_strikes_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_significant_strike_landed_diff,
        AVG(
            1.0 * (
                r1_knockdowns_scored / r1_significant_strikes_attempted
            ) - 1.0 * (
                opp_r1_knockdowns_scored / opp_r1_significant_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_significant_strike_attempted_diff,
        AVG(
            1.0 * (
                r1_knockdowns_scored / r1_significant_strikes_head_landed
            ) - 1.0 * (
                opp_r1_knockdowns_scored / opp_r1_significant_strikes_head_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff,
        AVG(
            1.0 * (
                r1_knockdowns_scored / r1_significant_strikes_head_attempted
            ) - 1.0 * (
                opp_r1_knockdowns_scored / opp_r1_significant_strikes_head_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff,
        AVG(
            r1_total_strikes_landed - opp_r1_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_landed_diff,
        AVG(
            1.0 * (
                r1_total_strikes_landed - opp_r1_total_strikes_landed
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_landed_per_second_diff,
        AVG(
            1.0 * (
                r1_total_strikes_landed / r1_total_strikes_attempted
            ) - 1.0 * (
                opp_r1_total_strikes_landed / opp_r1_total_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_accuracy_diff,
        AVG(
            r1_total_strikes_attempted - opp_r1_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_attempted_diff,
        AVG(
            1.0 * (
                r1_total_strikes_attempted - opp_r1_total_strikes_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_total_strikes_attempted_per_second_diff,
        AVG(
            r1_significant_strikes_landed - opp_r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_landed_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_landed - opp_r1_significant_strikes_landed
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_landed_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_landed / r1_significant_strikes_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_landed / opp_r1_significant_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_accuracy_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_landed / r1_total_strikes_landed
            ) - 1.0 * (
                opp_r1_significant_strikes_landed / opp_r1_total_strikes_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_landed_per_total_strikes_landed_diff,
        AVG(
            r1_significant_strikes_attempted - opp_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_attempted_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_attempted - opp_r1_significant_strikes_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_attempted_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_attempted / r1_total_strikes_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_attempted / opp_r1_total_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff,
        AVG(
            r1_significant_strikes_head_landed - opp_r1_significant_strikes_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_landed_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_head_landed - opp_r1_significant_strikes_head_landed
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_landed_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_head_landed / r1_significant_strikes_head_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_head_landed / opp_r1_significant_strikes_head_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_accuracy_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_head_landed / r1_significant_strikes_landed
            ) - 1.0 * (
                opp_r1_significant_strikes_head_landed / opp_r1_significant_strikes_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff,
        AVG(
            r1_significant_strikes_head_attempted - opp_r1_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_attempted_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_head_attempted - opp_r1_significant_strikes_head_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_attempted_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_head_attempted / r1_significant_strikes_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_head_attempted / opp_r1_significant_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff,
        AVG(
            r1_significant_strikes_body_landed - opp_r1_significant_strikes_body_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_landed_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_body_landed - opp_r1_significant_strikes_body_landed
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_landed_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_body_landed / r1_significant_strikes_body_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_body_landed / opp_r1_significant_strikes_body_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_accuracy_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_body_landed / r1_significant_strikes_landed
            ) - 1.0 * (
                opp_r1_significant_strikes_body_landed / opp_r1_significant_strikes_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff,
        AVG(
            r1_significant_strikes_body_attempted - opp_r1_significant_strikes_body_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_attempted_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_body_attempted - opp_r1_significant_strikes_body_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_attempted_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_body_attempted / r1_significant_strikes_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_body_attempted / opp_r1_significant_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff,
        AVG(
            r1_significant_strikes_leg_landed - opp_r1_significant_strikes_leg_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_landed_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_leg_landed - opp_r1_significant_strikes_leg_landed
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_landed_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_leg_landed / r1_significant_strikes_leg_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_leg_landed / opp_r1_significant_strikes_leg_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_accuracy_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_leg_landed / r1_significant_strikes_landed
            ) - 1.0 * (
                opp_r1_significant_strikes_leg_landed / opp_r1_significant_strikes_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff,
        AVG(
            r1_significant_strikes_leg_attempted - opp_r1_significant_strikes_leg_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_attempted_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_leg_attempted - opp_r1_significant_strikes_leg_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_attempted_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_leg_attempted / r1_significant_strikes_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_leg_attempted / opp_r1_significant_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff,
        AVG(
            r1_significant_strikes_distance_landed - opp_r1_significant_strikes_distance_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_landed_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_distance_landed - opp_r1_significant_strikes_distance_landed
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_landed_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_distance_landed / r1_significant_strikes_distance_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_distance_landed / opp_r1_significant_strikes_distance_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_accuracy_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_distance_landed / r1_significant_strikes_landed
            ) - 1.0 * (
                opp_r1_significant_strikes_distance_landed / opp_r1_significant_strikes_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff,
        AVG(
            r1_significant_strikes_distance_attempted - opp_r1_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_attempted_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_distance_attempted - opp_r1_significant_strikes_distance_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_attempted_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_distance_attempted / r1_significant_strikes_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_distance_attempted / opp_r1_significant_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff,
        AVG(
            r1_significant_strikes_clinch_landed - opp_r1_significant_strikes_clinch_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_landed_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_clinch_landed - opp_r1_significant_strikes_clinch_landed
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_landed_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_clinch_landed / r1_significant_strikes_clinch_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_clinch_landed / opp_r1_significant_strikes_clinch_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_accuracy_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_clinch_landed / r1_significant_strikes_landed
            ) - 1.0 * (
                opp_r1_significant_strikes_clinch_landed / opp_r1_significant_strikes_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff,
        AVG(
            r1_significant_strikes_clinch_attempted - opp_r1_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_attempted_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_clinch_attempted - opp_r1_significant_strikes_clinch_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_attempted_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_clinch_attempted / r1_significant_strikes_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_clinch_attempted / opp_r1_significant_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff,
        AVG(
            r1_significant_strikes_ground_landed - opp_r1_significant_strikes_ground_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_landed_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_ground_landed - opp_r1_significant_strikes_ground_landed
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_landed_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_ground_landed / r1_significant_strikes_ground_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_ground_landed / opp_r1_significant_strikes_ground_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_accuracy_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_ground_landed / r1_significant_strikes_landed
            ) - 1.0 * (
                opp_r1_significant_strikes_ground_landed / opp_r1_significant_strikes_landed
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff,
        AVG(
            r1_significant_strikes_ground_attempted - opp_r1_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_attempted_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_ground_attempted - opp_r1_significant_strikes_ground_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_attempted_per_second_diff,
        AVG(
            1.0 * (
                r1_significant_strikes_ground_attempted / r1_significant_strikes_attempted
            ) - 1.0 * (
                opp_r1_significant_strikes_ground_attempted / opp_r1_significant_strikes_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff,
        AVG(r1_takedowns_landed - opp_r1_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_landed_diff,
        AVG(
            1.0 * (r1_takedowns_landed - opp_r1_takedowns_landed) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_landed_per_second_diff,
        AVG(
            1.0 * (r1_takedowns_landed / r1_takedowns_attempted) - 1.0 * (
                opp_r1_takedowns_landed / opp_r1_takedowns_attempted
            )
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_accuracy_diff,
        AVG(
            r1_takedowns_attempted - opp_r1_takedowns_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_attempted_diff,
        AVG(
            1.0 * (
                r1_takedowns_attempted - opp_r1_takedowns_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_takedowns_attempted_per_second_diff,
        AVG(r1_reversals_scored - opp_r1_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_reversals_scored_diff,
        AVG(
            1.0 * (r1_reversals_scored - opp_r1_reversals_scored) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_reversals_scored_per_second_diff,
        AVG(
            r1_submissions_attempted - opp_r1_submissions_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_submissions_attempted_diff,
        AVG(
            1.0 * (
                r1_submissions_attempted - opp_r1_submissions_attempted
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_submissions_attempted_per_second_diff,
        AVG(
            r1_control_time_seconds - opp_r1_control_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_control_time_seconds_diff,
        AVG(
            1.0 * (
                r1_control_time_seconds - opp_r1_control_time_seconds
            ) / r1_total_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_r1_control_time_seconds_per_second_diff
    FROM cte2 t1
),
cte4 AS (
    SELECT t1.*,
        AVG(t2.avg_r1_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_r1_knockdowns_scored,
        AVG(
            t1.avg_r1_knockdowns_scored - t2.avg_r1_knockdowns_scored
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_diff,
        AVG(t2.cumulative_r1_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_knockdowns_scored,
        AVG(
            t1.cumulative_r1_knockdowns_scored - t2.cumulative_r1_knockdowns_scored
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_knockdowns_scored_diff,
        AVG(t2.avg_r1_knockdowns_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_second,
        AVG(
            t1.avg_r1_knockdowns_scored_per_second - t2.avg_r1_knockdowns_scored_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_second_diff,
        AVG(t2.cumulative_r1_knockdowns_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_knockdowns_scored_per_second,
        AVG(
            t1.cumulative_r1_knockdowns_scored_per_second - t2.cumulative_r1_knockdowns_scored_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_knockdowns_scored_per_second_diff,
        AVG(t2.avg_r1_knockdowns_scored_per_strike_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_strike_landed,
        AVG(
            t1.avg_r1_knockdowns_scored_per_strike_landed - t2.avg_r1_knockdowns_scored_per_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_strike_landed_diff,
        AVG(
            t2.cumulative_r1_knockdowns_scored_per_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_knockdowns_scored_per_strike_landed,
        AVG(
            t1.cumulative_r1_knockdowns_scored_per_strike_landed - t2.cumulative_r1_knockdowns_scored_per_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_knockdowns_scored_per_strike_landed_diff,
        AVG(t2.avg_r1_knockdowns_scored_per_strike_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_strike_attempted,
        AVG(
            t1.avg_r1_knockdowns_scored_per_strike_attempted - t2.avg_r1_knockdowns_scored_per_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_strike_attempted_diff,
        AVG(
            t2.cumulative_r1_knockdowns_scored_per_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_knockdowns_scored_per_strike_attempted,
        AVG(
            t1.cumulative_r1_knockdowns_scored_per_strike_attempted - t2.cumulative_r1_knockdowns_scored_per_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_knockdowns_scored_per_strike_attempted_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_significant_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_landed,
        AVG(
            t1.avg_r1_knockdowns_scored_per_significant_strike_landed - t2.avg_r1_knockdowns_scored_per_significant_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_significant_strike_landed_diff,
        AVG(
            t2.cumulative_r1_knockdowns_scored_per_significant_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_landed,
        AVG(
            t1.cumulative_r1_knockdowns_scored_per_significant_strike_landed - t2.cumulative_r1_knockdowns_scored_per_significant_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_knockdowns_scored_per_significant_strike_landed_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_significant_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_attempted,
        AVG(
            t1.avg_r1_knockdowns_scored_per_significant_strike_attempted - t2.avg_r1_knockdowns_scored_per_significant_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff,
        AVG(
            t2.cumulative_r1_knockdowns_scored_per_significant_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_attempted,
        AVG(
            t1.cumulative_r1_knockdowns_scored_per_significant_strike_attempted - t2.cumulative_r1_knockdowns_scored_per_significant_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_knockdowns_scored_per_significant_strike_attempted_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_significant_strike_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_landed,
        AVG(
            t1.avg_r1_knockdowns_scored_per_significant_strike_head_landed - t2.avg_r1_knockdowns_scored_per_significant_strike_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff,
        AVG(
            t2.cumulative_r1_knockdowns_scored_per_significant_strike_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_head_landed,
        AVG(
            t1.cumulative_r1_knockdowns_scored_per_significant_strike_head_landed - t2.cumulative_r1_knockdowns_scored_per_significant_strike_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_knockdowns_scored_per_significant_strike_head_landed_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_significant_strike_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(
            t1.avg_r1_knockdowns_scored_per_significant_strike_head_attempted - t2.avg_r1_knockdowns_scored_per_significant_strike_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff,
        AVG(
            t2.cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(
            t1.cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted - t2.cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted_diff,
        AVG(t2.avg_r1_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_landed,
        AVG(
            t1.avg_r1_total_strikes_landed - t2.avg_r1_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_landed_diff,
        AVG(t2.cumulative_r1_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_total_strikes_landed,
        AVG(
            t1.cumulative_r1_total_strikes_landed - t2.cumulative_r1_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_total_strikes_landed_diff,
        AVG(t2.avg_r1_total_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_landed_per_second,
        AVG(
            t1.avg_r1_total_strikes_landed_per_second - t2.avg_r1_total_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_landed_per_second_diff,
        AVG(t2.cumulative_r1_total_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_total_strikes_landed_per_second,
        AVG(
            t1.cumulative_r1_total_strikes_landed_per_second - t2.cumulative_r1_total_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_total_strikes_landed_per_second_diff,
        AVG(t2.avg_r1_total_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_accuracy,
        AVG(
            t1.avg_r1_total_strikes_accuracy - t2.avg_r1_total_strikes_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_accuracy_diff,
        AVG(t2.cumulative_r1_total_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_total_strikes_accuracy,
        AVG(
            t1.cumulative_r1_total_strikes_accuracy - t2.cumulative_r1_total_strikes_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_total_strikes_accuracy_diff,
        AVG(t2.avg_r1_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_attempted,
        AVG(
            t1.avg_r1_total_strikes_attempted - t2.avg_r1_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_attempted_diff,
        AVG(t2.cumulative_r1_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_total_strikes_attempted,
        AVG(
            t1.cumulative_r1_total_strikes_attempted - t2.cumulative_r1_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_total_strikes_attempted_diff,
        AVG(t2.avg_r1_total_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_attempted_per_second,
        AVG(
            t1.avg_r1_total_strikes_attempted_per_second - t2.avg_r1_total_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_total_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_total_strikes_attempted_per_second,
        AVG(
            t1.cumulative_r1_total_strikes_attempted_per_second - t2.cumulative_r1_total_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_total_strikes_attempted_per_second_diff,
        AVG(t2.avg_r1_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_landed,
        AVG(
            t1.avg_r1_significant_strikes_landed - t2.avg_r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_landed_diff,
        AVG(t2.cumulative_r1_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_landed - t2.cumulative_r1_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_landed_diff,
        AVG(t2.avg_r1_significant_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_landed_per_second,
        AVG(
            t1.avg_r1_significant_strikes_landed_per_second - t2.avg_r1_significant_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_landed_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_landed_per_second - t2.cumulative_r1_significant_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_landed_per_second_diff,
        AVG(t2.avg_r1_significant_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_accuracy,
        AVG(
            t1.avg_r1_significant_strikes_accuracy - t2.avg_r1_significant_strikes_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_accuracy_diff,
        AVG(t2.cumulative_r1_significant_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_accuracy,
        AVG(
            t1.cumulative_r1_significant_strikes_accuracy - t2.cumulative_r1_significant_strikes_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_accuracy_diff,
        AVG(
            t2.avg_r1_significant_strikes_landed_per_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_landed_per_total_strikes_landed,
        AVG(
            t1.avg_r1_significant_strikes_landed_per_total_strikes_landed - t2.avg_r1_significant_strikes_landed_per_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_landed_per_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_landed_per_total_strikes_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_landed_per_total_strikes_landed - t2.cumulative_r1_significant_strikes_landed_per_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_landed_per_total_strikes_landed_diff,
        AVG(t2.avg_r1_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_attempted,
        AVG(
            t1.avg_r1_significant_strikes_attempted - t2.avg_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_attempted_diff,
        AVG(t2.cumulative_r1_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_attempted - t2.cumulative_r1_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_attempted_diff,
        AVG(
            t2.avg_r1_significant_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_attempted_per_second,
        AVG(
            t1.avg_r1_significant_strikes_attempted_per_second - t2.avg_r1_significant_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_attempted_per_second,
        AVG(
            t2.avg_r1_significant_strikes_attempted_per_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_attempted_per_total_strikes_attempted,
        AVG(
            t1.avg_r1_significant_strikes_attempted_per_total_strikes_attempted - t2.avg_r1_significant_strikes_attempted_per_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted - t2.cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted_diff,
        AVG(t2.avg_r1_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_landed,
        AVG(
            t1.avg_r1_significant_strikes_head_landed - t2.avg_r1_significant_strikes_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_landed_diff,
        AVG(t2.cumulative_r1_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_head_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_head_landed - t2.cumulative_r1_significant_strikes_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_head_landed_diff,
        AVG(
            t2.avg_r1_significant_strikes_head_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_landed_per_second,
        AVG(
            t1.avg_r1_significant_strikes_head_landed_per_second - t2.avg_r1_significant_strikes_head_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_head_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_head_landed_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_head_landed_per_second - t2.cumulative_r1_significant_strikes_head_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_head_landed_per_second_diff,
        AVG(t2.avg_r1_significant_strikes_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_accuracy,
        AVG(
            t1.avg_r1_significant_strikes_head_accuracy - t2.avg_r1_significant_strikes_head_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_accuracy_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_head_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_head_accuracy,
        AVG(
            t1.cumulative_r1_significant_strikes_head_accuracy - t2.cumulative_r1_significant_strikes_head_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_head_accuracy_diff,
        AVG(
            t2.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed - t2.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed - t2.cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff,
        AVG(t2.avg_r1_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_attempted,
        AVG(
            t1.avg_r1_significant_strikes_head_attempted - t2.avg_r1_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_head_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_head_attempted - t2.cumulative_r1_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_head_attempted_diff,
        AVG(
            t2.avg_r1_significant_strikes_head_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_attempted_per_second,
        AVG(
            t1.avg_r1_significant_strikes_head_attempted_per_second - t2.avg_r1_significant_strikes_head_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_head_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_head_attempted_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_head_attempted_per_second - t2.cumulative_r1_significant_strikes_head_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_head_attempted_per_second_diff,
        AVG(
            t2.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted - t2.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted - t2.cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_landed,
        AVG(
            t1.avg_r1_significant_strikes_body_landed - t2.avg_r1_significant_strikes_body_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_landed_diff,
        AVG(t2.cumulative_r1_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_body_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_body_landed - t2.cumulative_r1_significant_strikes_body_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_body_landed_diff,
        AVG(
            t2.avg_r1_significant_strikes_body_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_landed_per_second,
        AVG(
            t1.avg_r1_significant_strikes_body_landed_per_second - t2.avg_r1_significant_strikes_body_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_body_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_body_landed_per_second,
        AVG(t2.avg_r1_significant_strikes_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_accuracy,
        AVG(
            t1.avg_r1_significant_strikes_body_accuracy - t2.avg_r1_significant_strikes_body_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_accuracy_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_body_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_body_accuracy,
        AVG(
            t1.cumulative_r1_significant_strikes_body_accuracy - t2.cumulative_r1_significant_strikes_body_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_body_accuracy_diff,
        AVG(
            t2.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed - t2.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed - t2.cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff,
        AVG(t2.avg_r1_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_attempted,
        AVG(
            t1.avg_r1_significant_strikes_body_attempted - t2.avg_r1_significant_strikes_body_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_body_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_body_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_body_attempted - t2.cumulative_r1_significant_strikes_body_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_body_attempted_diff,
        AVG(
            t2.avg_r1_significant_strikes_body_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_attempted_per_second,
        AVG(
            t1.avg_r1_significant_strikes_body_attempted_per_second - t2.avg_r1_significant_strikes_body_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_body_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_body_attempted_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_body_attempted_per_second - t2.cumulative_r1_significant_strikes_body_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_body_attempted_per_second_diff,
        AVG(
            t2.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted - t2.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted - t2.cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_landed,
        AVG(
            t1.avg_r1_significant_strikes_leg_landed - t2.avg_r1_significant_strikes_leg_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_landed_diff,
        AVG(t2.cumulative_r1_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_leg_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_leg_landed - t2.cumulative_r1_significant_strikes_leg_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_leg_landed_diff,
        AVG(
            t2.avg_r1_significant_strikes_leg_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_landed_per_second,
        AVG(
            t1.avg_r1_significant_strikes_leg_landed_per_second - t2.avg_r1_significant_strikes_leg_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_leg_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_leg_landed_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_leg_landed_per_second - t2.cumulative_r1_significant_strikes_leg_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_leg_landed_per_second_diff,
        AVG(t2.avg_r1_significant_strikes_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_accuracy,
        AVG(
            t1.avg_r1_significant_strikes_leg_accuracy - t2.avg_r1_significant_strikes_leg_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_accuracy_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_leg_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_leg_accuracy,
        AVG(
            t1.cumulative_r1_significant_strikes_leg_accuracy - t2.cumulative_r1_significant_strikes_leg_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_leg_accuracy_diff,
        AVG(
            t2.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed - t2.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed - t2.cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff,
        AVG(t2.avg_r1_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_attempted,
        AVG(
            t1.avg_r1_significant_strikes_leg_attempted - t2.avg_r1_significant_strikes_leg_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_leg_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_leg_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_leg_attempted - t2.cumulative_r1_significant_strikes_leg_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_leg_attempted_diff,
        AVG(
            t2.avg_r1_significant_strikes_leg_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_attempted_per_second,
        AVG(
            t1.avg_r1_significant_strikes_leg_attempted_per_second - t2.avg_r1_significant_strikes_leg_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_leg_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_leg_attempted_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_leg_attempted_per_second - t2.cumulative_r1_significant_strikes_leg_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_leg_attempted_per_second_diff,
        AVG(
            t2.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted - t2.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted - t2.cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_significant_strikes_distance_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_landed,
        AVG(
            t1.avg_r1_significant_strikes_distance_landed - t2.avg_r1_significant_strikes_distance_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_distance_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_distance_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_distance_landed - t2.cumulative_r1_significant_strikes_distance_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_distance_landed_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_landed_per_second,
        AVG(
            t1.avg_r1_significant_strikes_distance_landed_per_second - t2.avg_r1_significant_strikes_distance_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_distance_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_distance_landed_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_distance_landed_per_second - t2.cumulative_r1_significant_strikes_distance_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_distance_landed_per_second_diff,
        AVG(t2.avg_r1_significant_strikes_distance_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_accuracy,
        AVG(
            t1.avg_r1_significant_strikes_distance_accuracy - t2.avg_r1_significant_strikes_distance_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_accuracy_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_distance_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_distance_accuracy,
        AVG(
            t1.cumulative_r1_significant_strikes_distance_accuracy - t2.cumulative_r1_significant_strikes_distance_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_distance_accuracy_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed - t2.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed - t2.cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff,
        AVG(t2.avg_r1_significant_strikes_distance_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_attempted,
        AVG(
            t1.avg_r1_significant_strikes_distance_attempted - t2.avg_r1_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_distance_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_distance_attempted - t2.cumulative_r1_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_distance_attempted_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_attempted_per_second,
        AVG(
            t1.avg_r1_significant_strikes_distance_attempted_per_second - t2.avg_r1_significant_strikes_distance_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_distance_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_distance_attempted_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_distance_attempted_per_second - t2.cumulative_r1_significant_strikes_distance_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_distance_attempted_per_second_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted - t2.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted - t2.cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_landed,
        AVG(
            t1.avg_r1_significant_strikes_clinch_landed - t2.avg_r1_significant_strikes_clinch_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_clinch_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_clinch_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_clinch_landed - t2.cumulative_r1_significant_strikes_clinch_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_clinch_landed_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_landed_per_second,
        AVG(
            t1.avg_r1_significant_strikes_clinch_landed_per_second - t2.avg_r1_significant_strikes_clinch_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_clinch_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_clinch_landed_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_clinch_landed_per_second - t2.cumulative_r1_significant_strikes_clinch_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_clinch_landed_per_second_diff,
        AVG(t2.avg_r1_significant_strikes_clinch_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_accuracy,
        AVG(
            t1.avg_r1_significant_strikes_clinch_accuracy - t2.avg_r1_significant_strikes_clinch_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_accuracy_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_clinch_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_clinch_accuracy,
        AVG(
            t1.cumulative_r1_significant_strikes_clinch_accuracy - t2.cumulative_r1_significant_strikes_clinch_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_clinch_accuracy_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed - t2.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed - t2.cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff,
        AVG(t2.avg_r1_significant_strikes_clinch_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_attempted,
        AVG(
            t1.avg_r1_significant_strikes_clinch_attempted - t2.avg_r1_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_clinch_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_clinch_attempted - t2.cumulative_r1_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_clinch_attempted_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_attempted_per_second,
        AVG(
            t1.avg_r1_significant_strikes_clinch_attempted_per_second - t2.avg_r1_significant_strikes_clinch_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_clinch_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_clinch_attempted_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_clinch_attempted_per_second - t2.cumulative_r1_significant_strikes_clinch_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_clinch_attempted_per_second_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted - t2.avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted - t2.cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_landed,
        AVG(
            t1.avg_r1_significant_strikes_ground_landed - t2.avg_r1_significant_strikes_ground_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_ground_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_ground_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_ground_landed - t2.cumulative_r1_significant_strikes_ground_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_ground_landed_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_landed_per_second,
        AVG(
            t1.avg_r1_significant_strikes_ground_landed_per_second - t2.avg_r1_significant_strikes_ground_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_ground_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_ground_landed_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_ground_landed_per_second - t2.cumulative_r1_significant_strikes_ground_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_ground_landed_per_second_diff,
        AVG(t2.avg_r1_significant_strikes_ground_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_accuracy,
        AVG(
            t1.avg_r1_significant_strikes_ground_accuracy - t2.avg_r1_significant_strikes_ground_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_accuracy_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_ground_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_ground_accuracy,
        AVG(
            t1.cumulative_r1_significant_strikes_ground_accuracy - t2.cumulative_r1_significant_strikes_ground_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_ground_accuracy_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed - t2.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed - t2.cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff,
        AVG(t2.avg_r1_significant_strikes_ground_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_attempted,
        AVG(
            t1.avg_r1_significant_strikes_ground_attempted - t2.avg_r1_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_ground_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_ground_attempted - t2.cumulative_r1_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_ground_attempted_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_attempted_per_second,
        AVG(
            t1.avg_r1_significant_strikes_ground_attempted_per_second - t2.avg_r1_significant_strikes_ground_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_ground_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_ground_attempted_per_second,
        AVG(
            t1.cumulative_r1_significant_strikes_ground_attempted_per_second - t2.cumulative_r1_significant_strikes_ground_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_ground_attempted_per_second_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted - t2.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted - t2.cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_landed,
        AVG(
            t1.avg_r1_takedowns_landed - t2.avg_r1_takedowns_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_landed_diff,
        AVG(t2.cumulative_r1_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_takedowns_landed,
        AVG(
            t1.cumulative_r1_takedowns_landed - t2.cumulative_r1_takedowns_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_takedowns_landed_diff,
        AVG(t2.avg_r1_takedowns_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_landed_per_second,
        AVG(
            t1.avg_r1_takedowns_landed_per_second - t2.avg_r1_takedowns_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_landed_per_second_diff,
        AVG(t2.cumulative_r1_takedowns_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_takedowns_landed_per_second,
        AVG(
            t1.cumulative_r1_takedowns_landed_per_second - t2.cumulative_r1_takedowns_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_takedowns_landed_per_second_diff,
        AVG(t2.avg_r1_takedowns_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_accuracy,
        AVG(
            t1.avg_r1_takedowns_accuracy - t2.avg_r1_takedowns_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_accuracy_diff,
        AVG(t2.cumulative_r1_takedowns_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_takedowns_accuracy,
        AVG(
            t1.cumulative_r1_takedowns_accuracy - t2.cumulative_r1_takedowns_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_takedowns_accuracy_diff,
        AVG(t2.avg_r1_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_attempted,
        AVG(
            t1.avg_r1_takedowns_attempted - t2.avg_r1_takedowns_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_attempted_diff,
        AVG(t2.cumulative_r1_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_takedowns_attempted,
        AVG(
            t1.cumulative_r1_takedowns_attempted - t2.cumulative_r1_takedowns_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_takedowns_attempted_diff,
        AVG(t2.avg_r1_takedowns_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_attempted_per_second,
        AVG(
            t1.avg_r1_takedowns_attempted_per_second - t2.avg_r1_takedowns_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_attempted_per_second_diff,
        AVG(t2.cumulative_r1_takedowns_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_takedowns_attempted_per_second,
        AVG(
            t1.cumulative_r1_takedowns_attempted_per_second - t2.cumulative_r1_takedowns_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_takedowns_attempted_per_second_diff,
        AVG(t2.avg_r1_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_reversals_scored,
        AVG(
            t1.avg_r1_reversals_scored - t2.avg_r1_reversals_scored
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_reversals_scored_diff,
        AVG(t2.cumulative_r1_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_reversals_scored,
        AVG(
            t1.cumulative_r1_reversals_scored - t2.cumulative_r1_reversals_scored
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_reversals_scored_diff,
        AVG(t2.avg_r1_reversals_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_reversals_scored_per_second,
        AVG(
            t1.avg_r1_reversals_scored_per_second - t2.avg_r1_reversals_scored_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_reversals_scored_per_second_diff,
        AVG(t2.cumulative_r1_reversals_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_reversals_scored_per_second,
        AVG(
            t1.cumulative_r1_reversals_scored_per_second - t2.cumulative_r1_reversals_scored_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_reversals_scored_per_second_diff,
        AVG(t2.avg_r1_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_submissions_attempted,
        AVG(
            t1.avg_r1_submissions_attempted - t2.avg_r1_submissions_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_submissions_attempted_diff,
        AVG(t2.cumulative_r1_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_submissions_attempted,
        AVG(
            t1.cumulative_r1_submissions_attempted - t2.cumulative_r1_submissions_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_submissions_attempted_diff,
        AVG(t2.avg_r1_submissions_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_submissions_attempted_per_second,
        AVG(
            t1.avg_r1_submissions_attempted_per_second - t2.avg_r1_submissions_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_submissions_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_submissions_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_submissions_attempted_per_second,
        AVG(
            t1.cumulative_r1_submissions_attempted_per_second - t2.cumulative_r1_submissions_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_submissions_attempted_per_second_diff,
        AVG(t2.avg_r1_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_control_time_seconds,
        AVG(
            t1.avg_r1_control_time_seconds - t2.avg_r1_control_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_control_time_seconds_diff,
        AVG(t2.cumulative_r1_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_control_time_seconds,
        AVG(
            t1.cumulative_r1_control_time_seconds - t2.cumulative_r1_control_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_control_time_seconds_diff,
        AVG(t2.avg_r1_control_time_seconds_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_control_time_seconds_per_second,
        AVG(
            t1.avg_r1_control_time_seconds_per_second - t2.avg_r1_control_time_seconds_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_control_time_seconds_per_second_diff,
        AVG(t2.cumulative_r1_control_time_seconds_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_control_time_seconds_per_second,
        AVG(
            t1.cumulative_r1_control_time_seconds_per_second - t2.cumulative_r1_control_time_seconds_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_control_time_seconds_per_second_diff,
        AVG(t2.avg_r1_opp_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_knockdowns_scored,
        AVG(
            t1.avg_r1_opp_knockdowns_scored - t2.avg_r1_opp_knockdowns_scored
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_knockdowns_scored_diff,
        AVG(t2.cumulative_r1_opp_knockdowns_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_knockdowns_scored,
        AVG(
            t1.cumulative_r1_opp_knockdowns_scored - t2.cumulative_r1_opp_knockdowns_scored
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_knockdowns_scored_diff,
        AVG(t2.avg_r1_opp_knockdowns_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_knockdowns_scored_per_second,
        AVG(
            t1.avg_r1_opp_knockdowns_scored_per_second - t2.avg_r1_opp_knockdowns_scored_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_knockdowns_scored_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_knockdowns_scored_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_second,
        AVG(
            t1.cumulative_r1_opp_knockdowns_scored_per_second - t2.cumulative_r1_opp_knockdowns_scored_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_knockdowns_scored_per_second_diff,
        AVG(
            t2.avg_r1_opp_knockdowns_scored_per_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_knockdowns_scored_per_strike_landed,
        AVG(
            t1.avg_r1_opp_knockdowns_scored_per_strike_landed - t2.avg_r1_opp_knockdowns_scored_per_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_knockdowns_scored_per_strike_landed_diff,
        AVG(
            t2.cumulative_r1_opp_knockdowns_scored_per_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_strike_landed,
        AVG(
            t1.cumulative_r1_opp_knockdowns_scored_per_strike_landed - t2.cumulative_r1_opp_knockdowns_scored_per_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_knockdowns_scored_per_strike_landed_diff,
        AVG(
            t2.avg_r1_opp_knockdowns_scored_per_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_knockdowns_scored_per_strike_attempted,
        AVG(
            t1.avg_r1_opp_knockdowns_scored_per_strike_attempted - t2.avg_r1_opp_knockdowns_scored_per_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_knockdowns_scored_per_strike_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_knockdowns_scored_per_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_strike_attempted,
        AVG(
            t1.cumulative_r1_opp_knockdowns_scored_per_strike_attempted - t2.cumulative_r1_opp_knockdowns_scored_per_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_knockdowns_scored_per_strike_attempted_diff,
        AVG(
            t2.avg_r1_opp_knockdowns_scored_per_significant_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_landed,
        AVG(
            t1.avg_r1_opp_knockdowns_scored_per_significant_strike_landed - t2.avg_r1_opp_knockdowns_scored_per_significant_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_knockdowns_scored_per_significant_strike_landed_diff,
        AVG(
            t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed,
        AVG(
            t1.cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed - t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed_diff,
        AVG(
            t2.avg_r1_opp_knockdowns_scored_per_significant_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_attempted,
        AVG(
            t1.avg_r1_opp_knockdowns_scored_per_significant_strike_attempted - t2.avg_r1_opp_knockdowns_scored_per_significant_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_knockdowns_scored_per_significant_strike_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted,
        AVG(
            t1.cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted - t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted_diff,
        AVG(
            t2.avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed,
        AVG(
            t1.avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed - t2.avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed_diff,
        AVG(
            t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed,
        AVG(
            t1.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed - t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed_diff,
        AVG(
            t2.avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(
            t1.avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted - t2.avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted,
        AVG(
            t1.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted - t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_diff,
        AVG(t2.avg_r1_opp_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_total_strikes_landed,
        AVG(
            t1.avg_r1_opp_total_strikes_landed - t2.avg_r1_opp_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_total_strikes_landed_diff,
        AVG(t2.cumulative_r1_opp_total_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_total_strikes_landed,
        AVG(
            t1.cumulative_r1_opp_total_strikes_landed - t2.cumulative_r1_opp_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_total_strikes_landed_diff,
        AVG(t2.avg_r1_opp_total_strikes_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_total_strikes_landed_per_second,
        AVG(
            t1.avg_r1_opp_total_strikes_landed_per_second - t2.avg_r1_opp_total_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_total_strikes_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_total_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_total_strikes_landed_per_second,
        AVG(
            t1.cumulative_r1_opp_total_strikes_landed_per_second - t2.cumulative_r1_opp_total_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_total_strikes_landed_per_second_diff,
        AVG(t2.avg_r1_opp_total_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_total_strikes_accuracy,
        AVG(
            t1.avg_r1_opp_total_strikes_accuracy - t2.avg_r1_opp_total_strikes_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_total_strikes_accuracy_diff,
        AVG(t2.cumulative_r1_opp_total_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_total_strikes_accuracy,
        AVG(
            t1.cumulative_r1_opp_total_strikes_accuracy - t2.cumulative_r1_opp_total_strikes_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_total_strikes_accuracy_diff,
        AVG(t2.avg_r1_opp_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_total_strikes_attempted,
        AVG(
            t1.avg_r1_opp_total_strikes_attempted - t2.avg_r1_opp_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_total_strikes_attempted_diff,
        AVG(t2.cumulative_r1_opp_total_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_total_strikes_attempted,
        AVG(
            t1.cumulative_r1_opp_total_strikes_attempted - t2.cumulative_r1_opp_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_total_strikes_attempted_diff,
        AVG(t2.avg_r1_opp_total_strikes_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_total_strikes_attempted_per_second,
        AVG(
            t1.avg_r1_opp_total_strikes_attempted_per_second - t2.avg_r1_opp_total_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_total_strikes_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_total_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_total_strikes_attempted_per_second,
        AVG(
            t1.cumulative_r1_opp_total_strikes_attempted_per_second - t2.cumulative_r1_opp_total_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_total_strikes_attempted_per_second_diff,
        AVG(t2.avg_r1_opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_landed - t2.avg_r1_opp_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_landed_diff,
        AVG(t2.cumulative_r1_opp_significant_strikes_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_landed - t2.cumulative_r1_opp_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_landed_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_landed_per_second - t2.avg_r1_opp_significant_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_landed_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_landed_per_second - t2.cumulative_r1_opp_significant_strikes_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_landed_per_second_diff,
        AVG(t2.avg_r1_opp_significant_strikes_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_accuracy,
        AVG(
            t1.avg_r1_opp_significant_strikes_accuracy - t2.avg_r1_opp_significant_strikes_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_accuracy_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_accuracy,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_accuracy - t2.cumulative_r1_opp_significant_strikes_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_accuracy_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_landed_per_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_landed_per_total_strikes_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_landed_per_total_strikes_landed - t2.avg_r1_opp_significant_strikes_landed_per_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_landed_per_total_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed - t2.cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed_diff,
        AVG(t2.avg_r1_opp_significant_strikes_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_attempted - t2.avg_r1_opp_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_attempted - t2.cumulative_r1_opp_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_attempted_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_attempted_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_attempted_per_second - t2.avg_r1_opp_significant_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_attempted_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_attempted_per_second - t2.cumulative_r1_opp_significant_strikes_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_attempted_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted - t2.avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted - t2.cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_diff,
        AVG(t2.avg_r1_opp_significant_strikes_head_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_head_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_head_landed - t2.avg_r1_opp_significant_strikes_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_head_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_head_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_head_landed - t2.cumulative_r1_opp_significant_strikes_head_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_head_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_head_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_head_landed_per_second,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_head_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_head_landed_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_head_landed_per_second - t2.avg_r1_opp_significant_strikes_head_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_head_landed_per_second_diff,
        AVG(t2.avg_r1_opp_significant_strikes_head_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_head_accuracy,
        AVG(
            t1.avg_r1_opp_significant_strikes_head_accuracy - t2.avg_r1_opp_significant_strikes_head_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_head_accuracy_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_head_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_head_accuracy,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_head_accuracy - t2.cumulative_r1_opp_significant_strikes_head_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_head_accuracy_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed - t2.avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed - t2.cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_diff,
        AVG(t2.avg_r1_opp_significant_strikes_head_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_head_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_head_attempted - t2.avg_r1_opp_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_head_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_head_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_head_attempted - t2.cumulative_r1_opp_significant_strikes_head_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_head_attempted_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_head_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_head_attempted_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_head_attempted_per_second - t2.avg_r1_opp_significant_strikes_head_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_head_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_head_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_head_attempted_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_head_attempted_per_second - t2.cumulative_r1_opp_significant_strikes_head_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_head_attempted_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted - t2.avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted - t2.cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_opp_significant_strikes_body_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_body_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_body_landed - t2.avg_r1_opp_significant_strikes_body_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_body_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_body_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_body_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_body_landed - t2.cumulative_r1_opp_significant_strikes_body_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_body_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_body_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_body_landed_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_body_landed_per_second - t2.avg_r1_opp_significant_strikes_body_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_body_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_body_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_body_landed_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_body_landed_per_second - t2.cumulative_r1_opp_significant_strikes_body_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_body_landed_per_second_diff,
        AVG(t2.avg_r1_opp_significant_strikes_body_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_body_accuracy,
        AVG(
            t1.avg_r1_opp_significant_strikes_body_accuracy - t2.avg_r1_opp_significant_strikes_body_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_body_accuracy_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_body_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_body_accuracy,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_body_accuracy - t2.cumulative_r1_opp_significant_strikes_body_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_body_accuracy_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed - t2.avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed - t2.cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_diff,
        AVG(t2.avg_r1_opp_significant_strikes_body_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_body_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_body_attempted - t2.avg_r1_opp_significant_strikes_body_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_body_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_body_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_body_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_body_attempted - t2.cumulative_r1_opp_significant_strikes_body_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_body_attempted_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_body_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_body_attempted_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_body_attempted_per_second - t2.avg_r1_opp_significant_strikes_body_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_body_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_body_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_body_attempted_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_body_attempted_per_second - t2.cumulative_r1_opp_significant_strikes_body_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_body_attempted_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted - t2.avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted - t2.cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_opp_significant_strikes_leg_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_leg_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_leg_landed - t2.avg_r1_opp_significant_strikes_leg_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_leg_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_leg_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_leg_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_leg_landed - t2.cumulative_r1_opp_significant_strikes_leg_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_leg_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_leg_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_leg_landed_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_leg_landed_per_second - t2.avg_r1_opp_significant_strikes_leg_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_leg_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_leg_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_leg_landed_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_leg_landed_per_second - t2.cumulative_r1_opp_significant_strikes_leg_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_leg_landed_per_second_diff,
        AVG(t2.avg_r1_opp_significant_strikes_leg_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_leg_accuracy,
        AVG(
            t1.avg_r1_opp_significant_strikes_leg_accuracy - t2.avg_r1_opp_significant_strikes_leg_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_leg_accuracy_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_leg_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_leg_accuracy,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_leg_accuracy - t2.cumulative_r1_opp_significant_strikes_leg_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_leg_accuracy_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed - t2.avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed - t2.cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_diff,
        AVG(t2.avg_r1_opp_significant_strikes_leg_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_leg_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_leg_attempted - t2.avg_r1_opp_significant_strikes_leg_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_leg_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_leg_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted,
        AVG(
            t2.avg_r1_opp_significant_strikes_leg_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_leg_attempted_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_leg_attempted_per_second - t2.avg_r1_opp_significant_strikes_leg_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_leg_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_leg_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_leg_attempted_per_second - t2.cumulative_r1_opp_significant_strikes_leg_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_leg_attempted_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted - t2.avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted - t2.cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_distance_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_distance_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_distance_landed - t2.avg_r1_opp_significant_strikes_distance_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_distance_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_distance_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_distance_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_distance_landed - t2.cumulative_r1_opp_significant_strikes_distance_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_distance_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_distance_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_distance_landed_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_distance_landed_per_second - t2.avg_r1_opp_significant_strikes_distance_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_distance_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_distance_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_distance_landed_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_distance_landed_per_second - t2.cumulative_r1_opp_significant_strikes_distance_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_distance_landed_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_distance_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_distance_accuracy,
        AVG(
            t1.avg_r1_opp_significant_strikes_distance_accuracy - t2.avg_r1_opp_significant_strikes_distance_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_distance_accuracy_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_distance_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_distance_accuracy,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_distance_accuracy - t2.cumulative_r1_opp_significant_strikes_distance_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_distance_accuracy_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed - t2.avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed - t2.cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_distance_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_distance_attempted - t2.avg_r1_opp_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_distance_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_distance_attempted - t2.cumulative_r1_opp_significant_strikes_distance_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_distance_attempted_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_distance_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_distance_attempted_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_distance_attempted_per_second - t2.avg_r1_opp_significant_strikes_distance_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_distance_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_distance_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_distance_attempted_per_second - t2.cumulative_r1_opp_significant_strikes_distance_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_distance_attempted_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted - t2.avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted - t2.cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_opp_significant_strikes_clinch_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_clinch_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_clinch_landed - t2.avg_r1_opp_significant_strikes_clinch_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_clinch_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_clinch_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_clinch_landed - t2.cumulative_r1_opp_significant_strikes_clinch_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_clinch_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_clinch_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_clinch_landed_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_clinch_landed_per_second - t2.avg_r1_opp_significant_strikes_clinch_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_clinch_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_clinch_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_clinch_landed_per_second - t2.cumulative_r1_opp_significant_strikes_clinch_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_clinch_landed_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_clinch_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_clinch_accuracy,
        AVG(
            t1.avg_r1_opp_significant_strikes_clinch_accuracy - t2.avg_r1_opp_significant_strikes_clinch_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_clinch_accuracy_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_clinch_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_accuracy,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_clinch_accuracy - t2.cumulative_r1_opp_significant_strikes_clinch_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_clinch_accuracy_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed - t2.avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed - t2.cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_clinch_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_clinch_attempted - t2.avg_r1_opp_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_clinch_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_clinch_attempted - t2.cumulative_r1_opp_significant_strikes_clinch_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_clinch_attempted_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_clinch_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_clinch_attempted_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_clinch_attempted_per_second - t2.avg_r1_opp_significant_strikes_clinch_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_clinch_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_clinch_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_clinch_attempted_per_second - t2.cumulative_r1_opp_significant_strikes_clinch_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_clinch_attempted_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted - t2.avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted - t2.cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_opp_significant_strikes_ground_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_ground_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_ground_landed - t2.avg_r1_opp_significant_strikes_ground_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_ground_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_ground_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_ground_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_ground_landed - t2.cumulative_r1_opp_significant_strikes_ground_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_ground_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_ground_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_ground_landed_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_ground_landed_per_second - t2.avg_r1_opp_significant_strikes_ground_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_ground_landed_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_ground_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_ground_landed_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_ground_landed_per_second - t2.cumulative_r1_opp_significant_strikes_ground_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_ground_landed_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_ground_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_ground_accuracy,
        AVG(
            t1.avg_r1_opp_significant_strikes_ground_accuracy - t2.avg_r1_opp_significant_strikes_ground_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_ground_accuracy_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_ground_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_ground_accuracy,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_ground_accuracy - t2.cumulative_r1_opp_significant_strikes_ground_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_ground_accuracy_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed,
        AVG(
            t1.avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed - t2.avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed - t2.cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_ground_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_ground_attempted - t2.avg_r1_opp_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_ground_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_ground_attempted - t2.cumulative_r1_opp_significant_strikes_ground_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_ground_attempted_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_ground_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_ground_attempted_per_second,
        AVG(
            t1.avg_r1_opp_significant_strikes_ground_attempted_per_second - t2.avg_r1_opp_significant_strikes_ground_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_ground_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_ground_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted_per_second,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_ground_attempted_per_second - t2.cumulative_r1_opp_significant_strikes_ground_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_ground_attempted_per_second_diff,
        AVG(
            t2.avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted,
        AVG(
            t1.avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted - t2.avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t2.cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted,
        AVG(
            t1.cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted - t2.cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff,
        AVG(t2.avg_r1_opp_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_takedowns_landed,
        AVG(
            t1.avg_r1_opp_takedowns_landed - t2.avg_r1_opp_takedowns_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_takedowns_landed_diff,
        AVG(t2.cumulative_r1_opp_takedowns_landed) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_takedowns_landed,
        AVG(
            t1.cumulative_r1_opp_takedowns_landed - t2.cumulative_r1_opp_takedowns_landed
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_takedowns_landed_diff,
        AVG(t2.avg_r1_opp_takedowns_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_takedowns_landed_per_second,
        AVG(
            t1.avg_r1_opp_takedowns_landed_per_second - t2.avg_r1_opp_takedowns_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_takedowns_landed_per_second_diff,
        AVG(t2.cumulative_r1_opp_takedowns_landed_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_takedowns_landed_per_second,
        AVG(
            t1.cumulative_r1_opp_takedowns_landed_per_second - t2.cumulative_r1_opp_takedowns_landed_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_takedowns_landed_per_second_diff,
        AVG(t2.avg_r1_opp_takedowns_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_takedowns_accuracy,
        AVG(
            t1.avg_r1_opp_takedowns_accuracy - t2.avg_r1_opp_takedowns_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_takedowns_accuracy_diff,
        AVG(t2.cumulative_r1_opp_takedowns_accuracy) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_takedowns_accuracy,
        AVG(
            t1.cumulative_r1_opp_takedowns_accuracy - t2.cumulative_r1_opp_takedowns_accuracy
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_takedowns_accuracy_diff,
        AVG(t2.avg_r1_opp_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_takedowns_attempted,
        AVG(
            t1.avg_r1_opp_takedowns_attempted - t2.avg_r1_opp_takedowns_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_takedowns_attempted_diff,
        AVG(t2.cumulative_r1_opp_takedowns_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_takedowns_attempted,
        AVG(
            t1.cumulative_r1_opp_takedowns_attempted - t2.cumulative_r1_opp_takedowns_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_takedowns_attempted_diff,
        AVG(t2.avg_r1_opp_takedowns_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_takedowns_attempted_per_second,
        AVG(
            t1.avg_r1_opp_takedowns_attempted_per_second - t2.avg_r1_opp_takedowns_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_takedowns_attempted_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_takedowns_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_takedowns_attempted_per_second,
        AVG(
            t1.cumulative_r1_opp_takedowns_attempted_per_second - t2.cumulative_r1_opp_takedowns_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_takedowns_attempted_per_second_diff,
        AVG(t2.avg_r1_opp_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_reversals_scored,
        AVG(
            t1.avg_r1_opp_reversals_scored - t2.avg_r1_opp_reversals_scored
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_reversals_scored_diff,
        AVG(t2.cumulative_r1_opp_reversals_scored) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_reversals_scored,
        AVG(
            t1.cumulative_r1_opp_reversals_scored - t2.cumulative_r1_opp_reversals_scored
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_reversals_scored_diff,
        AVG(t2.avg_r1_opp_reversals_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_reversals_scored_per_second,
        AVG(
            t1.avg_r1_opp_reversals_scored_per_second - t2.avg_r1_opp_reversals_scored_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_reversals_scored_per_second_diff,
        AVG(t2.cumulative_r1_opp_reversals_scored_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_reversals_scored_per_second,
        AVG(
            t1.cumulative_r1_opp_reversals_scored_per_second - t2.cumulative_r1_opp_reversals_scored_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_reversals_scored_per_second_diff,
        AVG(t2.avg_r1_opp_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_submissions_attempted,
        AVG(
            t1.avg_r1_opp_submissions_attempted - t2.avg_r1_opp_submissions_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_submissions_attempted_diff,
        AVG(t2.cumulative_r1_opp_submissions_attempted) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_submissions_attempted,
        AVG(
            t1.cumulative_r1_opp_submissions_attempted - t2.cumulative_r1_opp_submissions_attempted
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_submissions_attempted_diff,
        AVG(t2.avg_r1_opp_submissions_attempted_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_submissions_attempted_per_second,
        AVG(
            t2.cumulative_r1_opp_submissions_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_submissions_attempted_per_second,
        AVG(
            t1.avg_r1_opp_submissions_attempted_per_second - t2.avg_r1_opp_submissions_attempted_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_submissions_attempted_per_second_diff,
        AVG(t2.avg_r1_opp_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_control_time_seconds,
        AVG(
            t1.avg_r1_opp_control_time_seconds - t2.avg_r1_opp_control_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_control_time_seconds_diff,
        AVG(t2.cumulative_r1_opp_control_time_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_control_time_seconds,
        AVG(
            t1.cumulative_r1_opp_control_time_seconds - t2.cumulative_r1_opp_control_time_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_control_time_seconds_diff,
        AVG(t2.avg_r1_opp_control_time_seconds_per_second) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_opp_control_time_seconds_per_second,
        AVG(
            t1.avg_r1_opp_control_time_seconds_per_second - t2.avg_r1_opp_control_time_seconds_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_opp_control_time_seconds_per_second_diff,
        AVG(
            t2.cumulative_r1_opp_control_time_seconds_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_cumulative_r1_opp_control_time_seconds_per_second,
        AVG(
            t1.cumulative_r1_opp_control_time_seconds_per_second - t2.cumulative_r1_opp_control_time_seconds_per_second
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_cumulative_r1_opp_control_time_seconds_per_second_diff,
        AVG(t2.avg_r1_knockdowns_scored_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_diff,
        AVG(
            t1.avg_r1_knockdowns_scored_diff - t2.avg_r1_knockdowns_scored_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_diff_diff,
        AVG(t2.avg_r1_knockdowns_scored_per_second_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_second_diff,
        AVG(
            t1.avg_r1_knockdowns_scored_per_second_diff - t2.avg_r1_knockdowns_scored_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_second_diff_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_strike_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_strike_landed_diff,
        AVG(
            t1.avg_r1_knockdowns_scored_per_strike_landed_diff - t2.avg_r1_knockdowns_scored_per_strike_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_strike_landed_diff_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_strike_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_strike_attempted_diff,
        AVG(
            t1.avg_r1_knockdowns_scored_per_strike_attempted_diff - t2.avg_r1_knockdowns_scored_per_strike_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_strike_attempted_diff_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_significant_strike_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_landed_diff,
        AVG(
            t1.avg_r1_knockdowns_scored_per_significant_strike_landed_diff - t2.avg_r1_knockdowns_scored_per_significant_strike_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_significant_strike_landed_diff_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_significant_strike_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff,
        AVG(
            t1.avg_r1_knockdowns_scored_per_significant_strike_attempted_diff - t2.avg_r1_knockdowns_scored_per_significant_strike_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff,
        AVG(
            t1.avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff - t2.avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff_diff,
        AVG(
            t2.avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff,
        AVG(
            t1.avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff - t2.avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff_diff,
        AVG(t2.avg_r1_total_strikes_landed_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_landed_diff,
        AVG(
            t1.avg_r1_total_strikes_landed_diff - t2.avg_r1_total_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_landed_diff_diff,
        AVG(t2.avg_r1_total_strikes_landed_per_second_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_landed_per_second_diff,
        AVG(
            t1.avg_r1_total_strikes_landed_per_second_diff - t2.avg_r1_total_strikes_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_landed_per_second_diff_diff,
        AVG(t2.avg_r1_total_strikes_accuracy_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_accuracy_diff,
        AVG(
            t1.avg_r1_total_strikes_accuracy_diff - t2.avg_r1_total_strikes_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_accuracy_diff_diff,
        AVG(t2.avg_r1_total_strikes_attempted_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_attempted_diff,
        AVG(
            t1.avg_r1_total_strikes_attempted_diff - t2.avg_r1_total_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_attempted_diff_diff,
        AVG(
            t2.avg_r1_total_strikes_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_total_strikes_attempted_per_second_diff,
        AVG(
            t1.avg_r1_total_strikes_attempted_per_second_diff - t2.avg_r1_total_strikes_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_total_strikes_attempted_per_second_diff_diff,
        AVG(t2.avg_r1_significant_strikes_landed_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_landed_diff - t2.avg_r1_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_landed_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_landed_per_second_diff - t2.avg_r1_significant_strikes_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_landed_per_second_diff_diff,
        AVG(t2.avg_r1_significant_strikes_accuracy_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_accuracy_diff,
        AVG(
            t1.avg_r1_significant_strikes_accuracy_diff - t2.avg_r1_significant_strikes_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_accuracy_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_landed_per_total_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_landed_per_total_strikes_landed_diff - t2.avg_r1_significant_strikes_landed_per_total_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff_diff,
        AVG(t2.avg_r1_significant_strikes_attempted_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_attempted_diff - t2.avg_r1_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_attempted_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_attempted_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_attempted_per_second_diff - t2.avg_r1_significant_strikes_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_attempted_per_second_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff - t2.avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff_diff,
        AVG(t2.avg_r1_significant_strikes_head_landed_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_head_landed_diff - t2.avg_r1_significant_strikes_head_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_head_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_landed_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_head_landed_per_second_diff - t2.avg_r1_significant_strikes_head_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_landed_per_second_diff_diff,
        AVG(t2.avg_r1_significant_strikes_head_accuracy_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_accuracy_diff,
        AVG(
            t1.avg_r1_significant_strikes_head_accuracy_diff - t2.avg_r1_significant_strikes_head_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_accuracy_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff - t2.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_head_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_head_attempted_diff - t2.avg_r1_significant_strikes_head_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_attempted_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_head_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_attempted_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_head_attempted_per_second_diff - t2.avg_r1_significant_strikes_head_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_attempted_per_second_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff - t2.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_diff,
        AVG(t2.avg_r1_significant_strikes_body_landed_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_body_landed_diff - t2.avg_r1_significant_strikes_body_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_body_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_landed_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_body_landed_per_second_diff - t2.avg_r1_significant_strikes_body_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_landed_per_second_diff_diff,
        AVG(t2.avg_r1_significant_strikes_body_accuracy_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_accuracy_diff,
        AVG(
            t1.avg_r1_significant_strikes_body_accuracy_diff - t2.avg_r1_significant_strikes_body_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_accuracy_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff - t2.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_body_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_body_attempted_diff - t2.avg_r1_significant_strikes_body_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_attempted_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_body_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_attempted_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_body_attempted_per_second_diff - t2.avg_r1_significant_strikes_body_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_attempted_per_second_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff - t2.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_diff,
        AVG(t2.avg_r1_significant_strikes_leg_landed_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_leg_landed_diff - t2.avg_r1_significant_strikes_leg_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_leg_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_landed_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_leg_landed_per_second_diff - t2.avg_r1_significant_strikes_leg_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_landed_per_second_diff_diff,
        AVG(t2.avg_r1_significant_strikes_leg_accuracy_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_accuracy_diff,
        AVG(
            t1.avg_r1_significant_strikes_leg_accuracy_diff - t2.avg_r1_significant_strikes_leg_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_accuracy_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff - t2.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff_diff,
        AVG(t2.avg_r1_significant_strikes_leg_attempted_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_leg_attempted_diff - t2.avg_r1_significant_strikes_leg_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_attempted_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_leg_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_attempted_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_leg_attempted_per_second_diff - t2.avg_r1_significant_strikes_leg_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_attempted_per_second_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff - t2.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_distance_landed_diff - t2.avg_r1_significant_strikes_distance_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_landed_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_distance_landed_per_second_diff - t2.avg_r1_significant_strikes_distance_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_landed_per_second_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_accuracy_diff,
        AVG(
            t1.avg_r1_significant_strikes_distance_accuracy_diff - t2.avg_r1_significant_strikes_distance_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_accuracy_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff - t2.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_distance_attempted_diff - t2.avg_r1_significant_strikes_distance_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_attempted_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_attempted_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_distance_attempted_per_second_diff - t2.avg_r1_significant_strikes_distance_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_attempted_per_second_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff - t2.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_diff,
        AVG(t2.avg_r1_significant_strikes_clinch_landed_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_clinch_landed_diff - t2.avg_r1_significant_strikes_clinch_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_landed_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_clinch_landed_per_second_diff - t2.avg_r1_significant_strikes_clinch_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_landed_per_second_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_accuracy_diff,
        AVG(
            t1.avg_r1_significant_strikes_clinch_accuracy_diff - t2.avg_r1_significant_strikes_clinch_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_accuracy_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff - t2.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_clinch_attempted_diff - t2.avg_r1_significant_strikes_clinch_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_attempted_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_attempted_per_second_diff,
        AVG(
            t2.avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_clinch_attempted_per_second_diff - t2.avg_r1_significant_strikes_clinch_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_clinch_attempted_per_second_diff_diff,
        AVG(t2.avg_r1_significant_strikes_ground_landed_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_ground_landed_diff - t2.avg_r1_significant_strikes_ground_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_landed_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_ground_landed_per_second_diff - t2.avg_r1_significant_strikes_ground_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_landed_per_second_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_accuracy_diff,
        AVG(
            t1.avg_r1_significant_strikes_ground_accuracy_diff - t2.avg_r1_significant_strikes_ground_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_accuracy_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff,
        AVG(
            t1.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff - t2.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_ground_attempted_diff - t2.avg_r1_significant_strikes_ground_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_attempted_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_attempted_per_second_diff,
        AVG(
            t1.avg_r1_significant_strikes_ground_attempted_per_second_diff - t2.avg_r1_significant_strikes_ground_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_attempted_per_second_diff_diff,
        AVG(
            t2.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff,
        AVG(
            t1.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff - t2.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_diff,
        AVG(t2.avg_r1_takedowns_landed_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_landed_diff,
        AVG(
            t1.avg_r1_takedowns_landed_diff - t2.avg_r1_takedowns_landed_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_landed_diff_diff,
        AVG(t2.avg_r1_takedowns_landed_per_second_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_landed_per_second_diff,
        AVG(
            t1.avg_r1_takedowns_landed_per_second_diff - t2.avg_r1_takedowns_landed_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_landed_per_second_diff_diff,
        AVG(t2.avg_r1_takedowns_accuracy_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_accuracy_diff,
        AVG(
            t1.avg_r1_takedowns_accuracy_diff - t2.avg_r1_takedowns_accuracy_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_accuracy_diff_diff,
        AVG(t2.avg_r1_takedowns_attempted_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_attempted_diff,
        AVG(
            t1.avg_r1_takedowns_attempted_diff - t2.avg_r1_takedowns_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_attempted_diff_diff,
        AVG(t2.avg_r1_takedowns_attempted_per_second_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_takedowns_attempted_per_second_diff,
        AVG(
            t1.avg_r1_takedowns_attempted_per_second_diff - t2.avg_r1_takedowns_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_takedowns_attempted_per_second_diff_diff,
        AVG(t2.avg_r1_reversals_scored_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_reversals_scored_diff,
        AVG(
            t1.avg_r1_reversals_scored_diff - t2.avg_r1_reversals_scored_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_reversals_scored_diff_diff,
        AVG(t2.avg_r1_reversals_scored_per_second_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_reversals_scored_per_second_diff,
        AVG(
            t1.avg_r1_reversals_scored_per_second_diff - t2.avg_r1_reversals_scored_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_reversals_scored_per_second_diff_diff,
        AVG(t2.avg_r1_submissions_attempted_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_submissions_attempted_diff,
        AVG(
            t1.avg_r1_submissions_attempted_diff - t2.avg_r1_submissions_attempted_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_submissions_attempted_diff_diff,
        AVG(t2.avg_r1_submissions_attempted_per_second_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_submissions_attempted_per_second_diff,
        AVG(
            t1.avg_r1_submissions_attempted_per_second_diff - t2.avg_r1_submissions_attempted_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_submissions_attempted_per_second_diff_diff,
        AVG(t2.avg_r1_control_time_seconds_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_control_time_seconds_diff,
        AVG(
            t1.avg_r1_control_time_seconds_diff - t2.avg_r1_control_time_seconds_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_control_time_seconds_diff_diff,
        AVG(t2.avg_r1_control_time_seconds_per_second_diff) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_r1_control_time_seconds_per_second_diff,
        AVG(
            t1.avg_r1_control_time_seconds_per_second_diff - t2.avg_r1_control_time_seconds_per_second_diff
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_r1_control_time_seconds_per_second_diff_diff
    FROM cte3 t1
        LEFT JOIN cte3 t2 ON t1.fighter_id = t2.opponent_id
        AND t1.bout_id = t2.bout_id
        AND t1.opponent_id = t2.fighter_id
)
SELECT t1.id,
    1.0 * t2.avg_r1_knockdowns_scored / t3.avg_r1_knockdowns_scored AS avg_r1_knockdowns_scored_ratio,
    1.0 * t2.cumulative_r1_knockdowns_scored / t3.cumulative_r1_knockdowns_scored AS cumulative_r1_knockdowns_scored_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_second / t3.avg_r1_knockdowns_scored_per_second AS avg_r1_knockdowns_scored_per_second_ratio,
    1.0 * t2.cumulative_r1_knockdowns_scored_per_second / t3.cumulative_r1_knockdowns_scored_per_second AS cumulative_r1_knockdowns_scored_per_second_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_strike_landed / t3.avg_r1_knockdowns_scored_per_strike_landed AS avg_r1_knockdowns_scored_per_strike_landed_ratio,
    1.0 * t2.cumulative_r1_knockdowns_scored_per_strike_landed / t3.cumulative_r1_knockdowns_scored_per_strike_landed AS cumulative_r1_knockdowns_scored_per_strike_landed_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_strike_attempted / t3.avg_r1_knockdowns_scored_per_strike_attempted AS avg_r1_knockdowns_scored_per_strike_attempted_ratio,
    1.0 * t2.cumulative_r1_knockdowns_scored_per_strike_attempted / t3.cumulative_r1_knockdowns_scored_per_strike_attempted AS cumulative_r1_knockdowns_scored_per_strike_attempted_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_significant_strike_landed / t3.avg_r1_knockdowns_scored_per_significant_strike_landed AS avg_r1_knockdowns_scored_per_significant_strike_landed_ratio,
    1.0 * t2.cumulative_r1_knockdowns_scored_per_significant_strike_landed / t3.cumulative_r1_knockdowns_scored_per_significant_strike_landed AS cumulative_r1_knockdowns_scored_per_significant_strike_landed_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_significant_strike_attempted / t3.avg_r1_knockdowns_scored_per_significant_strike_attempted AS avg_r1_knockdowns_scored_per_significant_strike_attempted_ratio,
    1.0 * t2.cumulative_r1_knockdowns_scored_per_significant_strike_attempted / t3.cumulative_r1_knockdowns_scored_per_significant_strike_attempted AS cumulative_r1_knockdowns_scored_per_significant_strike_attempted_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_significant_strike_head_landed / t3.avg_r1_knockdowns_scored_per_significant_strike_head_landed AS avg_r1_knockdowns_scored_per_significant_strike_head_landed_ratio,
    1.0 * t2.cumulative_r1_knockdowns_scored_per_significant_strike_head_landed / t3.cumulative_r1_knockdowns_scored_per_significant_strike_head_landed AS cumulative_r1_knockdowns_scored_per_significant_strike_head_landed_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_significant_strike_head_attempted / t3.avg_r1_knockdowns_scored_per_significant_strike_head_attempted AS avg_r1_knockdowns_scored_per_significant_strike_head_attempted_ratio,
    1.0 * t2.cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted / t3.cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted AS cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted_ratio,
    1.0 * t2.avg_r1_total_strikes_landed / t3.avg_r1_total_strikes_landed AS avg_r1_total_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_total_strikes_landed / t3.cumulative_r1_total_strikes_landed AS cumulative_r1_total_strikes_landed_ratio,
    1.0 * t2.avg_r1_total_strikes_landed_per_second / t3.avg_r1_total_strikes_landed_per_second AS avg_r1_total_strikes_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_total_strikes_landed_per_second / t3.cumulative_r1_total_strikes_landed_per_second AS cumulative_r1_total_strikes_landed_per_second_ratio,
    1.0 * t2.avg_r1_total_strikes_accuracy / t3.avg_r1_total_strikes_accuracy AS avg_r1_total_strikes_accuracy_ratio,
    1.0 * t2.cumulative_r1_total_strikes_accuracy / t3.cumulative_r1_total_strikes_accuracy AS cumulative_r1_total_strikes_accuracy_ratio,
    1.0 * t2.avg_r1_total_strikes_attempted / t3.avg_r1_total_strikes_attempted AS avg_r1_total_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_total_strikes_attempted / t3.cumulative_r1_total_strikes_attempted AS cumulative_r1_total_strikes_attempted_ratio,
    1.0 * t2.avg_r1_total_strikes_attempted_per_second / t3.avg_r1_total_strikes_attempted_per_second AS avg_r1_total_strikes_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_total_strikes_attempted_per_second / t3.cumulative_r1_total_strikes_attempted_per_second AS cumulative_r1_total_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_landed / t3.avg_r1_significant_strikes_landed AS avg_r1_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_landed / t3.cumulative_r1_significant_strikes_landed AS cumulative_r1_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_landed_per_second / t3.avg_r1_significant_strikes_landed_per_second AS avg_r1_significant_strikes_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_landed_per_second / t3.cumulative_r1_significant_strikes_landed_per_second AS cumulative_r1_significant_strikes_landed_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_accuracy / t3.avg_r1_significant_strikes_accuracy AS avg_r1_significant_strikes_accuracy_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_accuracy / t3.cumulative_r1_significant_strikes_accuracy AS cumulative_r1_significant_strikes_accuracy_ratio,
    1.0 * t2.avg_r1_significant_strikes_landed_per_total_strikes_landed / t3.avg_r1_significant_strikes_landed_per_total_strikes_landed AS avg_r1_significant_strikes_landed_per_total_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_landed_per_total_strikes_landed / t3.cumulative_r1_significant_strikes_landed_per_total_strikes_landed AS cumulative_r1_significant_strikes_landed_per_total_strikes_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_attempted / t3.avg_r1_significant_strikes_attempted AS avg_r1_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_attempted / t3.cumulative_r1_significant_strikes_attempted AS cumulative_r1_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_attempted_per_second / t3.avg_r1_significant_strikes_attempted_per_second AS avg_r1_significant_strikes_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_attempted_per_second / t3.cumulative_r1_significant_strikes_attempted_per_second AS cumulative_r1_significant_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_attempted_per_total_strikes_attempted / t3.avg_r1_significant_strikes_attempted_per_total_strikes_attempted AS avg_r1_significant_strikes_attempted_per_total_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted / t3.cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted AS cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_landed / t3.avg_r1_significant_strikes_head_landed AS avg_r1_significant_strikes_head_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_head_landed / t3.cumulative_r1_significant_strikes_head_landed AS cumulative_r1_significant_strikes_head_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_landed_per_second / t3.avg_r1_significant_strikes_head_landed_per_second AS avg_r1_significant_strikes_head_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_head_landed_per_second / t3.cumulative_r1_significant_strikes_head_landed_per_second AS cumulative_r1_significant_strikes_head_landed_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_accuracy / t3.avg_r1_significant_strikes_head_accuracy AS avg_r1_significant_strikes_head_accuracy_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_head_accuracy / t3.cumulative_r1_significant_strikes_head_accuracy AS cumulative_r1_significant_strikes_head_accuracy_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed / t3.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed AS avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed / t3.cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed AS cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_attempted / t3.avg_r1_significant_strikes_head_attempted AS avg_r1_significant_strikes_head_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_head_attempted / t3.cumulative_r1_significant_strikes_head_attempted AS cumulative_r1_significant_strikes_head_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_attempted_per_second / t3.avg_r1_significant_strikes_head_attempted_per_second AS avg_r1_significant_strikes_head_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_head_attempted_per_second / t3.cumulative_r1_significant_strikes_head_attempted_per_second AS cumulative_r1_significant_strikes_head_attempted_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted / t3.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted AS avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted / t3.cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted AS cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_landed / t3.avg_r1_significant_strikes_body_landed AS avg_r1_significant_strikes_body_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_body_landed / t3.cumulative_r1_significant_strikes_body_landed AS cumulative_r1_significant_strikes_body_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_landed_per_second / t3.avg_r1_significant_strikes_body_landed_per_second AS avg_r1_significant_strikes_body_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_body_landed_per_second / t3.cumulative_r1_significant_strikes_body_landed_per_second AS cumulative_r1_significant_strikes_body_landed_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_accuracy / t3.avg_r1_significant_strikes_body_accuracy AS avg_r1_significant_strikes_body_accuracy_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_body_accuracy / t3.cumulative_r1_significant_strikes_body_accuracy AS cumulative_r1_significant_strikes_body_accuracy_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed / t3.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed AS avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed / t3.cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed AS cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_attempted / t3.avg_r1_significant_strikes_body_attempted AS avg_r1_significant_strikes_body_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_body_attempted / t3.cumulative_r1_significant_strikes_body_attempted AS cumulative_r1_significant_strikes_body_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_attempted_per_second / t3.avg_r1_significant_strikes_body_attempted_per_second AS avg_r1_significant_strikes_body_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_body_attempted_per_second / t3.cumulative_r1_significant_strikes_body_attempted_per_second AS cumulative_r1_significant_strikes_body_attempted_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted / t3.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted AS avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted / t3.cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted AS cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_landed / t3.avg_r1_significant_strikes_leg_landed AS avg_r1_significant_strikes_leg_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_leg_landed / t3.cumulative_r1_significant_strikes_leg_landed AS cumulative_r1_significant_strikes_leg_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_landed_per_second / t3.avg_r1_significant_strikes_leg_landed_per_second AS avg_r1_significant_strikes_leg_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_leg_landed_per_second / t3.cumulative_r1_significant_strikes_leg_landed_per_second AS cumulative_r1_significant_strikes_leg_landed_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_accuracy / t3.avg_r1_significant_strikes_leg_accuracy AS avg_r1_significant_strikes_leg_accuracy_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_leg_accuracy / t3.cumulative_r1_significant_strikes_leg_accuracy AS cumulative_r1_significant_strikes_leg_accuracy_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed / t3.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed AS avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed / t3.cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed AS cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_attempted / t3.avg_r1_significant_strikes_leg_attempted AS avg_r1_significant_strikes_leg_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_leg_attempted / t3.cumulative_r1_significant_strikes_leg_attempted AS cumulative_r1_significant_strikes_leg_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_attempted_per_second / t3.avg_r1_significant_strikes_leg_attempted_per_second AS avg_r1_significant_strikes_leg_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_leg_attempted_per_second / t3.cumulative_r1_significant_strikes_leg_attempted_per_second AS cumulative_r1_significant_strikes_leg_attempted_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted / t3.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted AS avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted / t3.cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted AS cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_landed / t3.avg_r1_significant_strikes_distance_landed AS avg_r1_significant_strikes_distance_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_distance_landed / t3.cumulative_r1_significant_strikes_distance_landed AS cumulative_r1_significant_strikes_distance_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_landed_per_second / t3.avg_r1_significant_strikes_distance_landed_per_second AS avg_r1_significant_strikes_distance_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_distance_landed_per_second / t3.cumulative_r1_significant_strikes_distance_landed_per_second AS cumulative_r1_significant_strikes_distance_landed_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_accuracy / t3.avg_r1_significant_strikes_distance_accuracy AS avg_r1_significant_strikes_distance_accuracy_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_distance_accuracy / t3.cumulative_r1_significant_strikes_distance_accuracy AS cumulative_r1_significant_strikes_distance_accuracy_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed / t3.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed AS avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed / t3.cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed AS cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_attempted / t3.avg_r1_significant_strikes_distance_attempted AS avg_r1_significant_strikes_distance_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_distance_attempted / t3.cumulative_r1_significant_strikes_distance_attempted AS cumulative_r1_significant_strikes_distance_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_attempted_per_second / t3.avg_r1_significant_strikes_distance_attempted_per_second AS avg_r1_significant_strikes_distance_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_distance_attempted_per_second / t3.cumulative_r1_significant_strikes_distance_attempted_per_second AS cumulative_r1_significant_strikes_distance_attempted_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted / t3.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted AS avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted / t3.cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted AS cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_landed / t3.avg_r1_significant_strikes_clinch_landed AS avg_r1_significant_strikes_clinch_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_clinch_landed / t3.cumulative_r1_significant_strikes_clinch_landed AS cumulative_r1_significant_strikes_clinch_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_landed_per_second / t3.avg_r1_significant_strikes_clinch_landed_per_second AS avg_r1_significant_strikes_clinch_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_clinch_landed_per_second / t3.cumulative_r1_significant_strikes_clinch_landed_per_second AS cumulative_r1_significant_strikes_clinch_landed_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_accuracy / t3.avg_r1_significant_strikes_clinch_accuracy AS avg_r1_significant_strikes_clinch_accuracy_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_clinch_accuracy / t3.cumulative_r1_significant_strikes_clinch_accuracy AS cumulative_r1_significant_strikes_clinch_accuracy_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed / t3.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed AS avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed / t3.cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed AS cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_attempted / t3.avg_r1_significant_strikes_clinch_attempted AS avg_r1_significant_strikes_clinch_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_clinch_attempted / t3.cumulative_r1_significant_strikes_clinch_attempted AS cumulative_r1_significant_strikes_clinch_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_attempted_per_second / t3.avg_r1_significant_strikes_clinch_attempted_per_second AS avg_r1_significant_strikes_clinch_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_clinch_attempted_per_second / t3.cumulative_r1_significant_strikes_clinch_attempted_per_second AS cumulative_r1_significant_strikes_clinch_attempted_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted / t3.avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted AS avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted / t3.cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted AS cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_landed / t3.avg_r1_significant_strikes_ground_landed AS avg_r1_significant_strikes_ground_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_ground_landed / t3.cumulative_r1_significant_strikes_ground_landed AS cumulative_r1_significant_strikes_ground_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_landed_per_second / t3.avg_r1_significant_strikes_ground_landed_per_second AS avg_r1_significant_strikes_ground_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_ground_landed_per_second / t3.cumulative_r1_significant_strikes_ground_landed_per_second AS cumulative_r1_significant_strikes_ground_landed_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_accuracy / t3.avg_r1_significant_strikes_ground_accuracy AS avg_r1_significant_strikes_ground_accuracy_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_ground_accuracy / t3.cumulative_r1_significant_strikes_ground_accuracy AS cumulative_r1_significant_strikes_ground_accuracy_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed / t3.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed AS avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed / t3.cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed AS cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_attempted / t3.avg_r1_significant_strikes_ground_attempted AS avg_r1_significant_strikes_ground_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_ground_attempted / t3.cumulative_r1_significant_strikes_ground_attempted AS cumulative_r1_significant_strikes_ground_attempted_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_attempted_per_second / t3.avg_r1_significant_strikes_ground_attempted_per_second AS avg_r1_significant_strikes_ground_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_ground_attempted_per_second / t3.cumulative_r1_significant_strikes_ground_attempted_per_second AS cumulative_r1_significant_strikes_ground_attempted_per_second_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted / t3.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted AS avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted / t3.cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted AS cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_takedowns_landed / t3.avg_r1_takedowns_landed AS avg_r1_takedowns_landed_ratio,
    1.0 * t2.cumulative_r1_takedowns_landed / t3.cumulative_r1_takedowns_landed AS cumulative_r1_takedowns_landed_ratio,
    1.0 * t2.avg_r1_takedowns_landed_per_second / t3.avg_r1_takedowns_landed_per_second AS avg_r1_takedowns_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_takedowns_landed_per_second / t3.cumulative_r1_takedowns_landed_per_second AS cumulative_r1_takedowns_landed_per_second_ratio,
    1.0 * t2.avg_r1_takedowns_accuracy / t3.avg_r1_takedowns_accuracy AS avg_r1_takedowns_accuracy_ratio,
    1.0 * t2.cumulative_r1_takedowns_accuracy / t3.cumulative_r1_takedowns_accuracy AS cumulative_r1_takedowns_accuracy_ratio,
    1.0 * t2.avg_r1_takedowns_attempted / t3.avg_r1_takedowns_attempted AS avg_r1_takedowns_attempted_ratio,
    1.0 * t2.cumulative_r1_takedowns_attempted / t3.cumulative_r1_takedowns_attempted AS cumulative_r1_takedowns_attempted_ratio,
    1.0 * t2.avg_r1_takedowns_attempted_per_second / t3.avg_r1_takedowns_attempted_per_second AS avg_r1_takedowns_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_takedowns_attempted_per_second / t3.cumulative_r1_takedowns_attempted_per_second AS cumulative_r1_takedowns_attempted_per_second_ratio,
    1.0 * t2.avg_r1_reversals_scored / t3.avg_r1_reversals_scored AS avg_r1_reversals_scored_ratio,
    1.0 * t2.cumulative_r1_reversals_scored / t3.cumulative_r1_reversals_scored AS cumulative_r1_reversals_scored_ratio,
    1.0 * t2.avg_r1_reversals_scored_per_second / t3.avg_r1_reversals_scored_per_second AS avg_r1_reversals_scored_per_second_ratio,
    1.0 * t2.cumulative_r1_reversals_scored_per_second / t3.cumulative_r1_reversals_scored_per_second AS cumulative_r1_reversals_scored_per_second_ratio,
    1.0 * t2.avg_r1_submissions_attempted / t3.avg_r1_submissions_attempted AS avg_r1_submissions_attempted_ratio,
    1.0 * t2.cumulative_r1_submissions_attempted / t3.cumulative_r1_submissions_attempted AS cumulative_r1_submissions_attempted_ratio,
    1.0 * t2.avg_r1_submissions_attempted_per_second / t3.avg_r1_submissions_attempted_per_second AS avg_r1_submissions_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_submissions_attempted_per_second / t3.cumulative_r1_submissions_attempted_per_second AS cumulative_r1_submissions_attempted_per_second_ratio,
    1.0 * t2.avg_r1_control_time_seconds / t3.avg_r1_control_time_seconds AS avg_r1_control_time_seconds_ratio,
    1.0 * t2.cumulative_r1_control_time_seconds / t3.cumulative_r1_control_time_seconds AS cumulative_r1_control_time_seconds_ratio,
    1.0 * t2.avg_r1_control_time_seconds_per_second / t3.avg_r1_control_time_seconds_per_second AS avg_r1_control_time_seconds_per_second_ratio,
    1.0 * t2.cumulative_r1_control_time_seconds_per_second / t3.cumulative_r1_control_time_seconds_per_second AS cumulative_r1_control_time_seconds_per_second_ratio,
    1.0 * t2.avg_r1_opp_knockdowns_scored / t3.avg_r1_opp_knockdowns_scored AS avg_r1_opp_knockdowns_scored_ratio,
    1.0 * t2.cumulative_r1_opp_knockdowns_scored / t3.cumulative_r1_opp_knockdowns_scored AS cumulative_r1_opp_knockdowns_scored_ratio,
    1.0 * t2.avg_r1_opp_knockdowns_scored_per_second / t3.avg_r1_opp_knockdowns_scored_per_second AS avg_r1_opp_knockdowns_scored_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_knockdowns_scored_per_second / t3.cumulative_r1_opp_knockdowns_scored_per_second AS cumulative_r1_opp_knockdowns_scored_per_second_ratio,
    1.0 * t2.avg_r1_opp_knockdowns_scored_per_strike_landed / t3.avg_r1_opp_knockdowns_scored_per_strike_landed AS avg_r1_opp_knockdowns_scored_per_strike_landed_ratio,
    1.0 * t2.cumulative_r1_opp_knockdowns_scored_per_strike_landed / t3.cumulative_r1_opp_knockdowns_scored_per_strike_landed AS cumulative_r1_opp_knockdowns_scored_per_strike_landed_ratio,
    1.0 * t2.avg_r1_opp_knockdowns_scored_per_strike_attempted / t3.avg_r1_opp_knockdowns_scored_per_strike_attempted AS avg_r1_opp_knockdowns_scored_per_strike_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_knockdowns_scored_per_strike_attempted / t3.cumulative_r1_opp_knockdowns_scored_per_strike_attempted AS cumulative_r1_opp_knockdowns_scored_per_strike_attempted_ratio,
    1.0 * t2.avg_r1_opp_knockdowns_scored_per_significant_strike_landed / t3.avg_r1_opp_knockdowns_scored_per_significant_strike_landed AS avg_r1_opp_knockdowns_scored_per_significant_strike_landed_ratio,
    1.0 * t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed / t3.cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed AS cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed_ratio,
    1.0 * t2.avg_r1_opp_knockdowns_scored_per_significant_strike_attempted / t3.avg_r1_opp_knockdowns_scored_per_significant_strike_attempted AS avg_r1_opp_knockdowns_scored_per_significant_strike_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted / t3.cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted AS cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted_ratio,
    1.0 * t2.avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed / t3.avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed AS avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed_ratio,
    1.0 * t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed / t3.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed AS cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed_ratio,
    1.0 * t2.avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted / t3.avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted AS avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted / t3.cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted AS cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_ratio,
    1.0 * t2.avg_r1_opp_total_strikes_landed / t3.avg_r1_opp_total_strikes_landed AS avg_r1_opp_total_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_opp_total_strikes_landed / t3.cumulative_r1_opp_total_strikes_landed AS cumulative_r1_opp_total_strikes_landed_ratio,
    1.0 * t2.avg_r1_opp_total_strikes_landed_per_second / t3.avg_r1_opp_total_strikes_landed_per_second AS avg_r1_opp_total_strikes_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_total_strikes_landed_per_second / t3.cumulative_r1_opp_total_strikes_landed_per_second AS cumulative_r1_opp_total_strikes_landed_per_second_ratio,
    1.0 * t2.avg_r1_opp_total_strikes_accuracy / t3.avg_r1_opp_total_strikes_accuracy AS avg_r1_opp_total_strikes_accuracy_ratio,
    1.0 * t2.cumulative_r1_opp_total_strikes_accuracy / t3.cumulative_r1_opp_total_strikes_accuracy AS cumulative_r1_opp_total_strikes_accuracy_ratio,
    1.0 * t2.avg_r1_opp_total_strikes_attempted / t3.avg_r1_opp_total_strikes_attempted AS avg_r1_opp_total_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_total_strikes_attempted / t3.cumulative_r1_opp_total_strikes_attempted AS cumulative_r1_opp_total_strikes_attempted_ratio,
    1.0 * t2.avg_r1_opp_total_strikes_attempted_per_second / t3.avg_r1_opp_total_strikes_attempted_per_second AS avg_r1_opp_total_strikes_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_total_strikes_attempted_per_second / t3.cumulative_r1_opp_total_strikes_attempted_per_second AS cumulative_r1_opp_total_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_landed / t3.avg_r1_opp_significant_strikes_landed AS avg_r1_opp_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_landed / t3.cumulative_r1_opp_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_landed_per_second / t3.avg_r1_opp_significant_strikes_landed_per_second AS avg_r1_opp_significant_strikes_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_landed_per_second / t3.cumulative_r1_opp_significant_strikes_landed_per_second AS cumulative_r1_opp_significant_strikes_landed_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_accuracy / t3.avg_r1_opp_significant_strikes_accuracy AS avg_r1_opp_significant_strikes_accuracy_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_accuracy / t3.cumulative_r1_opp_significant_strikes_accuracy AS cumulative_r1_opp_significant_strikes_accuracy_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_landed_per_total_strikes_landed / t3.avg_r1_opp_significant_strikes_landed_per_total_strikes_landed AS avg_r1_opp_significant_strikes_landed_per_total_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed / t3.cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed AS cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_attempted / t3.avg_r1_opp_significant_strikes_attempted AS avg_r1_opp_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_attempted / t3.cumulative_r1_opp_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_attempted_per_second / t3.avg_r1_opp_significant_strikes_attempted_per_second AS avg_r1_opp_significant_strikes_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_attempted_per_second / t3.cumulative_r1_opp_significant_strikes_attempted_per_second AS cumulative_r1_opp_significant_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted / t3.avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted AS avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted / t3.cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted AS cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_head_landed / t3.avg_r1_opp_significant_strikes_head_landed AS avg_r1_opp_significant_strikes_head_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_head_landed / t3.cumulative_r1_opp_significant_strikes_head_landed AS cumulative_r1_opp_significant_strikes_head_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_head_landed_per_second / t3.avg_r1_opp_significant_strikes_head_landed_per_second AS avg_r1_opp_significant_strikes_head_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_head_landed_per_second / t3.cumulative_r1_opp_significant_strikes_head_landed_per_second AS cumulative_r1_opp_significant_strikes_head_landed_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_head_accuracy / t3.avg_r1_opp_significant_strikes_head_accuracy AS avg_r1_opp_significant_strikes_head_accuracy_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_head_accuracy / t3.cumulative_r1_opp_significant_strikes_head_accuracy AS cumulative_r1_opp_significant_strikes_head_accuracy_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed / t3.avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed AS avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed / t3.cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_head_attempted / t3.avg_r1_opp_significant_strikes_head_attempted AS avg_r1_opp_significant_strikes_head_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_head_attempted / t3.cumulative_r1_opp_significant_strikes_head_attempted AS cumulative_r1_opp_significant_strikes_head_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_head_attempted_per_second / t3.avg_r1_opp_significant_strikes_head_attempted_per_second AS avg_r1_opp_significant_strikes_head_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_head_attempted_per_second / t3.cumulative_r1_opp_significant_strikes_head_attempted_per_second AS cumulative_r1_opp_significant_strikes_head_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted / t3.avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted AS avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted / t3.cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_body_landed / t3.avg_r1_opp_significant_strikes_body_landed AS avg_r1_opp_significant_strikes_body_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_body_landed / t3.cumulative_r1_opp_significant_strikes_body_landed AS cumulative_r1_opp_significant_strikes_body_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_body_landed_per_second / t3.avg_r1_opp_significant_strikes_body_landed_per_second AS avg_r1_opp_significant_strikes_body_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_body_landed_per_second / t3.cumulative_r1_opp_significant_strikes_body_landed_per_second AS cumulative_r1_opp_significant_strikes_body_landed_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_body_accuracy / t3.avg_r1_opp_significant_strikes_body_accuracy AS avg_r1_opp_significant_strikes_body_accuracy_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_body_accuracy / t3.cumulative_r1_opp_significant_strikes_body_accuracy AS cumulative_r1_opp_significant_strikes_body_accuracy_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed / t3.avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed AS avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed / t3.cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_body_attempted / t3.avg_r1_opp_significant_strikes_body_attempted AS avg_r1_opp_significant_strikes_body_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_body_attempted / t3.cumulative_r1_opp_significant_strikes_body_attempted AS cumulative_r1_opp_significant_strikes_body_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_body_attempted_per_second / t3.avg_r1_opp_significant_strikes_body_attempted_per_second AS avg_r1_opp_significant_strikes_body_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_body_attempted_per_second / t3.cumulative_r1_opp_significant_strikes_body_attempted_per_second AS cumulative_r1_opp_significant_strikes_body_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted / t3.avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted AS avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted / t3.cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_leg_landed / t3.avg_r1_opp_significant_strikes_leg_landed AS avg_r1_opp_significant_strikes_leg_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_leg_landed / t3.cumulative_r1_opp_significant_strikes_leg_landed AS cumulative_r1_opp_significant_strikes_leg_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_leg_landed_per_second / t3.avg_r1_opp_significant_strikes_leg_landed_per_second AS avg_r1_opp_significant_strikes_leg_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_leg_landed_per_second / t3.cumulative_r1_opp_significant_strikes_leg_landed_per_second AS cumulative_r1_opp_significant_strikes_leg_landed_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_leg_accuracy / t3.avg_r1_opp_significant_strikes_leg_accuracy AS avg_r1_opp_significant_strikes_leg_accuracy_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_leg_accuracy / t3.cumulative_r1_opp_significant_strikes_leg_accuracy AS cumulative_r1_opp_significant_strikes_leg_accuracy_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed / t3.avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed AS avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed / t3.cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_leg_attempted / t3.avg_r1_opp_significant_strikes_leg_attempted AS avg_r1_opp_significant_strikes_leg_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_leg_attempted / t3.cumulative_r1_opp_significant_strikes_leg_attempted AS cumulative_r1_opp_significant_strikes_leg_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_leg_attempted_per_second / t3.avg_r1_opp_significant_strikes_leg_attempted_per_second AS avg_r1_opp_significant_strikes_leg_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_leg_attempted_per_second / t3.cumulative_r1_opp_significant_strikes_leg_attempted_per_second AS cumulative_r1_opp_significant_strikes_leg_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted / t3.avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted AS avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted / t3.cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_distance_landed / t3.avg_r1_opp_significant_strikes_distance_landed AS avg_r1_opp_significant_strikes_distance_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_distance_landed / t3.cumulative_r1_opp_significant_strikes_distance_landed AS cumulative_r1_opp_significant_strikes_distance_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_distance_landed_per_second / t3.avg_r1_opp_significant_strikes_distance_landed_per_second AS avg_r1_opp_significant_strikes_distance_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_distance_landed_per_second / t3.cumulative_r1_opp_significant_strikes_distance_landed_per_second AS cumulative_r1_opp_significant_strikes_distance_landed_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_distance_accuracy / t3.avg_r1_opp_significant_strikes_distance_accuracy AS avg_r1_opp_significant_strikes_distance_accuracy_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_distance_accuracy / t3.cumulative_r1_opp_significant_strikes_distance_accuracy AS cumulative_r1_opp_significant_strikes_distance_accuracy_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed / t3.avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed AS avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed / t3.cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_distance_attempted / t3.avg_r1_opp_significant_strikes_distance_attempted AS avg_r1_opp_significant_strikes_distance_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_distance_attempted / t3.cumulative_r1_opp_significant_strikes_distance_attempted AS cumulative_r1_opp_significant_strikes_distance_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_distance_attempted_per_second / t3.avg_r1_opp_significant_strikes_distance_attempted_per_second AS avg_r1_opp_significant_strikes_distance_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_distance_attempted_per_second / t3.cumulative_r1_opp_significant_strikes_distance_attempted_per_second AS cumulative_r1_opp_significant_strikes_distance_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted / t3.avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted AS avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted / t3.cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_clinch_landed / t3.avg_r1_opp_significant_strikes_clinch_landed AS avg_r1_opp_significant_strikes_clinch_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_clinch_landed / t3.cumulative_r1_opp_significant_strikes_clinch_landed AS cumulative_r1_opp_significant_strikes_clinch_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_clinch_landed_per_second / t3.avg_r1_opp_significant_strikes_clinch_landed_per_second AS avg_r1_opp_significant_strikes_clinch_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_clinch_landed_per_second / t3.cumulative_r1_opp_significant_strikes_clinch_landed_per_second AS cumulative_r1_opp_significant_strikes_clinch_landed_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_clinch_accuracy / t3.avg_r1_opp_significant_strikes_clinch_accuracy AS avg_r1_opp_significant_strikes_clinch_accuracy_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_clinch_accuracy / t3.cumulative_r1_opp_significant_strikes_clinch_accuracy AS cumulative_r1_opp_significant_strikes_clinch_accuracy_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed / t3.avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed AS avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed / t3.cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_clinch_attempted / t3.avg_r1_opp_significant_strikes_clinch_attempted AS avg_r1_opp_significant_strikes_clinch_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_clinch_attempted / t3.cumulative_r1_opp_significant_strikes_clinch_attempted AS cumulative_r1_opp_significant_strikes_clinch_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_clinch_attempted_per_second / t3.avg_r1_opp_significant_strikes_clinch_attempted_per_second AS avg_r1_opp_significant_strikes_clinch_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_clinch_attempted_per_second / t3.cumulative_r1_opp_significant_strikes_clinch_attempted_per_second AS cumulative_r1_opp_significant_strikes_clinch_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted / t3.avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted AS avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted / t3.cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_ground_landed / t3.avg_r1_opp_significant_strikes_ground_landed AS avg_r1_opp_significant_strikes_ground_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_ground_landed / t3.cumulative_r1_opp_significant_strikes_ground_landed AS cumulative_r1_opp_significant_strikes_ground_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_ground_landed_per_second / t3.avg_r1_opp_significant_strikes_ground_landed_per_second AS avg_r1_opp_significant_strikes_ground_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_ground_landed_per_second / t3.cumulative_r1_opp_significant_strikes_ground_landed_per_second AS cumulative_r1_opp_significant_strikes_ground_landed_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_ground_accuracy / t3.avg_r1_opp_significant_strikes_ground_accuracy AS avg_r1_opp_significant_strikes_ground_accuracy_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_ground_accuracy / t3.cumulative_r1_opp_significant_strikes_ground_accuracy AS cumulative_r1_opp_significant_strikes_ground_accuracy_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed / t3.avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed AS avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed / t3.cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed AS cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_ground_attempted / t3.avg_r1_opp_significant_strikes_ground_attempted AS avg_r1_opp_significant_strikes_ground_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_ground_attempted / t3.cumulative_r1_opp_significant_strikes_ground_attempted AS cumulative_r1_opp_significant_strikes_ground_attempted_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_ground_attempted_per_second / t3.avg_r1_opp_significant_strikes_ground_attempted_per_second AS avg_r1_opp_significant_strikes_ground_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_ground_attempted_per_second / t3.cumulative_r1_opp_significant_strikes_ground_attempted_per_second AS cumulative_r1_opp_significant_strikes_ground_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted / t3.avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted AS avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted / t3.cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted AS cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_r1_opp_takedowns_landed / t3.avg_r1_opp_takedowns_landed AS avg_r1_opp_takedowns_landed_ratio,
    1.0 * t2.cumulative_r1_opp_takedowns_landed / t3.cumulative_r1_opp_takedowns_landed AS cumulative_r1_opp_takedowns_landed_ratio,
    1.0 * t2.avg_r1_opp_takedowns_landed_per_second / t3.avg_r1_opp_takedowns_landed_per_second AS avg_r1_opp_takedowns_landed_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_takedowns_landed_per_second / t3.cumulative_r1_opp_takedowns_landed_per_second AS cumulative_r1_opp_takedowns_landed_per_second_ratio,
    1.0 * t2.avg_r1_opp_takedowns_accuracy / t3.avg_r1_opp_takedowns_accuracy AS avg_r1_opp_takedowns_accuracy_ratio,
    1.0 * t2.cumulative_r1_opp_takedowns_accuracy / t3.cumulative_r1_opp_takedowns_accuracy AS cumulative_r1_opp_takedowns_accuracy_ratio,
    1.0 * t2.avg_r1_opp_takedowns_attempted / t3.avg_r1_opp_takedowns_attempted AS avg_r1_opp_takedowns_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_takedowns_attempted / t3.cumulative_r1_opp_takedowns_attempted AS cumulative_r1_opp_takedowns_attempted_ratio,
    1.0 * t2.avg_r1_opp_takedowns_attempted_per_second / t3.avg_r1_opp_takedowns_attempted_per_second AS avg_r1_opp_takedowns_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_takedowns_attempted_per_second / t3.cumulative_r1_opp_takedowns_attempted_per_second AS cumulative_r1_opp_takedowns_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_reversals_scored / t3.avg_r1_opp_reversals_scored AS avg_r1_opp_reversals_scored_ratio,
    1.0 * t2.cumulative_r1_opp_reversals_scored / t3.cumulative_r1_opp_reversals_scored AS cumulative_r1_opp_reversals_scored_ratio,
    1.0 * t2.avg_r1_opp_reversals_scored_per_second / t3.avg_r1_opp_reversals_scored_per_second AS avg_r1_opp_reversals_scored_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_reversals_scored_per_second / t3.cumulative_r1_opp_reversals_scored_per_second AS cumulative_r1_opp_reversals_scored_per_second_ratio,
    1.0 * t2.avg_r1_opp_submissions_attempted / t3.avg_r1_opp_submissions_attempted AS avg_r1_opp_submissions_attempted_ratio,
    1.0 * t2.cumulative_r1_opp_submissions_attempted / t3.cumulative_r1_opp_submissions_attempted AS cumulative_r1_opp_submissions_attempted_ratio,
    1.0 * t2.avg_r1_opp_submissions_attempted_per_second / t3.avg_r1_opp_submissions_attempted_per_second AS avg_r1_opp_submissions_attempted_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_submissions_attempted_per_second / t3.cumulative_r1_opp_submissions_attempted_per_second AS cumulative_r1_opp_submissions_attempted_per_second_ratio,
    1.0 * t2.avg_r1_opp_control_time_seconds / t3.avg_r1_opp_control_time_seconds AS avg_r1_opp_control_time_seconds_ratio,
    1.0 * t2.cumulative_r1_opp_control_time_seconds / t3.cumulative_r1_opp_control_time_seconds AS cumulative_r1_opp_control_time_seconds_ratio,
    1.0 * t2.avg_r1_opp_control_time_seconds_per_second / t3.avg_r1_opp_control_time_seconds_per_second AS avg_r1_opp_control_time_seconds_per_second_ratio,
    1.0 * t2.cumulative_r1_opp_control_time_seconds_per_second / t3.cumulative_r1_opp_control_time_seconds_per_second AS cumulative_r1_opp_control_time_seconds_per_second_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_diff / t3.avg_r1_knockdowns_scored_diff AS avg_r1_knockdowns_scored_diff_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_second_diff / t3.avg_r1_knockdowns_scored_per_second_diff AS avg_r1_knockdowns_scored_per_second_diff_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_strike_landed_diff / t3.avg_r1_knockdowns_scored_per_strike_landed_diff AS avg_r1_knockdowns_scored_per_strike_landed_diff_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_strike_attempted_diff / t3.avg_r1_knockdowns_scored_per_strike_attempted_diff AS avg_r1_knockdowns_scored_per_strike_attempted_diff_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_significant_strike_landed_diff / t3.avg_r1_knockdowns_scored_per_significant_strike_landed_diff AS avg_r1_knockdowns_scored_per_significant_strike_landed_diff_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_significant_strike_attempted_diff / t3.avg_r1_knockdowns_scored_per_significant_strike_attempted_diff AS avg_r1_knockdowns_scored_per_significant_strike_attempted_diff_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff / t3.avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff AS avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff_ratio,
    1.0 * t2.avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff / t3.avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff AS avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff_ratio,
    1.0 * t2.avg_r1_total_strikes_landed_diff / t3.avg_r1_total_strikes_landed_diff AS avg_r1_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_r1_total_strikes_landed_per_second_diff / t3.avg_r1_total_strikes_landed_per_second_diff AS avg_r1_total_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_r1_total_strikes_accuracy_diff / t3.avg_r1_total_strikes_accuracy_diff AS avg_r1_total_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_r1_total_strikes_attempted_diff / t3.avg_r1_total_strikes_attempted_diff AS avg_r1_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_r1_total_strikes_attempted_per_second_diff / t3.avg_r1_total_strikes_attempted_per_second_diff AS avg_r1_total_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_landed_diff / t3.avg_r1_significant_strikes_landed_diff AS avg_r1_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_landed_per_second_diff / t3.avg_r1_significant_strikes_landed_per_second_diff AS avg_r1_significant_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_accuracy_diff / t3.avg_r1_significant_strikes_accuracy_diff AS avg_r1_significant_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_landed_per_total_strikes_landed_diff / t3.avg_r1_significant_strikes_landed_per_total_strikes_landed_diff AS avg_r1_significant_strikes_landed_per_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_attempted_diff / t3.avg_r1_significant_strikes_attempted_diff AS avg_r1_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_attempted_per_second_diff / t3.avg_r1_significant_strikes_attempted_per_second_diff AS avg_r1_significant_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff / t3.avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff AS avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_landed_diff / t3.avg_r1_significant_strikes_head_landed_diff AS avg_r1_significant_strikes_head_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_landed_per_second_diff / t3.avg_r1_significant_strikes_head_landed_per_second_diff AS avg_r1_significant_strikes_head_landed_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_accuracy_diff / t3.avg_r1_significant_strikes_head_accuracy_diff AS avg_r1_significant_strikes_head_accuracy_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff / t3.avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff AS avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_attempted_diff / t3.avg_r1_significant_strikes_head_attempted_diff AS avg_r1_significant_strikes_head_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_attempted_per_second_diff / t3.avg_r1_significant_strikes_head_attempted_per_second_diff AS avg_r1_significant_strikes_head_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff / t3.avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff AS avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_landed_diff / t3.avg_r1_significant_strikes_body_landed_diff AS avg_r1_significant_strikes_body_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_landed_per_second_diff / t3.avg_r1_significant_strikes_body_landed_per_second_diff AS avg_r1_significant_strikes_body_landed_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_accuracy_diff / t3.avg_r1_significant_strikes_body_accuracy_diff AS avg_r1_significant_strikes_body_accuracy_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff / t3.avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff AS avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_attempted_diff / t3.avg_r1_significant_strikes_body_attempted_diff AS avg_r1_significant_strikes_body_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_attempted_per_second_diff / t3.avg_r1_significant_strikes_body_attempted_per_second_diff AS avg_r1_significant_strikes_body_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff / t3.avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff AS avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_landed_diff / t3.avg_r1_significant_strikes_leg_landed_diff AS avg_r1_significant_strikes_leg_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_landed_per_second_diff / t3.avg_r1_significant_strikes_leg_landed_per_second_diff AS avg_r1_significant_strikes_leg_landed_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_accuracy_diff / t3.avg_r1_significant_strikes_leg_accuracy_diff AS avg_r1_significant_strikes_leg_accuracy_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff / t3.avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff AS avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_attempted_diff / t3.avg_r1_significant_strikes_leg_attempted_diff AS avg_r1_significant_strikes_leg_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_attempted_per_second_diff / t3.avg_r1_significant_strikes_leg_attempted_per_second_diff AS avg_r1_significant_strikes_leg_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff / t3.avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff AS avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_landed_diff / t3.avg_r1_significant_strikes_distance_landed_diff AS avg_r1_significant_strikes_distance_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_landed_per_second_diff / t3.avg_r1_significant_strikes_distance_landed_per_second_diff AS avg_r1_significant_strikes_distance_landed_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_accuracy_diff / t3.avg_r1_significant_strikes_distance_accuracy_diff AS avg_r1_significant_strikes_distance_accuracy_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff / t3.avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff AS avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_attempted_diff / t3.avg_r1_significant_strikes_distance_attempted_diff AS avg_r1_significant_strikes_distance_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_attempted_per_second_diff / t3.avg_r1_significant_strikes_distance_attempted_per_second_diff AS avg_r1_significant_strikes_distance_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff / t3.avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff AS avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_landed_diff / t3.avg_r1_significant_strikes_clinch_landed_diff AS avg_r1_significant_strikes_clinch_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_landed_per_second_diff / t3.avg_r1_significant_strikes_clinch_landed_per_second_diff AS avg_r1_significant_strikes_clinch_landed_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_accuracy_diff / t3.avg_r1_significant_strikes_clinch_accuracy_diff AS avg_r1_significant_strikes_clinch_accuracy_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff / t3.avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff AS avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_attempted_diff / t3.avg_r1_significant_strikes_clinch_attempted_diff AS avg_r1_significant_strikes_clinch_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_attempted_per_second_diff / t3.avg_r1_significant_strikes_clinch_attempted_per_second_diff AS avg_r1_significant_strikes_clinch_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff / t3.avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff AS avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_landed_diff / t3.avg_r1_significant_strikes_ground_landed_diff AS avg_r1_significant_strikes_ground_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_landed_per_second_diff / t3.avg_r1_significant_strikes_ground_landed_per_second_diff AS avg_r1_significant_strikes_ground_landed_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_accuracy_diff / t3.avg_r1_significant_strikes_ground_accuracy_diff AS avg_r1_significant_strikes_ground_accuracy_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff / t3.avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff AS avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_attempted_diff / t3.avg_r1_significant_strikes_ground_attempted_diff AS avg_r1_significant_strikes_ground_attempted_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_attempted_per_second_diff / t3.avg_r1_significant_strikes_ground_attempted_per_second_diff AS avg_r1_significant_strikes_ground_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff / t3.avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff AS avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_r1_takedowns_landed_diff / t3.avg_r1_takedowns_landed_diff AS avg_r1_takedowns_landed_diff_ratio,
    1.0 * t2.avg_r1_takedowns_landed_per_second_diff / t3.avg_r1_takedowns_landed_per_second_diff AS avg_r1_takedowns_landed_per_second_diff_ratio,
    1.0 * t2.avg_r1_takedowns_accuracy_diff / t3.avg_r1_takedowns_accuracy_diff AS avg_r1_takedowns_accuracy_diff_ratio,
    1.0 * t2.avg_r1_takedowns_attempted_diff / t3.avg_r1_takedowns_attempted_diff AS avg_r1_takedowns_attempted_diff_ratio,
    1.0 * t2.avg_r1_takedowns_attempted_per_second_diff / t3.avg_r1_takedowns_attempted_per_second_diff AS avg_r1_takedowns_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_reversals_scored_diff / t3.avg_r1_reversals_scored_diff AS avg_r1_reversals_scored_diff_ratio,
    1.0 * t2.avg_r1_reversals_scored_per_second_diff / t3.avg_r1_reversals_scored_per_second_diff AS avg_r1_reversals_scored_per_second_diff_ratio,
    1.0 * t2.avg_r1_submissions_attempted_diff / t3.avg_r1_submissions_attempted_diff AS avg_r1_submissions_attempted_diff_ratio,
    1.0 * t2.avg_r1_submissions_attempted_per_second_diff / t3.avg_r1_submissions_attempted_per_second_diff AS avg_r1_submissions_attempted_per_second_diff_ratio,
    1.0 * t2.avg_r1_control_time_seconds_diff / t3.avg_r1_control_time_seconds_diff AS avg_r1_control_time_seconds_diff_ratio,
    1.0 * t2.avg_r1_control_time_seconds_per_second_diff / t3.avg_r1_control_time_seconds_per_second_diff AS avg_r1_control_time_seconds_per_second_diff_ratio,
    1.0 * t2.avg_opp_r1_knockdowns_scored / t3.avg_opp_r1_knockdowns_scored AS avg_opp_r1_knockdowns_scored_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_diff / t3.avg_avg_r1_knockdowns_scored_diff AS avg_avg_r1_knockdowns_scored_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_knockdowns_scored / t3.avg_opp_cumulative_r1_knockdowns_scored AS avg_opp_cumulative_r1_knockdowns_scored_ratio,
    1.0 * t2.avg_cumulative_r1_knockdowns_scored_diff / t3.avg_cumulative_r1_knockdowns_scored_diff AS avg_cumulative_r1_knockdowns_scored_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_second / t3.avg_opp_avg_r1_knockdowns_scored_per_second AS avg_opp_avg_r1_knockdowns_scored_per_second_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_second_diff / t3.avg_avg_r1_knockdowns_scored_per_second_diff AS avg_avg_r1_knockdowns_scored_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_knockdowns_scored_per_second / t3.avg_opp_cumulative_r1_knockdowns_scored_per_second AS avg_opp_cumulative_r1_knockdowns_scored_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_knockdowns_scored_per_second_diff / t3.avg_cumulative_r1_knockdowns_scored_per_second_diff AS avg_cumulative_r1_knockdowns_scored_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_strike_landed / t3.avg_opp_avg_r1_knockdowns_scored_per_strike_landed AS avg_opp_avg_r1_knockdowns_scored_per_strike_landed_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_strike_landed_diff / t3.avg_avg_r1_knockdowns_scored_per_strike_landed_diff AS avg_avg_r1_knockdowns_scored_per_strike_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_knockdowns_scored_per_strike_landed / t3.avg_opp_cumulative_r1_knockdowns_scored_per_strike_landed AS avg_opp_cumulative_r1_knockdowns_scored_per_strike_landed_ratio,
    1.0 * t2.avg_cumulative_r1_knockdowns_scored_per_strike_landed_diff / t3.avg_cumulative_r1_knockdowns_scored_per_strike_landed_diff AS avg_cumulative_r1_knockdowns_scored_per_strike_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_strike_attempted / t3.avg_opp_avg_r1_knockdowns_scored_per_strike_attempted AS avg_opp_avg_r1_knockdowns_scored_per_strike_attempted_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_strike_attempted_diff / t3.avg_avg_r1_knockdowns_scored_per_strike_attempted_diff AS avg_avg_r1_knockdowns_scored_per_strike_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_knockdowns_scored_per_strike_attempted / t3.avg_opp_cumulative_r1_knockdowns_scored_per_strike_attempted AS avg_opp_cumulative_r1_knockdowns_scored_per_strike_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_knockdowns_scored_per_strike_attempted_diff / t3.avg_cumulative_r1_knockdowns_scored_per_strike_attempted_diff AS avg_cumulative_r1_knockdowns_scored_per_strike_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_landed / t3.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_landed AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_landed_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_significant_strike_landed_diff / t3.avg_avg_r1_knockdowns_scored_per_significant_strike_landed_diff AS avg_avg_r1_knockdowns_scored_per_significant_strike_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_landed / t3.avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_landed AS avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_landed_ratio,
    1.0 * t2.avg_cumulative_r1_knockdowns_scored_per_significant_strike_landed_diff / t3.avg_cumulative_r1_knockdowns_scored_per_significant_strike_landed_diff AS avg_cumulative_r1_knockdowns_scored_per_significant_strike_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_attempted / t3.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_attempted AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_attempted_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff / t3.avg_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff AS avg_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_attempted / t3.avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_attempted AS avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_knockdowns_scored_per_significant_strike_attempted_diff / t3.avg_cumulative_r1_knockdowns_scored_per_significant_strike_attempted_diff AS avg_cumulative_r1_knockdowns_scored_per_significant_strike_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_landed / t3.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_landed AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_landed_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff / t3.avg_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff AS avg_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_head_landed / t3.avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_head_landed AS avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_head_landed_ratio,
    1.0 * t2.avg_cumulative_r1_knockdowns_scored_per_significant_strike_head_landed_diff / t3.avg_cumulative_r1_knockdowns_scored_per_significant_strike_head_landed_diff AS avg_cumulative_r1_knockdowns_scored_per_significant_strike_head_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_attempted / t3.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_attempted AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff / t3.avg_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff AS avg_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted / t3.avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted AS avg_opp_cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted_diff / t3.avg_cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted_diff AS avg_cumulative_r1_knockdowns_scored_per_significant_strike_head_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_landed / t3.avg_opp_avg_r1_total_strikes_landed AS avg_opp_avg_r1_total_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_landed_diff / t3.avg_avg_r1_total_strikes_landed_diff AS avg_avg_r1_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_total_strikes_landed / t3.avg_opp_cumulative_r1_total_strikes_landed AS avg_opp_cumulative_r1_total_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_total_strikes_landed_diff / t3.avg_cumulative_r1_total_strikes_landed_diff AS avg_cumulative_r1_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_landed_per_second / t3.avg_opp_avg_r1_total_strikes_landed_per_second AS avg_opp_avg_r1_total_strikes_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_landed_per_second_diff / t3.avg_avg_r1_total_strikes_landed_per_second_diff AS avg_avg_r1_total_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_total_strikes_landed_per_second / t3.avg_opp_cumulative_r1_total_strikes_landed_per_second AS avg_opp_cumulative_r1_total_strikes_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_total_strikes_landed_per_second_diff / t3.avg_cumulative_r1_total_strikes_landed_per_second_diff AS avg_cumulative_r1_total_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_accuracy / t3.avg_opp_avg_r1_total_strikes_accuracy AS avg_opp_avg_r1_total_strikes_accuracy_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_accuracy_diff / t3.avg_avg_r1_total_strikes_accuracy_diff AS avg_avg_r1_total_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_total_strikes_accuracy / t3.avg_opp_cumulative_r1_total_strikes_accuracy AS avg_opp_cumulative_r1_total_strikes_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_total_strikes_accuracy_diff / t3.avg_cumulative_r1_total_strikes_accuracy_diff AS avg_cumulative_r1_total_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_attempted / t3.avg_opp_avg_r1_total_strikes_attempted AS avg_opp_avg_r1_total_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_attempted_diff / t3.avg_avg_r1_total_strikes_attempted_diff AS avg_avg_r1_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_total_strikes_attempted / t3.avg_opp_cumulative_r1_total_strikes_attempted AS avg_opp_cumulative_r1_total_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_total_strikes_attempted_diff / t3.avg_cumulative_r1_total_strikes_attempted_diff AS avg_cumulative_r1_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_attempted_per_second / t3.avg_opp_avg_r1_total_strikes_attempted_per_second AS avg_opp_avg_r1_total_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_attempted_per_second_diff / t3.avg_avg_r1_total_strikes_attempted_per_second_diff AS avg_avg_r1_total_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_total_strikes_attempted_per_second / t3.avg_opp_cumulative_r1_total_strikes_attempted_per_second AS avg_opp_cumulative_r1_total_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_total_strikes_attempted_per_second_diff / t3.avg_cumulative_r1_total_strikes_attempted_per_second_diff AS avg_cumulative_r1_total_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_landed / t3.avg_opp_avg_r1_significant_strikes_landed AS avg_opp_avg_r1_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_landed_diff / t3.avg_avg_r1_significant_strikes_landed_diff AS avg_avg_r1_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_landed / t3.avg_opp_cumulative_r1_significant_strikes_landed AS avg_opp_cumulative_r1_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_landed_diff / t3.avg_cumulative_r1_significant_strikes_landed_diff AS avg_cumulative_r1_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_landed_per_second / t3.avg_opp_avg_r1_significant_strikes_landed_per_second AS avg_opp_avg_r1_significant_strikes_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_landed_per_second_diff / t3.avg_avg_r1_significant_strikes_landed_per_second_diff AS avg_avg_r1_significant_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_landed_per_second / t3.avg_opp_cumulative_r1_significant_strikes_landed_per_second AS avg_opp_cumulative_r1_significant_strikes_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_landed_per_second_diff / t3.avg_cumulative_r1_significant_strikes_landed_per_second_diff AS avg_cumulative_r1_significant_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_accuracy / t3.avg_opp_avg_r1_significant_strikes_accuracy AS avg_opp_avg_r1_significant_strikes_accuracy_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_accuracy_diff / t3.avg_avg_r1_significant_strikes_accuracy_diff AS avg_avg_r1_significant_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_accuracy / t3.avg_opp_cumulative_r1_significant_strikes_accuracy AS avg_opp_cumulative_r1_significant_strikes_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_accuracy_diff / t3.avg_cumulative_r1_significant_strikes_accuracy_diff AS avg_cumulative_r1_significant_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_landed_per_total_strikes_landed / t3.avg_opp_avg_r1_significant_strikes_landed_per_total_strikes_landed AS avg_opp_avg_r1_significant_strikes_landed_per_total_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff / t3.avg_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff AS avg_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_landed_per_total_strikes_landed / t3.avg_opp_cumulative_r1_significant_strikes_landed_per_total_strikes_landed AS avg_opp_cumulative_r1_significant_strikes_landed_per_total_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_landed_per_total_strikes_landed_diff / t3.avg_cumulative_r1_significant_strikes_landed_per_total_strikes_landed_diff AS avg_cumulative_r1_significant_strikes_landed_per_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_attempted / t3.avg_opp_avg_r1_significant_strikes_attempted AS avg_opp_avg_r1_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_attempted_diff / t3.avg_avg_r1_significant_strikes_attempted_diff AS avg_avg_r1_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_attempted / t3.avg_opp_cumulative_r1_significant_strikes_attempted AS avg_opp_cumulative_r1_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_attempted_diff / t3.avg_cumulative_r1_significant_strikes_attempted_diff AS avg_cumulative_r1_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_attempted_per_second / t3.avg_opp_avg_r1_significant_strikes_attempted_per_second AS avg_opp_avg_r1_significant_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_attempted_per_second_diff / t3.avg_avg_r1_significant_strikes_attempted_per_second_diff AS avg_avg_r1_significant_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_attempted_per_second / t3.avg_opp_cumulative_r1_significant_strikes_attempted_per_second AS avg_opp_cumulative_r1_significant_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_attempted_per_total_strikes_attempted / t3.avg_opp_avg_r1_significant_strikes_attempted_per_total_strikes_attempted AS avg_opp_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff / t3.avg_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff AS avg_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted / t3.avg_opp_cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted AS avg_opp_cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted_diff / t3.avg_cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted_diff AS avg_cumulative_r1_significant_strikes_attempted_per_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_landed / t3.avg_opp_avg_r1_significant_strikes_head_landed AS avg_opp_avg_r1_significant_strikes_head_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_landed_diff / t3.avg_avg_r1_significant_strikes_head_landed_diff AS avg_avg_r1_significant_strikes_head_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_head_landed / t3.avg_opp_cumulative_r1_significant_strikes_head_landed AS avg_opp_cumulative_r1_significant_strikes_head_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_head_landed_diff / t3.avg_cumulative_r1_significant_strikes_head_landed_diff AS avg_cumulative_r1_significant_strikes_head_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_landed_per_second / t3.avg_opp_avg_r1_significant_strikes_head_landed_per_second AS avg_opp_avg_r1_significant_strikes_head_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_landed_per_second_diff / t3.avg_avg_r1_significant_strikes_head_landed_per_second_diff AS avg_avg_r1_significant_strikes_head_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_head_landed_per_second / t3.avg_opp_cumulative_r1_significant_strikes_head_landed_per_second AS avg_opp_cumulative_r1_significant_strikes_head_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_head_landed_per_second_diff / t3.avg_cumulative_r1_significant_strikes_head_landed_per_second_diff AS avg_cumulative_r1_significant_strikes_head_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_accuracy / t3.avg_opp_avg_r1_significant_strikes_head_accuracy AS avg_opp_avg_r1_significant_strikes_head_accuracy_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_accuracy_diff / t3.avg_avg_r1_significant_strikes_head_accuracy_diff AS avg_avg_r1_significant_strikes_head_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_head_accuracy / t3.avg_opp_cumulative_r1_significant_strikes_head_accuracy AS avg_opp_cumulative_r1_significant_strikes_head_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_head_accuracy_diff / t3.avg_cumulative_r1_significant_strikes_head_accuracy_diff AS avg_cumulative_r1_significant_strikes_head_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed AS avg_opp_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff AS avg_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_attempted / t3.avg_opp_avg_r1_significant_strikes_head_attempted AS avg_opp_avg_r1_significant_strikes_head_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_attempted_diff / t3.avg_avg_r1_significant_strikes_head_attempted_diff AS avg_avg_r1_significant_strikes_head_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_head_attempted / t3.avg_opp_cumulative_r1_significant_strikes_head_attempted AS avg_opp_cumulative_r1_significant_strikes_head_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_head_attempted_diff / t3.avg_cumulative_r1_significant_strikes_head_attempted_diff AS avg_cumulative_r1_significant_strikes_head_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_attempted_per_second / t3.avg_opp_avg_r1_significant_strikes_head_attempted_per_second AS avg_opp_avg_r1_significant_strikes_head_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_attempted_per_second_diff / t3.avg_avg_r1_significant_strikes_head_attempted_per_second_diff AS avg_avg_r1_significant_strikes_head_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_head_attempted_per_second / t3.avg_opp_cumulative_r1_significant_strikes_head_attempted_per_second AS avg_opp_cumulative_r1_significant_strikes_head_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_head_attempted_per_second_diff / t3.avg_cumulative_r1_significant_strikes_head_attempted_per_second_diff AS avg_cumulative_r1_significant_strikes_head_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_landed / t3.avg_opp_avg_r1_significant_strikes_body_landed AS avg_opp_avg_r1_significant_strikes_body_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_landed_diff / t3.avg_avg_r1_significant_strikes_body_landed_diff AS avg_avg_r1_significant_strikes_body_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_body_landed / t3.avg_opp_cumulative_r1_significant_strikes_body_landed AS avg_opp_cumulative_r1_significant_strikes_body_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_body_landed_diff / t3.avg_cumulative_r1_significant_strikes_body_landed_diff AS avg_cumulative_r1_significant_strikes_body_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_landed_per_second / t3.avg_opp_avg_r1_significant_strikes_body_landed_per_second AS avg_opp_avg_r1_significant_strikes_body_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_landed_per_second_diff / t3.avg_avg_r1_significant_strikes_body_landed_per_second_diff AS avg_avg_r1_significant_strikes_body_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_body_landed_per_second / t3.avg_opp_cumulative_r1_significant_strikes_body_landed_per_second AS avg_opp_cumulative_r1_significant_strikes_body_landed_per_second_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_accuracy / t3.avg_opp_avg_r1_significant_strikes_body_accuracy AS avg_opp_avg_r1_significant_strikes_body_accuracy_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_accuracy_diff / t3.avg_avg_r1_significant_strikes_body_accuracy_diff AS avg_avg_r1_significant_strikes_body_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_body_accuracy / t3.avg_opp_cumulative_r1_significant_strikes_body_accuracy AS avg_opp_cumulative_r1_significant_strikes_body_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_body_accuracy_diff / t3.avg_cumulative_r1_significant_strikes_body_accuracy_diff AS avg_cumulative_r1_significant_strikes_body_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed AS avg_opp_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff AS avg_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_attempted / t3.avg_opp_avg_r1_significant_strikes_body_attempted AS avg_opp_avg_r1_significant_strikes_body_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_attempted_diff / t3.avg_avg_r1_significant_strikes_body_attempted_diff AS avg_avg_r1_significant_strikes_body_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_body_attempted / t3.avg_opp_cumulative_r1_significant_strikes_body_attempted AS avg_opp_cumulative_r1_significant_strikes_body_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_body_attempted_diff / t3.avg_cumulative_r1_significant_strikes_body_attempted_diff AS avg_cumulative_r1_significant_strikes_body_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_attempted_per_second / t3.avg_opp_avg_r1_significant_strikes_body_attempted_per_second AS avg_opp_avg_r1_significant_strikes_body_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_attempted_per_second_diff / t3.avg_avg_r1_significant_strikes_body_attempted_per_second_diff AS avg_avg_r1_significant_strikes_body_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_body_attempted_per_second / t3.avg_opp_cumulative_r1_significant_strikes_body_attempted_per_second AS avg_opp_cumulative_r1_significant_strikes_body_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_body_attempted_per_second_diff / t3.avg_cumulative_r1_significant_strikes_body_attempted_per_second_diff AS avg_cumulative_r1_significant_strikes_body_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_landed / t3.avg_opp_avg_r1_significant_strikes_leg_landed AS avg_opp_avg_r1_significant_strikes_leg_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_landed_diff / t3.avg_avg_r1_significant_strikes_leg_landed_diff AS avg_avg_r1_significant_strikes_leg_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_leg_landed / t3.avg_opp_cumulative_r1_significant_strikes_leg_landed AS avg_opp_cumulative_r1_significant_strikes_leg_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_leg_landed_diff / t3.avg_cumulative_r1_significant_strikes_leg_landed_diff AS avg_cumulative_r1_significant_strikes_leg_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_landed_per_second / t3.avg_opp_avg_r1_significant_strikes_leg_landed_per_second AS avg_opp_avg_r1_significant_strikes_leg_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_landed_per_second_diff / t3.avg_avg_r1_significant_strikes_leg_landed_per_second_diff AS avg_avg_r1_significant_strikes_leg_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_leg_landed_per_second / t3.avg_opp_cumulative_r1_significant_strikes_leg_landed_per_second AS avg_opp_cumulative_r1_significant_strikes_leg_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_leg_landed_per_second_diff / t3.avg_cumulative_r1_significant_strikes_leg_landed_per_second_diff AS avg_cumulative_r1_significant_strikes_leg_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_accuracy / t3.avg_opp_avg_r1_significant_strikes_leg_accuracy AS avg_opp_avg_r1_significant_strikes_leg_accuracy_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_accuracy_diff / t3.avg_avg_r1_significant_strikes_leg_accuracy_diff AS avg_avg_r1_significant_strikes_leg_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_leg_accuracy / t3.avg_opp_cumulative_r1_significant_strikes_leg_accuracy AS avg_opp_cumulative_r1_significant_strikes_leg_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_leg_accuracy_diff / t3.avg_cumulative_r1_significant_strikes_leg_accuracy_diff AS avg_cumulative_r1_significant_strikes_leg_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed AS avg_opp_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff AS avg_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_attempted / t3.avg_opp_avg_r1_significant_strikes_leg_attempted AS avg_opp_avg_r1_significant_strikes_leg_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_attempted_diff / t3.avg_avg_r1_significant_strikes_leg_attempted_diff AS avg_avg_r1_significant_strikes_leg_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_leg_attempted / t3.avg_opp_cumulative_r1_significant_strikes_leg_attempted AS avg_opp_cumulative_r1_significant_strikes_leg_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_leg_attempted_diff / t3.avg_cumulative_r1_significant_strikes_leg_attempted_diff AS avg_cumulative_r1_significant_strikes_leg_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_attempted_per_second / t3.avg_opp_avg_r1_significant_strikes_leg_attempted_per_second AS avg_opp_avg_r1_significant_strikes_leg_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_attempted_per_second_diff / t3.avg_avg_r1_significant_strikes_leg_attempted_per_second_diff AS avg_avg_r1_significant_strikes_leg_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_leg_attempted_per_second / t3.avg_opp_cumulative_r1_significant_strikes_leg_attempted_per_second AS avg_opp_cumulative_r1_significant_strikes_leg_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_leg_attempted_per_second_diff / t3.avg_cumulative_r1_significant_strikes_leg_attempted_per_second_diff AS avg_cumulative_r1_significant_strikes_leg_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_landed / t3.avg_opp_avg_r1_significant_strikes_distance_landed AS avg_opp_avg_r1_significant_strikes_distance_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_landed_diff / t3.avg_avg_r1_significant_strikes_distance_landed_diff AS avg_avg_r1_significant_strikes_distance_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_distance_landed / t3.avg_opp_cumulative_r1_significant_strikes_distance_landed AS avg_opp_cumulative_r1_significant_strikes_distance_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_distance_landed_diff / t3.avg_cumulative_r1_significant_strikes_distance_landed_diff AS avg_cumulative_r1_significant_strikes_distance_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_landed_per_second / t3.avg_opp_avg_r1_significant_strikes_distance_landed_per_second AS avg_opp_avg_r1_significant_strikes_distance_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_landed_per_second_diff / t3.avg_avg_r1_significant_strikes_distance_landed_per_second_diff AS avg_avg_r1_significant_strikes_distance_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_distance_landed_per_second / t3.avg_opp_cumulative_r1_significant_strikes_distance_landed_per_second AS avg_opp_cumulative_r1_significant_strikes_distance_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_distance_landed_per_second_diff / t3.avg_cumulative_r1_significant_strikes_distance_landed_per_second_diff AS avg_cumulative_r1_significant_strikes_distance_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_accuracy / t3.avg_opp_avg_r1_significant_strikes_distance_accuracy AS avg_opp_avg_r1_significant_strikes_distance_accuracy_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_accuracy_diff / t3.avg_avg_r1_significant_strikes_distance_accuracy_diff AS avg_avg_r1_significant_strikes_distance_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_distance_accuracy / t3.avg_opp_cumulative_r1_significant_strikes_distance_accuracy AS avg_opp_cumulative_r1_significant_strikes_distance_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_distance_accuracy_diff / t3.avg_cumulative_r1_significant_strikes_distance_accuracy_diff AS avg_cumulative_r1_significant_strikes_distance_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed AS avg_opp_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff AS avg_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_attempted / t3.avg_opp_avg_r1_significant_strikes_distance_attempted AS avg_opp_avg_r1_significant_strikes_distance_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_attempted_diff / t3.avg_avg_r1_significant_strikes_distance_attempted_diff AS avg_avg_r1_significant_strikes_distance_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_distance_attempted / t3.avg_opp_cumulative_r1_significant_strikes_distance_attempted AS avg_opp_cumulative_r1_significant_strikes_distance_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_distance_attempted_diff / t3.avg_cumulative_r1_significant_strikes_distance_attempted_diff AS avg_cumulative_r1_significant_strikes_distance_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_attempted_per_second / t3.avg_opp_avg_r1_significant_strikes_distance_attempted_per_second AS avg_opp_avg_r1_significant_strikes_distance_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_attempted_per_second_diff / t3.avg_avg_r1_significant_strikes_distance_attempted_per_second_diff AS avg_avg_r1_significant_strikes_distance_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_distance_attempted_per_second / t3.avg_opp_cumulative_r1_significant_strikes_distance_attempted_per_second AS avg_opp_cumulative_r1_significant_strikes_distance_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_distance_attempted_per_second_diff / t3.avg_cumulative_r1_significant_strikes_distance_attempted_per_second_diff AS avg_cumulative_r1_significant_strikes_distance_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_landed / t3.avg_opp_avg_r1_significant_strikes_clinch_landed AS avg_opp_avg_r1_significant_strikes_clinch_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_landed_diff / t3.avg_avg_r1_significant_strikes_clinch_landed_diff AS avg_avg_r1_significant_strikes_clinch_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_clinch_landed / t3.avg_opp_cumulative_r1_significant_strikes_clinch_landed AS avg_opp_cumulative_r1_significant_strikes_clinch_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_clinch_landed_diff / t3.avg_cumulative_r1_significant_strikes_clinch_landed_diff AS avg_cumulative_r1_significant_strikes_clinch_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_landed_per_second / t3.avg_opp_avg_r1_significant_strikes_clinch_landed_per_second AS avg_opp_avg_r1_significant_strikes_clinch_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_landed_per_second_diff / t3.avg_avg_r1_significant_strikes_clinch_landed_per_second_diff AS avg_avg_r1_significant_strikes_clinch_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_clinch_landed_per_second / t3.avg_opp_cumulative_r1_significant_strikes_clinch_landed_per_second AS avg_opp_cumulative_r1_significant_strikes_clinch_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_clinch_landed_per_second_diff / t3.avg_cumulative_r1_significant_strikes_clinch_landed_per_second_diff AS avg_cumulative_r1_significant_strikes_clinch_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_accuracy / t3.avg_opp_avg_r1_significant_strikes_clinch_accuracy AS avg_opp_avg_r1_significant_strikes_clinch_accuracy_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_accuracy_diff / t3.avg_avg_r1_significant_strikes_clinch_accuracy_diff AS avg_avg_r1_significant_strikes_clinch_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_clinch_accuracy / t3.avg_opp_cumulative_r1_significant_strikes_clinch_accuracy AS avg_opp_cumulative_r1_significant_strikes_clinch_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_clinch_accuracy_diff / t3.avg_cumulative_r1_significant_strikes_clinch_accuracy_diff AS avg_cumulative_r1_significant_strikes_clinch_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed AS avg_opp_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff AS avg_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_attempted / t3.avg_opp_avg_r1_significant_strikes_clinch_attempted AS avg_opp_avg_r1_significant_strikes_clinch_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_attempted_diff / t3.avg_avg_r1_significant_strikes_clinch_attempted_diff AS avg_avg_r1_significant_strikes_clinch_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_clinch_attempted / t3.avg_opp_cumulative_r1_significant_strikes_clinch_attempted AS avg_opp_cumulative_r1_significant_strikes_clinch_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_clinch_attempted_diff / t3.avg_cumulative_r1_significant_strikes_clinch_attempted_diff AS avg_cumulative_r1_significant_strikes_clinch_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_attempted_per_second / t3.avg_opp_avg_r1_significant_strikes_clinch_attempted_per_second AS avg_opp_avg_r1_significant_strikes_clinch_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_attempted_per_second_diff / t3.avg_avg_r1_significant_strikes_clinch_attempted_per_second_diff AS avg_avg_r1_significant_strikes_clinch_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_clinch_attempted_per_second / t3.avg_opp_cumulative_r1_significant_strikes_clinch_attempted_per_second AS avg_opp_cumulative_r1_significant_strikes_clinch_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_clinch_attempted_per_second_diff / t3.avg_cumulative_r1_significant_strikes_clinch_attempted_per_second_diff AS avg_cumulative_r1_significant_strikes_clinch_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_landed / t3.avg_opp_avg_r1_significant_strikes_ground_landed AS avg_opp_avg_r1_significant_strikes_ground_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_landed_diff / t3.avg_avg_r1_significant_strikes_ground_landed_diff AS avg_avg_r1_significant_strikes_ground_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_ground_landed / t3.avg_opp_cumulative_r1_significant_strikes_ground_landed AS avg_opp_cumulative_r1_significant_strikes_ground_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_ground_landed_diff / t3.avg_cumulative_r1_significant_strikes_ground_landed_diff AS avg_cumulative_r1_significant_strikes_ground_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_landed_per_second / t3.avg_opp_avg_r1_significant_strikes_ground_landed_per_second AS avg_opp_avg_r1_significant_strikes_ground_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_landed_per_second_diff / t3.avg_avg_r1_significant_strikes_ground_landed_per_second_diff AS avg_avg_r1_significant_strikes_ground_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_ground_landed_per_second / t3.avg_opp_cumulative_r1_significant_strikes_ground_landed_per_second AS avg_opp_cumulative_r1_significant_strikes_ground_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_ground_landed_per_second_diff / t3.avg_cumulative_r1_significant_strikes_ground_landed_per_second_diff AS avg_cumulative_r1_significant_strikes_ground_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_accuracy / t3.avg_opp_avg_r1_significant_strikes_ground_accuracy AS avg_opp_avg_r1_significant_strikes_ground_accuracy_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_accuracy_diff / t3.avg_avg_r1_significant_strikes_ground_accuracy_diff AS avg_avg_r1_significant_strikes_ground_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_ground_accuracy / t3.avg_opp_cumulative_r1_significant_strikes_ground_accuracy AS avg_opp_cumulative_r1_significant_strikes_ground_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_ground_accuracy_diff / t3.avg_cumulative_r1_significant_strikes_ground_accuracy_diff AS avg_cumulative_r1_significant_strikes_ground_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed AS avg_opp_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff AS avg_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_attempted / t3.avg_opp_avg_r1_significant_strikes_ground_attempted AS avg_opp_avg_r1_significant_strikes_ground_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_attempted_diff / t3.avg_avg_r1_significant_strikes_ground_attempted_diff AS avg_avg_r1_significant_strikes_ground_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_ground_attempted / t3.avg_opp_cumulative_r1_significant_strikes_ground_attempted AS avg_opp_cumulative_r1_significant_strikes_ground_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_ground_attempted_diff / t3.avg_cumulative_r1_significant_strikes_ground_attempted_diff AS avg_cumulative_r1_significant_strikes_ground_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_attempted_per_second / t3.avg_opp_avg_r1_significant_strikes_ground_attempted_per_second AS avg_opp_avg_r1_significant_strikes_ground_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_attempted_per_second_diff / t3.avg_avg_r1_significant_strikes_ground_attempted_per_second_diff AS avg_avg_r1_significant_strikes_ground_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_ground_attempted_per_second / t3.avg_opp_cumulative_r1_significant_strikes_ground_attempted_per_second AS avg_opp_cumulative_r1_significant_strikes_ground_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_ground_attempted_per_second_diff / t3.avg_cumulative_r1_significant_strikes_ground_attempted_per_second_diff AS avg_cumulative_r1_significant_strikes_ground_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_landed / t3.avg_opp_avg_r1_takedowns_landed AS avg_opp_avg_r1_takedowns_landed_ratio,
    1.0 * t2.avg_avg_r1_takedowns_landed_diff / t3.avg_avg_r1_takedowns_landed_diff AS avg_avg_r1_takedowns_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_takedowns_landed / t3.avg_opp_cumulative_r1_takedowns_landed AS avg_opp_cumulative_r1_takedowns_landed_ratio,
    1.0 * t2.avg_cumulative_r1_takedowns_landed_diff / t3.avg_cumulative_r1_takedowns_landed_diff AS avg_cumulative_r1_takedowns_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_landed_per_second / t3.avg_opp_avg_r1_takedowns_landed_per_second AS avg_opp_avg_r1_takedowns_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_takedowns_landed_per_second_diff / t3.avg_avg_r1_takedowns_landed_per_second_diff AS avg_avg_r1_takedowns_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_takedowns_landed_per_second / t3.avg_opp_cumulative_r1_takedowns_landed_per_second AS avg_opp_cumulative_r1_takedowns_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_takedowns_landed_per_second_diff / t3.avg_cumulative_r1_takedowns_landed_per_second_diff AS avg_cumulative_r1_takedowns_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_accuracy / t3.avg_opp_avg_r1_takedowns_accuracy AS avg_opp_avg_r1_takedowns_accuracy_ratio,
    1.0 * t2.avg_avg_r1_takedowns_accuracy_diff / t3.avg_avg_r1_takedowns_accuracy_diff AS avg_avg_r1_takedowns_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_takedowns_accuracy / t3.avg_opp_cumulative_r1_takedowns_accuracy AS avg_opp_cumulative_r1_takedowns_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_takedowns_accuracy_diff / t3.avg_cumulative_r1_takedowns_accuracy_diff AS avg_cumulative_r1_takedowns_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_attempted / t3.avg_opp_avg_r1_takedowns_attempted AS avg_opp_avg_r1_takedowns_attempted_ratio,
    1.0 * t2.avg_avg_r1_takedowns_attempted_diff / t3.avg_avg_r1_takedowns_attempted_diff AS avg_avg_r1_takedowns_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_takedowns_attempted / t3.avg_opp_cumulative_r1_takedowns_attempted AS avg_opp_cumulative_r1_takedowns_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_takedowns_attempted_diff / t3.avg_cumulative_r1_takedowns_attempted_diff AS avg_cumulative_r1_takedowns_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_attempted_per_second / t3.avg_opp_avg_r1_takedowns_attempted_per_second AS avg_opp_avg_r1_takedowns_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_takedowns_attempted_per_second_diff / t3.avg_avg_r1_takedowns_attempted_per_second_diff AS avg_avg_r1_takedowns_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_takedowns_attempted_per_second / t3.avg_opp_cumulative_r1_takedowns_attempted_per_second AS avg_opp_cumulative_r1_takedowns_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_takedowns_attempted_per_second_diff / t3.avg_cumulative_r1_takedowns_attempted_per_second_diff AS avg_cumulative_r1_takedowns_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_reversals_scored / t3.avg_opp_avg_r1_reversals_scored AS avg_opp_avg_r1_reversals_scored_ratio,
    1.0 * t2.avg_avg_r1_reversals_scored_diff / t3.avg_avg_r1_reversals_scored_diff AS avg_avg_r1_reversals_scored_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_reversals_scored / t3.avg_opp_cumulative_r1_reversals_scored AS avg_opp_cumulative_r1_reversals_scored_ratio,
    1.0 * t2.avg_cumulative_r1_reversals_scored_diff / t3.avg_cumulative_r1_reversals_scored_diff AS avg_cumulative_r1_reversals_scored_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_reversals_scored_per_second / t3.avg_opp_avg_r1_reversals_scored_per_second AS avg_opp_avg_r1_reversals_scored_per_second_ratio,
    1.0 * t2.avg_avg_r1_reversals_scored_per_second_diff / t3.avg_avg_r1_reversals_scored_per_second_diff AS avg_avg_r1_reversals_scored_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_reversals_scored_per_second / t3.avg_opp_cumulative_r1_reversals_scored_per_second AS avg_opp_cumulative_r1_reversals_scored_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_reversals_scored_per_second_diff / t3.avg_cumulative_r1_reversals_scored_per_second_diff AS avg_cumulative_r1_reversals_scored_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_submissions_attempted / t3.avg_opp_avg_r1_submissions_attempted AS avg_opp_avg_r1_submissions_attempted_ratio,
    1.0 * t2.avg_avg_r1_submissions_attempted_diff / t3.avg_avg_r1_submissions_attempted_diff AS avg_avg_r1_submissions_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_submissions_attempted / t3.avg_opp_cumulative_r1_submissions_attempted AS avg_opp_cumulative_r1_submissions_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_submissions_attempted_diff / t3.avg_cumulative_r1_submissions_attempted_diff AS avg_cumulative_r1_submissions_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_submissions_attempted_per_second / t3.avg_opp_avg_r1_submissions_attempted_per_second AS avg_opp_avg_r1_submissions_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_submissions_attempted_per_second_diff / t3.avg_avg_r1_submissions_attempted_per_second_diff AS avg_avg_r1_submissions_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_submissions_attempted_per_second / t3.avg_opp_cumulative_r1_submissions_attempted_per_second AS avg_opp_cumulative_r1_submissions_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_submissions_attempted_per_second_diff / t3.avg_cumulative_r1_submissions_attempted_per_second_diff AS avg_cumulative_r1_submissions_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_control_time_seconds / t3.avg_opp_avg_r1_control_time_seconds AS avg_opp_avg_r1_control_time_seconds_ratio,
    1.0 * t2.avg_avg_r1_control_time_seconds_diff / t3.avg_avg_r1_control_time_seconds_diff AS avg_avg_r1_control_time_seconds_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_control_time_seconds / t3.avg_opp_cumulative_r1_control_time_seconds AS avg_opp_cumulative_r1_control_time_seconds_ratio,
    1.0 * t2.avg_cumulative_r1_control_time_seconds_diff / t3.avg_cumulative_r1_control_time_seconds_diff AS avg_cumulative_r1_control_time_seconds_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_control_time_seconds_per_second / t3.avg_opp_avg_r1_control_time_seconds_per_second AS avg_opp_avg_r1_control_time_seconds_per_second_ratio,
    1.0 * t2.avg_avg_r1_control_time_seconds_per_second_diff / t3.avg_avg_r1_control_time_seconds_per_second_diff AS avg_avg_r1_control_time_seconds_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_control_time_seconds_per_second / t3.avg_opp_cumulative_r1_control_time_seconds_per_second AS avg_opp_cumulative_r1_control_time_seconds_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_control_time_seconds_per_second_diff / t3.avg_cumulative_r1_control_time_seconds_per_second_diff AS avg_cumulative_r1_control_time_seconds_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_knockdowns_scored / t3.avg_opp_avg_r1_opp_knockdowns_scored AS avg_opp_avg_r1_opp_knockdowns_scored_ratio,
    1.0 * t2.avg_avg_r1_opp_knockdowns_scored_diff / t3.avg_avg_r1_opp_knockdowns_scored_diff AS avg_avg_r1_opp_knockdowns_scored_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_knockdowns_scored / t3.avg_opp_cumulative_r1_opp_knockdowns_scored AS avg_opp_cumulative_r1_opp_knockdowns_scored_ratio,
    1.0 * t2.avg_cumulative_r1_opp_knockdowns_scored_diff / t3.avg_cumulative_r1_opp_knockdowns_scored_diff AS avg_cumulative_r1_opp_knockdowns_scored_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_knockdowns_scored_per_second / t3.avg_opp_avg_r1_opp_knockdowns_scored_per_second AS avg_opp_avg_r1_opp_knockdowns_scored_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_knockdowns_scored_per_second_diff / t3.avg_avg_r1_opp_knockdowns_scored_per_second_diff AS avg_avg_r1_opp_knockdowns_scored_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_knockdowns_scored_per_second / t3.avg_opp_cumulative_r1_opp_knockdowns_scored_per_second AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_knockdowns_scored_per_second_diff / t3.avg_cumulative_r1_opp_knockdowns_scored_per_second_diff AS avg_cumulative_r1_opp_knockdowns_scored_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_knockdowns_scored_per_strike_landed / t3.avg_opp_avg_r1_opp_knockdowns_scored_per_strike_landed AS avg_opp_avg_r1_opp_knockdowns_scored_per_strike_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_knockdowns_scored_per_strike_landed_diff / t3.avg_avg_r1_opp_knockdowns_scored_per_strike_landed_diff AS avg_avg_r1_opp_knockdowns_scored_per_strike_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_knockdowns_scored_per_strike_landed / t3.avg_opp_cumulative_r1_opp_knockdowns_scored_per_strike_landed AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_strike_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_knockdowns_scored_per_strike_landed_diff / t3.avg_cumulative_r1_opp_knockdowns_scored_per_strike_landed_diff AS avg_cumulative_r1_opp_knockdowns_scored_per_strike_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_knockdowns_scored_per_strike_attempted / t3.avg_opp_avg_r1_opp_knockdowns_scored_per_strike_attempted AS avg_opp_avg_r1_opp_knockdowns_scored_per_strike_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_knockdowns_scored_per_strike_attempted_diff / t3.avg_avg_r1_opp_knockdowns_scored_per_strike_attempted_diff AS avg_avg_r1_opp_knockdowns_scored_per_strike_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_knockdowns_scored_per_strike_attempted / t3.avg_opp_cumulative_r1_opp_knockdowns_scored_per_strike_attempted AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_strike_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_knockdowns_scored_per_strike_attempted_diff / t3.avg_cumulative_r1_opp_knockdowns_scored_per_strike_attempted_diff AS avg_cumulative_r1_opp_knockdowns_scored_per_strike_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_landed / t3.avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_landed AS avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_knockdowns_scored_per_significant_strike_landed_diff / t3.avg_avg_r1_opp_knockdowns_scored_per_significant_strike_landed_diff AS avg_avg_r1_opp_knockdowns_scored_per_significant_strike_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed / t3.avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed_diff / t3.avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed_diff AS avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_attempted / t3.avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_attempted AS avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_knockdowns_scored_per_significant_strike_attempted_diff / t3.avg_avg_r1_opp_knockdowns_scored_per_significant_strike_attempted_diff AS avg_avg_r1_opp_knockdowns_scored_per_significant_strike_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted / t3.avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted_diff / t3.avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted_diff AS avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed / t3.avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed AS avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed_diff / t3.avg_avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed_diff AS avg_avg_r1_opp_knockdowns_scored_per_significant_strike_head_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed / t3.avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed_diff / t3.avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed_diff AS avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted / t3.avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted AS avg_opp_avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_diff / t3.avg_avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_diff AS avg_avg_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted / t3.avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted AS avg_opp_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_diff / t3.avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_diff AS avg_cumulative_r1_opp_knockdowns_scored_per_significant_strike_head_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_total_strikes_landed / t3.avg_opp_avg_r1_opp_total_strikes_landed AS avg_opp_avg_r1_opp_total_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_total_strikes_landed_diff / t3.avg_avg_r1_opp_total_strikes_landed_diff AS avg_avg_r1_opp_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_total_strikes_landed / t3.avg_opp_cumulative_r1_opp_total_strikes_landed AS avg_opp_cumulative_r1_opp_total_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_total_strikes_landed_diff / t3.avg_cumulative_r1_opp_total_strikes_landed_diff AS avg_cumulative_r1_opp_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_total_strikes_landed_per_second / t3.avg_opp_avg_r1_opp_total_strikes_landed_per_second AS avg_opp_avg_r1_opp_total_strikes_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_total_strikes_landed_per_second_diff / t3.avg_avg_r1_opp_total_strikes_landed_per_second_diff AS avg_avg_r1_opp_total_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_total_strikes_landed_per_second / t3.avg_opp_cumulative_r1_opp_total_strikes_landed_per_second AS avg_opp_cumulative_r1_opp_total_strikes_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_total_strikes_landed_per_second_diff / t3.avg_cumulative_r1_opp_total_strikes_landed_per_second_diff AS avg_cumulative_r1_opp_total_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_total_strikes_accuracy / t3.avg_opp_avg_r1_opp_total_strikes_accuracy AS avg_opp_avg_r1_opp_total_strikes_accuracy_ratio,
    1.0 * t2.avg_avg_r1_opp_total_strikes_accuracy_diff / t3.avg_avg_r1_opp_total_strikes_accuracy_diff AS avg_avg_r1_opp_total_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_total_strikes_accuracy / t3.avg_opp_cumulative_r1_opp_total_strikes_accuracy AS avg_opp_cumulative_r1_opp_total_strikes_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_opp_total_strikes_accuracy_diff / t3.avg_cumulative_r1_opp_total_strikes_accuracy_diff AS avg_cumulative_r1_opp_total_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_total_strikes_attempted / t3.avg_opp_avg_r1_opp_total_strikes_attempted AS avg_opp_avg_r1_opp_total_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_total_strikes_attempted_diff / t3.avg_avg_r1_opp_total_strikes_attempted_diff AS avg_avg_r1_opp_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_total_strikes_attempted / t3.avg_opp_cumulative_r1_opp_total_strikes_attempted AS avg_opp_cumulative_r1_opp_total_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_total_strikes_attempted_diff / t3.avg_cumulative_r1_opp_total_strikes_attempted_diff AS avg_cumulative_r1_opp_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_total_strikes_attempted_per_second / t3.avg_opp_avg_r1_opp_total_strikes_attempted_per_second AS avg_opp_avg_r1_opp_total_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_total_strikes_attempted_per_second_diff / t3.avg_avg_r1_opp_total_strikes_attempted_per_second_diff AS avg_avg_r1_opp_total_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_total_strikes_attempted_per_second / t3.avg_opp_cumulative_r1_opp_total_strikes_attempted_per_second AS avg_opp_cumulative_r1_opp_total_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_total_strikes_attempted_per_second_diff / t3.avg_cumulative_r1_opp_total_strikes_attempted_per_second_diff AS avg_cumulative_r1_opp_total_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_landed / t3.avg_opp_avg_r1_opp_significant_strikes_landed AS avg_opp_avg_r1_opp_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_landed_diff / t3.avg_avg_r1_opp_significant_strikes_landed_diff AS avg_avg_r1_opp_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_landed AS avg_opp_cumulative_r1_opp_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_landed_diff AS avg_cumulative_r1_opp_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_landed_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_landed_per_second AS avg_opp_avg_r1_opp_significant_strikes_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_landed_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_landed_per_second_diff AS avg_avg_r1_opp_significant_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_landed_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_landed_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_landed_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_landed_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_accuracy / t3.avg_opp_avg_r1_opp_significant_strikes_accuracy AS avg_opp_avg_r1_opp_significant_strikes_accuracy_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_accuracy_diff / t3.avg_avg_r1_opp_significant_strikes_accuracy_diff AS avg_avg_r1_opp_significant_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_accuracy / t3.avg_opp_cumulative_r1_opp_significant_strikes_accuracy AS avg_opp_cumulative_r1_opp_significant_strikes_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_accuracy_diff / t3.avg_cumulative_r1_opp_significant_strikes_accuracy_diff AS avg_cumulative_r1_opp_significant_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_landed_per_total_strikes_landed / t3.avg_opp_avg_r1_opp_significant_strikes_landed_per_total_strikes_landed AS avg_opp_avg_r1_opp_significant_strikes_landed_per_total_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_landed_per_total_strikes_landed_diff / t3.avg_avg_r1_opp_significant_strikes_landed_per_total_strikes_landed_diff AS avg_avg_r1_opp_significant_strikes_landed_per_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed AS avg_opp_cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed_diff AS avg_cumulative_r1_opp_significant_strikes_landed_per_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_attempted AS avg_opp_avg_r1_opp_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_attempted_diff AS avg_avg_r1_opp_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_attempted_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_attempted_per_second AS avg_opp_avg_r1_opp_significant_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_attempted_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_attempted_per_second_diff AS avg_avg_r1_opp_significant_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_attempted_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_attempted_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_attempted_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_attempted_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted AS avg_opp_avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_diff AS avg_avg_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_attempted_per_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_head_landed / t3.avg_opp_avg_r1_opp_significant_strikes_head_landed AS avg_opp_avg_r1_opp_significant_strikes_head_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_head_landed_diff / t3.avg_avg_r1_opp_significant_strikes_head_landed_diff AS avg_avg_r1_opp_significant_strikes_head_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_head_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_head_landed AS avg_opp_cumulative_r1_opp_significant_strikes_head_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_head_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_head_landed_diff AS avg_cumulative_r1_opp_significant_strikes_head_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_head_landed_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_head_landed_per_second AS avg_opp_avg_r1_opp_significant_strikes_head_landed_per_second_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_head_landed_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_head_landed_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_head_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_head_landed_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_head_landed_per_second_diff AS avg_avg_r1_opp_significant_strikes_head_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_head_accuracy / t3.avg_opp_avg_r1_opp_significant_strikes_head_accuracy AS avg_opp_avg_r1_opp_significant_strikes_head_accuracy_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_head_accuracy_diff / t3.avg_avg_r1_opp_significant_strikes_head_accuracy_diff AS avg_avg_r1_opp_significant_strikes_head_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_head_accuracy / t3.avg_opp_cumulative_r1_opp_significant_strikes_head_accuracy AS avg_opp_cumulative_r1_opp_significant_strikes_head_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_head_accuracy_diff / t3.avg_cumulative_r1_opp_significant_strikes_head_accuracy_diff AS avg_cumulative_r1_opp_significant_strikes_head_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed AS avg_opp_avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_diff AS avg_avg_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_opp_significant_strikes_head_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_head_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_head_attempted AS avg_opp_avg_r1_opp_significant_strikes_head_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_head_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_head_attempted_diff AS avg_avg_r1_opp_significant_strikes_head_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_head_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_head_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_head_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_head_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_head_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_head_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_head_attempted_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_head_attempted_per_second AS avg_opp_avg_r1_opp_significant_strikes_head_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_head_attempted_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_head_attempted_per_second_diff AS avg_avg_r1_opp_significant_strikes_head_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_head_attempted_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_head_attempted_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_head_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_head_attempted_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_head_attempted_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_head_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_body_landed / t3.avg_opp_avg_r1_opp_significant_strikes_body_landed AS avg_opp_avg_r1_opp_significant_strikes_body_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_body_landed_diff / t3.avg_avg_r1_opp_significant_strikes_body_landed_diff AS avg_avg_r1_opp_significant_strikes_body_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_body_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_body_landed AS avg_opp_cumulative_r1_opp_significant_strikes_body_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_body_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_body_landed_diff AS avg_cumulative_r1_opp_significant_strikes_body_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_body_landed_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_body_landed_per_second AS avg_opp_avg_r1_opp_significant_strikes_body_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_body_landed_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_body_landed_per_second_diff AS avg_avg_r1_opp_significant_strikes_body_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_body_landed_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_body_landed_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_body_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_body_landed_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_body_landed_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_body_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_body_accuracy / t3.avg_opp_avg_r1_opp_significant_strikes_body_accuracy AS avg_opp_avg_r1_opp_significant_strikes_body_accuracy_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_body_accuracy_diff / t3.avg_avg_r1_opp_significant_strikes_body_accuracy_diff AS avg_avg_r1_opp_significant_strikes_body_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_body_accuracy / t3.avg_opp_cumulative_r1_opp_significant_strikes_body_accuracy AS avg_opp_cumulative_r1_opp_significant_strikes_body_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_body_accuracy_diff / t3.avg_cumulative_r1_opp_significant_strikes_body_accuracy_diff AS avg_cumulative_r1_opp_significant_strikes_body_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed AS avg_opp_avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_diff AS avg_avg_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_opp_significant_strikes_body_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_body_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_body_attempted AS avg_opp_avg_r1_opp_significant_strikes_body_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_body_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_body_attempted_diff AS avg_avg_r1_opp_significant_strikes_body_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_body_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_body_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_body_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_body_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_body_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_body_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_body_attempted_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_body_attempted_per_second AS avg_opp_avg_r1_opp_significant_strikes_body_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_body_attempted_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_body_attempted_per_second_diff AS avg_avg_r1_opp_significant_strikes_body_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_body_attempted_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_body_attempted_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_body_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_body_attempted_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_body_attempted_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_body_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_leg_landed / t3.avg_opp_avg_r1_opp_significant_strikes_leg_landed AS avg_opp_avg_r1_opp_significant_strikes_leg_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_leg_landed_diff / t3.avg_avg_r1_opp_significant_strikes_leg_landed_diff AS avg_avg_r1_opp_significant_strikes_leg_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_leg_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_leg_landed AS avg_opp_cumulative_r1_opp_significant_strikes_leg_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_leg_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_leg_landed_diff AS avg_cumulative_r1_opp_significant_strikes_leg_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_leg_landed_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_leg_landed_per_second AS avg_opp_avg_r1_opp_significant_strikes_leg_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_leg_landed_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_leg_landed_per_second_diff AS avg_avg_r1_opp_significant_strikes_leg_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_leg_landed_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_leg_landed_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_leg_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_leg_landed_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_leg_landed_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_leg_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_leg_accuracy / t3.avg_opp_avg_r1_opp_significant_strikes_leg_accuracy AS avg_opp_avg_r1_opp_significant_strikes_leg_accuracy_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_leg_accuracy_diff / t3.avg_avg_r1_opp_significant_strikes_leg_accuracy_diff AS avg_avg_r1_opp_significant_strikes_leg_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_leg_accuracy / t3.avg_opp_cumulative_r1_opp_significant_strikes_leg_accuracy AS avg_opp_cumulative_r1_opp_significant_strikes_leg_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_leg_accuracy_diff / t3.avg_cumulative_r1_opp_significant_strikes_leg_accuracy_diff AS avg_cumulative_r1_opp_significant_strikes_leg_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed AS avg_opp_avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_diff AS avg_avg_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_opp_significant_strikes_leg_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_leg_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_leg_attempted AS avg_opp_avg_r1_opp_significant_strikes_leg_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_leg_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_leg_attempted_diff AS avg_avg_r1_opp_significant_strikes_leg_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_leg_attempted_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_leg_attempted_per_second AS avg_opp_avg_r1_opp_significant_strikes_leg_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_leg_attempted_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_leg_attempted_per_second_diff AS avg_avg_r1_opp_significant_strikes_leg_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_leg_attempted_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_leg_attempted_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_leg_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_distance_landed / t3.avg_opp_avg_r1_opp_significant_strikes_distance_landed AS avg_opp_avg_r1_opp_significant_strikes_distance_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_distance_landed_diff / t3.avg_avg_r1_opp_significant_strikes_distance_landed_diff AS avg_avg_r1_opp_significant_strikes_distance_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_distance_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_distance_landed AS avg_opp_cumulative_r1_opp_significant_strikes_distance_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_distance_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_distance_landed_diff AS avg_cumulative_r1_opp_significant_strikes_distance_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_distance_landed_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_distance_landed_per_second AS avg_opp_avg_r1_opp_significant_strikes_distance_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_distance_landed_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_distance_landed_per_second_diff AS avg_avg_r1_opp_significant_strikes_distance_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_distance_landed_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_distance_landed_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_distance_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_distance_landed_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_distance_landed_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_distance_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_distance_accuracy / t3.avg_opp_avg_r1_opp_significant_strikes_distance_accuracy AS avg_opp_avg_r1_opp_significant_strikes_distance_accuracy_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_distance_accuracy_diff / t3.avg_avg_r1_opp_significant_strikes_distance_accuracy_diff AS avg_avg_r1_opp_significant_strikes_distance_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_distance_accuracy / t3.avg_opp_cumulative_r1_opp_significant_strikes_distance_accuracy AS avg_opp_cumulative_r1_opp_significant_strikes_distance_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_distance_accuracy_diff / t3.avg_cumulative_r1_opp_significant_strikes_distance_accuracy_diff AS avg_cumulative_r1_opp_significant_strikes_distance_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed AS avg_opp_avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_diff AS avg_avg_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_opp_significant_strikes_distance_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_distance_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_distance_attempted AS avg_opp_avg_r1_opp_significant_strikes_distance_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_distance_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_distance_attempted_diff AS avg_avg_r1_opp_significant_strikes_distance_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_distance_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_distance_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_distance_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_distance_attempted_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_distance_attempted_per_second AS avg_opp_avg_r1_opp_significant_strikes_distance_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_distance_attempted_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_distance_attempted_per_second_diff AS avg_avg_r1_opp_significant_strikes_distance_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_distance_attempted_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_distance_attempted_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_distance_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_clinch_landed / t3.avg_opp_avg_r1_opp_significant_strikes_clinch_landed AS avg_opp_avg_r1_opp_significant_strikes_clinch_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_clinch_landed_diff / t3.avg_avg_r1_opp_significant_strikes_clinch_landed_diff AS avg_avg_r1_opp_significant_strikes_clinch_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_clinch_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_clinch_landed_diff AS avg_cumulative_r1_opp_significant_strikes_clinch_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_clinch_landed_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_clinch_landed_per_second AS avg_opp_avg_r1_opp_significant_strikes_clinch_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_clinch_landed_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_clinch_landed_per_second_diff AS avg_avg_r1_opp_significant_strikes_clinch_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_clinch_landed_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_clinch_landed_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_clinch_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_clinch_accuracy / t3.avg_opp_avg_r1_opp_significant_strikes_clinch_accuracy AS avg_opp_avg_r1_opp_significant_strikes_clinch_accuracy_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_clinch_accuracy_diff / t3.avg_avg_r1_opp_significant_strikes_clinch_accuracy_diff AS avg_avg_r1_opp_significant_strikes_clinch_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_clinch_accuracy / t3.avg_opp_cumulative_r1_opp_significant_strikes_clinch_accuracy AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_clinch_accuracy_diff / t3.avg_cumulative_r1_opp_significant_strikes_clinch_accuracy_diff AS avg_cumulative_r1_opp_significant_strikes_clinch_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed AS avg_opp_avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_diff AS avg_avg_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_opp_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_clinch_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_clinch_attempted AS avg_opp_avg_r1_opp_significant_strikes_clinch_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_clinch_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_clinch_attempted_diff AS avg_avg_r1_opp_significant_strikes_clinch_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_clinch_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_clinch_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_clinch_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_clinch_attempted_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_clinch_attempted_per_second AS avg_opp_avg_r1_opp_significant_strikes_clinch_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_clinch_attempted_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_clinch_attempted_per_second_diff AS avg_avg_r1_opp_significant_strikes_clinch_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_clinch_attempted_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_clinch_attempted_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_clinch_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_ground_landed / t3.avg_opp_avg_r1_opp_significant_strikes_ground_landed AS avg_opp_avg_r1_opp_significant_strikes_ground_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_ground_landed_diff / t3.avg_avg_r1_opp_significant_strikes_ground_landed_diff AS avg_avg_r1_opp_significant_strikes_ground_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_ground_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_ground_landed AS avg_opp_cumulative_r1_opp_significant_strikes_ground_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_ground_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_ground_landed_diff AS avg_cumulative_r1_opp_significant_strikes_ground_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_ground_landed_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_ground_landed_per_second AS avg_opp_avg_r1_opp_significant_strikes_ground_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_ground_landed_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_ground_landed_per_second_diff AS avg_avg_r1_opp_significant_strikes_ground_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_ground_landed_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_ground_landed_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_ground_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_ground_landed_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_ground_landed_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_ground_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_ground_accuracy / t3.avg_opp_avg_r1_opp_significant_strikes_ground_accuracy AS avg_opp_avg_r1_opp_significant_strikes_ground_accuracy_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_ground_accuracy_diff / t3.avg_avg_r1_opp_significant_strikes_ground_accuracy_diff AS avg_avg_r1_opp_significant_strikes_ground_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_ground_accuracy / t3.avg_opp_cumulative_r1_opp_significant_strikes_ground_accuracy AS avg_opp_cumulative_r1_opp_significant_strikes_ground_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_ground_accuracy_diff / t3.avg_cumulative_r1_opp_significant_strikes_ground_accuracy_diff AS avg_cumulative_r1_opp_significant_strikes_ground_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed / t3.avg_opp_avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed AS avg_opp_avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_diff / t3.avg_avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_diff AS avg_avg_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed / t3.avg_opp_cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed AS avg_opp_cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_diff / t3.avg_cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_diff AS avg_cumulative_r1_opp_significant_strikes_ground_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_ground_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_ground_attempted AS avg_opp_avg_r1_opp_significant_strikes_ground_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_ground_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_ground_attempted_diff AS avg_avg_r1_opp_significant_strikes_ground_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_ground_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_ground_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_ground_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_ground_attempted_per_second / t3.avg_opp_avg_r1_opp_significant_strikes_ground_attempted_per_second AS avg_opp_avg_r1_opp_significant_strikes_ground_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_ground_attempted_per_second_diff / t3.avg_avg_r1_opp_significant_strikes_ground_attempted_per_second_diff AS avg_avg_r1_opp_significant_strikes_ground_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted_per_second / t3.avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted_per_second AS avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_ground_attempted_per_second_diff / t3.avg_cumulative_r1_opp_significant_strikes_ground_attempted_per_second_diff AS avg_cumulative_r1_opp_significant_strikes_ground_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted / t3.avg_opp_avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted AS avg_opp_avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff / t3.avg_avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff AS avg_avg_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted / t3.avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted AS avg_opp_cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff / t3.avg_cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff AS avg_cumulative_r1_opp_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_takedowns_landed / t3.avg_opp_avg_r1_opp_takedowns_landed AS avg_opp_avg_r1_opp_takedowns_landed_ratio,
    1.0 * t2.avg_avg_r1_opp_takedowns_landed_diff / t3.avg_avg_r1_opp_takedowns_landed_diff AS avg_avg_r1_opp_takedowns_landed_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_takedowns_landed / t3.avg_opp_cumulative_r1_opp_takedowns_landed AS avg_opp_cumulative_r1_opp_takedowns_landed_ratio,
    1.0 * t2.avg_cumulative_r1_opp_takedowns_landed_diff / t3.avg_cumulative_r1_opp_takedowns_landed_diff AS avg_cumulative_r1_opp_takedowns_landed_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_takedowns_landed_per_second / t3.avg_opp_avg_r1_opp_takedowns_landed_per_second AS avg_opp_avg_r1_opp_takedowns_landed_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_takedowns_landed_per_second_diff / t3.avg_avg_r1_opp_takedowns_landed_per_second_diff AS avg_avg_r1_opp_takedowns_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_takedowns_landed_per_second / t3.avg_opp_cumulative_r1_opp_takedowns_landed_per_second AS avg_opp_cumulative_r1_opp_takedowns_landed_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_takedowns_landed_per_second_diff / t3.avg_cumulative_r1_opp_takedowns_landed_per_second_diff AS avg_cumulative_r1_opp_takedowns_landed_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_takedowns_accuracy / t3.avg_opp_avg_r1_opp_takedowns_accuracy AS avg_opp_avg_r1_opp_takedowns_accuracy_ratio,
    1.0 * t2.avg_avg_r1_opp_takedowns_accuracy_diff / t3.avg_avg_r1_opp_takedowns_accuracy_diff AS avg_avg_r1_opp_takedowns_accuracy_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_takedowns_accuracy / t3.avg_opp_cumulative_r1_opp_takedowns_accuracy AS avg_opp_cumulative_r1_opp_takedowns_accuracy_ratio,
    1.0 * t2.avg_cumulative_r1_opp_takedowns_accuracy_diff / t3.avg_cumulative_r1_opp_takedowns_accuracy_diff AS avg_cumulative_r1_opp_takedowns_accuracy_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_takedowns_attempted / t3.avg_opp_avg_r1_opp_takedowns_attempted AS avg_opp_avg_r1_opp_takedowns_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_takedowns_attempted_diff / t3.avg_avg_r1_opp_takedowns_attempted_diff AS avg_avg_r1_opp_takedowns_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_takedowns_attempted / t3.avg_opp_cumulative_r1_opp_takedowns_attempted AS avg_opp_cumulative_r1_opp_takedowns_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_takedowns_attempted_diff / t3.avg_cumulative_r1_opp_takedowns_attempted_diff AS avg_cumulative_r1_opp_takedowns_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_takedowns_attempted_per_second / t3.avg_opp_avg_r1_opp_takedowns_attempted_per_second AS avg_opp_avg_r1_opp_takedowns_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_takedowns_attempted_per_second_diff / t3.avg_avg_r1_opp_takedowns_attempted_per_second_diff AS avg_avg_r1_opp_takedowns_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_takedowns_attempted_per_second / t3.avg_opp_cumulative_r1_opp_takedowns_attempted_per_second AS avg_opp_cumulative_r1_opp_takedowns_attempted_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_takedowns_attempted_per_second_diff / t3.avg_cumulative_r1_opp_takedowns_attempted_per_second_diff AS avg_cumulative_r1_opp_takedowns_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_reversals_scored / t3.avg_opp_avg_r1_opp_reversals_scored AS avg_opp_avg_r1_opp_reversals_scored_ratio,
    1.0 * t2.avg_avg_r1_opp_reversals_scored_diff / t3.avg_avg_r1_opp_reversals_scored_diff AS avg_avg_r1_opp_reversals_scored_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_reversals_scored / t3.avg_opp_cumulative_r1_opp_reversals_scored AS avg_opp_cumulative_r1_opp_reversals_scored_ratio,
    1.0 * t2.avg_cumulative_r1_opp_reversals_scored_diff / t3.avg_cumulative_r1_opp_reversals_scored_diff AS avg_cumulative_r1_opp_reversals_scored_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_reversals_scored_per_second / t3.avg_opp_avg_r1_opp_reversals_scored_per_second AS avg_opp_avg_r1_opp_reversals_scored_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_reversals_scored_per_second_diff / t3.avg_avg_r1_opp_reversals_scored_per_second_diff AS avg_avg_r1_opp_reversals_scored_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_reversals_scored_per_second / t3.avg_opp_cumulative_r1_opp_reversals_scored_per_second AS avg_opp_cumulative_r1_opp_reversals_scored_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_reversals_scored_per_second_diff / t3.avg_cumulative_r1_opp_reversals_scored_per_second_diff AS avg_cumulative_r1_opp_reversals_scored_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_submissions_attempted / t3.avg_opp_avg_r1_opp_submissions_attempted AS avg_opp_avg_r1_opp_submissions_attempted_ratio,
    1.0 * t2.avg_avg_r1_opp_submissions_attempted_diff / t3.avg_avg_r1_opp_submissions_attempted_diff AS avg_avg_r1_opp_submissions_attempted_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_submissions_attempted / t3.avg_opp_cumulative_r1_opp_submissions_attempted AS avg_opp_cumulative_r1_opp_submissions_attempted_ratio,
    1.0 * t2.avg_cumulative_r1_opp_submissions_attempted_diff / t3.avg_cumulative_r1_opp_submissions_attempted_diff AS avg_cumulative_r1_opp_submissions_attempted_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_submissions_attempted_per_second / t3.avg_opp_avg_r1_opp_submissions_attempted_per_second AS avg_opp_avg_r1_opp_submissions_attempted_per_second_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_submissions_attempted_per_second / t3.avg_opp_cumulative_r1_opp_submissions_attempted_per_second AS avg_opp_cumulative_r1_opp_submissions_attempted_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_submissions_attempted_per_second_diff / t3.avg_avg_r1_opp_submissions_attempted_per_second_diff AS avg_avg_r1_opp_submissions_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_control_time_seconds / t3.avg_opp_avg_r1_opp_control_time_seconds AS avg_opp_avg_r1_opp_control_time_seconds_ratio,
    1.0 * t2.avg_avg_r1_opp_control_time_seconds_diff / t3.avg_avg_r1_opp_control_time_seconds_diff AS avg_avg_r1_opp_control_time_seconds_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_control_time_seconds / t3.avg_opp_cumulative_r1_opp_control_time_seconds AS avg_opp_cumulative_r1_opp_control_time_seconds_ratio,
    1.0 * t2.avg_cumulative_r1_opp_control_time_seconds_diff / t3.avg_cumulative_r1_opp_control_time_seconds_diff AS avg_cumulative_r1_opp_control_time_seconds_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_opp_control_time_seconds_per_second / t3.avg_opp_avg_r1_opp_control_time_seconds_per_second AS avg_opp_avg_r1_opp_control_time_seconds_per_second_ratio,
    1.0 * t2.avg_avg_r1_opp_control_time_seconds_per_second_diff / t3.avg_avg_r1_opp_control_time_seconds_per_second_diff AS avg_avg_r1_opp_control_time_seconds_per_second_diff_ratio,
    1.0 * t2.avg_opp_cumulative_r1_opp_control_time_seconds_per_second / t3.avg_opp_cumulative_r1_opp_control_time_seconds_per_second AS avg_opp_cumulative_r1_opp_control_time_seconds_per_second_ratio,
    1.0 * t2.avg_cumulative_r1_opp_control_time_seconds_per_second_diff / t3.avg_cumulative_r1_opp_control_time_seconds_per_second_diff AS avg_cumulative_r1_opp_control_time_seconds_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_diff / t3.avg_opp_avg_r1_knockdowns_scored_diff AS avg_opp_avg_r1_knockdowns_scored_diff_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_diff_diff / t3.avg_avg_r1_knockdowns_scored_diff_diff AS avg_avg_r1_knockdowns_scored_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_second_diff / t3.avg_opp_avg_r1_knockdowns_scored_per_second_diff AS avg_opp_avg_r1_knockdowns_scored_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_second_diff_diff / t3.avg_avg_r1_knockdowns_scored_per_second_diff_diff AS avg_avg_r1_knockdowns_scored_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_strike_landed_diff / t3.avg_opp_avg_r1_knockdowns_scored_per_strike_landed_diff AS avg_opp_avg_r1_knockdowns_scored_per_strike_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_strike_landed_diff_diff / t3.avg_avg_r1_knockdowns_scored_per_strike_landed_diff_diff AS avg_avg_r1_knockdowns_scored_per_strike_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_strike_attempted_diff / t3.avg_opp_avg_r1_knockdowns_scored_per_strike_attempted_diff AS avg_opp_avg_r1_knockdowns_scored_per_strike_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_strike_attempted_diff_diff / t3.avg_avg_r1_knockdowns_scored_per_strike_attempted_diff_diff AS avg_avg_r1_knockdowns_scored_per_strike_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_landed_diff / t3.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_landed_diff AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_significant_strike_landed_diff_diff / t3.avg_avg_r1_knockdowns_scored_per_significant_strike_landed_diff_diff AS avg_avg_r1_knockdowns_scored_per_significant_strike_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff / t3.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff_diff / t3.avg_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff_diff AS avg_avg_r1_knockdowns_scored_per_significant_strike_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff / t3.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff_diff / t3.avg_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff_diff AS avg_avg_r1_knockdowns_scored_per_significant_strike_head_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff / t3.avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff AS avg_opp_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff_diff / t3.avg_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff_diff AS avg_avg_r1_knockdowns_scored_per_significant_strike_head_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_landed_diff / t3.avg_opp_avg_r1_total_strikes_landed_diff AS avg_opp_avg_r1_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_landed_diff_diff / t3.avg_avg_r1_total_strikes_landed_diff_diff AS avg_avg_r1_total_strikes_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_landed_per_second_diff / t3.avg_opp_avg_r1_total_strikes_landed_per_second_diff AS avg_opp_avg_r1_total_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_landed_per_second_diff_diff / t3.avg_avg_r1_total_strikes_landed_per_second_diff_diff AS avg_avg_r1_total_strikes_landed_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_accuracy_diff / t3.avg_opp_avg_r1_total_strikes_accuracy_diff AS avg_opp_avg_r1_total_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_accuracy_diff_diff / t3.avg_avg_r1_total_strikes_accuracy_diff_diff AS avg_avg_r1_total_strikes_accuracy_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_attempted_diff / t3.avg_opp_avg_r1_total_strikes_attempted_diff AS avg_opp_avg_r1_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_attempted_diff_diff / t3.avg_avg_r1_total_strikes_attempted_diff_diff AS avg_avg_r1_total_strikes_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_total_strikes_attempted_per_second_diff / t3.avg_opp_avg_r1_total_strikes_attempted_per_second_diff AS avg_opp_avg_r1_total_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_total_strikes_attempted_per_second_diff_diff / t3.avg_avg_r1_total_strikes_attempted_per_second_diff_diff AS avg_avg_r1_total_strikes_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_landed_diff / t3.avg_opp_avg_r1_significant_strikes_landed_diff AS avg_opp_avg_r1_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_landed_diff_diff / t3.avg_avg_r1_significant_strikes_landed_diff_diff AS avg_avg_r1_significant_strikes_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_landed_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_landed_per_second_diff AS avg_opp_avg_r1_significant_strikes_landed_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_landed_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_landed_per_second_diff_diff AS avg_avg_r1_significant_strikes_landed_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_accuracy_diff / t3.avg_opp_avg_r1_significant_strikes_accuracy_diff AS avg_opp_avg_r1_significant_strikes_accuracy_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_accuracy_diff_diff / t3.avg_avg_r1_significant_strikes_accuracy_diff_diff AS avg_avg_r1_significant_strikes_accuracy_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff / t3.avg_opp_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff AS avg_opp_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff_diff / t3.avg_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff_diff AS avg_avg_r1_significant_strikes_landed_per_total_strikes_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_attempted_diff AS avg_opp_avg_r1_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_attempted_diff_diff AS avg_avg_r1_significant_strikes_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_attempted_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_attempted_per_second_diff AS avg_opp_avg_r1_significant_strikes_attempted_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_attempted_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_attempted_per_second_diff_diff AS avg_avg_r1_significant_strikes_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff AS avg_opp_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff_diff AS avg_avg_r1_significant_strikes_attempted_per_total_strikes_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_landed_diff / t3.avg_opp_avg_r1_significant_strikes_head_landed_diff AS avg_opp_avg_r1_significant_strikes_head_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_landed_diff_diff / t3.avg_avg_r1_significant_strikes_head_landed_diff_diff AS avg_avg_r1_significant_strikes_head_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_landed_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_head_landed_per_second_diff AS avg_opp_avg_r1_significant_strikes_head_landed_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_landed_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_head_landed_per_second_diff_diff AS avg_avg_r1_significant_strikes_head_landed_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_accuracy_diff / t3.avg_opp_avg_r1_significant_strikes_head_accuracy_diff AS avg_opp_avg_r1_significant_strikes_head_accuracy_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_accuracy_diff_diff / t3.avg_avg_r1_significant_strikes_head_accuracy_diff_diff AS avg_avg_r1_significant_strikes_head_accuracy_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff / t3.avg_opp_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff AS avg_opp_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff_diff / t3.avg_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff_diff AS avg_avg_r1_significant_strikes_head_landed_per_significant_strikes_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_head_attempted_diff AS avg_opp_avg_r1_significant_strikes_head_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_head_attempted_diff_diff AS avg_avg_r1_significant_strikes_head_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_attempted_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_head_attempted_per_second_diff AS avg_opp_avg_r1_significant_strikes_head_attempted_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_attempted_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_head_attempted_per_second_diff_diff AS avg_avg_r1_significant_strikes_head_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff AS avg_opp_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_diff AS avg_avg_r1_significant_strikes_head_attempted_per_significant_strikes_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_landed_diff / t3.avg_opp_avg_r1_significant_strikes_body_landed_diff AS avg_opp_avg_r1_significant_strikes_body_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_landed_diff_diff / t3.avg_avg_r1_significant_strikes_body_landed_diff_diff AS avg_avg_r1_significant_strikes_body_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_landed_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_body_landed_per_second_diff AS avg_opp_avg_r1_significant_strikes_body_landed_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_landed_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_body_landed_per_second_diff_diff AS avg_avg_r1_significant_strikes_body_landed_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_accuracy_diff / t3.avg_opp_avg_r1_significant_strikes_body_accuracy_diff AS avg_opp_avg_r1_significant_strikes_body_accuracy_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_accuracy_diff_diff / t3.avg_avg_r1_significant_strikes_body_accuracy_diff_diff AS avg_avg_r1_significant_strikes_body_accuracy_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff / t3.avg_opp_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff AS avg_opp_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff_diff / t3.avg_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff_diff AS avg_avg_r1_significant_strikes_body_landed_per_significant_strikes_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_body_attempted_diff AS avg_opp_avg_r1_significant_strikes_body_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_body_attempted_diff_diff AS avg_avg_r1_significant_strikes_body_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_attempted_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_body_attempted_per_second_diff AS avg_opp_avg_r1_significant_strikes_body_attempted_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_attempted_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_body_attempted_per_second_diff_diff AS avg_avg_r1_significant_strikes_body_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff AS avg_opp_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_diff AS avg_avg_r1_significant_strikes_body_attempted_per_significant_strikes_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_landed_diff / t3.avg_opp_avg_r1_significant_strikes_leg_landed_diff AS avg_opp_avg_r1_significant_strikes_leg_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_landed_diff_diff / t3.avg_avg_r1_significant_strikes_leg_landed_diff_diff AS avg_avg_r1_significant_strikes_leg_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_landed_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_leg_landed_per_second_diff AS avg_opp_avg_r1_significant_strikes_leg_landed_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_landed_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_leg_landed_per_second_diff_diff AS avg_avg_r1_significant_strikes_leg_landed_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_accuracy_diff / t3.avg_opp_avg_r1_significant_strikes_leg_accuracy_diff AS avg_opp_avg_r1_significant_strikes_leg_accuracy_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_accuracy_diff_diff / t3.avg_avg_r1_significant_strikes_leg_accuracy_diff_diff AS avg_avg_r1_significant_strikes_leg_accuracy_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff / t3.avg_opp_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff AS avg_opp_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff_diff / t3.avg_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff_diff AS avg_avg_r1_significant_strikes_leg_landed_per_significant_strikes_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_leg_attempted_diff AS avg_opp_avg_r1_significant_strikes_leg_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_leg_attempted_diff_diff AS avg_avg_r1_significant_strikes_leg_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_attempted_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_leg_attempted_per_second_diff AS avg_opp_avg_r1_significant_strikes_leg_attempted_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_attempted_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_leg_attempted_per_second_diff_diff AS avg_avg_r1_significant_strikes_leg_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff AS avg_opp_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_diff AS avg_avg_r1_significant_strikes_leg_attempted_per_significant_strikes_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_landed_diff / t3.avg_opp_avg_r1_significant_strikes_distance_landed_diff AS avg_opp_avg_r1_significant_strikes_distance_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_landed_diff_diff / t3.avg_avg_r1_significant_strikes_distance_landed_diff_diff AS avg_avg_r1_significant_strikes_distance_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_landed_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_distance_landed_per_second_diff AS avg_opp_avg_r1_significant_strikes_distance_landed_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_landed_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_distance_landed_per_second_diff_diff AS avg_avg_r1_significant_strikes_distance_landed_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_accuracy_diff / t3.avg_opp_avg_r1_significant_strikes_distance_accuracy_diff AS avg_opp_avg_r1_significant_strikes_distance_accuracy_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_accuracy_diff_diff / t3.avg_avg_r1_significant_strikes_distance_accuracy_diff_diff AS avg_avg_r1_significant_strikes_distance_accuracy_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff / t3.avg_opp_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff AS avg_opp_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff_diff / t3.avg_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff_diff AS avg_avg_r1_significant_strikes_distance_landed_per_significant_strikes_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_distance_attempted_diff AS avg_opp_avg_r1_significant_strikes_distance_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_distance_attempted_diff_diff AS avg_avg_r1_significant_strikes_distance_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_attempted_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_distance_attempted_per_second_diff AS avg_opp_avg_r1_significant_strikes_distance_attempted_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_attempted_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_distance_attempted_per_second_diff_diff AS avg_avg_r1_significant_strikes_distance_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff AS avg_opp_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_diff AS avg_avg_r1_significant_strikes_distance_attempted_per_significant_strikes_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_landed_diff / t3.avg_opp_avg_r1_significant_strikes_clinch_landed_diff AS avg_opp_avg_r1_significant_strikes_clinch_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_landed_diff_diff / t3.avg_avg_r1_significant_strikes_clinch_landed_diff_diff AS avg_avg_r1_significant_strikes_clinch_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_landed_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_clinch_landed_per_second_diff AS avg_opp_avg_r1_significant_strikes_clinch_landed_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_landed_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_clinch_landed_per_second_diff_diff AS avg_avg_r1_significant_strikes_clinch_landed_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_accuracy_diff / t3.avg_opp_avg_r1_significant_strikes_clinch_accuracy_diff AS avg_opp_avg_r1_significant_strikes_clinch_accuracy_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_accuracy_diff_diff / t3.avg_avg_r1_significant_strikes_clinch_accuracy_diff_diff AS avg_avg_r1_significant_strikes_clinch_accuracy_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff / t3.avg_opp_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff AS avg_opp_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_diff / t3.avg_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_diff AS avg_avg_r1_significant_strikes_clinch_landed_per_significant_strikes_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_clinch_attempted_diff AS avg_opp_avg_r1_significant_strikes_clinch_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_clinch_attempted_diff_diff AS avg_avg_r1_significant_strikes_clinch_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_attempted_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_clinch_attempted_per_second_diff AS avg_opp_avg_r1_significant_strikes_clinch_attempted_per_second_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff AS avg_opp_avg_r1_significant_strikes_clinch_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_clinch_attempted_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_clinch_attempted_per_second_diff_diff AS avg_avg_r1_significant_strikes_clinch_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_landed_diff / t3.avg_opp_avg_r1_significant_strikes_ground_landed_diff AS avg_opp_avg_r1_significant_strikes_ground_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_landed_diff_diff / t3.avg_avg_r1_significant_strikes_ground_landed_diff_diff AS avg_avg_r1_significant_strikes_ground_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_landed_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_ground_landed_per_second_diff AS avg_opp_avg_r1_significant_strikes_ground_landed_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_landed_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_ground_landed_per_second_diff_diff AS avg_avg_r1_significant_strikes_ground_landed_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_accuracy_diff / t3.avg_opp_avg_r1_significant_strikes_ground_accuracy_diff AS avg_opp_avg_r1_significant_strikes_ground_accuracy_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_accuracy_diff_diff / t3.avg_avg_r1_significant_strikes_ground_accuracy_diff_diff AS avg_avg_r1_significant_strikes_ground_accuracy_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff / t3.avg_opp_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff AS avg_opp_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff_diff / t3.avg_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff_diff AS avg_avg_r1_significant_strikes_ground_landed_per_significant_strikes_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_ground_attempted_diff AS avg_opp_avg_r1_significant_strikes_ground_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_ground_attempted_diff_diff AS avg_avg_r1_significant_strikes_ground_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_attempted_per_second_diff / t3.avg_opp_avg_r1_significant_strikes_ground_attempted_per_second_diff AS avg_opp_avg_r1_significant_strikes_ground_attempted_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_attempted_per_second_diff_diff / t3.avg_avg_r1_significant_strikes_ground_attempted_per_second_diff_diff AS avg_avg_r1_significant_strikes_ground_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff / t3.avg_opp_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff AS avg_opp_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_diff / t3.avg_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_diff AS avg_avg_r1_significant_strikes_ground_attempted_per_significant_strikes_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_landed_diff / t3.avg_opp_avg_r1_takedowns_landed_diff AS avg_opp_avg_r1_takedowns_landed_diff_ratio,
    1.0 * t2.avg_avg_r1_takedowns_landed_diff_diff / t3.avg_avg_r1_takedowns_landed_diff_diff AS avg_avg_r1_takedowns_landed_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_landed_per_second_diff / t3.avg_opp_avg_r1_takedowns_landed_per_second_diff AS avg_opp_avg_r1_takedowns_landed_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_takedowns_landed_per_second_diff_diff / t3.avg_avg_r1_takedowns_landed_per_second_diff_diff AS avg_avg_r1_takedowns_landed_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_accuracy_diff / t3.avg_opp_avg_r1_takedowns_accuracy_diff AS avg_opp_avg_r1_takedowns_accuracy_diff_ratio,
    1.0 * t2.avg_avg_r1_takedowns_accuracy_diff_diff / t3.avg_avg_r1_takedowns_accuracy_diff_diff AS avg_avg_r1_takedowns_accuracy_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_attempted_diff / t3.avg_opp_avg_r1_takedowns_attempted_diff AS avg_opp_avg_r1_takedowns_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_takedowns_attempted_diff_diff / t3.avg_avg_r1_takedowns_attempted_diff_diff AS avg_avg_r1_takedowns_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_takedowns_attempted_per_second_diff / t3.avg_opp_avg_r1_takedowns_attempted_per_second_diff AS avg_opp_avg_r1_takedowns_attempted_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_takedowns_attempted_per_second_diff_diff / t3.avg_avg_r1_takedowns_attempted_per_second_diff_diff AS avg_avg_r1_takedowns_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_reversals_scored_diff / t3.avg_opp_avg_r1_reversals_scored_diff AS avg_opp_avg_r1_reversals_scored_diff_ratio,
    1.0 * t2.avg_avg_r1_reversals_scored_diff_diff / t3.avg_avg_r1_reversals_scored_diff_diff AS avg_avg_r1_reversals_scored_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_reversals_scored_per_second_diff / t3.avg_opp_avg_r1_reversals_scored_per_second_diff AS avg_opp_avg_r1_reversals_scored_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_reversals_scored_per_second_diff_diff / t3.avg_avg_r1_reversals_scored_per_second_diff_diff AS avg_avg_r1_reversals_scored_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_submissions_attempted_diff / t3.avg_opp_avg_r1_submissions_attempted_diff AS avg_opp_avg_r1_submissions_attempted_diff_ratio,
    1.0 * t2.avg_avg_r1_submissions_attempted_diff_diff / t3.avg_avg_r1_submissions_attempted_diff_diff AS avg_avg_r1_submissions_attempted_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_submissions_attempted_per_second_diff / t3.avg_opp_avg_r1_submissions_attempted_per_second_diff AS avg_opp_avg_r1_submissions_attempted_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_submissions_attempted_per_second_diff_diff / t3.avg_avg_r1_submissions_attempted_per_second_diff_diff AS avg_avg_r1_submissions_attempted_per_second_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_control_time_seconds_diff / t3.avg_opp_avg_r1_control_time_seconds_diff AS avg_opp_avg_r1_control_time_seconds_diff_ratio,
    1.0 * t2.avg_avg_r1_control_time_seconds_diff_diff / t3.avg_avg_r1_control_time_seconds_diff_diff AS avg_avg_r1_control_time_seconds_diff_diff_ratio,
    1.0 * t2.avg_opp_avg_r1_control_time_seconds_per_second_diff / t3.avg_opp_avg_r1_control_time_seconds_per_second_diff AS avg_opp_avg_r1_control_time_seconds_per_second_diff_ratio,
    1.0 * t2.avg_avg_r1_control_time_seconds_per_second_diff_diff / t3.avg_avg_r1_control_time_seconds_per_second_diff_diff AS avg_avg_r1_control_time_seconds_per_second_diff_diff_ratio,
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