WITH cte1 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        opponent_id,
        JULIANDAY(date) - JULIANDAY(
            LAG(date) OVER (
                PARTITION BY fighter_id
                ORDER BY t1.'order'
            )
        ) AS days_since_last_fight,
        JULIANDAY(date) - JULIANDAY(pro_debut_date) AS days_since_pro_debut,
        CASE
            WHEN JULIANDAY(date) - JULIANDAY(ufc_debut_date) < 0 THEN NULL
            ELSE JULIANDAY(date) - JULIANDAY(ufc_debut_date)
        END AS days_since_ufc_debut,
        CASE
            WHEN outcome = 'W' THEN 1
            ELSE 0
        END AS win_flag,
        CASE
            WHEN outcome = 'L' THEN 1
            ELSE 0
        END AS loss_flag
    FROM fightmatrix_fighter_histories t1
        LEFT JOIN fightmatrix_fighters t2 ON t1.fighter_id = t2.id
),
cte2 AS (
    SELECT *,
        SUM(win_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS wins,
        SUM(loss_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS losses,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) - ROW_NUMBER() OVER (
            PARTITION BY fighter_id,
            win_flag
            ORDER BY t1.'order'
        ) AS win_grp,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) - ROW_NUMBER() OVER (
            PARTITION BY fighter_id,
            loss_flag
            ORDER BY t1.'order'
        ) AS loss_grp
    FROM cte1 t1
),
cte3 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        opponent_id,
        days_since_last_fight,
        days_since_pro_debut,
        days_since_ufc_debut,
        wins,
        1.0 * wins / t1.'order' AS win_pct,
        losses,
        1.0 * losses / t1.'order' AS loss_pct,
        CASE
            WHEN win_flag = 1 THEN COUNT(*) OVER (
                PARTITION BY fighter_id,
                win_flag,
                win_grp
                ORDER BY t1.'order'
            )
            ELSE 0
        END AS win_streak,
        CASE
            WHEN loss_flag = 1 THEN COUNT(*) OVER (
                PARTITION BY fighter_id,
                loss_flag,
                loss_grp
                ORDER BY t1.'order'
            )
            ELSE 0
        END AS loss_streak
    FROM cte2 t1
    ORDER BY fighter_id,
        t1.'order'
),
cte4 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        opponent_id,
        days_since_last_fight,
        days_since_pro_debut,
        days_since_ufc_debut,
        LAG(t1.'order') OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS total_fights,
        LAG(wins) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins,
        LAG(win_pct) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS win_pct,
        LAG(losses) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses,
        LAG(loss_pct) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS loss_pct,
        LAG(win_streak) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS win_streak,
        LAG(loss_streak) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS loss_streak
    FROM cte3 t1
),
cte5 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        opponent_id,
        days_since_last_fight,
        AVG(days_since_last_fight) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_days_since_last_fight,
        days_since_pro_debut,
        AVG(days_since_pro_debut) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_days_since_pro_debut,
        days_since_ufc_debut,
        AVG(days_since_ufc_debut) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_days_since_ufc_debut,
        CASE
            WHEN total_fights IS NULL THEN 0
            ELSE total_fights
        END AS total_fights,
        CASE
            WHEN wins IS NULL THEN 0
            ELSE wins
        END AS wins,
        win_pct,
        CASE
            WHEN losses IS NULL THEN 0
            ELSE losses
        END AS losses,
        loss_pct,
        CASE
            WHEN win_streak IS NULL THEN 0
            ELSE win_streak
        END AS win_streak,
        CASE
            WHEN loss_streak IS NULL THEN 0
            ELSE loss_streak
        END AS loss_streak
    FROM cte4 t1
),
cte6 AS (
    SELECT *,
        MAX(win_streak) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS longest_win_streak,
        MAX(loss_streak) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS longest_loss_streak,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id,
            event_id,
            opponent_id
            ORDER BY t1.'order'
        ) AS temp_rn
    FROM cte5 t1
),
cte7 AS (
    SELECT t1.*,
        AVG(t2.days_since_last_fight) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_days_since_last_fight,
        AVG(
            t1.days_since_last_fight - t2.days_since_last_fight
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_days_since_last_fight_diff,
        AVG(t2.avg_days_since_last_fight) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_days_since_last_fight,
        AVG(
            t1.avg_days_since_last_fight - t2.avg_days_since_last_fight
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_days_since_last_fight_diff,
        AVG(t2.days_since_pro_debut) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_days_since_pro_debut,
        AVG(
            t1.days_since_pro_debut - t2.days_since_pro_debut
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_days_since_pro_debut_diff,
        AVG(t2.avg_days_since_pro_debut) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_days_since_pro_debut,
        AVG(
            t1.avg_days_since_pro_debut - t2.avg_days_since_pro_debut
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_days_since_pro_debut_diff,
        AVG(t2.days_since_ufc_debut) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_days_since_ufc_debut,
        AVG(
            t1.days_since_ufc_debut - t2.days_since_ufc_debut
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_days_since_ufc_debut_diff,
        AVG(t2.avg_days_since_ufc_debut) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_days_since_ufc_debut,
        AVG(
            t1.avg_days_since_ufc_debut - t2.avg_days_since_ufc_debut
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_days_since_ufc_debut_diff,
        AVG(t2.total_fights) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_total_fights,
        AVG(t1.total_fights - t2.total_fights) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_total_fights_diff,
        AVG(t2.wins) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins,
        AVG(t1.wins - t2.wins) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_diff,
        AVG(t2.win_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct,
        AVG(t1.win_pct - t2.win_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_win_pct_diff,
        AVG(t2.losses) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses,
        AVG(t1.losses - t2.losses) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_diff,
        AVG(t2.loss_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct,
        AVG(t1.loss_pct - t2.loss_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_loss_pct_diff,
        AVG(t2.win_streak) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_streak,
        AVG(t1.win_streak - t2.win_streak) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_win_streak_diff,
        AVG(t2.loss_streak) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_streak,
        AVG(t1.loss_streak - t2.loss_streak) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_loss_streak_diff,
        AVG(t2.longest_win_streak) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_longest_win_streak,
        AVG(t1.longest_win_streak - t2.longest_win_streak) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_longest_win_streak_diff,
        AVG(t2.longest_loss_streak) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_longest_loss_streak,
        AVG(t1.longest_loss_streak - t2.longest_loss_streak) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_longest_loss_streak_diff
    FROM cte6 t1
        LEFT JOIN cte6 t2 ON t1.fighter_id = t2.opponent_id
        AND t1.opponent_id = t2.fighter_id
        AND t1.event_id = t2.event_id
        AND t1.temp_rn = t2.temp_rn
),
cte8 AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t1.'order',
        t4.ufcstats_id AS event_id,
        t3.ufcstats_id AS opponent_id,
        t1.days_since_last_fight,
        t1.avg_days_since_last_fight,
        t1.days_since_pro_debut,
        t1.avg_days_since_pro_debut,
        t1.days_since_ufc_debut,
        t1.avg_days_since_ufc_debut,
        t1.total_fights,
        t1.wins,
        t1.win_pct,
        t1.losses,
        t1.loss_pct,
        t1.win_streak,
        t1.loss_streak,
        t1.longest_win_streak,
        t1.longest_loss_streak,
        t1.avg_opp_days_since_last_fight,
        t1.avg_days_since_last_fight_diff,
        t1.avg_opp_avg_days_since_last_fight,
        t1.avg_avg_days_since_last_fight_diff,
        t1.avg_opp_days_since_pro_debut,
        t1.avg_days_since_pro_debut_diff,
        t1.avg_opp_avg_days_since_pro_debut,
        t1.avg_avg_days_since_pro_debut_diff,
        t1.avg_opp_days_since_ufc_debut,
        t1.avg_days_since_ufc_debut_diff,
        t1.avg_opp_avg_days_since_ufc_debut,
        t1.avg_avg_days_since_ufc_debut_diff,
        t1.avg_opp_total_fights,
        t1.avg_total_fights_diff,
        t1.avg_opp_wins,
        t1.avg_wins_diff,
        t1.avg_opp_win_pct,
        t1.avg_win_pct_diff,
        t1.avg_opp_losses,
        t1.avg_losses_diff,
        t1.avg_opp_loss_pct,
        t1.avg_loss_pct_diff,
        t1.avg_opp_win_streak,
        t1.avg_win_streak_diff,
        t1.avg_opp_loss_streak,
        t1.avg_loss_streak_diff,
        t1.avg_opp_longest_win_streak,
        t1.avg_longest_win_streak_diff,
        t1.avg_opp_longest_loss_streak,
        t1.avg_longest_loss_streak_diff
    FROM cte7 t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.fightmatrix_id
        INNER JOIN fighter_mapping AS t3 ON t1.opponent_id = t3.fightmatrix_id
        INNER JOIN event_mapping AS t4 ON t1.event_id = t4.fightmatrix_id
),
fightmatrix_feats AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        opponent_id,
        t1.days_since_last_fight,
        t1.avg_days_since_last_fight,
        t1.days_since_pro_debut,
        t1.avg_days_since_pro_debut,
        t1.days_since_ufc_debut,
        t1.avg_days_since_ufc_debut,
        t1.total_fights,
        t1.wins,
        t1.win_pct,
        t1.losses,
        t1.loss_pct,
        t1.win_streak,
        t1.loss_streak,
        t1.longest_win_streak,
        t1.longest_loss_streak,
        t1.avg_opp_days_since_last_fight,
        t1.avg_days_since_last_fight_diff,
        t1.avg_opp_avg_days_since_last_fight,
        t1.avg_avg_days_since_last_fight_diff,
        t1.avg_opp_days_since_pro_debut,
        t1.avg_days_since_pro_debut_diff,
        t1.avg_opp_avg_days_since_pro_debut,
        t1.avg_avg_days_since_pro_debut_diff,
        t1.avg_opp_days_since_ufc_debut,
        t1.avg_days_since_ufc_debut_diff,
        t1.avg_opp_avg_days_since_ufc_debut,
        t1.avg_avg_days_since_ufc_debut_diff,
        t1.avg_opp_total_fights,
        t1.avg_total_fights_diff,
        t1.avg_opp_wins,
        t1.avg_wins_diff,
        t1.avg_opp_win_pct,
        t1.avg_win_pct_diff,
        t1.avg_opp_losses,
        t1.avg_losses_diff,
        t1.avg_opp_loss_pct,
        t1.avg_loss_pct_diff,
        t1.avg_opp_win_streak,
        t1.avg_win_streak_diff,
        t1.avg_opp_loss_streak,
        t1.avg_loss_streak_diff,
        t1.avg_opp_longest_win_streak,
        t1.avg_longest_win_streak_diff,
        t1.avg_opp_longest_loss_streak,
        t1.avg_longest_loss_streak_diff
    FROM cte8 t1
),
cte9 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        date,
        opponent_id,
        CASE
            WHEN outcome = 'W' THEN 1
            ELSE 0
        END AS win_flag,
        CASE
            WHEN outcome = 'L' THEN 1
            ELSE 0
        END AS loss_flag,
        CASE
            WHEN outcome = 'W'
            AND outcome_method_broad = 'KO/TKO' THEN 1
            ELSE 0
        END AS win_by_ko_tko_flag,
        CASE
            WHEN outcome = 'W'
            AND outcome_method_broad = 'Submission' THEN 1
            ELSE 0
        END AS win_by_submission_flag,
        CASE
            WHEN outcome = 'W'
            AND outcome_method_broad = 'Decision' THEN 1
            ELSE 0
        END AS win_by_decision_flag,
        CASE
            WHEN outcome = 'L'
            AND outcome_method_broad = 'KO/TKO' THEN 1
            ELSE 0
        END AS loss_by_ko_tko_flag,
        CASE
            WHEN outcome = 'L'
            AND outcome_method_broad = 'Submission' THEN 1
            ELSE 0
        END AS loss_by_submission_flag,
        CASE
            WHEN outcome = 'L'
            AND outcome_method_broad = 'Decision' THEN 1
            ELSE 0
        END AS loss_by_decision_flag,
        end_round,
        CASE
            WHEN outcome = 'W' THEN end_round
            ELSE NULL
        END AS win_round,
        CASE
            WHEN outcome = 'L' THEN end_round
            ELSE NULL
        END AS loss_round,
        total_time_seconds,
        CASE
            WHEN outcome = 'W' THEN total_time_seconds
            ELSE NULL
        END AS win_time_seconds,
        CASE
            WHEN outcome = 'L' THEN total_time_seconds
            ELSE NULL
        END AS loss_time_seconds
    FROM sherdog_fighter_histories t1
),
cte10 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        date,
        opponent_id,
        SUM(win_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS wins,
        SUM(loss_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS losses,
        t1.'order' AS total_fights,
        SUM(win_by_ko_tko_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS wins_by_ko_tko,
        SUM(win_by_submission_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS wins_by_submission,
        SUM(win_by_decision_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS wins_by_decision,
        SUM(loss_by_ko_tko_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS losses_by_ko_tko,
        SUM(loss_by_submission_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS losses_by_submission,
        SUM(loss_by_decision_flag) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS losses_by_decision,
        SUM(end_round) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_rounds_fought,
        SUM(win_round) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_rounds_won,
        SUM(loss_round) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_rounds_lost,
        SUM(total_time_seconds) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_time_fought_seconds,
        SUM(win_time_seconds) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_time_won_seconds,
        SUM(loss_time_seconds) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_time_lost_seconds
    FROM cte9 t1
),
cte11 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        date,
        opponent_id,
        LAG(wins_by_ko_tko) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins_by_ko_tko,
        LAG(1.0 * wins_by_ko_tko / wins) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins_by_ko_tko_pct,
        LAG(1.0 * wins_by_ko_tko / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins_by_ko_tko_pct_overall,
        LAG(
            60.0 * wins_by_ko_tko / total_time_fought_seconds
        ) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ko_tko_landed_per_minute,
        LAG(wins_by_submission) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins_by_submission,
        LAG(1.0 * wins_by_submission / wins) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins_by_submission_pct,
        LAG(1.0 * wins_by_submission / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins_by_submission_pct_overall,
        LAG(
            60.0 * wins_by_submission / total_time_fought_seconds
        ) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS submissions_landed_per_minute,
        LAG(wins_by_decision) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins_by_decision,
        LAG(1.0 * wins_by_decision / wins) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins_by_decision_pct,
        LAG(1.0 * wins_by_decision / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS wins_by_decision_pct_overall,
        LAG(losses_by_ko_tko) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses_by_ko_tko,
        LAG(1.0 * losses_by_ko_tko / losses) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses_by_ko_tko_pct,
        LAG(1.0 * losses_by_ko_tko / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses_by_ko_tko_pct_overall,
        LAG(
            60.0 * losses_by_ko_tko / total_time_fought_seconds
        ) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ko_tko_absorbed_per_minute,
        LAG(losses_by_submission) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses_by_submission,
        LAG(1.0 * losses_by_submission / losses) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses_by_submission_pct,
        LAG(1.0 * losses_by_submission / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses_by_submission_pct_overall,
        LAG(
            60.0 * losses_by_submission / total_time_fought_seconds
        ) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS submissions_absorbed_per_minute,
        LAG(losses_by_decision) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses_by_decision,
        LAG(1.0 * losses_by_decision / losses) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses_by_decision_pct,
        LAG(1.0 * losses_by_decision / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS losses_by_decision_pct_overall,
        LAG(1.0 * total_rounds_fought / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS avg_end_round,
        LAG(1.0 * total_rounds_won / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS avg_end_round_win,
        LAG(1.0 * total_rounds_lost / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS avg_end_round_loss,
        LAG(total_time_fought_seconds) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS total_time_fought_seconds,
        LAG(1.0 * total_time_fought_seconds / total_fights) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS avg_time_fought_seconds,
        LAG(1.0 * total_time_won_seconds / wins) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS avg_time_to_win_seconds,
        LAG(1.0 * total_time_lost_seconds / losses) OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS avg_time_to_lose_seconds
    FROM cte10 t1
),
cte12 AS (
    SELECT fighter_id,
        t1.'order',
        event_id,
        date,
        opponent_id,
        CASE
            WHEN wins_by_ko_tko IS NULL THEN 0
            ELSE wins_by_ko_tko
        END AS wins_by_ko_tko,
        wins_by_ko_tko_pct,
        wins_by_ko_tko_pct_overall,
        ko_tko_landed_per_minute,
        CASE
            WHEN wins_by_submission IS NULL THEN 0
            ELSE wins_by_submission
        END AS wins_by_submission,
        wins_by_submission_pct,
        wins_by_submission_pct_overall,
        submissions_landed_per_minute,
        CASE
            WHEN wins_by_decision IS NULL THEN 0
            ELSE wins_by_decision
        END AS wins_by_decision,
        wins_by_decision_pct,
        wins_by_decision_pct_overall,
        CASE
            WHEN losses_by_ko_tko IS NULL THEN 0
            ELSE losses_by_ko_tko
        END AS losses_by_ko_tko,
        losses_by_ko_tko_pct,
        losses_by_ko_tko_pct_overall,
        ko_tko_absorbed_per_minute,
        CASE
            WHEN losses_by_submission IS NULL THEN 0
            ELSE losses_by_submission
        END AS losses_by_submission,
        losses_by_submission_pct,
        losses_by_submission_pct_overall,
        submissions_absorbed_per_minute,
        CASE
            WHEN losses_by_decision IS NULL THEN 0
            ELSE losses_by_decision
        END AS losses_by_decision,
        losses_by_decision_pct,
        losses_by_decision_pct_overall,
        avg_end_round,
        avg_end_round_win,
        avg_end_round_loss,
        CASE
            WHEN total_time_fought_seconds IS NULL THEN 0
            ELSE total_time_fought_seconds
        END AS total_time_fought_seconds,
        avg_time_fought_seconds,
        avg_time_to_win_seconds,
        avg_time_to_lose_seconds,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id,
            date,
            opponent_id
            ORDER BY t1.'order'
        ) AS temp_rn
    FROM cte11 t1
),
cte13 AS (
    SELECT t1.fighter_id,
        t1.'order',
        t1.event_id,
        t1.date,
        t1.opponent_id,
        t1.wins_by_ko_tko,
        t1.wins_by_ko_tko_pct,
        t1.wins_by_ko_tko_pct_overall,
        t1.ko_tko_landed_per_minute,
        t1.wins_by_submission,
        t1.wins_by_submission_pct,
        t1.wins_by_submission_pct_overall,
        t1.submissions_landed_per_minute,
        t1.wins_by_decision,
        t1.wins_by_decision_pct,
        t1.wins_by_decision_pct_overall,
        t1.losses_by_ko_tko,
        t1.losses_by_ko_tko_pct,
        t1.losses_by_ko_tko_pct_overall,
        t1.ko_tko_absorbed_per_minute,
        t1.losses_by_submission,
        t1.losses_by_submission_pct,
        t1.losses_by_submission_pct_overall,
        t1.submissions_absorbed_per_minute,
        t1.losses_by_decision,
        t1.losses_by_decision_pct,
        t1.losses_by_decision_pct_overall,
        t1.avg_end_round,
        t1.avg_end_round_win,
        t1.avg_end_round_loss,
        t1.total_time_fought_seconds,
        t1.avg_time_fought_seconds,
        t1.avg_time_to_win_seconds,
        t1.avg_time_to_lose_seconds,
        AVG(t2.wins_by_ko_tko) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_ko_tko,
        AVG(t1.wins_by_ko_tko - t2.wins_by_ko_tko) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_by_ko_tko_diff,
        AVG(t2.wins_by_ko_tko_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_ko_tko_pct,
        AVG(t1.wins_by_ko_tko_pct - t2.wins_by_ko_tko_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_by_ko_tko_pct_diff,
        AVG(t2.wins_by_ko_tko_pct_overall) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_ko_tko_pct_overall,
        AVG(
            t1.wins_by_ko_tko_pct_overall - t2.wins_by_ko_tko_pct_overall
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_by_ko_tko_pct_overall_diff,
        AVG(t2.ko_tko_landed_per_minute) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_landed_per_minute,
        AVG(
            t1.ko_tko_landed_per_minute - t2.ko_tko_landed_per_minute
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_landed_per_minute_diff,
        AVG(t2.wins_by_submission) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_submission,
        AVG(t1.wins_by_submission - t2.wins_by_submission) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_by_submission_diff,
        AVG(t2.wins_by_submission_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_submission_pct,
        AVG(
            t1.wins_by_submission_pct - t2.wins_by_submission_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_by_submission_pct_diff,
        AVG(t2.wins_by_submission_pct_overall) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_submission_pct_overall,
        AVG(
            t1.wins_by_submission_pct_overall - t2.wins_by_submission_pct_overall
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_by_submission_pct_overall_diff,
        AVG(t2.submissions_landed_per_minute) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_submissions_landed_per_minute,
        AVG(
            t1.submissions_landed_per_minute - t2.submissions_landed_per_minute
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_submissions_landed_per_minute_diff,
        AVG(t2.wins_by_decision) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_decision,
        AVG(t1.wins_by_decision - t2.wins_by_decision) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_by_decision_diff,
        AVG(t2.wins_by_decision_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_decision_pct,
        AVG(
            t1.wins_by_decision_pct - t2.wins_by_decision_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_by_decision_pct_diff,
        AVG(t2.wins_by_decision_pct_overall) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_by_decision_pct_overall,
        AVG(
            t1.wins_by_decision_pct_overall - t2.wins_by_decision_pct_overall
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_wins_by_decision_pct_overall_diff,
        AVG(t2.losses_by_ko_tko) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_ko_tko,
        AVG(t1.losses_by_ko_tko - t2.losses_by_ko_tko) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_by_ko_tko_diff,
        AVG(t2.losses_by_ko_tko_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_ko_tko_pct,
        AVG(
            t1.losses_by_ko_tko_pct - t2.losses_by_ko_tko_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_by_ko_tko_pct_diff,
        AVG(t2.losses_by_ko_tko_pct_overall) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_ko_tko_pct_overall,
        AVG(
            t1.losses_by_ko_tko_pct_overall - t2.losses_by_ko_tko_pct_overall
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_by_ko_tko_pct_overall_diff,
        AVG(t2.ko_tko_absorbed_per_minute) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_ko_tko_absorbed_per_minute,
        AVG(
            t1.ko_tko_absorbed_per_minute - t2.ko_tko_absorbed_per_minute
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_ko_tko_absorbed_per_minute_diff,
        AVG(t2.losses_by_submission) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_submission,
        AVG(
            t1.losses_by_submission - t2.losses_by_submission
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_by_submission_diff,
        AVG(t2.losses_by_submission_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_submission_pct,
        AVG(
            t1.losses_by_submission_pct - t2.losses_by_submission_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_by_submission_pct_diff,
        AVG(t2.losses_by_submission_pct_overall) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_submission_pct_overall,
        AVG(
            t1.losses_by_submission_pct_overall - t2.losses_by_submission_pct_overall
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_by_submission_pct_overall_diff,
        AVG(t2.submissions_absorbed_per_minute) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_submissions_absorbed_per_minute,
        AVG(
            t1.submissions_absorbed_per_minute - t2.submissions_absorbed_per_minute
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_submissions_absorbed_per_minute_diff,
        AVG(t2.losses_by_decision) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_decision,
        AVG(t1.losses_by_decision - t2.losses_by_decision) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_by_decision_diff,
        AVG(t2.losses_by_decision_pct) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_decision_pct,
        AVG(
            t1.losses_by_decision_pct - t2.losses_by_decision_pct
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_by_decision_pct_diff,
        AVG(t2.losses_by_decision_pct_overall) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_by_decision_pct_overall,
        AVG(
            t1.losses_by_decision_pct_overall - t2.losses_by_decision_pct_overall
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_losses_by_decision_pct_overall_diff,
        AVG(t2.avg_end_round) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_end_round,
        AVG(t1.avg_end_round - t2.avg_end_round) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_end_round_diff,
        AVG(t2.avg_end_round_win) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_end_round_win,
        AVG(t1.avg_end_round_win - t2.avg_end_round_win) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_end_round_win_diff,
        AVG(t2.avg_end_round_loss) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_end_round_loss,
        AVG(t1.avg_end_round_loss - t2.avg_end_round_loss) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_end_round_loss_diff,
        AVG(t2.total_time_fought_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_total_time_fought_seconds,
        AVG(
            t1.total_time_fought_seconds - t2.total_time_fought_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_total_time_fought_seconds_diff,
        AVG(t2.avg_time_fought_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_time_fought_seconds,
        AVG(
            t1.avg_time_fought_seconds - t2.avg_time_fought_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_time_fought_seconds_diff,
        AVG(t2.avg_time_to_win_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_time_to_win_seconds,
        AVG(
            t1.avg_time_to_win_seconds - t2.avg_time_to_win_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_time_to_win_seconds_diff,
        AVG(t2.avg_time_to_lose_seconds) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_avg_time_to_lose_seconds,
        AVG(
            t1.avg_time_to_lose_seconds - t2.avg_time_to_lose_seconds
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.'order' ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_avg_time_to_lose_seconds_diff
    FROM cte12 t1
        LEFT JOIN cte12 t2 ON t1.fighter_id = t2.opponent_id
        AND t1.opponent_id = t2.fighter_id
        AND t1.date = t2.date
        AND t1.temp_rn = t2.temp_rn
),
cte14 AS (
    SELECT t2.ufcstats_id AS fighter_id,
        t1.'order',
        t4.ufcstats_id AS event_id,
        t3.ufcstats_id AS opponent_id,
        t1.wins_by_ko_tko,
        t1.wins_by_ko_tko_pct,
        t1.wins_by_ko_tko_pct_overall,
        t1.ko_tko_landed_per_minute,
        t1.wins_by_submission,
        t1.wins_by_submission_pct,
        t1.wins_by_submission_pct_overall,
        t1.submissions_landed_per_minute,
        t1.wins_by_decision,
        t1.wins_by_decision_pct,
        t1.wins_by_decision_pct_overall,
        t1.losses_by_ko_tko,
        t1.losses_by_ko_tko_pct,
        t1.losses_by_ko_tko_pct_overall,
        t1.ko_tko_absorbed_per_minute,
        t1.losses_by_submission,
        t1.losses_by_submission_pct,
        t1.losses_by_submission_pct_overall,
        t1.submissions_absorbed_per_minute,
        t1.losses_by_decision,
        t1.losses_by_decision_pct,
        t1.losses_by_decision_pct_overall,
        t1.avg_end_round,
        t1.avg_end_round_win,
        t1.avg_end_round_loss,
        t1.total_time_fought_seconds,
        t1.avg_time_fought_seconds,
        t1.avg_time_to_win_seconds,
        t1.avg_time_to_lose_seconds,
        t1.avg_opp_wins_by_ko_tko,
        t1.avg_wins_by_ko_tko_diff,
        t1.avg_opp_wins_by_ko_tko_pct,
        t1.avg_wins_by_ko_tko_pct_diff,
        t1.avg_opp_wins_by_ko_tko_pct_overall,
        t1.avg_wins_by_ko_tko_pct_overall_diff,
        t1.avg_opp_ko_tko_landed_per_minute,
        t1.avg_ko_tko_landed_per_minute_diff,
        t1.avg_opp_wins_by_submission,
        t1.avg_wins_by_submission_diff,
        t1.avg_opp_wins_by_submission_pct,
        t1.avg_wins_by_submission_pct_diff,
        t1.avg_opp_wins_by_submission_pct_overall,
        t1.avg_wins_by_submission_pct_overall_diff,
        t1.avg_opp_submissions_landed_per_minute,
        t1.avg_submissions_landed_per_minute_diff,
        t1.avg_opp_wins_by_decision,
        t1.avg_wins_by_decision_diff,
        t1.avg_opp_wins_by_decision_pct,
        t1.avg_wins_by_decision_pct_diff,
        t1.avg_opp_wins_by_decision_pct_overall,
        t1.avg_wins_by_decision_pct_overall_diff,
        t1.avg_opp_losses_by_ko_tko,
        t1.avg_losses_by_ko_tko_diff,
        t1.avg_opp_losses_by_ko_tko_pct,
        t1.avg_losses_by_ko_tko_pct_diff,
        t1.avg_opp_losses_by_ko_tko_pct_overall,
        t1.avg_losses_by_ko_tko_pct_overall_diff,
        t1.avg_opp_ko_tko_absorbed_per_minute,
        t1.avg_ko_tko_absorbed_per_minute_diff,
        t1.avg_opp_losses_by_submission,
        t1.avg_losses_by_submission_diff,
        t1.avg_opp_losses_by_submission_pct,
        t1.avg_losses_by_submission_pct_diff,
        t1.avg_opp_losses_by_submission_pct_overall,
        t1.avg_losses_by_submission_pct_overall_diff,
        t1.avg_opp_submissions_absorbed_per_minute,
        t1.avg_submissions_absorbed_per_minute_diff,
        t1.avg_opp_losses_by_decision,
        t1.avg_losses_by_decision_diff,
        t1.avg_opp_losses_by_decision_pct,
        t1.avg_losses_by_decision_pct_diff,
        t1.avg_opp_losses_by_decision_pct_overall,
        t1.avg_losses_by_decision_pct_overall_diff,
        t1.avg_opp_avg_end_round,
        t1.avg_avg_end_round_diff,
        t1.avg_opp_avg_end_round_win,
        t1.avg_avg_end_round_win_diff,
        t1.avg_opp_avg_end_round_loss,
        t1.avg_avg_end_round_loss_diff,
        t1.avg_opp_total_time_fought_seconds,
        t1.avg_total_time_fought_seconds_diff,
        t1.avg_opp_avg_time_fought_seconds,
        t1.avg_avg_time_fought_seconds_diff,
        t1.avg_opp_avg_time_to_win_seconds,
        t1.avg_avg_time_to_win_seconds_diff,
        t1.avg_opp_avg_time_to_lose_seconds,
        t1.avg_avg_time_to_lose_seconds_diff
    FROM cte13 t1
        INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.sherdog_id
        INNER JOIN fighter_mapping AS t3 ON t1.opponent_id = t3.sherdog_id
        INNER JOIN event_mapping AS t4 ON t1.event_id = t4.sherdog_id
),
sherdog_feats AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        opponent_id,
        wins_by_ko_tko,
        wins_by_ko_tko_pct,
        wins_by_ko_tko_pct_overall,
        ko_tko_landed_per_minute,
        wins_by_submission,
        wins_by_submission_pct,
        wins_by_submission_pct_overall,
        submissions_landed_per_minute,
        wins_by_decision,
        wins_by_decision_pct,
        wins_by_decision_pct_overall,
        losses_by_ko_tko,
        losses_by_ko_tko_pct,
        losses_by_ko_tko_pct_overall,
        ko_tko_absorbed_per_minute,
        losses_by_submission,
        losses_by_submission_pct,
        losses_by_submission_pct_overall,
        submissions_absorbed_per_minute,
        losses_by_decision,
        losses_by_decision_pct,
        losses_by_decision_pct_overall,
        avg_end_round,
        avg_end_round_win,
        avg_end_round_loss,
        total_time_fought_seconds,
        avg_time_fought_seconds,
        avg_time_to_win_seconds,
        avg_time_to_lose_seconds,
        avg_opp_wins_by_ko_tko,
        avg_wins_by_ko_tko_diff,
        avg_opp_wins_by_ko_tko_pct,
        avg_wins_by_ko_tko_pct_diff,
        avg_opp_wins_by_ko_tko_pct_overall,
        avg_wins_by_ko_tko_pct_overall_diff,
        avg_opp_ko_tko_landed_per_minute,
        avg_ko_tko_landed_per_minute_diff,
        avg_opp_wins_by_submission,
        avg_wins_by_submission_diff,
        avg_opp_wins_by_submission_pct,
        avg_wins_by_submission_pct_diff,
        avg_opp_wins_by_submission_pct_overall,
        avg_wins_by_submission_pct_overall_diff,
        avg_opp_submissions_landed_per_minute,
        avg_submissions_landed_per_minute_diff,
        avg_opp_wins_by_decision,
        avg_wins_by_decision_diff,
        avg_opp_wins_by_decision_pct,
        avg_wins_by_decision_pct_diff,
        avg_opp_wins_by_decision_pct_overall,
        avg_wins_by_decision_pct_overall_diff,
        avg_opp_losses_by_ko_tko,
        avg_losses_by_ko_tko_diff,
        avg_opp_losses_by_ko_tko_pct,
        avg_losses_by_ko_tko_pct_diff,
        avg_opp_losses_by_ko_tko_pct_overall,
        avg_losses_by_ko_tko_pct_overall_diff,
        avg_opp_ko_tko_absorbed_per_minute,
        avg_ko_tko_absorbed_per_minute_diff,
        avg_opp_losses_by_submission,
        avg_losses_by_submission_diff,
        avg_opp_losses_by_submission_pct,
        avg_losses_by_submission_pct_diff,
        avg_opp_losses_by_submission_pct_overall,
        avg_losses_by_submission_pct_overall_diff,
        avg_opp_submissions_absorbed_per_minute,
        avg_submissions_absorbed_per_minute_diff,
        avg_opp_losses_by_decision,
        avg_losses_by_decision_diff,
        avg_opp_losses_by_decision_pct,
        avg_losses_by_decision_pct_diff,
        avg_opp_losses_by_decision_pct_overall,
        avg_losses_by_decision_pct_overall_diff,
        avg_opp_avg_end_round,
        avg_avg_end_round_diff,
        avg_opp_avg_end_round_win,
        avg_avg_end_round_win_diff,
        avg_opp_avg_end_round_loss,
        avg_avg_end_round_loss_diff,
        avg_opp_total_time_fought_seconds,
        avg_total_time_fought_seconds_diff,
        avg_opp_avg_time_fought_seconds,
        avg_avg_time_fought_seconds_diff,
        avg_opp_avg_time_to_win_seconds,
        avg_avg_time_to_win_seconds_diff,
        avg_opp_avg_time_to_lose_seconds,
        avg_avg_time_to_lose_seconds_diff
    FROM cte14 t1
),
cte15 AS (
    SELECT t1.*
    FROM ufcstats_fighter_histories AS t1
        LEFT JOIN ufcstats_bouts AS t2 ON t1.bout_id = t2.id
        LEFT JOIN ufcstats_events AS t3 ON t2.event_id = t3.id
    WHERE t3.is_ufc_event = 1
),
cte16 AS (
    SELECT fighter_id,
        ROW_NUMBER() OVER (
            PARTITION BY fighter_id
            ORDER BY t1.'order'
        ) AS ufc_order,
        bout_id,
        opponent_id
    FROM cte15 t1
),
cte17 AS (
    SELECT t1.fighter_id,
        t1.bout_id,
        t2.days_since_last_fight,
        t2.avg_days_since_last_fight,
        t2.days_since_pro_debut,
        t2.avg_days_since_pro_debut,
        t2.days_since_ufc_debut,
        t2.avg_days_since_ufc_debut,
        t2.total_fights,
        t2.wins,
        t2.win_pct,
        t2.losses,
        t2.loss_pct,
        t2.win_streak,
        t2.loss_streak,
        t2.longest_win_streak,
        t2.longest_loss_streak,
        t2.avg_opp_days_since_last_fight,
        t2.avg_days_since_last_fight_diff,
        t2.avg_opp_avg_days_since_last_fight,
        t2.avg_avg_days_since_last_fight_diff,
        t2.avg_opp_days_since_pro_debut,
        t2.avg_days_since_pro_debut_diff,
        t2.avg_opp_avg_days_since_pro_debut,
        t2.avg_avg_days_since_pro_debut_diff,
        t2.avg_opp_days_since_ufc_debut,
        t2.avg_days_since_ufc_debut_diff,
        t2.avg_opp_avg_days_since_ufc_debut,
        t2.avg_avg_days_since_ufc_debut_diff,
        t2.avg_opp_total_fights,
        t2.avg_total_fights_diff,
        t2.avg_opp_wins,
        t2.avg_wins_diff,
        t2.avg_opp_win_pct,
        t2.avg_win_pct_diff,
        t2.avg_opp_losses,
        t2.avg_losses_diff,
        t2.avg_opp_loss_pct,
        t2.avg_loss_pct_diff,
        t2.avg_opp_win_streak,
        t2.avg_win_streak_diff,
        t2.avg_opp_loss_streak,
        t2.avg_loss_streak_diff,
        t2.avg_opp_longest_win_streak,
        t2.avg_longest_win_streak_diff,
        t2.avg_opp_longest_loss_streak,
        t2.avg_longest_loss_streak_diff,
        t3.wins_by_ko_tko,
        t3.wins_by_ko_tko_pct,
        t3.wins_by_ko_tko_pct_overall,
        t3.ko_tko_landed_per_minute,
        t3.wins_by_submission,
        t3.wins_by_submission_pct,
        t3.wins_by_submission_pct_overall,
        t3.submissions_landed_per_minute,
        t3.wins_by_decision,
        t3.wins_by_decision_pct,
        t3.wins_by_decision_pct_overall,
        t3.losses_by_ko_tko,
        t3.losses_by_ko_tko_pct,
        t3.losses_by_ko_tko_pct_overall,
        t3.ko_tko_absorbed_per_minute,
        t3.losses_by_submission,
        t3.losses_by_submission_pct,
        t3.losses_by_submission_pct_overall,
        t3.submissions_absorbed_per_minute,
        t3.losses_by_decision,
        t3.losses_by_decision_pct,
        t3.losses_by_decision_pct_overall,
        t3.avg_end_round,
        t3.avg_end_round_win,
        t3.avg_end_round_loss,
        t3.total_time_fought_seconds,
        t3.avg_time_fought_seconds,
        t3.avg_time_to_win_seconds,
        t3.avg_time_to_lose_seconds,
        t3.avg_opp_wins_by_ko_tko,
        t3.avg_wins_by_ko_tko_diff,
        t3.avg_opp_wins_by_ko_tko_pct,
        t3.avg_wins_by_ko_tko_pct_diff,
        t3.avg_opp_wins_by_ko_tko_pct_overall,
        t3.avg_wins_by_ko_tko_pct_overall_diff,
        t3.avg_opp_ko_tko_landed_per_minute,
        t3.avg_ko_tko_landed_per_minute_diff,
        t3.avg_opp_wins_by_submission,
        t3.avg_wins_by_submission_diff,
        t3.avg_opp_wins_by_submission_pct,
        t3.avg_wins_by_submission_pct_diff,
        t3.avg_opp_wins_by_submission_pct_overall,
        t3.avg_wins_by_submission_pct_overall_diff,
        t3.avg_opp_submissions_landed_per_minute,
        t3.avg_submissions_landed_per_minute_diff,
        t3.avg_opp_wins_by_decision,
        t3.avg_wins_by_decision_diff,
        t3.avg_opp_wins_by_decision_pct,
        t3.avg_wins_by_decision_pct_diff,
        t3.avg_opp_wins_by_decision_pct_overall,
        t3.avg_wins_by_decision_pct_overall_diff,
        t3.avg_opp_losses_by_ko_tko,
        t3.avg_losses_by_ko_tko_diff,
        t3.avg_opp_losses_by_ko_tko_pct,
        t3.avg_losses_by_ko_tko_pct_diff,
        t3.avg_opp_losses_by_ko_tko_pct_overall,
        t3.avg_losses_by_ko_tko_pct_overall_diff,
        t3.avg_opp_ko_tko_absorbed_per_minute,
        t3.avg_ko_tko_absorbed_per_minute_diff,
        t3.avg_opp_losses_by_submission,
        t3.avg_losses_by_submission_diff,
        t3.avg_opp_losses_by_submission_pct,
        t3.avg_losses_by_submission_pct_diff,
        t3.avg_opp_losses_by_submission_pct_overall,
        t3.avg_losses_by_submission_pct_overall_diff,
        t3.avg_opp_submissions_absorbed_per_minute,
        t3.avg_submissions_absorbed_per_minute_diff,
        t3.avg_opp_losses_by_decision,
        t3.avg_losses_by_decision_diff,
        t3.avg_opp_losses_by_decision_pct,
        t3.avg_losses_by_decision_pct_diff,
        t3.avg_opp_losses_by_decision_pct_overall,
        t3.avg_losses_by_decision_pct_overall_diff,
        t3.avg_opp_avg_end_round,
        t3.avg_avg_end_round_diff,
        t3.avg_opp_avg_end_round_win,
        t3.avg_avg_end_round_win_diff,
        t3.avg_opp_avg_end_round_loss,
        t3.avg_avg_end_round_loss_diff,
        t3.avg_opp_total_time_fought_seconds,
        t3.avg_total_time_fought_seconds_diff,
        t3.avg_opp_avg_time_fought_seconds,
        t3.avg_avg_time_fought_seconds_diff,
        t3.avg_opp_avg_time_to_win_seconds,
        t3.avg_avg_time_to_win_seconds_diff,
        t3.avg_opp_avg_time_to_lose_seconds,
        t3.avg_avg_time_to_lose_seconds_diff
    FROM cte16 t1
        INNER JOIN fightmatrix_feats AS t2 ON t1.fighter_id = t2.fighter_id
        AND t1.opponent_id = t2.opponent_id
        AND t1.ufc_order = t2.ufc_order
        INNER JOIN sherdog_feats AS t3 ON t1.fighter_id = t3.fighter_id
        AND t1.opponent_id = t3.opponent_id
        AND t1.ufc_order = t3.ufc_order
)
SELECT id,
    t2.days_since_last_fight - t3.days_since_last_fight AS days_since_last_fight_diff,
    t2.avg_days_since_last_fight - t3.avg_days_since_last_fight AS avg_days_since_last_fight_diff,
    t2.days_since_pro_debut - t3.days_since_pro_debut AS days_since_pro_debut_diff,
    t2.avg_days_since_pro_debut - t3.avg_days_since_pro_debut AS avg_days_since_pro_debut_diff,
    t2.days_since_ufc_debut - t3.days_since_ufc_debut AS days_since_ufc_debut_diff,
    t2.avg_days_since_ufc_debut - t3.avg_days_since_ufc_debut AS avg_days_since_ufc_debut_diff,
    t2.total_fights - t3.total_fights AS total_fights_diff,
    t2.wins - t3.wins AS wins_diff,
    t2.win_pct - t3.win_pct AS win_pct_diff,
    t2.losses - t3.losses AS losses_diff,
    t2.loss_pct - t3.loss_pct AS loss_pct_diff,
    t2.win_streak - t3.win_streak AS win_streak_diff,
    t2.loss_streak - t3.loss_streak AS loss_streak_diff,
    t2.longest_win_streak - t3.longest_win_streak AS longest_win_streak_diff,
    t2.longest_loss_streak - t3.longest_loss_streak AS longest_loss_streak_diff,
    t2.avg_opp_days_since_last_fight - t3.avg_opp_days_since_last_fight AS avg_opp_days_since_last_fight_diff,
    t2.avg_days_since_last_fight_diff - t3.avg_days_since_last_fight_diff AS avg_days_since_last_fight_diff_diff,
    t2.avg_opp_avg_days_since_last_fight - t3.avg_opp_avg_days_since_last_fight AS avg_opp_avg_days_since_last_fight_diff,
    t2.avg_avg_days_since_last_fight_diff - t3.avg_avg_days_since_last_fight_diff AS avg_avg_days_since_last_fight_diff_diff,
    t2.avg_opp_days_since_pro_debut - t3.avg_opp_days_since_pro_debut AS avg_opp_days_since_pro_debut_diff,
    t2.avg_days_since_pro_debut_diff - t3.avg_days_since_pro_debut_diff AS avg_days_since_pro_debut_diff_diff,
    t2.avg_opp_avg_days_since_pro_debut - t3.avg_opp_avg_days_since_pro_debut AS avg_opp_avg_days_since_pro_debut_diff,
    t2.avg_avg_days_since_pro_debut_diff - t3.avg_avg_days_since_pro_debut_diff AS avg_avg_days_since_pro_debut_diff_diff,
    t2.avg_opp_days_since_ufc_debut - t3.avg_opp_days_since_ufc_debut AS avg_opp_days_since_ufc_debut_diff,
    t2.avg_days_since_ufc_debut_diff - t3.avg_days_since_ufc_debut_diff AS avg_days_since_ufc_debut_diff_diff,
    t2.avg_opp_avg_days_since_ufc_debut - t3.avg_opp_avg_days_since_ufc_debut AS avg_opp_avg_days_since_ufc_debut_diff,
    t2.avg_avg_days_since_ufc_debut_diff - t3.avg_avg_days_since_ufc_debut_diff AS avg_avg_days_since_ufc_debut_diff_diff,
    t2.avg_opp_total_fights - t3.avg_opp_total_fights AS avg_opp_total_fights_diff,
    t2.avg_total_fights_diff - t3.avg_total_fights_diff AS avg_total_fights_diff_diff,
    t2.avg_opp_wins - t3.avg_opp_wins AS avg_opp_wins_diff,
    t2.avg_wins_diff - t3.avg_wins_diff AS avg_wins_diff_diff,
    t2.avg_opp_win_pct - t3.avg_opp_win_pct AS avg_opp_win_pct_diff,
    t2.avg_win_pct_diff - t3.avg_win_pct_diff AS avg_win_pct_diff_diff,
    t2.avg_opp_losses - t3.avg_opp_losses AS avg_opp_losses_diff,
    t2.avg_losses_diff - t3.avg_losses_diff AS avg_losses_diff_diff,
    t2.avg_opp_loss_pct - t3.avg_opp_loss_pct AS avg_opp_loss_pct_diff,
    t2.avg_loss_pct_diff - t3.avg_loss_pct_diff AS avg_loss_pct_diff_diff,
    t2.avg_opp_win_streak - t3.avg_opp_win_streak AS avg_opp_win_streak_diff,
    t2.avg_win_streak_diff - t3.avg_win_streak_diff AS avg_win_streak_diff_diff,
    t2.avg_opp_loss_streak - t3.avg_opp_loss_streak AS avg_opp_loss_streak_diff,
    t2.avg_loss_streak_diff - t3.avg_loss_streak_diff AS avg_loss_streak_diff_diff,
    t2.avg_opp_longest_win_streak - t3.avg_opp_longest_win_streak AS avg_opp_longest_win_streak_diff,
    t2.avg_longest_win_streak_diff - t3.avg_longest_win_streak_diff AS avg_longest_win_streak_diff_diff,
    t2.avg_opp_longest_loss_streak - t3.avg_opp_longest_loss_streak AS avg_opp_longest_loss_streak_diff,
    t2.avg_longest_loss_streak_diff - t3.avg_longest_loss_streak_diff AS avg_longest_loss_streak_diff_diff,
    t2.wins_by_ko_tko - t3.wins_by_ko_tko AS wins_by_ko_tko_diff,
    t2.wins_by_ko_tko_pct - t3.wins_by_ko_tko_pct AS wins_by_ko_tko_pct_diff,
    t2.wins_by_ko_tko_pct_overall - t3.wins_by_ko_tko_pct_overall AS wins_by_ko_tko_pct_overall_diff,
    t2.ko_tko_landed_per_minute - t3.ko_tko_landed_per_minute AS ko_tko_landed_per_minute_diff,
    t2.wins_by_submission - t3.wins_by_submission AS wins_by_submission_diff,
    t2.wins_by_submission_pct - t3.wins_by_submission_pct AS wins_by_submission_pct_diff,
    t2.wins_by_submission_pct_overall - t3.wins_by_submission_pct_overall AS wins_by_submission_pct_overall_diff,
    t2.submissions_landed_per_minute - t3.submissions_landed_per_minute AS submissions_landed_per_minute_diff,
    t2.wins_by_decision - t3.wins_by_decision AS wins_by_decision_diff,
    t2.wins_by_decision_pct - t3.wins_by_decision_pct AS wins_by_decision_pct_diff,
    t2.wins_by_decision_pct_overall - t3.wins_by_decision_pct_overall AS wins_by_decision_pct_overall_diff,
    t2.losses_by_ko_tko - t3.losses_by_ko_tko AS losses_by_ko_tko_diff,
    t2.losses_by_ko_tko_pct - t3.losses_by_ko_tko_pct AS losses_by_ko_tko_pct_diff,
    t2.losses_by_ko_tko_pct_overall - t3.losses_by_ko_tko_pct_overall AS losses_by_ko_tko_pct_overall_diff,
    t2.ko_tko_absorbed_per_minute - t3.ko_tko_absorbed_per_minute AS ko_tko_absorbed_per_minute_diff,
    t2.losses_by_submission - t3.losses_by_submission AS losses_by_submission_diff,
    t2.losses_by_submission_pct - t3.losses_by_submission_pct AS losses_by_submission_pct_diff,
    t2.losses_by_submission_pct_overall - t3.losses_by_submission_pct_overall AS losses_by_submission_pct_overall_diff,
    t2.submissions_absorbed_per_minute - t3.submissions_absorbed_per_minute AS submissions_absorbed_per_minute_diff,
    t2.losses_by_decision - t3.losses_by_decision AS losses_by_decision_diff,
    t2.losses_by_decision_pct - t3.losses_by_decision_pct AS losses_by_decision_pct_diff,
    t2.losses_by_decision_pct_overall - t3.losses_by_decision_pct_overall AS losses_by_decision_pct_overall_diff,
    t2.avg_end_round - t3.avg_end_round AS avg_end_round_diff,
    t2.avg_end_round_win - t3.avg_end_round_win AS avg_end_round_win_diff,
    t2.avg_end_round_loss - t3.avg_end_round_loss AS avg_end_round_loss_diff,
    t2.total_time_fought_seconds - t3.total_time_fought_seconds AS total_time_fought_seconds_diff,
    t2.avg_time_fought_seconds - t3.avg_time_fought_seconds AS avg_time_fought_seconds_diff,
    t2.avg_time_to_win_seconds - t3.avg_time_to_win_seconds AS avg_time_to_win_seconds_diff,
    t2.avg_time_to_lose_seconds - t3.avg_time_to_lose_seconds AS avg_time_to_lose_seconds_diff,
    t2.avg_opp_wins_by_ko_tko - t3.avg_opp_wins_by_ko_tko AS avg_opp_wins_by_ko_tko_diff,
    t2.avg_wins_by_ko_tko_diff - t3.avg_wins_by_ko_tko_diff AS avg_wins_by_ko_tko_diff_diff,
    t2.avg_opp_wins_by_ko_tko_pct - t3.avg_opp_wins_by_ko_tko_pct AS avg_opp_wins_by_ko_tko_pct_diff,
    t2.avg_wins_by_ko_tko_pct_diff - t3.avg_wins_by_ko_tko_pct_diff AS avg_wins_by_ko_tko_pct_diff_diff,
    t2.avg_opp_wins_by_ko_tko_pct_overall - t3.avg_opp_wins_by_ko_tko_pct_overall AS avg_opp_wins_by_ko_tko_pct_overall_diff,
    t2.avg_wins_by_ko_tko_pct_overall_diff - t3.avg_wins_by_ko_tko_pct_overall_diff AS avg_wins_by_ko_tko_pct_overall_diff_diff,
    t2.avg_opp_ko_tko_landed_per_minute - t3.avg_opp_ko_tko_landed_per_minute AS avg_opp_ko_tko_landed_per_minute_diff,
    t2.avg_ko_tko_landed_per_minute_diff - t3.avg_ko_tko_landed_per_minute_diff AS avg_ko_tko_landed_per_minute_diff_diff,
    t2.avg_opp_wins_by_submission - t3.avg_opp_wins_by_submission AS avg_opp_wins_by_submission_diff,
    t2.avg_wins_by_submission_diff - t3.avg_wins_by_submission_diff AS avg_wins_by_submission_diff_diff,
    t2.avg_opp_wins_by_submission_pct - t3.avg_opp_wins_by_submission_pct AS avg_opp_wins_by_submission_pct_diff,
    t2.avg_wins_by_submission_pct_diff - t3.avg_wins_by_submission_pct_diff AS avg_wins_by_submission_pct_diff_diff,
    t2.avg_opp_wins_by_submission_pct_overall - t3.avg_opp_wins_by_submission_pct_overall AS avg_opp_wins_by_submission_pct_overall_diff,
    t2.avg_wins_by_submission_pct_overall_diff - t3.avg_wins_by_submission_pct_overall_diff AS avg_wins_by_submission_pct_overall_diff_diff,
    t2.avg_opp_submissions_landed_per_minute - t3.avg_opp_submissions_landed_per_minute AS avg_opp_submissions_landed_per_minute_diff,
    t2.avg_submissions_landed_per_minute_diff - t3.avg_submissions_landed_per_minute_diff AS avg_submissions_landed_per_minute_diff_diff,
    t2.avg_opp_wins_by_decision - t3.avg_opp_wins_by_decision AS avg_opp_wins_by_decision_diff,
    t2.avg_wins_by_decision_diff - t3.avg_wins_by_decision_diff AS avg_wins_by_decision_diff_diff,
    t2.avg_opp_wins_by_decision_pct - t3.avg_opp_wins_by_decision_pct AS avg_opp_wins_by_decision_pct_diff,
    t2.avg_wins_by_decision_pct_diff - t3.avg_wins_by_decision_pct_diff AS avg_wins_by_decision_pct_diff_diff,
    t2.avg_opp_wins_by_decision_pct_overall - t3.avg_opp_wins_by_decision_pct_overall AS avg_opp_wins_by_decision_pct_overall_diff,
    t2.avg_wins_by_decision_pct_overall_diff - t3.avg_wins_by_decision_pct_overall_diff AS avg_wins_by_decision_pct_overall_diff_diff,
    t2.avg_opp_losses_by_ko_tko - t3.avg_opp_losses_by_ko_tko AS avg_opp_losses_by_ko_tko_diff,
    t2.avg_losses_by_ko_tko_diff - t3.avg_losses_by_ko_tko_diff AS avg_losses_by_ko_tko_diff_diff,
    t2.avg_opp_losses_by_ko_tko_pct - t3.avg_opp_losses_by_ko_tko_pct AS avg_opp_losses_by_ko_tko_pct_diff,
    t2.avg_losses_by_ko_tko_pct_diff - t3.avg_losses_by_ko_tko_pct_diff AS avg_losses_by_ko_tko_pct_diff_diff,
    t2.avg_opp_losses_by_ko_tko_pct_overall - t3.avg_opp_losses_by_ko_tko_pct_overall AS avg_opp_losses_by_ko_tko_pct_overall_diff,
    t2.avg_losses_by_ko_tko_pct_overall_diff - t3.avg_losses_by_ko_tko_pct_overall_diff AS avg_losses_by_ko_tko_pct_overall_diff_diff,
    t2.avg_opp_ko_tko_absorbed_per_minute - t3.avg_opp_ko_tko_absorbed_per_minute AS avg_opp_ko_tko_absorbed_per_minute_diff,
    t2.avg_ko_tko_absorbed_per_minute_diff - t3.avg_ko_tko_absorbed_per_minute_diff AS avg_ko_tko_absorbed_per_minute_diff_diff,
    t2.avg_opp_losses_by_submission - t3.avg_opp_losses_by_submission AS avg_opp_losses_by_submission_diff,
    t2.avg_losses_by_submission_diff - t3.avg_losses_by_submission_diff AS avg_losses_by_submission_diff_diff,
    t2.avg_opp_losses_by_submission_pct - t3.avg_opp_losses_by_submission_pct AS avg_opp_losses_by_submission_pct_diff,
    t2.avg_losses_by_submission_pct_diff - t3.avg_losses_by_submission_pct_diff AS avg_losses_by_submission_pct_diff_diff,
    t2.avg_opp_losses_by_submission_pct_overall - t3.avg_opp_losses_by_submission_pct_overall AS avg_opp_losses_by_submission_pct_overall_diff,
    t2.avg_losses_by_submission_pct_overall_diff - t3.avg_losses_by_submission_pct_overall_diff AS avg_losses_by_submission_pct_overall_diff_diff,
    t2.avg_opp_submissions_absorbed_per_minute - t3.avg_opp_submissions_absorbed_per_minute AS avg_opp_submissions_absorbed_per_minute_diff,
    t2.avg_submissions_absorbed_per_minute_diff - t3.avg_submissions_absorbed_per_minute_diff AS avg_submissions_absorbed_per_minute_diff_diff,
    t2.avg_opp_losses_by_decision - t3.avg_opp_losses_by_decision AS avg_opp_losses_by_decision_diff,
    t2.avg_losses_by_decision_diff - t3.avg_losses_by_decision_diff AS avg_losses_by_decision_diff_diff,
    t2.avg_opp_losses_by_decision_pct - t3.avg_opp_losses_by_decision_pct AS avg_opp_losses_by_decision_pct_diff,
    t2.avg_losses_by_decision_pct_diff - t3.avg_losses_by_decision_pct_diff AS avg_losses_by_decision_pct_diff_diff,
    t2.avg_opp_losses_by_decision_pct_overall - t3.avg_opp_losses_by_decision_pct_overall AS avg_opp_losses_by_decision_pct_overall_diff,
    t2.avg_losses_by_decision_pct_overall_diff - t3.avg_losses_by_decision_pct_overall_diff AS avg_losses_by_decision_pct_overall_diff_diff,
    t2.avg_opp_avg_end_round - t3.avg_opp_avg_end_round AS avg_opp_avg_end_round_diff,
    t2.avg_avg_end_round_diff - t3.avg_avg_end_round_diff AS avg_avg_end_round_diff_diff,
    t2.avg_opp_avg_end_round_win - t3.avg_opp_avg_end_round_win AS avg_opp_avg_end_round_win_diff,
    t2.avg_avg_end_round_win_diff - t3.avg_avg_end_round_win_diff AS avg_avg_end_round_win_diff_diff,
    t2.avg_opp_avg_end_round_loss - t3.avg_opp_avg_end_round_loss AS avg_opp_avg_end_round_loss_diff,
    t2.avg_avg_end_round_loss_diff - t3.avg_avg_end_round_loss_diff AS avg_avg_end_round_loss_diff_diff,
    t2.avg_opp_total_time_fought_seconds - t3.avg_opp_total_time_fought_seconds AS avg_opp_total_time_fought_seconds_diff,
    t2.avg_total_time_fought_seconds_diff - t3.avg_total_time_fought_seconds_diff AS avg_total_time_fought_seconds_diff_diff,
    t2.avg_opp_avg_time_fought_seconds - t3.avg_opp_avg_time_fought_seconds AS avg_opp_avg_time_fought_seconds_diff,
    t2.avg_avg_time_fought_seconds_diff - t3.avg_avg_time_fought_seconds_diff AS avg_avg_time_fought_seconds_diff_diff,
    t2.avg_opp_avg_time_to_win_seconds - t3.avg_opp_avg_time_to_win_seconds AS avg_opp_avg_time_to_win_seconds_diff,
    t2.avg_avg_time_to_win_seconds_diff - t3.avg_avg_time_to_win_seconds_diff AS avg_avg_time_to_win_seconds_diff_diff,
    t2.avg_opp_avg_time_to_lose_seconds - t3.avg_opp_avg_time_to_lose_seconds AS avg_opp_avg_time_to_lose_seconds_diff,
    t2.avg_avg_time_to_lose_seconds_diff - t3.avg_avg_time_to_lose_seconds_diff AS avg_avg_time_to_lose_seconds_diff_diff,
    CASE
        WHEN red_outcome = 'W' THEN 1
        WHEN red_outcome = 'L' THEN 0
        ELSE NULL
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte17 AS t2 ON t1.id = t2.bout_id
    AND t1.red_fighter_id = t2.fighter_id
    LEFT JOIN cte17 AS t3 ON t1.id = t3.bout_id
    AND t1.blue_fighter_id = t3.fighter_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );