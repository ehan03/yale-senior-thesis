WITH cte1 AS (
    SELECT event_id,
        MAX(name) AS event_name,
        t2.date,
        MAX(t3.wikipedia_id) AS event_order,
        COUNT(
            CASE
                WHEN red_outcome = 'W' THEN 1
            END
        ) AS red_wins,
        COUNT(*) AS n_bouts
    FROM ufcstats_bouts AS t1
        LEFT JOIN ufcstats_events AS t2 ON t1.event_id = t2.id
        INNER JOIN event_mapping AS t3 ON t1.event_id = t3.ufcstats_id
    WHERE t2.is_ufc_event = 1
    GROUP BY event_id
    ORDER BY event_order
),
cte2 AS (
    SELECT t1.event_id,
        t1.date,
        t4.latitude,
        t4.longitude,
        t4.elevation_meters,
        AVG(t3.attendance) OVER(
            PARTITION BY t3.venue_id
            ORDER BY t1.event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_venue_attendance,
        t4.capacity AS venue_capacity,
        AVG(1.0 * t3.attendance / t4.capacity) OVER(
            PARTITION BY t3.venue_id
            ORDER BY t1.event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_venue_occupancy_pct,
        AVG(1.0 * t3.attendance / t4.capacity) OVER(
            ORDER BY t1.event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_occupancy_pct,
        t1.event_order,
        t1.red_wins,
        t1.n_bouts,
        CASE
            WHEN t1.event_name LIKE 'UFC %'
            AND t1.event_name GLOB 'UFC [0-9]*' THEN 1
            ELSE 0
        END AS is_ppv,
        t3.venue_id,
        t5.country,
        strftime('%Y', t6.date) AS year,
        strftime('%m', t6.date) AS month,
        t6.hour_utc AS start_hour_utc
    FROM cte1 AS t1
        LEFT JOIN event_mapping AS t2 ON t1.event_id = t2.ufcstats_id
        LEFT JOIN wikipedia_events AS t3 ON t2.wikipedia_id = t3.id
        LEFT JOIN wikipedia_venues AS t4 ON t3.venue_id = t4.id
        LEFT JOIN fightmatrix_events AS t5 ON t2.fightmatrix_id = t5.id
        LEFT JOIN espn_events AS t6 ON t2.espn_id = t6.id
),
cte3 AS (
    SELECT event_id,
        latitude,
        longitude,
        elevation_meters,
        CASE
            WHEN avg_venue_attendance IS NULL THEN avg_occupancy_pct * venue_capacity
            ELSE avg_venue_attendance
        END AS avg_venue_attendance,
        venue_capacity,
        CASE
            WHEN avg_venue_occupancy_pct IS NULL THEN avg_occupancy_pct
            ELSE avg_venue_occupancy_pct
        END AS avg_venue_occupancy_pct,
        event_order,
        SUM(red_wins) OVER(
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS red_wins_cumsum,
        SUM(n_bouts) OVER(
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS n_bouts_cumsum,
        is_ppv,
        SUM(red_wins) OVER (
            PARTITION BY is_ppv
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS red_wins_cumsum_ppv_type,
        SUM(n_bouts) OVER (
            PARTITION BY is_ppv
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS n_bouts_cumsum_ppv_type,
        SUM(red_wins) OVER(
            PARTITION BY venue_id
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS red_wins_cumsum_venue,
        SUM(n_bouts) OVER(
            PARTITION BY venue_id
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS n_bouts_cumsum_venue,
        SUM(red_wins) OVER(
            PARTITION BY country
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS red_wins_cumsum_country,
        SUM(n_bouts) OVER(
            PARTITION BY country
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS n_bouts_cumsum_country,
        SUM(red_wins) OVER(
            PARTITION BY year
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS red_wins_cumsum_year,
        SUM(n_bouts) OVER(
            PARTITION BY year
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS n_bouts_cumsum_year,
        SUM(red_wins) OVER(
            PARTITION BY year,
            month
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS red_wins_cumsum_month,
        SUM(n_bouts) OVER(
            PARTITION BY year,
            month
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS n_bouts_cumsum_month,
        SUM(red_wins) OVER(
            PARTITION BY year,
            month
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS red_wins_cumsum_year_month,
        SUM(n_bouts) OVER(
            PARTITION BY year,
            month
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS n_bouts_cumsum_year_month,
        SUM(red_wins) OVER(
            PARTITION BY start_hour_utc
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS red_wins_cumsum_start_hour,
        SUM(n_bouts) OVER(
            PARTITION BY start_hour_utc
            ORDER BY event_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS n_bouts_cumsum_start_hour
    FROM cte2 AS t1
    WHERE t1.date >= '2008-04-19'
),
cte4 AS (
    SELECT event_id,
        latitude,
        longitude,
        elevation_meters,
        avg_venue_attendance,
        venue_capacity,
        avg_venue_occupancy_pct,
        CASE
            WHEN red_wins_cumsum IS NULL then 0.5
            ELSE 1.0 * red_wins_cumsum / n_bouts_cumsum
        END AS red_win_pct_overall,
        is_ppv,
        red_wins_cumsum_ppv_type,
        n_bouts_cumsum_ppv_type,
        red_wins_cumsum_venue,
        n_bouts_cumsum_venue,
        red_wins_cumsum_country,
        n_bouts_cumsum_country,
        red_wins_cumsum_year,
        n_bouts_cumsum_year,
        red_wins_cumsum_month,
        n_bouts_cumsum_month,
        red_wins_cumsum_year_month,
        n_bouts_cumsum_year_month,
        red_wins_cumsum_start_hour,
        n_bouts_cumsum_start_hour
    FROM cte3
),
cte5 AS (
    SELECT event_id,
        latitude,
        longitude,
        elevation_meters,
        avg_venue_attendance,
        venue_capacity,
        avg_venue_occupancy_pct,
        red_win_pct_overall,
        is_ppv,
        CASE
            WHEN red_wins_cumsum_ppv_type IS NULL THEN red_win_pct_overall
            ELSE 1.0 * red_wins_cumsum_ppv_type / n_bouts_cumsum_ppv_type
        END AS red_win_pct_by_ppv_type,
        CASE
            WHEN red_wins_cumsum_venue IS NULL THEN red_win_pct_overall
            ELSE 1.0 * red_wins_cumsum_venue / n_bouts_cumsum_venue
        END AS red_win_pct_by_venue,
        CASE
            WHEN red_wins_cumsum_country IS NULL THEN red_win_pct_overall
            ELSE 1.0 * red_wins_cumsum_country / n_bouts_cumsum_country
        END AS red_win_pct_by_country,
        CASE
            WHEN red_wins_cumsum_year IS NULL THEN red_win_pct_overall
            ELSE 1.0 * red_wins_cumsum_year / n_bouts_cumsum_year
        END AS red_win_pct_by_year,
        CASE
            WHEN red_wins_cumsum_month IS NULL THEN red_win_pct_overall
            ELSE 1.0 * red_wins_cumsum_month / n_bouts_cumsum_month
        END AS red_win_pct_by_month,
        CASE
            WHEN red_wins_cumsum_year_month IS NULL THEN red_win_pct_overall
            ELSE 1.0 * red_wins_cumsum_year_month / n_bouts_cumsum_year_month
        END AS red_win_pct_by_year_month,
        CASE
            WHEN red_wins_cumsum_start_hour IS NULL THEN red_win_pct_overall
            ELSE 1.0 * red_wins_cumsum_start_hour / n_bouts_cumsum_start_hour
        END AS red_win_pct_by_start_hour
    FROM cte4
)
SELECT t1.id,
    latitude,
    longitude,
    elevation_meters,
    avg_venue_attendance,
    venue_capacity,
    avg_venue_occupancy_pct,
    red_win_pct_overall,
    is_ppv,
    red_win_pct_by_ppv_type,
    red_win_pct_by_venue,
    red_win_pct_by_country,
    red_win_pct_by_year,
    red_win_pct_by_month,
    red_win_pct_by_year_month,
    red_win_pct_by_start_hour,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte5 AS t2 ON t1.event_id = t2.event_id
WHERE t1.event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );