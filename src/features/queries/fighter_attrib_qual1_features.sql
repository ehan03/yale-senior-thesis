WITH stances_imputed AS (
    SELECT t1.id AS fighter_id,
        CASE
            WHEN t1.stance IS NOT NULL THEN t1.stance
            WHEN t3.stance IS NOT NULL THEN t3.stance
            WHEN t4.stance IS NOT NULL
            AND t4.stance LIKE 'Switches%' THEN 'Switch'
            WHEN t4.stance IS NOT NULL THEN t4.stance
            ELSE 'Unknown'
        END AS stance
    FROM ufcstats_fighters AS t1
        INNER JOIN fighter_mapping AS t2 ON t1.id = t2.ufcstats_id
        LEFT JOIN fightoddsio_fighters AS t3 ON t2.fightoddsio_id = t3.id
        LEFT JOIN betmma_fighters AS t4 ON t2.betmma_id = t4.id
),
cte1 AS (
    SELECT id AS bout_id,
        red_fighter_id AS fighter_id,
        red_outcome AS outcome,
        CASE
            WHEN type_verbose LIKE '%Title Bout'
            AND type_verbose NOT LIKE '%Tournament%' THEN 1
            ELSE 0
        END AS is_title_bout,
        CASE
            WHEN red_outcome = 'W'
            AND performance_bonus = 1 THEN 1
            ELSE 0
        END AS got_perf_bonus
    FROM ufcstats_bouts
    UNION
    SELECT id AS bout_id,
        blue_fighter_id AS fighter_id,
        blue_outcome AS outcome,
        CASE
            WHEN type_verbose LIKE '%Title Bout'
            AND type_verbose NOT LIKE '%Tournament%' THEN 1
            ELSE 0
        END AS is_title_bout,
        CASE
            WHEN blue_outcome = 'W'
            AND performance_bonus = 1 THEN 1
            ELSE 0
        END AS got_perf_bonus
    FROM ufcstats_bouts
),
cte2 AS (
    SELECT t1.fighter_id,
        t1.'order' AS bout_order,
        t1.bout_id,
        t1.opponent_id,
        CASE
            WHEN t2.outcome = 'W' THEN 1
            ELSE 0
        END AS win,
        CASE
            WHEN t2.outcome = 'L' THEN 1
            ELSE 0
        END AS loss,
        t4.card_segment,
        t2.is_title_bout,
        t5.stance AS opp_stance,
        CASE
            WHEN t7.fighting_style IS NOT NULL THEN t7.fighting_style
            ELSE 'Unknown'
        END AS opp_fighting_style,
        t2.got_perf_bonus
    FROM ufcstats_fighter_histories t1
        LEFT JOIN cte1 t2 ON t1.bout_id = t2.bout_id
        AND t1.fighter_id = t2.fighter_id
        INNER JOIN bout_mapping t3 ON t1.bout_id = t3.ufcstats_id
        LEFT JOIN espn_bouts t4 ON t3.espn_id = t4.id
        LEFT JOIN stances_imputed t5 ON t1.opponent_id = t5.fighter_id
        LEFT JOIN fighter_mapping t6 ON t1.opponent_id = t6.ufcstats_id
        LEFT JOIN fightoddsio_fighters t7 ON t6.fightoddsio_id = t7.id
),
cte3 AS (
    SELECT fighter_id,
        bout_order,
        bout_id,
        opponent_id,
        SUM(win) OVER (
            PARTITION BY fighter_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_ufc,
        SUM(loss) OVER (
            PARTITION BY fighter_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_ufc,
        AVG(win) OVER (
            PARTITION BY fighter_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_ufc,
        AVG(loss) OVER (
            PARTITION BY fighter_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS loss_pct_ufc,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            card_segment
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_ufc_by_card_segment,
        SUM(loss) OVER (
            PARTITION BY fighter_id,
            card_segment
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_ufc_by_card_segment,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            card_segment
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_ufc_by_card_segment,
        AVG(loss) OVER (
            PARTITION BY fighter_id,
            card_segment
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS loss_pct_ufc_by_card_segment,
        SUM(is_title_bout) OVER (
            PARTITION BY fighter_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS title_bouts_fought_ufc,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            is_title_bout
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_ufc_by_title_bout,
        SUM(loss) OVER (
            PARTITION BY fighter_id,
            is_title_bout
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_ufc_by_title_bout,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            is_title_bout
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_ufc_by_title_bout,
        AVG(loss) OVER (
            PARTITION BY fighter_id,
            is_title_bout
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS loss_pct_ufc_by_title_bout,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            opp_stance
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_ufc_against_stance,
        SUM(loss) OVER (
            PARTITION BY fighter_id,
            opp_stance
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_ufc_against_stance,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            opp_stance
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_ufc_against_stance,
        AVG(loss) OVER (
            PARTITION BY fighter_id,
            opp_stance
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS loss_pct_ufc_against_stance,
        SUM(win) OVER (
            PARTITION BY fighter_id,
            opp_fighting_style
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS wins_ufc_against_fighting_style,
        SUM(loss) OVER (
            PARTITION BY fighter_id,
            opp_fighting_style
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS losses_ufc_against_fighting_style,
        AVG(win) OVER (
            PARTITION BY fighter_id,
            opp_fighting_style
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS win_pct_ufc_against_fighting_style,
        AVG(loss) OVER (
            PARTITION BY fighter_id,
            opp_fighting_style
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS loss_pct_ufc_against_fighting_style,
        SUM(got_perf_bonus) OVER (
            PARTITION BY fighter_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS perf_bonuses_ufc,
        AVG(got_perf_bonus) OVER (
            PARTITION BY fighter_id
            ORDER BY bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS perf_bonus_pct_ufc
    FROM cte2
),
cte4 AS (
    SELECT fighter_id,
        bout_order,
        bout_id,
        opponent_id,
        CASE
            WHEN wins_ufc IS NULL THEN 0
            ELSE wins_ufc
        END AS wins_ufc,
        CASE
            WHEN losses_ufc IS NULL THEN 0
            ELSE losses_ufc
        END AS losses_ufc,
        win_pct_ufc,
        loss_pct_ufc,
        CASE
            WHEN wins_ufc_by_card_segment IS NULL THEN 0
            ELSE wins_ufc_by_card_segment
        END AS wins_ufc_by_card_segment,
        CASE
            WHEN losses_ufc_by_card_segment IS NULL THEN 0
            ELSE losses_ufc_by_card_segment
        END AS losses_ufc_by_card_segment,
        CASE
            WHEN win_pct_ufc_by_card_segment IS NULL THEN win_pct_ufc
            ELSE win_pct_ufc_by_card_segment
        END AS win_pct_ufc_by_card_segment,
        CASE
            WHEN loss_pct_ufc_by_card_segment IS NULL THEN loss_pct_ufc
            ELSE loss_pct_ufc_by_card_segment
        END AS loss_pct_ufc_by_card_segment,
        CASE
            WHEN title_bouts_fought_ufc IS NULL THEN 0
            ELSE title_bouts_fought_ufc
        END AS title_bouts_fought_ufc,
        CASE
            WHEN wins_ufc_by_title_bout IS NULL THEN 0
            ELSE wins_ufc_by_title_bout
        END AS wins_ufc_by_title_bout,
        CASE
            WHEN losses_ufc_by_title_bout IS NULL THEN 0
            ELSE losses_ufc_by_title_bout
        END AS losses_ufc_by_title_bout,
        CASE
            WHEN win_pct_ufc_by_title_bout IS NULL THEN win_pct_ufc
            ELSE win_pct_ufc_by_title_bout
        END AS win_pct_ufc_by_title_bout,
        CASE
            WHEN loss_pct_ufc_by_title_bout IS NULL THEN loss_pct_ufc
            ELSE loss_pct_ufc_by_title_bout
        END AS loss_pct_ufc_by_title_bout,
        CASE
            WHEN wins_ufc_against_stance IS NULL THEN 0
            ELSE wins_ufc_against_stance
        END AS wins_ufc_against_stance,
        CASE
            WHEN losses_ufc_against_stance IS NULL THEN 0
            ELSE losses_ufc_against_stance
        END AS losses_ufc_against_stance,
        CASE
            WHEN win_pct_ufc_against_stance IS NULL THEN win_pct_ufc
            ELSE win_pct_ufc_against_stance
        END AS win_pct_ufc_against_stance,
        CASE
            WHEN loss_pct_ufc_against_stance IS NULL THEN loss_pct_ufc
            ELSE loss_pct_ufc_against_stance
        END AS loss_pct_ufc_against_stance,
        CASE
            WHEN wins_ufc_against_fighting_style IS NULL THEN 0
            ELSE wins_ufc_against_fighting_style
        END AS wins_ufc_against_fighting_style,
        CASE
            WHEN losses_ufc_against_fighting_style IS NULL THEN 0
            ELSE losses_ufc_against_fighting_style
        END AS losses_ufc_against_fighting_style,
        CASE
            WHEN win_pct_ufc_against_fighting_style IS NULL THEN win_pct_ufc
            ELSE win_pct_ufc_against_fighting_style
        END AS win_pct_ufc_against_fighting_style,
        CASE
            WHEN loss_pct_ufc_against_fighting_style IS NULL THEN loss_pct_ufc
            ELSE loss_pct_ufc_against_fighting_style
        END AS loss_pct_ufc_against_fighting_style,
        CASE
            WHEN perf_bonuses_ufc IS NULL THEN 0
            ELSE perf_bonuses_ufc
        END AS perf_bonuses_ufc,
        perf_bonus_pct_ufc
    FROM cte3
    ORDER BY fighter_id,
        bout_order
),
cte5 AS (
    SELECT t1.fighter_id,
        t1.bout_order,
        t1.bout_id,
        t1.opponent_id,
        t1.wins_ufc,
        t1.losses_ufc,
        t1.win_pct_ufc,
        t1.loss_pct_ufc,
        t1.wins_ufc_by_card_segment,
        t1.losses_ufc_by_card_segment,
        t1.win_pct_ufc_by_card_segment,
        t1.loss_pct_ufc_by_card_segment,
        t1.title_bouts_fought_ufc,
        t1.wins_ufc_by_title_bout,
        t1.losses_ufc_by_title_bout,
        t1.win_pct_ufc_by_title_bout,
        t1.loss_pct_ufc_by_title_bout,
        t1.wins_ufc_against_stance,
        t1.losses_ufc_against_stance,
        t1.win_pct_ufc_against_stance,
        t1.loss_pct_ufc_against_stance,
        t1.wins_ufc_against_fighting_style,
        t1.losses_ufc_against_fighting_style,
        t1.win_pct_ufc_against_fighting_style,
        t1.loss_pct_ufc_against_fighting_style,
        t1.perf_bonuses_ufc,
        t1.perf_bonus_pct_ufc,
        AVG(t2.wins_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc,
        AVG(t1.wins_ufc - t2.wins_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc_diff,
        AVG(t2.losses_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc,
        AVG(t1.losses_ufc - t2.losses_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc_diff,
        AVG(t2.win_pct_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc,
        AVG(t1.win_pct_ufc - t2.win_pct_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc_diff,
        AVG(t2.loss_pct_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc,
        AVG(t1.loss_pct_ufc - t2.loss_pct_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc_diff,
        AVG(t2.wins_ufc_by_card_segment) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc_by_card_segment,
        AVG(
            t1.wins_ufc_by_card_segment - t2.wins_ufc_by_card_segment
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc_by_card_segment_diff,
        AVG(t2.losses_ufc_by_card_segment) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc_by_card_segment,
        AVG(
            t1.losses_ufc_by_card_segment - t2.losses_ufc_by_card_segment
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc_by_card_segment_diff,
        AVG(t2.win_pct_ufc_by_card_segment) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc_by_card_segment,
        AVG(
            t1.win_pct_ufc_by_card_segment - t2.win_pct_ufc_by_card_segment
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc_by_card_segment_diff,
        AVG(t2.loss_pct_ufc_by_card_segment) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc_by_card_segment,
        AVG(
            t1.loss_pct_ufc_by_card_segment - t2.loss_pct_ufc_by_card_segment
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc_by_card_segment_diff,
        AVG(t2.title_bouts_fought_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_title_bouts_fought_ufc,
        AVG(
            t1.title_bouts_fought_ufc - t2.title_bouts_fought_ufc
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_title_bouts_fought_ufc_diff,
        AVG(t2.wins_ufc_by_title_bout) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc_by_title_bout,
        AVG(
            t1.wins_ufc_by_title_bout - t2.wins_ufc_by_title_bout
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc_by_title_bout_diff,
        AVG(t2.losses_ufc_by_title_bout) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc_by_title_bout,
        AVG(
            t1.losses_ufc_by_title_bout - t2.losses_ufc_by_title_bout
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc_by_title_bout_diff,
        AVG(t2.win_pct_ufc_by_title_bout) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc_by_title_bout,
        AVG(
            t1.win_pct_ufc_by_title_bout - t2.win_pct_ufc_by_title_bout
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc_by_title_bout_diff,
        AVG(t2.loss_pct_ufc_by_title_bout) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc_by_title_bout,
        AVG(
            t1.loss_pct_ufc_by_title_bout - t2.loss_pct_ufc_by_title_bout
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc_by_title_bout_diff,
        AVG(t2.wins_ufc_against_stance) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc_against_stance,
        AVG(
            t1.wins_ufc_against_stance - t2.wins_ufc_against_stance
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc_against_stance_diff,
        AVG(t2.losses_ufc_against_stance) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc_against_stance,
        AVG(
            t1.losses_ufc_against_stance - t2.losses_ufc_against_stance
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc_against_stance_diff,
        AVG(t2.win_pct_ufc_against_stance) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc_against_stance,
        AVG(
            t1.win_pct_ufc_against_stance - t2.win_pct_ufc_against_stance
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc_against_stance_diff,
        AVG(t2.loss_pct_ufc_against_stance) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc_against_stance,
        AVG(
            t1.loss_pct_ufc_against_stance - t2.loss_pct_ufc_against_stance
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc_against_stance_diff,
        AVG(t2.wins_ufc_against_fighting_style) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc_against_fighting_style,
        AVG(
            t1.wins_ufc_against_fighting_style - t2.wins_ufc_against_fighting_style
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_wins_ufc_against_fighting_style_diff,
        AVG(t2.losses_ufc_against_fighting_style) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc_against_fighting_style,
        AVG(
            t1.losses_ufc_against_fighting_style - t2.losses_ufc_against_fighting_style
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_losses_ufc_against_fighting_style_diff,
        AVG(t2.win_pct_ufc_against_fighting_style) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc_against_fighting_style,
        AVG(
            t1.win_pct_ufc_against_fighting_style - t2.win_pct_ufc_against_fighting_style
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_win_pct_ufc_against_fighting_style_diff,
        AVG(t2.loss_pct_ufc_against_fighting_style) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc_against_fighting_style,
        AVG(
            t1.loss_pct_ufc_against_fighting_style - t2.loss_pct_ufc_against_fighting_style
        ) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_loss_pct_ufc_against_fighting_style_diff,
        AVG(t2.perf_bonuses_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_perf_bonuses_ufc,
        AVG(t1.perf_bonuses_ufc - t2.perf_bonuses_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_perf_bonuses_ufc_diff,
        AVG(t2.perf_bonus_pct_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_perf_bonus_pct_ufc,
        AVG(t1.perf_bonus_pct_ufc - t2.perf_bonus_pct_ufc) OVER (
            PARTITION BY t1.fighter_id
            ORDER BY t1.bout_order ROWS BETWEEN UNBOUNDED PRECEDING AND 1 PRECEDING
        ) AS avg_opp_perf_bonus_pct_ufc_diff
    FROM cte4 t1
        LEFT JOIN cte4 t2 ON t1.fighter_id = t2.opponent_id
        AND t1.bout_id = t2.bout_id
        AND t1.opponent_id = t2.fighter_id
)
SELECT id,
    t2.wins_ufc - t3.wins_ufc AS wins_ufc_diff,
    t2.losses_ufc - t3.losses_ufc AS losses_ufc_diff,
    t2.win_pct_ufc - t3.win_pct_ufc AS win_pct_ufc_diff,
    t2.loss_pct_ufc - t3.loss_pct_ufc AS loss_pct_ufc_diff,
    t2.wins_ufc_by_card_segment - t3.wins_ufc_by_card_segment AS wins_ufc_by_card_segment_diff,
    t2.losses_ufc_by_card_segment - t3.losses_ufc_by_card_segment AS losses_ufc_by_card_segment_diff,
    t2.win_pct_ufc_by_card_segment - t3.win_pct_ufc_by_card_segment AS win_pct_ufc_by_card_segment_diff,
    t2.loss_pct_ufc_by_card_segment - t3.loss_pct_ufc_by_card_segment AS loss_pct_ufc_by_card_segment_diff,
    t2.title_bouts_fought_ufc - t3.title_bouts_fought_ufc AS title_bouts_fought_ufc_diff,
    t2.wins_ufc_by_title_bout - t3.wins_ufc_by_title_bout AS wins_ufc_by_title_bout_diff,
    t2.losses_ufc_by_title_bout - t3.losses_ufc_by_title_bout AS losses_ufc_by_title_bout_diff,
    t2.win_pct_ufc_by_title_bout - t3.win_pct_ufc_by_title_bout AS win_pct_ufc_by_title_bout_diff,
    t2.loss_pct_ufc_by_title_bout - t3.loss_pct_ufc_by_title_bout AS loss_pct_ufc_by_title_bout_diff,
    t2.wins_ufc_against_stance - t3.wins_ufc_against_stance AS wins_ufc_against_stance_diff,
    t2.losses_ufc_against_stance - t3.losses_ufc_against_stance AS losses_ufc_against_stance_diff,
    t2.win_pct_ufc_against_stance - t3.win_pct_ufc_against_stance AS win_pct_ufc_against_stance_diff,
    t2.loss_pct_ufc_against_stance - t3.loss_pct_ufc_against_stance AS loss_pct_ufc_against_stance_diff,
    t2.wins_ufc_against_fighting_style - t3.wins_ufc_against_fighting_style AS wins_ufc_against_fighting_style_diff,
    t2.losses_ufc_against_fighting_style - t3.losses_ufc_against_fighting_style AS losses_ufc_against_fighting_style_diff,
    t2.win_pct_ufc_against_fighting_style - t3.win_pct_ufc_against_fighting_style AS win_pct_ufc_against_fighting_style_diff,
    t2.loss_pct_ufc_against_fighting_style - t3.loss_pct_ufc_against_fighting_style AS loss_pct_ufc_against_fighting_style_diff,
    t2.perf_bonuses_ufc - t3.perf_bonuses_ufc AS perf_bonuses_ufc_diff,
    t2.perf_bonus_pct_ufc - t3.perf_bonus_pct_ufc AS perf_bonus_pct_ufc_diff,
    t2.avg_opp_wins_ufc - t3.avg_opp_wins_ufc AS avg_opp_wins_ufc_diff,
    t2.avg_opp_wins_ufc_diff - t3.avg_opp_wins_ufc_diff AS avg_opp_wins_ufc_diff_diff,
    t2.avg_opp_losses_ufc - t3.avg_opp_losses_ufc AS avg_opp_losses_ufc_diff,
    t2.avg_opp_losses_ufc_diff - t3.avg_opp_losses_ufc_diff AS avg_opp_losses_ufc_diff_diff,
    t2.avg_opp_win_pct_ufc - t3.avg_opp_win_pct_ufc AS avg_opp_win_pct_ufc_diff,
    t2.avg_opp_win_pct_ufc_diff - t3.avg_opp_win_pct_ufc_diff AS avg_opp_win_pct_ufc_diff_diff,
    t2.avg_opp_loss_pct_ufc - t3.avg_opp_loss_pct_ufc AS avg_opp_loss_pct_ufc_diff,
    t2.avg_opp_loss_pct_ufc_diff - t3.avg_opp_loss_pct_ufc_diff AS avg_opp_loss_pct_ufc_diff_diff,
    t2.avg_opp_wins_ufc_by_card_segment - t3.avg_opp_wins_ufc_by_card_segment AS avg_opp_wins_ufc_by_card_segment_diff,
    t2.avg_opp_wins_ufc_by_card_segment_diff - t3.avg_opp_wins_ufc_by_card_segment_diff AS avg_opp_wins_ufc_by_card_segment_diff_diff,
    t2.avg_opp_losses_ufc_by_card_segment - t3.avg_opp_losses_ufc_by_card_segment AS avg_opp_losses_ufc_by_card_segment_diff,
    t2.avg_opp_losses_ufc_by_card_segment_diff - t3.avg_opp_losses_ufc_by_card_segment_diff AS avg_opp_losses_ufc_by_card_segment_diff_diff,
    t2.avg_opp_win_pct_ufc_by_card_segment - t3.avg_opp_win_pct_ufc_by_card_segment AS avg_opp_win_pct_ufc_by_card_segment_diff,
    t2.avg_opp_win_pct_ufc_by_card_segment_diff - t3.avg_opp_win_pct_ufc_by_card_segment_diff AS avg_opp_win_pct_ufc_by_card_segment_diff_diff,
    t2.avg_opp_loss_pct_ufc_by_card_segment - t3.avg_opp_loss_pct_ufc_by_card_segment AS avg_opp_loss_pct_ufc_by_card_segment_diff,
    t2.avg_opp_loss_pct_ufc_by_card_segment_diff - t3.avg_opp_loss_pct_ufc_by_card_segment_diff AS avg_opp_loss_pct_ufc_by_card_segment_diff_diff,
    t2.avg_opp_title_bouts_fought_ufc - t3.avg_opp_title_bouts_fought_ufc AS avg_opp_title_bouts_fought_ufc_diff,
    t2.avg_opp_title_bouts_fought_ufc_diff - t3.avg_opp_title_bouts_fought_ufc_diff AS avg_opp_title_bouts_fought_ufc_diff_diff,
    t2.avg_opp_wins_ufc_by_title_bout - t3.avg_opp_wins_ufc_by_title_bout AS avg_opp_wins_ufc_by_title_bout_diff,
    t2.avg_opp_wins_ufc_by_title_bout_diff - t3.avg_opp_wins_ufc_by_title_bout_diff AS avg_opp_wins_ufc_by_title_bout_diff_diff,
    t2.avg_opp_losses_ufc_by_title_bout - t3.avg_opp_losses_ufc_by_title_bout AS avg_opp_losses_ufc_by_title_bout_diff,
    t2.avg_opp_losses_ufc_by_title_bout_diff - t3.avg_opp_losses_ufc_by_title_bout_diff AS avg_opp_losses_ufc_by_title_bout_diff_diff,
    t2.avg_opp_win_pct_ufc_by_title_bout - t3.avg_opp_win_pct_ufc_by_title_bout AS avg_opp_win_pct_ufc_by_title_bout_diff,
    t2.avg_opp_win_pct_ufc_by_title_bout_diff - t3.avg_opp_win_pct_ufc_by_title_bout_diff AS avg_opp_win_pct_ufc_by_title_bout_diff_diff,
    t2.avg_opp_loss_pct_ufc_by_title_bout - t3.avg_opp_loss_pct_ufc_by_title_bout AS avg_opp_loss_pct_ufc_by_title_bout_diff,
    t2.avg_opp_loss_pct_ufc_by_title_bout_diff - t3.avg_opp_loss_pct_ufc_by_title_bout_diff AS avg_opp_loss_pct_ufc_by_title_bout_diff_diff,
    t2.avg_opp_wins_ufc_against_stance - t3.avg_opp_wins_ufc_against_stance AS avg_opp_wins_ufc_against_stance_diff,
    t2.avg_opp_wins_ufc_against_stance_diff - t3.avg_opp_wins_ufc_against_stance_diff AS avg_opp_wins_ufc_against_stance_diff_diff,
    t2.avg_opp_losses_ufc_against_stance - t3.avg_opp_losses_ufc_against_stance AS avg_opp_losses_ufc_against_stance_diff,
    t2.avg_opp_losses_ufc_against_stance_diff - t3.avg_opp_losses_ufc_against_stance_diff AS avg_opp_losses_ufc_against_stance_diff_diff,
    t2.avg_opp_win_pct_ufc_against_stance - t3.avg_opp_win_pct_ufc_against_stance AS avg_opp_win_pct_ufc_against_stance_diff,
    t2.avg_opp_win_pct_ufc_against_stance_diff - t3.avg_opp_win_pct_ufc_against_stance_diff AS avg_opp_win_pct_ufc_against_stance_diff_diff,
    t2.avg_opp_loss_pct_ufc_against_stance - t3.avg_opp_loss_pct_ufc_against_stance AS avg_opp_loss_pct_ufc_against_stance_diff,
    t2.avg_opp_loss_pct_ufc_against_stance_diff - t3.avg_opp_loss_pct_ufc_against_stance_diff AS avg_opp_loss_pct_ufc_against_stance_diff_diff,
    t2.avg_opp_wins_ufc_against_fighting_style - t3.avg_opp_wins_ufc_against_fighting_style AS avg_opp_wins_ufc_against_fighting_style_diff,
    t2.avg_opp_wins_ufc_against_fighting_style_diff - t3.avg_opp_wins_ufc_against_fighting_style_diff AS avg_opp_wins_ufc_against_fighting_style_diff_diff,
    t2.avg_opp_losses_ufc_against_fighting_style - t3.avg_opp_losses_ufc_against_fighting_style AS avg_opp_losses_ufc_against_fighting_style_diff,
    t2.avg_opp_losses_ufc_against_fighting_style_diff - t3.avg_opp_losses_ufc_against_fighting_style_diff AS avg_opp_losses_ufc_against_fighting_style_diff_diff,
    t2.avg_opp_win_pct_ufc_against_fighting_style - t3.avg_opp_win_pct_ufc_against_fighting_style AS avg_opp_win_pct_ufc_against_fighting_style_diff,
    t2.avg_opp_win_pct_ufc_against_fighting_style_diff - t3.avg_opp_win_pct_ufc_against_fighting_style_diff AS avg_opp_win_pct_ufc_against_fighting_style_diff_diff,
    t2.avg_opp_loss_pct_ufc_against_fighting_style - t3.avg_opp_loss_pct_ufc_against_fighting_style AS avg_opp_loss_pct_ufc_against_fighting_style_diff,
    t2.avg_opp_loss_pct_ufc_against_fighting_style_diff - t3.avg_opp_loss_pct_ufc_against_fighting_style_diff AS avg_opp_loss_pct_ufc_against_fighting_style_diff_diff,
    t2.avg_opp_perf_bonuses_ufc - t3.avg_opp_perf_bonuses_ufc AS avg_opp_perf_bonuses_ufc_diff,
    t2.avg_opp_perf_bonuses_ufc_diff - t3.avg_opp_perf_bonuses_ufc_diff AS avg_opp_perf_bonuses_ufc_diff_diff,
    t2.avg_opp_perf_bonus_pct_ufc - t3.avg_opp_perf_bonus_pct_ufc AS avg_opp_perf_bonus_pct_ufc_diff,
    t2.avg_opp_perf_bonus_pct_ufc_diff - t3.avg_opp_perf_bonus_pct_ufc_diff AS avg_opp_perf_bonus_pct_ufc_diff_diff,
    CASE
        WHEN red_outcome = 'W' THEN 1
        WHEN red_outcome = 'L' THEN 0
        ELSE NULL
    END AS red_win
FROM ufcstats_bouts AS t1
    LEFT JOIN cte5 AS t2 ON t1.id = t2.bout_id
    AND t2.fighter_id = t1.red_fighter_id
    LEFT JOIN cte5 AS t3 ON t1.id = t3.bout_id
    AND t3.fighter_id = t1.blue_fighter_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    );