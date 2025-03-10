WITH cte1 AS (
    SELECT issue_date,
        weight_class,
        MAX(rank) AS max_rank,
        MIN(points) AS min_points,
        MAX(points) AS max_points
    FROM fightmatrix_rankings
    GROUP BY issue_date,
        weight_class
),
cte2 AS (
    SELECT fighter_id,
        t1.issue_date,
        t1.weight_class,
        rank,
        AVG(rank) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_rank,
        rank - LAG(rank) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.issue_date
        ) AS rank_change,
        1.0 * (max_rank - rank) / max_rank AS rank_percentile,
        AVG(1.0 * (max_rank - rank) / max_rank) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_rank_percentile,
        1.0 * (max_rank - rank) / max_rank - LAG(1.0 * (max_rank - rank) / max_rank) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.issue_date
        ) AS rank_percentile_change,
        points AS ranking_points,
        AVG(points) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_ranking_points,
        points - LAG(points) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.issue_date
        ) AS ranking_points_change,
        1.0 * (points - min_points) / (max_points - min_points) AS ranking_points_scaled,
        AVG(
            1.0 * (points - min_points) / (max_points - min_points)
        ) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_ranking_points_scaled,
        1.0 * (points - min_points) / (max_points - min_points) - LAG(
            1.0 * (points - min_points) / (max_points - min_points)
        ) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.issue_date
        ) AS ranking_points_scaled_change
    FROM fightmatrix_rankings AS t1
        LEFT JOIN cte1 AS t2 ON t1.issue_date = t2.issue_date
        AND t1.weight_class = t2.weight_class
),
cte3 AS (
    SELECT fighter_id,
        issue_date,
        rank,
        avg_rank,
        rank_change,
        AVG(rank_change) OVER (
            PARTITION BY fighter_id
            ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_rank_change,
        rank_percentile,
        avg_rank_percentile,
        rank_percentile_change,
        AVG(rank_percentile_change) OVER (
            PARTITION BY fighter_id
            ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_rank_percentile_change,
        ranking_points,
        avg_ranking_points,
        ranking_points_change,
        AVG(ranking_points_change) OVER (
            PARTITION BY fighter_id
            ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_ranking_points_change,
        ranking_points_scaled,
        avg_ranking_points_scaled,
        ranking_points_scaled_change,
        AVG(ranking_points_scaled_change) OVER (
            PARTITION BY fighter_id
            ORDER BY issue_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS avg_ranking_points_scaled_change
    FROM cte2
),
cte4 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.event_id,
        t1.date,
        t1.opponent_id,
        t2.rank,
        t2.avg_rank,
        t2.rank_change,
        t2.avg_rank_change,
        t2.rank_percentile,
        t2.avg_rank_percentile,
        t2.rank_percentile_change,
        t2.avg_rank_percentile_change,
        t2.ranking_points,
        t2.avg_ranking_points,
        t2.ranking_points_change,
        t2.avg_ranking_points_change,
        t2.ranking_points_scaled,
        t2.avg_ranking_points_scaled,
        t2.ranking_points_scaled_change,
        t2.avg_ranking_points_scaled_change,
        ROW_NUMBER() OVER (
            PARTITION BY t1.fighter_id,
            t1.'order'
            ORDER BY t2.issue_date DESC
        ) AS rn
    FROM fightmatrix_fighter_histories AS t1
        LEFT JOIN cte3 AS t2 ON t1.fighter_id = t2.fighter_id
        AND t1.date > t2.issue_date
),
cte5 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.event_id,
        t1.date,
        t1.opponent_id,
        t1.rank,
        t1.avg_rank,
        t1.rank_change,
        t1.avg_rank_change,
        t1.rank_percentile,
        t1.avg_rank_percentile,
        t1.rank_percentile_change,
        t1.avg_rank_percentile_change,
        t1.ranking_points,
        t1.avg_ranking_points,
        t1.ranking_points_change,
        t1.avg_ranking_points_change,
        t1.ranking_points_scaled,
        t1.avg_ranking_points_scaled,
        t1.ranking_points_scaled_change,
        t1.avg_ranking_points_scaled_change
    FROM cte4 AS t1
    WHERE t1.rn = 1
),
cte6 AS (
    SELECT t1.*,
        t2.rank AS opp_rank,
        t2.avg_rank AS opp_avg_rank,
        t2.rank_change AS opp_rank_change,
        t2.avg_rank_change AS opp_avg_rank_change,
        t2.rank_percentile AS opp_rank_percentile,
        t2.avg_rank_percentile AS opp_avg_rank_percentile,
        t2.rank_percentile_change AS opp_rank_percentile_change,
        t2.avg_rank_percentile_change AS opp_avg_rank_percentile_change,
        t2.ranking_points AS opp_ranking_points,
        t2.avg_ranking_points AS opp_avg_ranking_points,
        t2.ranking_points_change AS opp_ranking_points_change,
        t2.avg_ranking_points_change AS opp_avg_ranking_points_change,
        t2.ranking_points_scaled AS opp_ranking_points_scaled,
        t2.avg_ranking_points_scaled AS opp_avg_ranking_points_scaled,
        t2.ranking_points_scaled_change AS opp_ranking_points_scaled_change,
        t2.avg_ranking_points_scaled_change AS opp_avg_ranking_points_scaled_change,
        ROW_NUMBER() OVER (
            PARTITION BY t1.fighter_id,
            t1.'order'
            ORDER BY t2.issue_date DESC
        ) AS rn
    FROM cte5 AS t1
        LEFT JOIN cte3 AS t2 ON t1.opponent_id = t2.fighter_id
        AND t1.date > t2.issue_date
),
cte7 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        date,
        opponent_id,
        rank,
        avg_rank,
        rank_change,
        avg_rank_change,
        rank_percentile,
        avg_rank_percentile,
        rank_percentile_change,
        avg_rank_percentile_change,
        ranking_points,
        avg_ranking_points,
        ranking_points_change,
        avg_ranking_points_change,
        ranking_points_scaled,
        avg_ranking_points_scaled,
        ranking_points_scaled_change,
        avg_ranking_points_scaled_change,
        opp_rank,
        opp_avg_rank,
        opp_rank_change,
        opp_avg_rank_change,
        opp_rank_percentile,
        opp_avg_rank_percentile,
        opp_rank_percentile_change,
        opp_avg_rank_percentile_change,
        opp_ranking_points,
        opp_avg_ranking_points,
        opp_ranking_points_change,
        opp_avg_ranking_points_change,
        opp_ranking_points_scaled,
        opp_avg_ranking_points_scaled,
        opp_ranking_points_scaled_change,
        opp_avg_ranking_points_scaled_change
    FROM cte6 AS t1
    WHERE rn = 1
),
cte8 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        date,
        opponent_id,
        rank,
        avg_rank,
        rank_change,
        avg_rank_change,
        rank_percentile,
        avg_rank_percentile,
        rank_percentile_change,
        avg_rank_percentile_change,
        ranking_points,
        avg_ranking_points,
        ranking_points_change,
        avg_ranking_points_change,
        ranking_points_scaled,
        avg_ranking_points_scaled,
        ranking_points_scaled_change,
        avg_ranking_points_scaled_change,
        AVG(opp_rank) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_rank,
        AVG(opp_avg_rank) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_rank,
        AVG(opp_rank_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_rank_change,
        AVG(opp_avg_rank_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_rank_change,
        AVG(opp_rank_percentile) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_rank_percentile,
        AVG(opp_avg_rank_percentile) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_rank_percentile,
        AVG(opp_rank_percentile_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_rank_percentile_change,
        AVG(opp_avg_rank_percentile_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_rank_percentile_change,
        AVG(opp_ranking_points) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ranking_points,
        AVG(opp_avg_ranking_points) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ranking_points,
        AVG(opp_ranking_points_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ranking_points_change,
        AVG(opp_avg_ranking_points_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ranking_points_change,
        AVG(opp_ranking_points_scaled) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ranking_points_scaled,
        AVG(opp_avg_ranking_points_scaled) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ranking_points_scaled,
        AVG(opp_ranking_points_scaled_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ranking_points_scaled_change,
        AVG(opp_avg_ranking_points_scaled_change) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_ranking_points_scaled_change,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id,
            event_id,
            opponent_id
            ORDER BY t1.'order'
        ) AS temp_rn
    FROM cte7 AS t1
),
cte9 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.event_id,
        t1.date,
        t1.opponent_id,
        t1.rank,
        t1.avg_rank,
        t1.rank_change,
        t1.avg_rank_change,
        t1.rank_percentile,
        t1.avg_rank_percentile,
        t1.rank_percentile_change,
        t1.avg_rank_percentile_change,
        t1.ranking_points,
        t1.avg_ranking_points,
        t1.ranking_points_change,
        t1.avg_ranking_points_change,
        t1.ranking_points_scaled,
        t1.avg_ranking_points_scaled,
        t1.ranking_points_scaled_change,
        t1.avg_ranking_points_scaled_change,
        t1.avg_opp_rank,
        t1.avg_opp_avg_rank,
        t1.avg_opp_rank_change,
        t1.avg_opp_avg_rank_change,
        t1.avg_opp_rank_percentile,
        t1.avg_opp_avg_rank_percentile,
        t1.avg_opp_rank_percentile_change,
        t1.avg_opp_avg_rank_percentile_change,
        t1.avg_opp_ranking_points,
        t1.avg_opp_avg_ranking_points,
        t1.avg_opp_ranking_points_change,
        t1.avg_opp_avg_ranking_points_change,
        t1.avg_opp_ranking_points_scaled,
        t1.avg_opp_avg_ranking_points_scaled,
        t1.avg_opp_ranking_points_scaled_change,
        t1.avg_opp_avg_ranking_points_scaled_change,
        AVG(t1.rank - t2.rank) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_rank_diff,
        AVG(t1.avg_rank - t2.avg_rank) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_rank_diff,
        AVG(t1.rank_change - t2.rank_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_rank_change_diff,
        AVG(t1.avg_rank_change - t2.avg_rank_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_rank_change_diff,
        AVG(t1.rank_percentile - t2.rank_percentile) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_rank_percentile_diff,
        AVG(t1.avg_rank_percentile - t2.avg_rank_percentile) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_rank_percentile_diff,
        AVG(
            t1.rank_percentile_change - t2.rank_percentile_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_rank_percentile_change_diff,
        AVG(
            t1.avg_rank_percentile_change - t2.avg_rank_percentile_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_rank_percentile_change_diff,
        AVG(t1.ranking_points - t2.ranking_points) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ranking_points_diff,
        AVG(t1.avg_ranking_points - t2.avg_ranking_points) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ranking_points_diff,
        AVG(
            t1.ranking_points_change - t2.ranking_points_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ranking_points_change_diff,
        AVG(
            t1.avg_ranking_points_change - t2.avg_ranking_points_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ranking_points_change_diff,
        AVG(
            t1.ranking_points_scaled - t2.ranking_points_scaled
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ranking_points_scaled_diff,
        AVG(
            t1.avg_ranking_points_scaled - t2.avg_ranking_points_scaled
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ranking_points_scaled_diff,
        AVG(
            t1.ranking_points_scaled_change - t2.ranking_points_scaled_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ranking_points_scaled_change_diff,
        AVG(
            t1.avg_ranking_points_scaled_change - t2.avg_ranking_points_scaled_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_ranking_points_scaled_change_diff,
        AVG(t1.avg_opp_rank - t2.avg_opp_rank) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_rank_diff,
        AVG(t1.avg_opp_avg_rank - t2.avg_opp_avg_rank) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_avg_rank_diff,
        AVG(t1.avg_opp_rank_change - t2.avg_opp_rank_change) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_rank_change_diff,
        AVG(
            t1.avg_opp_avg_rank_change - t2.avg_opp_avg_rank_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_avg_rank_change_diff,
        AVG(
            t1.avg_opp_rank_percentile - t2.avg_opp_rank_percentile
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_rank_percentile_diff,
        AVG(
            t1.avg_opp_avg_rank_percentile - t2.avg_opp_avg_rank_percentile
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_avg_rank_percentile_diff,
        AVG(
            t1.avg_opp_rank_percentile_change - t2.avg_opp_rank_percentile_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_rank_percentile_change_diff,
        AVG(
            t1.avg_opp_avg_rank_percentile_change - t2.avg_opp_avg_rank_percentile_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_avg_rank_percentile_change_diff,
        AVG(
            t1.avg_opp_ranking_points - t2.avg_opp_ranking_points
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_ranking_points_diff,
        AVG(
            t1.avg_opp_avg_ranking_points - t2.avg_opp_avg_ranking_points
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_avg_ranking_points_diff,
        AVG(
            t1.avg_opp_ranking_points_change - t2.avg_opp_ranking_points_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_ranking_points_change_diff,
        AVG(
            t1.avg_opp_avg_ranking_points_change - t2.avg_opp_avg_ranking_points_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_avg_ranking_points_change_diff,
        AVG(
            t1.avg_opp_ranking_points_scaled - t2.avg_opp_ranking_points_scaled
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_ranking_points_scaled_diff,
        AVG(
            t1.avg_opp_avg_ranking_points_scaled - t2.avg_opp_avg_ranking_points_scaled
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_avg_ranking_points_scaled_diff,
        AVG(
            t1.avg_opp_ranking_points_scaled_change - t2.avg_opp_ranking_points_scaled_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_ranking_points_scaled_change_diff,
        AVG(
            t1.avg_opp_avg_ranking_points_scaled_change - t2.avg_opp_avg_ranking_points_scaled_change
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_opp_avg_ranking_points_scaled_change_diff
    FROM cte8 AS t1
        LEFT JOIN cte8 AS t2 ON t1.opponent_id = t2.fighter_id
        AND t1.event_id = t2.event_id
        AND t1.fighter_id = t2.opponent_id
        AND t1.temp_rn = t2.temp_rn
),
cte10 AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t1.'order',
        t4.ufcstats_id AS event_id,
        t3.ufcstats_id AS opponent_id,
        t1.rank,
        t1.avg_rank,
        t1.rank_change,
        t1.avg_rank_change,
        t1.rank_percentile,
        t1.avg_rank_percentile,
        t1.rank_percentile_change,
        t1.avg_rank_percentile_change,
        t1.ranking_points,
        t1.avg_ranking_points,
        t1.ranking_points_change,
        t1.avg_ranking_points_change,
        t1.ranking_points_scaled,
        t1.avg_ranking_points_scaled,
        t1.ranking_points_scaled_change,
        t1.avg_ranking_points_scaled_change,
        t1.avg_opp_rank,
        t1.avg_opp_avg_rank,
        t1.avg_opp_rank_change,
        t1.avg_opp_avg_rank_change,
        t1.avg_opp_rank_percentile,
        t1.avg_opp_avg_rank_percentile,
        t1.avg_opp_rank_percentile_change,
        t1.avg_opp_avg_rank_percentile_change,
        t1.avg_opp_ranking_points,
        t1.avg_opp_avg_ranking_points,
        t1.avg_opp_ranking_points_change,
        t1.avg_opp_avg_ranking_points_change,
        t1.avg_opp_ranking_points_scaled,
        t1.avg_opp_avg_ranking_points_scaled,
        t1.avg_opp_ranking_points_scaled_change,
        t1.avg_opp_avg_ranking_points_scaled_change,
        t1.avg_rank_diff,
        t1.avg_avg_rank_diff,
        t1.avg_rank_change_diff,
        t1.avg_avg_rank_change_diff,
        t1.avg_rank_percentile_diff,
        t1.avg_avg_rank_percentile_diff,
        t1.avg_rank_percentile_change_diff,
        t1.avg_avg_rank_percentile_change_diff,
        t1.avg_ranking_points_diff,
        t1.avg_avg_ranking_points_diff,
        t1.avg_ranking_points_change_diff,
        t1.avg_avg_ranking_points_change_diff,
        t1.avg_ranking_points_scaled_diff,
        t1.avg_avg_ranking_points_scaled_diff,
        t1.avg_ranking_points_scaled_change_diff,
        t1.avg_avg_ranking_points_scaled_change_diff,
        t1.avg_avg_opp_rank_diff,
        t1.avg_avg_opp_avg_rank_diff,
        t1.avg_avg_opp_rank_change_diff,
        t1.avg_avg_opp_avg_rank_change_diff,
        t1.avg_avg_opp_rank_percentile_diff,
        t1.avg_avg_opp_avg_rank_percentile_diff,
        t1.avg_avg_opp_rank_percentile_change_diff,
        t1.avg_avg_opp_avg_rank_percentile_change_diff,
        t1.avg_avg_opp_ranking_points_diff,
        t1.avg_avg_opp_avg_ranking_points_diff,
        t1.avg_avg_opp_ranking_points_change_diff,
        t1.avg_avg_opp_avg_ranking_points_change_diff,
        t1.avg_avg_opp_ranking_points_scaled_diff,
        t1.avg_avg_opp_avg_ranking_points_scaled_diff,
        t1.avg_avg_opp_ranking_points_scaled_change_diff,
        t1.avg_avg_opp_avg_ranking_points_scaled_change_diff
    FROM cte9 AS t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.fightmatrix_id
        INNER JOIN fighter_mapping AS t3 ON t1.opponent_id = t3.fightmatrix_id
        INNER JOIN event_mapping AS t4 ON t1.event_id = t4.fightmatrix_id
),
cte11 AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        opponent_id,
        t1.rank,
        t1.avg_rank,
        t1.rank_change,
        t1.avg_rank_change,
        t1.rank_percentile,
        t1.avg_rank_percentile,
        t1.rank_percentile_change,
        t1.avg_rank_percentile_change,
        t1.ranking_points,
        t1.avg_ranking_points,
        t1.ranking_points_change,
        t1.avg_ranking_points_change,
        t1.ranking_points_scaled,
        t1.avg_ranking_points_scaled,
        t1.ranking_points_scaled_change,
        t1.avg_ranking_points_scaled_change,
        t1.avg_opp_rank,
        t1.avg_opp_avg_rank,
        t1.avg_opp_rank_change,
        t1.avg_opp_avg_rank_change,
        t1.avg_opp_rank_percentile,
        t1.avg_opp_avg_rank_percentile,
        t1.avg_opp_rank_percentile_change,
        t1.avg_opp_avg_rank_percentile_change,
        t1.avg_opp_ranking_points,
        t1.avg_opp_avg_ranking_points,
        t1.avg_opp_ranking_points_change,
        t1.avg_opp_avg_ranking_points_change,
        t1.avg_opp_ranking_points_scaled,
        t1.avg_opp_avg_ranking_points_scaled,
        t1.avg_opp_ranking_points_scaled_change,
        t1.avg_opp_avg_ranking_points_scaled_change,
        t1.avg_rank_diff,
        t1.avg_avg_rank_diff,
        t1.avg_rank_change_diff,
        t1.avg_avg_rank_change_diff,
        t1.avg_rank_percentile_diff,
        t1.avg_avg_rank_percentile_diff,
        t1.avg_rank_percentile_change_diff,
        t1.avg_avg_rank_percentile_change_diff,
        t1.avg_ranking_points_diff,
        t1.avg_avg_ranking_points_diff,
        t1.avg_ranking_points_change_diff,
        t1.avg_avg_ranking_points_change_diff,
        t1.avg_ranking_points_scaled_diff,
        t1.avg_avg_ranking_points_scaled_diff,
        t1.avg_ranking_points_scaled_change_diff,
        t1.avg_avg_ranking_points_scaled_change_diff,
        t1.avg_avg_opp_rank_diff,
        t1.avg_avg_opp_avg_rank_diff,
        t1.avg_avg_opp_rank_change_diff,
        t1.avg_avg_opp_avg_rank_change_diff,
        t1.avg_avg_opp_rank_percentile_diff,
        t1.avg_avg_opp_avg_rank_percentile_diff,
        t1.avg_avg_opp_rank_percentile_change_diff,
        t1.avg_avg_opp_avg_rank_percentile_change_diff,
        t1.avg_avg_opp_ranking_points_diff,
        t1.avg_avg_opp_avg_ranking_points_diff,
        t1.avg_avg_opp_ranking_points_change_diff,
        t1.avg_avg_opp_avg_ranking_points_change_diff,
        t1.avg_avg_opp_ranking_points_scaled_diff,
        t1.avg_avg_opp_avg_ranking_points_scaled_diff,
        t1.avg_avg_opp_ranking_points_scaled_change_diff,
        t1.avg_avg_opp_avg_ranking_points_scaled_change_diff
    FROM cte10 AS t1
),
cte12 AS (
    SELECT t1.*
    FROM ufcstats_fighter_histories AS t1
        LEFT JOIN ufcstats_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN ufcstats_events AS t3 ON t2.event_id = t3.id
    WHERE t3.is_ufc_event = 1
),
cte13 AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        bout_id,
        opponent_id
    FROM cte12 AS t1
),
cte14 AS (
    SELECT t1.fighter_id,
        t1.bout_id,
        t2.rank,
        t2.avg_rank,
        t2.rank_change,
        t2.avg_rank_change,
        t2.rank_percentile,
        t2.avg_rank_percentile,
        t2.rank_percentile_change,
        t2.avg_rank_percentile_change,
        t2.ranking_points,
        t2.avg_ranking_points,
        t2.ranking_points_change,
        t2.avg_ranking_points_change,
        t2.ranking_points_scaled,
        t2.avg_ranking_points_scaled,
        t2.ranking_points_scaled_change,
        t2.avg_ranking_points_scaled_change,
        t2.avg_opp_rank,
        t2.avg_opp_avg_rank,
        t2.avg_opp_rank_change,
        t2.avg_opp_avg_rank_change,
        t2.avg_opp_rank_percentile,
        t2.avg_opp_avg_rank_percentile,
        t2.avg_opp_rank_percentile_change,
        t2.avg_opp_avg_rank_percentile_change,
        t2.avg_opp_ranking_points,
        t2.avg_opp_avg_ranking_points,
        t2.avg_opp_ranking_points_change,
        t2.avg_opp_avg_ranking_points_change,
        t2.avg_opp_ranking_points_scaled,
        t2.avg_opp_avg_ranking_points_scaled,
        t2.avg_opp_ranking_points_scaled_change,
        t2.avg_opp_avg_ranking_points_scaled_change,
        t2.avg_rank_diff,
        t2.avg_avg_rank_diff,
        t2.avg_rank_change_diff,
        t2.avg_avg_rank_change_diff,
        t2.avg_rank_percentile_diff,
        t2.avg_avg_rank_percentile_diff,
        t2.avg_rank_percentile_change_diff,
        t2.avg_avg_rank_percentile_change_diff,
        t2.avg_ranking_points_diff,
        t2.avg_avg_ranking_points_diff,
        t2.avg_ranking_points_change_diff,
        t2.avg_avg_ranking_points_change_diff,
        t2.avg_ranking_points_scaled_diff,
        t2.avg_avg_ranking_points_scaled_diff,
        t2.avg_ranking_points_scaled_change_diff,
        t2.avg_avg_ranking_points_scaled_change_diff,
        t2.avg_avg_opp_rank_diff,
        t2.avg_avg_opp_avg_rank_diff,
        t2.avg_avg_opp_rank_change_diff,
        t2.avg_avg_opp_avg_rank_change_diff,
        t2.avg_avg_opp_rank_percentile_diff,
        t2.avg_avg_opp_avg_rank_percentile_diff,
        t2.avg_avg_opp_rank_percentile_change_diff,
        t2.avg_avg_opp_avg_rank_percentile_change_diff,
        t2.avg_avg_opp_ranking_points_diff,
        t2.avg_avg_opp_avg_ranking_points_diff,
        t2.avg_avg_opp_ranking_points_change_diff,
        t2.avg_avg_opp_avg_ranking_points_change_diff,
        t2.avg_avg_opp_ranking_points_scaled_diff,
        t2.avg_avg_opp_avg_ranking_points_scaled_diff,
        t2.avg_avg_opp_ranking_points_scaled_change_diff,
        t2.avg_avg_opp_avg_ranking_points_scaled_change_diff
    FROM cte13 AS t1
        INNER JOIN cte11 AS t2 ON t1.fighter_id = t2.fighter_id
        AND t1.ufc_order = t2.ufc_order
        AND t1.opponent_id = t2.opponent_id
)
SELECT id,
    t2.rank - t3.rank AS rank_diff,
    t2.avg_rank - t3.avg_rank AS avg_rank_diff,
    t2.rank_change - t3.rank_change AS rank_change_diff,
    t2.avg_rank_change - t3.avg_rank_change AS avg_rank_change_diff,
    t2.rank_percentile - t3.rank_percentile AS rank_percentile_diff,
    t2.avg_rank_percentile - t3.avg_rank_percentile AS avg_rank_percentile_diff,
    t2.rank_percentile_change - t3.rank_percentile_change AS rank_percentile_change_diff,
    t2.avg_rank_percentile_change - t3.avg_rank_percentile_change AS avg_rank_percentile_change_diff,
    t2.ranking_points - t3.ranking_points AS ranking_points_diff,
    t2.avg_ranking_points - t3.avg_ranking_points AS avg_ranking_points_diff,
    t2.ranking_points_change - t3.ranking_points_change AS ranking_points_change_diff,
    t2.avg_ranking_points_change - t3.avg_ranking_points_change AS avg_ranking_points_change_diff,
    t2.ranking_points_scaled - t3.ranking_points_scaled AS ranking_points_scaled_diff,
    t2.avg_ranking_points_scaled - t3.avg_ranking_points_scaled AS avg_ranking_points_scaled_diff,
    t2.ranking_points_scaled_change - t3.ranking_points_scaled_change AS ranking_points_scaled_change_diff,
    t2.avg_ranking_points_scaled_change - t3.avg_ranking_points_scaled_change AS avg_ranking_points_scaled_change_diff,
    t2.avg_opp_rank - t3.avg_opp_rank AS avg_opp_rank_diff,
    t2.avg_opp_avg_rank - t3.avg_opp_avg_rank AS avg_opp_avg_rank_diff,
    t2.avg_opp_rank_change - t3.avg_opp_rank_change AS avg_opp_rank_change_diff,
    t2.avg_opp_avg_rank_change - t3.avg_opp_avg_rank_change AS avg_opp_avg_rank_change_diff,
    t2.avg_opp_rank_percentile - t3.avg_opp_rank_percentile AS avg_opp_rank_percentile_diff,
    t2.avg_opp_avg_rank_percentile - t3.avg_opp_avg_rank_percentile AS avg_opp_avg_rank_percentile_diff,
    t2.avg_opp_rank_percentile_change - t3.avg_opp_rank_percentile_change AS avg_opp_rank_percentile_change_diff,
    t2.avg_opp_avg_rank_percentile_change - t3.avg_opp_avg_rank_percentile_change AS avg_opp_avg_rank_percentile_change_diff,
    t2.avg_opp_ranking_points - t3.avg_opp_ranking_points AS avg_opp_ranking_points_diff,
    t2.avg_opp_avg_ranking_points - t3.avg_opp_avg_ranking_points AS avg_opp_avg_ranking_points_diff,
    t2.avg_opp_ranking_points_change - t3.avg_opp_ranking_points_change AS avg_opp_ranking_points_change_diff,
    t2.avg_opp_avg_ranking_points_change - t3.avg_opp_avg_ranking_points_change AS avg_opp_avg_ranking_points_change_diff,
    t2.avg_opp_ranking_points_scaled - t3.avg_opp_ranking_points_scaled AS avg_opp_ranking_points_scaled_diff,
    t2.avg_opp_avg_ranking_points_scaled - t3.avg_opp_avg_ranking_points_scaled AS avg_opp_avg_ranking_points_scaled_diff,
    t2.avg_opp_ranking_points_scaled_change - t3.avg_opp_ranking_points_scaled_change AS avg_opp_ranking_points_scaled_change_diff,
    t2.avg_opp_avg_ranking_points_scaled_change - t3.avg_opp_avg_ranking_points_scaled_change AS avg_opp_avg_ranking_points_scaled_change_diff,
    t2.avg_rank_diff - t3.avg_rank_diff AS avg_rank_diff_diff,
    t2.avg_avg_rank_diff - t3.avg_avg_rank_diff AS avg_avg_rank_diff_diff,
    t2.avg_rank_change_diff - t3.avg_rank_change_diff AS avg_rank_change_diff_diff,
    t2.avg_avg_rank_change_diff - t3.avg_avg_rank_change_diff AS avg_avg_rank_change_diff_diff,
    t2.avg_rank_percentile_diff - t3.avg_rank_percentile_diff AS avg_rank_percentile_diff_diff,
    t2.avg_avg_rank_percentile_diff - t3.avg_avg_rank_percentile_diff AS avg_avg_rank_percentile_diff_diff,
    t2.avg_rank_percentile_change_diff - t3.avg_rank_percentile_change_diff AS avg_rank_percentile_change_diff_diff,
    t2.avg_avg_rank_percentile_change_diff - t3.avg_avg_rank_percentile_change_diff AS avg_avg_rank_percentile_change_diff_diff,
    t2.avg_ranking_points_diff - t3.avg_ranking_points_diff AS avg_ranking_points_diff_diff,
    t2.avg_avg_ranking_points_diff - t3.avg_avg_ranking_points_diff AS avg_avg_ranking_points_diff_diff,
    t2.avg_ranking_points_change_diff - t3.avg_ranking_points_change_diff AS avg_ranking_points_change_diff_diff,
    t2.avg_avg_ranking_points_change_diff - t3.avg_avg_ranking_points_change_diff AS avg_avg_ranking_points_change_diff_diff,
    t2.avg_ranking_points_scaled_diff - t3.avg_ranking_points_scaled_diff AS avg_ranking_points_scaled_diff_diff,
    t2.avg_avg_ranking_points_scaled_diff - t3.avg_avg_ranking_points_scaled_diff AS avg_avg_ranking_points_scaled_diff_diff,
    t2.avg_ranking_points_scaled_change_diff - t3.avg_ranking_points_scaled_change_diff AS avg_ranking_points_scaled_change_diff_diff,
    t2.avg_avg_ranking_points_scaled_change_diff - t3.avg_avg_ranking_points_scaled_change_diff AS avg_avg_ranking_points_scaled_change_diff_diff,
    t2.avg_avg_opp_rank_diff - t3.avg_avg_opp_rank_diff AS avg_avg_opp_rank_diff_diff,
    t2.avg_avg_opp_avg_rank_diff - t3.avg_avg_opp_avg_rank_diff AS avg_avg_opp_avg_rank_diff_diff,
    t2.avg_avg_opp_rank_change_diff - t3.avg_avg_opp_rank_change_diff AS avg_avg_opp_rank_change_diff_diff,
    t2.avg_avg_opp_avg_rank_change_diff - t3.avg_avg_opp_avg_rank_change_diff AS avg_avg_opp_avg_rank_change_diff_diff,
    t2.avg_avg_opp_rank_percentile_diff - t3.avg_avg_opp_rank_percentile_diff AS avg_avg_opp_rank_percentile_diff_diff,
    t2.avg_avg_opp_avg_rank_percentile_diff - t3.avg_avg_opp_avg_rank_percentile_diff AS avg_avg_opp_avg_rank_percentile_diff_diff,
    t2.avg_avg_opp_rank_percentile_change_diff - t3.avg_avg_opp_rank_percentile_change_diff AS avg_avg_opp_rank_percentile_change_diff_diff,
    t2.avg_avg_opp_avg_rank_percentile_change_diff - t3.avg_avg_opp_avg_rank_percentile_change_diff AS avg_avg_opp_avg_rank_percentile_change_diff_diff,
    t2.avg_avg_opp_ranking_points_diff - t3.avg_avg_opp_ranking_points_diff AS avg_avg_opp_ranking_points_diff_diff,
    t2.avg_avg_opp_avg_ranking_points_diff - t3.avg_avg_opp_avg_ranking_points_diff AS avg_avg_opp_avg_ranking_points_diff_diff,
    t2.avg_avg_opp_ranking_points_change_diff - t3.avg_avg_opp_ranking_points_change_diff AS avg_avg_opp_ranking_points_change_diff_diff,
    t2.avg_avg_opp_avg_ranking_points_change_diff - t3.avg_avg_opp_avg_ranking_points_change_diff AS avg_avg_opp_avg_ranking_points_change_diff_diff,
    t2.avg_avg_opp_ranking_points_scaled_diff - t3.avg_avg_opp_ranking_points_scaled_diff AS avg_avg_opp_ranking_points_scaled_diff_diff,
    t2.avg_avg_opp_avg_ranking_points_scaled_diff - t3.avg_avg_opp_avg_ranking_points_scaled_diff AS avg_avg_opp_avg_ranking_points_scaled_diff_diff,
    t2.avg_avg_opp_ranking_points_scaled_change_diff - t3.avg_avg_opp_ranking_points_scaled_change_diff AS avg_avg_opp_ranking_points_scaled_change_diff_diff,
    t2.avg_avg_opp_avg_ranking_points_scaled_change_diff - t3.avg_avg_opp_avg_ranking_points_scaled_change_diff AS avg_avg_opp_avg_ranking_points_scaled_change_diff_diff,
    CASE
        WHEN red_outcome = 'W' THEN 1
        ELSE 0
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte14 AS t2 ON t1.id = t2.bout_id
    AND t1.red_fighter_id = t2.fighter_id
    LEFT JOIN cte14 AS t3 ON t1.id = t3.bout_id
    AND t1.blue_fighter_id = t3.fighter_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );