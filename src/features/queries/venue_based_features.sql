WITH cte1 AS (
    SELECT id,
        red_fighter_id AS fighter_id,
        red_outcome AS outcome
    FROM ufcstats_bouts
    UNION
    SELECT id,
        blue_fighter_id AS fighter_id,
        blue_outcome AS outcome
    FROM ufcstats_bouts
),
cte2 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.bout_id,
        t1.opponent_id,
        CASE
            WHEN t6.outcome = 'W' THEN 1
            ELSE 0
        END AS win,
        CASE
            WHEN t6.outcome = 'L' THEN 1
            ELSE 0
        END AS loss,
        t4.venue_id,
        t5.latitude,
        t5.longitude,
        LAG(t5.latitude) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
        ) AS prev_latitude,
        LAG(t5.longitude) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order'
        ) AS prev_longitude,
        t5.elevation_meters,
        t5.capacity,
        t4.attendance
    FROM ufcstats_fighter_histories t1
        LEFT JOIN ufcstats_bouts t2 ON t1.bout_id = t2.id
        LEFT JOIN event_mapping t3 ON t2.event_id = t3.ufcstats_id
        LEFT JOIN wikipedia_events t4 ON t3.wikipedia_id = t4.id
        LEFT JOIN wikipedia_venues t5 ON t4.venue_id = t5.id
        LEFT JOIN cte1 t6 ON t1.bout_id = t6.id
        AND t1.fighter_id = t6.fighter_id
),
cte3 AS (
    SELECT fighter_id,
        t1.'order',
        bout_id,
        opponent_id,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            venue_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_at_venue,
        SUM(loss) OVER (
            PARTITION BY fighter_id,
            venue_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_at_venue,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            venue_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_rate_at_venue,
        AVG(loss) OVER (
            PARTITION BY fighter_id,
            venue_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS loss_rate_at_venue,
        AVG(win) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_rate_temp,
        AVG(loss) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS loss_rate_temp,
        CASE
            WHEN latitude IS NULL
            OR prev_latitude IS NULL
            OR longitude IS NULL
            OR prev_longitude IS NULL THEN NULL
            ELSE 111.0 * DEGREES(
                ACOS(
                    MIN(
                        1.0,
                        COS(RADIANS(latitude)) * COS(RADIANS(prev_latitude)) * COS(RADIANS(longitude - prev_longitude)) + SIN(RADIANS(latitude)) * SIN(RADIANS(prev_latitude))
                    )
                )
            )
        END AS distance_km_change,
        AVG(elevation_meters) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elevation_meters,
        elevation_meters - LAG(elevation_meters) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS elevation_meters_change,
        AVG(capacity) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_event_capacity,
        capacity - LAG(capacity) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS event_capacity_change,
        AVG(attendance) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_event_attendance,
        attendance - LAG(attendance) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS event_attendance_change,
        1.0 * attendance / capacity AS event_occupancy_pct,
        1.0 * attendance / capacity - LAG(1.0 * attendance / capacity) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS event_occupancy_pct_change
    FROM cte2 t1
    ORDER BY fighter_id,
        t1.'order'
),
cte4 AS (
    SELECT fighter_id,
        t1.'order',
        bout_id,
        opponent_id,
        CASE
            WHEN wins_at_venue IS NULL THEN 0
            ELSE wins_at_venue
        END AS wins_at_venue,
        CASE
            WHEN losses_at_venue IS NULL THEN 0
            ELSE losses_at_venue
        END AS losses_at_venue,
        CASE
            WHEN win_rate_at_venue IS NULL THEN win_rate_temp
            ELSE win_rate_at_venue
        END AS win_rate_at_venue,
        CASE
            WHEN loss_rate_at_venue IS NULL THEN loss_rate_temp
            ELSE loss_rate_at_venue
        END AS loss_rate_at_venue,
        distance_km_change,
        AVG(distance_km_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_distance_km_change,
        avg_elevation_meters,
        elevation_meters_change,
        AVG(elevation_meters_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_elevation_meters_change,
        avg_event_capacity,
        event_capacity_change,
        AVG(event_capacity_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_event_capacity_change,
        avg_event_attendance,
        event_attendance_change,
        AVG(event_attendance_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_event_attendance_change,
        AVG(event_occupancy_pct) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_event_occupancy_pct,
        LAG(event_occupancy_pct_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS event_occupancy_pct_change,
        AVG(event_occupancy_pct_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_event_occupancy_pct_change
    FROM cte3 t1
),
cte5 AS (
    SELECT t1.*,
        AVG(t2.wins_at_venue) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_at_venue,
        AVG(t1.wins_at_venue - t2.wins_at_venue) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_at_venue_diff,
        AVG(t2.losses_at_venue) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_at_venue,
        AVG(t1.losses_at_venue - t2.losses_at_venue) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_at_venue_diff,
        AVG(t2.win_rate_at_venue) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_rate_at_venue,
        AVG(t1.win_rate_at_venue - t2.win_rate_at_venue) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_rate_at_venue_diff,
        AVG(t2.loss_rate_at_venue) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_rate_at_venue,
        AVG(t1.loss_rate_at_venue - t2.loss_rate_at_venue) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_rate_at_venue_diff,
        AVG(t2.distance_km_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_distance_km_change,
        AVG(t1.distance_km_change - t2.distance_km_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_distance_km_change_diff,
        AVG(t2.avg_distance_km_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_distance_km_change,
        AVG(
            t1.distance_km_change - t2.avg_distance_km_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_distance_km_change_diff,
        AVG(t2.avg_elevation_meters) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_elevation_meters,
        AVG(
            t1.avg_elevation_meters - t2.avg_elevation_meters
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_elevation_meters_diff,
        AVG(t2.elevation_meters_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_elevation_meters_change,
        AVG(
            t1.elevation_meters_change - t2.elevation_meters_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_elevation_meters_change_diff,
        AVG(t2.avg_elevation_meters_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_elevation_meters_change,
        AVG(
            t1.avg_elevation_meters_change - t2.avg_elevation_meters_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_elevation_meters_change_diff,
        AVG(t2.avg_event_capacity) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_capacity,
        AVG(t1.avg_event_capacity - t2.avg_event_capacity) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_capacity_diff,
        AVG(t2.event_capacity_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_event_capacity_change,
        AVG(
            t1.event_capacity_change - t2.event_capacity_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_event_capacity_change_diff,
        AVG(t2.avg_event_capacity_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_capacity_change,
        AVG(
            t1.avg_event_capacity_change - t2.avg_event_capacity_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_capacity_change_diff,
        AVG(t2.avg_event_attendance) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_attendance,
        AVG(
            t1.avg_event_attendance - t2.avg_event_attendance
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_attendance_diff,
        AVG(t2.event_attendance_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_event_attendance_change,
        AVG(
            t1.event_attendance_change - t2.event_attendance_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_event_attendance_change_diff,
        AVG(t2.avg_event_attendance_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_attendance_change,
        AVG(
            t1.avg_event_attendance_change - t2.avg_event_attendance_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_attendance_change_diff,
        AVG(t2.avg_event_occupancy_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_occupancy_pct,
        AVG(
            t1.avg_event_occupancy_pct - t2.avg_event_occupancy_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_occupancy_pct_diff,
        AVG(t2.event_occupancy_pct_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_event_occupancy_pct_change,
        AVG(
            t1.event_occupancy_pct_change - t2.event_occupancy_pct_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_event_occupancy_pct_change_diff,
        AVG(t2.avg_event_occupancy_pct_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_occupancy_pct_change,
        AVG(
            t1.avg_event_occupancy_pct_change - t2.avg_event_occupancy_pct_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_event_occupancy_pct_change_diff
    FROM cte4 t1
        LEFT JOIN cte4 t2 ON t1.fighter_id = t2.opponent_id
        AND t1.bout_id = t2.bout_id
        AND t1.opponent_id = t2.fighter_id
)
SELECT id,
    t2.wins_at_venue - t3.wins_at_venue AS wins_at_venue_diff,
    1.0 * t2.wins_at_venue / t3.wins_at_venue AS wins_at_venue_ratio,
    t2.losses_at_venue - t3.losses_at_venue AS losses_at_venue_diff,
    1.0 * t2.losses_at_venue / t3.losses_at_venue AS losses_at_venue_ratio,
    t2.win_rate_at_venue - t3.win_rate_at_venue AS win_rate_at_venue_diff,
    1.0 * t2.win_rate_at_venue / t3.win_rate_at_venue AS win_rate_at_venue_ratio,
    t2.loss_rate_at_venue - t3.loss_rate_at_venue AS loss_rate_at_venue_diff,
    1.0 * t2.loss_rate_at_venue / t3.loss_rate_at_venue AS loss_rate_at_venue_ratio,
    t2.distance_km_change - t3.distance_km_change AS distance_km_change_diff,
    1.0 * t2.distance_km_change / t3.distance_km_change AS distance_km_change_ratio,
    t2.avg_distance_km_change - t3.avg_distance_km_change AS avg_distance_km_change_diff,
    1.0 * t2.avg_distance_km_change / t3.avg_distance_km_change AS avg_distance_km_change_ratio,
    t2.avg_elevation_meters - t3.avg_elevation_meters AS avg_elevation_meters_diff,
    1.0 * t2.avg_elevation_meters / t3.avg_elevation_meters AS avg_elevation_meters_ratio,
    t2.elevation_meters_change - t3.elevation_meters_change AS elevation_meters_change_diff,
    1.0 * t2.elevation_meters_change / t3.elevation_meters_change AS elevation_meters_change_ratio,
    t2.avg_elevation_meters_change - t3.avg_elevation_meters_change AS avg_elevation_meters_change_diff,
    1.0 * t2.avg_elevation_meters_change / t3.avg_elevation_meters_change AS avg_elevation_meters_change_ratio,
    t2.avg_event_capacity - t3.avg_event_capacity AS avg_event_capacity_diff,
    1.0 * t2.avg_event_capacity / t3.avg_event_capacity AS avg_event_capacity_ratio,
    t2.event_capacity_change - t3.event_capacity_change AS event_capacity_change_diff,
    1.0 * t2.event_capacity_change / t3.event_capacity_change AS event_capacity_change_ratio,
    t2.avg_event_capacity_change - t3.avg_event_capacity_change AS avg_event_capacity_change_diff,
    1.0 * t2.avg_event_capacity_change / t3.avg_event_capacity_change AS avg_event_capacity_change_ratio,
    t2.avg_event_attendance - t3.avg_event_attendance AS avg_event_attendance_diff,
    1.0 * t2.avg_event_attendance / t3.avg_event_attendance AS avg_event_attendance_ratio,
    t2.event_attendance_change - t3.event_attendance_change AS event_attendance_change_diff,
    1.0 * t2.event_attendance_change / t3.event_attendance_change AS event_attendance_change_ratio,
    t2.avg_event_attendance_change - t3.avg_event_attendance_change AS avg_event_attendance_change_diff,
    1.0 * t2.avg_event_attendance_change / t3.avg_event_attendance_change AS avg_event_attendance_change_ratio,
    t2.avg_event_occupancy_pct - t3.avg_event_occupancy_pct AS avg_event_occupancy_pct_diff,
    1.0 * t2.avg_event_occupancy_pct / t3.avg_event_occupancy_pct AS avg_event_occupancy_pct_ratio,
    t2.event_occupancy_pct_change - t3.event_occupancy_pct_change AS event_occupancy_pct_change_diff,
    1.0 * t2.event_occupancy_pct_change / t3.event_occupancy_pct_change AS event_occupancy_pct_change_ratio,
    t2.avg_event_occupancy_pct_change - t3.avg_event_occupancy_pct_change AS avg_event_occupancy_pct_change_diff,
    1.0 * t2.avg_event_occupancy_pct_change / t3.avg_event_occupancy_pct_change AS avg_event_occupancy_pct_change_ratio,
    t2.avg_opp_wins_at_venue - t3.wins_at_venue AS avg_opp_wins_at_venue_diff,
    1.0 * t2.avg_opp_wins_at_venue / t3.wins_at_venue AS avg_opp_wins_at_venue_ratio,
    t2.avg_opp_wins_at_venue_diff - t3.wins_at_venue_diff AS avg_opp_wins_at_venue_diff_diff,
    1.0 * t2.avg_opp_wins_at_venue_diff / t3.wins_at_venue_diff AS avg_opp_wins_at_venue_diff_ratio,
    t2.avg_opp_losses_at_venue - t3.losses_at_venue AS avg_opp_losses_at_venue_diff,
    1.0 * t2.avg_opp_losses_at_venue / t3.losses_at_venue AS avg_opp_losses_at_venue_ratio,
    t2.avg_opp_losses_at_venue_diff - t3.losses_at_venue_diff AS avg_opp_losses_at_venue_diff_diff,
    1.0 * t2.avg_opp_losses_at_venue_diff / t3.losses_at_venue_diff AS avg_opp_losses_at_venue_diff_ratio,
    t2.avg_opp_win_rate_at_venue - t3.win_rate_at_venue AS avg_opp_win_rate_at_venue_diff,
    1.0 * t2.avg_opp_win_rate_at_venue / t3.win_rate_at_venue AS avg_opp_win_rate_at_venue_ratio,
    t2.avg_opp_win_rate_at_venue_diff - t3.avg_opp_win_rate_at_venue_diff AS avg_opp_win_rate_at_venue_diff_diff,
    1.0 * t2.avg_opp_win_rate_at_venue_diff / t3.avg_opp_win_rate_at_venue_diff AS avg_opp_win_rate_at_venue_diff_ratio,
    t2.avg_opp_loss_rate_at_venue - t3.loss_rate_at_venue AS avg_opp_loss_rate_at_venue_diff,
    1.0 * t2.avg_opp_loss_rate_at_venue / t3.loss_rate_at_venue AS avg_opp_loss_rate_at_venue_ratio,
    t2.avg_opp_loss_rate_at_venue_diff - t3.avg_opp_loss_rate_at_venue_diff AS avg_opp_loss_rate_at_venue_diff_diff,
    1.0 * t2.avg_opp_loss_rate_at_venue_diff / t3.avg_opp_loss_rate_at_venue_diff AS avg_opp_loss_rate_at_venue_diff_ratio,
    t2.avg_opp_distance_km_change - t3.avg_opp_distance_km_change AS avg_opp_distance_km_change_diff,
    1.0 * t2.avg_opp_distance_km_change / t3.avg_opp_distance_km_change AS avg_opp_distance_km_change_ratio,
    t2.avg_opp_distance_km_change_diff - t3.avg_opp_distance_km_change_diff AS avg_opp_distance_km_change_diff_diff,
    1.0 * t2.avg_opp_distance_km_change_diff / t3.avg_opp_distance_km_change_diff AS avg_opp_distance_km_change_diff_ratio,
    t2.avg_opp_avg_distance_km_change - t3.avg_opp_avg_distance_km_change AS avg_opp_avg_distance_km_change_diff,
    1.0 * t2.avg_opp_avg_distance_km_change / t3.avg_opp_avg_distance_km_change AS avg_opp_avg_distance_km_change_ratio,
    t2.avg_opp_avg_distance_km_change_diff - t3.avg_opp_avg_distance_km_change_diff AS avg_opp_avg_distance_km_change_diff_diff,
    1.0 * t2.avg_opp_avg_distance_km_change_diff / t3.avg_opp_avg_distance_km_change_diff AS avg_opp_avg_distance_km_change_diff_ratio,
    t2.avg_opp_avg_elevation_meters - t3.avg_opp_avg_elevation_meters AS avg_opp_avg_elevation_meters_diff,
    1.0 * t2.avg_opp_avg_elevation_meters / t3.avg_opp_avg_elevation_meters AS avg_opp_avg_elevation_meters_ratio,
    t2.avg_opp_avg_elevation_meters_diff - t3.avg_opp_avg_elevation_meters_diff AS avg_opp_avg_elevation_meters_diff_diff,
    1.0 * t2.avg_opp_avg_elevation_meters_diff / t3.avg_opp_avg_elevation_meters_diff AS avg_opp_avg_elevation_meters_diff_ratio,
    t2.avg_opp_elevation_meters_change - t3.avg_opp_elevation_meters_change AS avg_opp_elevation_meters_change_diff,
    1.0 * t2.avg_opp_elevation_meters_change / t3.avg_opp_elevation_meters_change AS avg_opp_elevation_meters_change_ratio,
    t2.avg_opp_elevation_meters_change_diff - t3.avg_opp_elevation_meters_change_diff AS avg_opp_elevation_meters_change_diff_diff,
    1.0 * t2.avg_opp_elevation_meters_change_diff / t3.avg_opp_elevation_meters_change_diff AS avg_opp_elevation_meters_change_diff_ratio,
    t2.avg_opp_avg_elevation_meters_change - t3.avg_opp_avg_elevation_meters_change AS avg_opp_avg_elevation_meters_change_diff,
    1.0 * t2.avg_opp_avg_elevation_meters_change / t3.avg_opp_avg_elevation_meters_change AS avg_opp_avg_elevation_meters_change_ratio,
    t2.avg_opp_avg_elevation_meters_change_diff - t3.avg_opp_avg_elevation_meters_change_diff AS avg_opp_avg_elevation_meters_change_diff_diff,
    1.0 * t2.avg_opp_avg_elevation_meters_change_diff / t3.avg_opp_avg_elevation_meters_change_diff AS avg_opp_avg_elevation_meters_change_diff_ratio,
    t2.avg_opp_avg_event_capacity - t3.avg_opp_avg_event_capacity AS avg_opp_avg_event_capacity_diff,
    1.0 * t2.avg_opp_avg_event_capacity / t3.avg_opp_avg_event_capacity AS avg_opp_avg_event_capacity_ratio,
    t2.avg_opp_avg_event_capacity_diff - t3.avg_opp_avg_event_capacity_diff AS avg_opp_avg_event_capacity_diff_diff,
    1.0 * t2.avg_opp_avg_event_capacity_diff / t3.avg_opp_avg_event_capacity_diff AS avg_opp_avg_event_capacity_diff_ratio,
    t2.avg_opp_event_capacity_change - t3.avg_opp_event_capacity_change AS avg_opp_event_capacity_change_diff,
    1.0 * t2.avg_opp_event_capacity_change / t3.avg_opp_event_capacity_change AS avg_opp_event_capacity_change_ratio,
    t2.avg_opp_event_capacity_change_diff - t3.avg_opp_event_capacity_change_diff AS avg_opp_event_capacity_change_diff_diff,
    1.0 * t2.avg_opp_event_capacity_change_diff / t3.avg_opp_event_capacity_change_diff AS avg_opp_event_capacity_change_diff_ratio,
    t2.avg_opp_avg_event_capacity_change - t3.avg_opp_avg_event_capacity_change AS avg_opp_avg_event_capacity_change_diff,
    1.0 * t2.avg_opp_avg_event_capacity_change / t3.avg_opp_avg_event_capacity_change AS avg_opp_avg_event_capacity_change_ratio,
    t2.avg_opp_avg_event_capacity_change_diff - t3.avg_opp_avg_event_capacity_change_diff AS avg_opp_avg_event_capacity_change_diff_diff,
    1.0 * t2.avg_opp_avg_event_capacity_change_diff / t3.avg_opp_avg_event_capacity_change_diff AS avg_opp_avg_event_capacity_change_diff_ratio,
    t2.avg_opp_avg_event_attendance - t3.avg_opp_avg_event_attendance AS avg_opp_avg_event_attendance_diff,
    1.0 * t2.avg_opp_avg_event_attendance / t3.avg_opp_avg_event_attendance AS avg_opp_avg_event_attendance_ratio,
    t2.avg_opp_avg_event_attendance_diff - t3.avg_opp_avg_event_attendance_diff AS avg_opp_avg_event_attendance_diff_diff,
    1.0 * t2.avg_opp_avg_event_attendance_diff / t3.avg_opp_avg_event_attendance_diff AS avg_opp_avg_event_attendance_diff_ratio,
    t2.avg_opp_event_attendance_change - t3.avg_opp_event_attendance_change AS avg_opp_event_attendance_change_diff,
    1.0 * t2.avg_opp_event_attendance_change / t3.avg_opp_event_attendance_change AS avg_opp_event_attendance_change_ratio,
    t2.avg_opp_event_attendance_change_diff - t3.avg_opp_event_attendance_change_diff AS avg_opp_event_attendance_change_diff_diff,
    1.0 * t2.avg_opp_event_attendance_change_diff / t3.avg_opp_event_attendance_change_diff AS avg_opp_event_attendance_change_diff_ratio,
    t2.avg_opp_avg_event_attendance_change - t3.avg_opp_avg_event_attendance_change AS avg_opp_avg_event_attendance_change_diff,
    1.0 * t2.avg_opp_avg_event_attendance_change / t3.avg_opp_avg_event_attendance_change AS avg_opp_avg_event_attendance_change_ratio,
    t2.avg_opp_avg_event_attendance_change_diff - t3.avg_opp_avg_event_attendance_change_diff AS avg_opp_avg_event_attendance_change_diff_diff,
    1.0 * t2.avg_opp_avg_event_attendance_change_diff / t3.avg_opp_avg_event_attendance_change_diff AS avg_opp_avg_event_attendance_change_diff_ratio,
    t2.avg_opp_avg_event_occupancy_pct - t3.avg_opp_avg_event_occupancy_pct AS avg_opp_avg_event_occupancy_pct_diff,
    1.0 * t2.avg_opp_avg_event_occupancy_pct / t3.avg_opp_avg_event_occupancy_pct AS avg_opp_avg_event_occupancy_pct_ratio,
    t2.avg_opp_avg_event_occupancy_pct_diff - t3.avg_opp_avg_event_occupancy_pct_diff AS avg_opp_avg_event_occupancy_pct_diff_diff,
    1.0 * t2.avg_opp_avg_event_occupancy_pct_diff / t3.avg_opp_avg_event_occupancy_pct_diff AS avg_opp_avg_event_occupancy_pct_diff_ratio,
    t2.avg_opp_event_occupancy_pct_change - t3.avg_opp_event_occupancy_pct_change AS avg_opp_event_occupancy_pct_change_diff,
    1.0 * t2.avg_opp_event_occupancy_pct_change / t3.avg_opp_event_occupancy_pct_change AS avg_opp_event_occupancy_pct_change_ratio,
    t2.avg_opp_event_occupancy_pct_change_diff - t3.avg_opp_event_occupancy_pct_change_diff AS avg_opp_event_occupancy_pct_change_diff_diff,
    1.0 * t2.avg_opp_event_occupancy_pct_change_diff / t3.avg_opp_event_occupancy_pct_change_diff AS avg_opp_event_occupancy_pct_change_diff_ratio,
    t2.avg_opp_avg_event_occupancy_pct_change - t3.avg_opp_avg_event_occupancy_pct_change AS avg_opp_avg_event_occupancy_pct_change_diff,
    1.0 * t2.avg_opp_avg_event_occupancy_pct_change / t3.avg_opp_avg_event_occupancy_pct_change AS avg_opp_avg_event_occupancy_pct_change_ratio,
    t2.avg_opp_avg_event_occupancy_pct_change_diff - t3.avg_opp_avg_event_occupancy_pct_change_diff AS avg_opp_avg_event_occupancy_pct_change_diff_diff,
    1.0 * t2.avg_opp_avg_event_occupancy_pct_change_diff / t3.avg_opp_avg_event_occupancy_pct_change_diff AS avg_opp_avg_event_occupancy_pct_change_diff_ratio,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte5 AS t2 ON t1.id = t2.bout_id
    AND t1.red_fighter_id = t2.fighter_id
    LEFT JOIN cte5 AS t3 ON t1.id = t3.bout_id
    AND t1.blue_fighter_id = t3.fighter_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );