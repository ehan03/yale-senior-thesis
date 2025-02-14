WITH cte1 AS (
    SELECT t2.ufcstats_id AS ufcstats_fighter_id,
        t2.bestfightodds_id AS bestfightodds_fighter_id,
        t2.fightoddsio_id AS fightoddsio_fighter_id,
        t1.'order',
        t3.ufcstats_id AS ufcstats_bout_id,
        t3.fightoddsio_id AS fightoddsio_bout_id,
        t4.bestfightodds_id AS bestfightodds_event_id,
        CASE
            WHEN odds > 0 THEN 1 + odds / 100.0
            WHEN odds < 0 THEN 1 - 100.0 / odds
            ELSE odds
        end AS tapology_closing_odds
    FROM tapology_fighter_histories AS t1
        LEFT JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.tapology_id
        LEFT JOIN bout_mapping AS t3 ON t1.bout_id = t3.tapology_id
        LEFT JOIN event_mapping AS t4 ON t1.event_id = t4.tapology_id
),
cte2 AS (
    SELECT bout_id,
        fighter_1_id,
        fighter_2_id,
        avg(fighter_1_opening_odds) AS fighter_1_opening_odds,
        avg(fighter_1_closing_odds) AS fighter_1_closing_odds,
        avg(fighter_2_opening_odds) AS fighter_2_opening_odds,
        avg(fighter_2_closing_odds) AS fighter_2_closing_odds
    FROM (
            SELECT row_number() over (
                    partition BY bout_id,
                    sportsbook_id
                    ORDER BY t1.rowid DESC
                ) AS rn,
                bout_id,
                sportsbook_id,
                fighter_1_id,
                fighter_2_id,
                CASE
                    WHEN fighter_1_odds_open > 0 THEN 1 + fighter_1_odds_open / 100.0
                    WHEN fighter_1_odds_open < 0 THEN 1 - 100.0 / fighter_1_odds_open
                    ELSE fighter_1_odds_open
                end AS fighter_1_opening_odds,
                CASE
                    WHEN fighter_1_odds_current > 0 THEN 1 + fighter_1_odds_current / 100.0
                    WHEN fighter_1_odds_current < 0 THEN 1 - 100.0 / fighter_1_odds_current
                    ELSE fighter_1_odds_current
                end AS fighter_1_closing_odds,
                CASE
                    WHEN fighter_2_odds_open > 0 THEN 1 + fighter_2_odds_open / 100.0
                    WHEN fighter_2_odds_open < 0 THEN 1 - 100.0 / fighter_2_odds_open
                    ELSE fighter_2_odds_open
                end AS fighter_2_opening_odds,
                CASE
                    WHEN fighter_2_odds_current > 0 THEN 1 + fighter_2_odds_current / 100.0
                    WHEN fighter_2_odds_current < 0 THEN 1 - 100.0 / fighter_2_odds_current
                    ELSE fighter_2_odds_current
                end AS fighter_2_closing_odds
            FROM fightoddsio_moneyline_odds AS t1
                LEFT JOIN fightoddsio_bouts AS t2 ON t1.bout_id = t2.id
            WHERE sportsbook_id IN (
                    SELECT id
                    FROM fightoddsio_sportsbooks
                    WHERE full_name NOT IN (
                            'DraftKings',
                            'FanDuel',
                            'Bookmaker',
                            'MyBookie',
                            'Betway'
                        )
                )
        )
    GROUP BY bout_id,
        fighter_1_id,
        fighter_2_id
    HAVING rn = 1
),
cte3 AS (
    SELECT bout_id AS fightoddsio_bout_id,
        fighter_1_id AS fightoddsio_fighter_id,
        fighter_1_opening_odds AS fightoddsio_opening_odds,
        fighter_1_closing_odds AS fightoddsio_closing_odds
    FROM cte2
    UNION
    SELECT bout_id AS fightoddsio_bout_id,
        fighter_2_id AS fightoddsio_fighter_id,
        fighter_2_opening_odds AS fightoddsio_opening_odds,
        fighter_2_closing_odds AS fightoddsio_closing_odds
    FROM cte2
),
cte4 AS (
    SELECT event_id,
        fighter_id,
        betsite,
        min(timestamp) AS first_timestamp,
        max(timestamp) AS last_timestamp
    FROM bestfightodds_moneyline_odds
    GROUP BY event_id,
        fighter_id,
        betsite
),
cte5 AS (
    SELECT t1.event_id AS bestfightodds_event_id,
        t1.fighter_id AS bestfightodds_fighter_id,
        avg(
            CASE
                WHEN t2.odds > 0 THEN 1 + t2.odds / 100.0
                WHEN t2.odds < 0 THEN 1 - 100.0 / t2.odds
                ELSE t2.odds
            end
        ) AS bestfightodds_opening_odds,
        avg(
            CASE
                WHEN t3.odds > 0 THEN 1 + t3.odds / 100.0
                WHEN t3.odds < 0 THEN 1 - 100.0 / t3.odds
                ELSE t3.odds
            end
        ) AS bestfightodds_closing_odds
    FROM cte4 AS t1
        LEFT JOIN bestfightodds_moneyline_odds AS t2 ON t1.event_id = t2.event_id
        AND t1.fighter_id = t2.fighter_id
        AND t1.betsite = t2.betsite
        AND t1.first_timestamp = t2.timestamp
        LEFT JOIN bestfightodds_moneyline_odds AS t3 ON t1.event_id = t3.event_id
        AND t1.fighter_id = t3.fighter_id
        AND t1.betsite = t3.betsite
        AND t1.last_timestamp = t3.timestamp
    GROUP BY t1.event_id,
        t1.fighter_id
),
prop1 AS (
    SELECT event_id AS bestfightodds_event_id,
        fighter_id AS bestfightodds_fighter_id,
        avg(
            CASE
                WHEN description = 'Wins by decision'
                AND odds > 0 THEN 1 + odds / 100.0
                WHEN description = 'Wins by decision'
                AND odds < 0 THEN 1 - 100.0 / odds
                ELSE NULL
            end
        ) AS bestfightodds_win_by_decision_odds,
        avg(
            CASE
                WHEN description = 'Wins by submission'
                AND odds > 0 THEN 1 + odds / 100.0
                WHEN description = 'Wins by submission'
                AND odds < 0 THEN 1 - 100.0 / odds
                ELSE NULL
            end
        ) AS bestfightodds_win_by_submission_odds,
        avg(
            CASE
                WHEN description = 'Wins by tko/ko'
                AND odds > 0 THEN 1 + odds / 100.0
                WHEN description = 'Wins by tko/ko'
                AND odds < 0 THEN 1 - 100.0 / odds
                ELSE NULL
            end
        ) AS bestfightodds_win_by_tko_ko_odds,
        avg(
            CASE
                WHEN description = 'Wins inside distance'
                AND odds > 0 THEN 1 + odds / 100.0
                WHEN description = 'Wins inside distance'
                AND odds < 0 THEN 1 - 100.0 / odds
                ELSE NULL
            end
        ) AS bestfightodds_win_inside_distance_odds,
        avg(
            CASE
                WHEN description = 'Wins in round 1'
                AND odds > 0 THEN 1 + odds / 100.0
                WHEN description = 'Wins in round 1'
                AND odds < 0 THEN 1 - 100.0 / odds
                ELSE NULL
            end
        ) AS bestfightodds_win_in_round_1_odds,
        avg(
            CASE
                WHEN description = 'Wins in round 2'
                AND odds > 0 THEN 1 + odds / 100.0
                WHEN description = 'Wins in round 2'
                AND odds < 0 THEN 1 - 100.0 / odds
                ELSE NULL
            end
        ) AS bestfightodds_win_in_round_2_odds,
        avg(
            CASE
                WHEN description = 'Wins in round 3'
                AND odds > 0 THEN 1 + odds / 100.0
                WHEN description = 'Wins in round 3'
                AND odds < 0 THEN 1 - 100.0 / odds
                ELSE NULL
            end
        ) AS bestfightodds_win_in_round_3_odds
    FROM bestfightodds_bout_proposition_odds
    WHERE fighter_id IS NOT NULL
        AND is_not = 0
        AND description IN (
            'Wins by decision',
            'Wins by submission',
            'Wins by tko/ko',
            'Wins inside distance',
            'Wins in round 1',
            'Wins in round 2',
            'Wins in round 3'
        )
    GROUP BY event_id,
        fighter_id
),
prop2 AS (
    SELECT t1.bout_id AS fightoddsio_bout_id,
        t2.id AS fightoddsio_fighter_id,
        avg(
            CASE
                WHEN offer_type_id = 'DEC'
                AND average_odds > 0 THEN 1 + average_odds / 100.0
                WHEN offer_type_id = 'DEC'
                AND average_odds < 0 THEN 1 - 100.0 / average_odds
                ELSE NULL
            end
        ) AS fightoddsio_win_by_decision_odds,
        avg(
            CASE
                WHEN offer_type_id = 'SUB'
                AND average_odds > 0 THEN 1 + average_odds / 100.0
                WHEN offer_type_id = 'SUB'
                AND average_odds < 0 THEN 1 - 100.0 / average_odds
                ELSE NULL
            end
        ) AS fightoddsio_win_by_submission_odds,
        avg(
            CASE
                WHEN offer_type_id = 'KO'
                AND average_odds > 0 THEN 1 + average_odds / 100.0
                WHEN offer_type_id = 'KO'
                AND average_odds < 0 THEN 1 - 100.0 / average_odds
                ELSE NULL
            end
        ) AS fightoddsio_win_by_tko_ko_odds,
        avg(
            CASE
                WHEN offer_type_id = 'ID'
                AND average_odds > 0 THEN 1 + average_odds / 100.0
                WHEN offer_type_id = 'ID'
                AND average_odds < 0 THEN 1 - 100.0 / average_odds
                ELSE NULL
            end
        ) AS fightoddsio_win_inside_distance_odds,
        avg(
            CASE
                WHEN offer_type_id = 'R_1'
                AND average_odds > 0 THEN 1 + average_odds / 100.0
                WHEN offer_type_id = 'R_1'
                AND average_odds < 0 THEN 1 - 100.0 / average_odds
                ELSE NULL
            end
        ) AS fightoddsio_win_in_round_1_odds,
        avg(
            CASE
                WHEN offer_type_id = 'R_2'
                AND average_odds > 0 THEN 1 + average_odds / 100.0
                WHEN offer_type_id = 'R_2'
                AND average_odds < 0 THEN 1 - 100.0 / average_odds
                ELSE NULL
            end
        ) AS fightoddsio_win_in_round_2_odds,
        avg(
            CASE
                WHEN offer_type_id = 'R_3'
                AND average_odds > 0 THEN 1 + average_odds / 100.0
                WHEN offer_type_id = 'R_3'
                AND average_odds < 0 THEN 1 - 100.0 / average_odds
                ELSE NULL
            end
        ) AS fightoddsio_win_in_round_3_odds
    FROM fightoddsio_proposition_odds AS t1
        LEFT JOIN fightoddsio_fighters AS t2 ON t1.fighter_pk = t2.pk
    WHERE fighter_pk IS NOT NULL
        AND is_not = 0
        AND offer_type_id IN (
            'DEC',
            'SUB',
            'KO',
            'ID',
            'R_1',
            'R_2',
            'R_3'
        )
    GROUP BY t1.bout_id,
        t2.id
),
cte6 AS (
    SELECT ufcstats_fighter_id,
        cte1.'order',
        ufcstats_bout_id,
        CASE
            WHEN fightoddsio_opening_odds IS NOT NULL THEN fightoddsio_opening_odds
            WHEN bestfightodds_opening_odds IS NOT NULL THEN bestfightodds_opening_odds
            ELSE NULL
        end AS opening_odds,
        CASE
            WHEN fightoddsio_closing_odds IS NOT NULL THEN fightoddsio_closing_odds
            WHEN bestfightodds_closing_odds IS NOT NULL THEN bestfightodds_closing_odds
            ELSE tapology_closing_odds
        end AS closing_odds,
        CASE
            WHEN fightoddsio_win_by_decision_odds IS NOT NULL THEN fightoddsio_win_by_decision_odds
            WHEN bestfightodds_win_by_decision_odds IS NOT NULL THEN bestfightodds_win_by_decision_odds
            ELSE NULL
        end AS win_by_decision_odds,
        CASE
            WHEN fightoddsio_win_by_submission_odds IS NOT NULL THEN fightoddsio_win_by_submission_odds
            WHEN bestfightodds_win_by_submission_odds IS NOT NULL THEN bestfightodds_win_by_submission_odds
            ELSE NULL
        end AS win_by_submission_odds,
        CASE
            WHEN fightoddsio_win_by_tko_ko_odds IS NOT NULL THEN fightoddsio_win_by_tko_ko_odds
            WHEN bestfightodds_win_by_tko_ko_odds IS NOT NULL THEN bestfightodds_win_by_tko_ko_odds
            ELSE NULL
        end AS win_by_tko_ko_odds,
        CASE
            WHEN fightoddsio_win_inside_distance_odds IS NOT NULL THEN fightoddsio_win_inside_distance_odds
            WHEN bestfightodds_win_inside_distance_odds IS NOT NULL THEN bestfightodds_win_inside_distance_odds
            ELSE NULL
        end AS win_inside_distance_odds,
        CASE
            WHEN fightoddsio_win_in_round_1_odds IS NOT NULL THEN fightoddsio_win_in_round_1_odds
            WHEN bestfightodds_win_in_round_1_odds IS NOT NULL THEN bestfightodds_win_in_round_1_odds
            ELSE NULL
        end AS win_in_round_1_odds,
        CASE
            WHEN fightoddsio_win_in_round_2_odds IS NOT NULL THEN fightoddsio_win_in_round_2_odds
            WHEN bestfightodds_win_in_round_2_odds IS NOT NULL THEN bestfightodds_win_in_round_2_odds
            ELSE NULL
        end AS win_in_round_2_odds,
        CASE
            WHEN fightoddsio_win_in_round_3_odds IS NOT NULL THEN fightoddsio_win_in_round_3_odds
            WHEN bestfightodds_win_in_round_3_odds IS NOT NULL THEN bestfightodds_win_in_round_3_odds
            ELSE NULL
        end AS win_in_round_3_odds
    FROM cte1
        LEFT JOIN cte3 ON cte1.fightoddsio_fighter_id = cte3.fightoddsio_fighter_id
        AND cte1.fightoddsio_bout_id = cte3.fightoddsio_bout_id
        LEFT JOIN cte5 ON cte1.bestfightodds_fighter_id = cte5.bestfightodds_fighter_id
        AND cte1.bestfightodds_event_id = cte5.bestfightodds_event_id
        LEFT JOIN prop1 ON cte1.bestfightodds_event_id = prop1.bestfightodds_event_id
        AND cte1.bestfightodds_fighter_id = prop1.bestfightodds_fighter_id
        LEFT JOIN prop2 ON cte1.fightoddsio_bout_id = prop2.fightoddsio_bout_id
        AND cte1.fightoddsio_fighter_id = prop2.fightoddsio_fighter_id
),
cte7 AS (
    SELECT ufcstats_fighter_id,
        cte6.'order',
        ufcstats_bout_id,
        avg(opening_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_moneyline_opening_odds,
        avg(1.0 / opening_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_moneyline_opening_implied_prob,
        avg(closing_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_moneyline_closing_odds,
        avg(1.0 / closing_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_moneyline_closing_implied_prob,
        avg(closing_odds - opening_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_moneyline_odds_change,
        avg(1.0 / closing_odds - 1.0 / opening_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_moneyline_implied_prob_change,
        avg(win_by_decision_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_by_decision_odds,
        avg(1.0 / win_by_decision_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_by_decision_implied_prob,
        avg(win_by_submission_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_by_submission_odds,
        avg(1.0 / win_by_submission_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_by_submission_implied_prob,
        avg(win_by_tko_ko_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_by_tko_ko_odds,
        avg(1.0 / win_by_tko_ko_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_by_tko_ko_implied_prob,
        avg(win_inside_distance_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_inside_distance_odds,
        avg(1.0 / win_inside_distance_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_inside_distance_implied_prob,
        avg(win_in_round_1_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_in_round_1_odds,
        avg(1.0 / win_in_round_1_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_in_round_1_implied_prob,
        avg(win_in_round_2_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_in_round_2_odds,
        avg(1.0 / win_in_round_2_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_in_round_2_implied_prob,
        avg(win_in_round_3_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_in_round_3_odds,
        avg(1.0 / win_in_round_3_odds) over (
            partition BY ufcstats_fighter_id
            ORDER BY cte6.'order' ASC rows BETWEEN unbounded preceding AND 1 preceding
        ) AS avg_win_in_round_3_implied_prob
    FROM cte6
)
SELECT id,
    t2.avg_moneyline_opening_odds - t3.avg_moneyline_opening_odds AS avg_moneyline_opening_odds_diff,
    t2.avg_moneyline_opening_implied_prob - t3.avg_moneyline_opening_implied_prob AS avg_moneyline_opening_implied_prob_diff,
    t2.avg_moneyline_closing_odds - t3.avg_moneyline_closing_odds AS avg_moneyline_closing_odds_diff,
    t2.avg_moneyline_closing_implied_prob - t3.avg_moneyline_closing_implied_prob AS avg_moneyline_closing_implied_prob_diff,
    t2.avg_moneyline_odds_change - t3.avg_moneyline_odds_change AS avg_moneyline_odds_change_diff,
    t2.avg_moneyline_implied_prob_change - t3.avg_moneyline_implied_prob_change AS avg_moneyline_implied_prob_change_diff,
    t2.avg_win_by_decision_odds - t3.avg_win_by_decision_odds AS avg_win_by_decision_odds_diff,
    t2.avg_win_by_decision_implied_prob - t3.avg_win_by_decision_implied_prob AS avg_win_by_decision_implied_prob_diff,
    t2.avg_win_by_submission_odds - t3.avg_win_by_submission_odds AS avg_win_by_submission_odds_diff,
    t2.avg_win_by_submission_implied_prob - t3.avg_win_by_submission_implied_prob AS avg_win_by_submission_implied_prob_diff,
    t2.avg_win_by_tko_ko_odds - t3.avg_win_by_tko_ko_odds AS avg_win_by_tko_ko_odds_diff,
    t2.avg_win_by_tko_ko_implied_prob - t3.avg_win_by_tko_ko_implied_prob AS avg_win_by_tko_ko_implied_prob_diff,
    t2.avg_win_inside_distance_odds - t3.avg_win_inside_distance_odds AS avg_win_inside_distance_odds_diff,
    t2.avg_win_inside_distance_implied_prob - t3.avg_win_inside_distance_implied_prob AS avg_win_inside_distance_implied_prob_diff,
    t2.avg_win_in_round_1_odds - t3.avg_win_in_round_1_odds AS avg_win_in_round_1_odds_diff,
    t2.avg_win_in_round_1_implied_prob - t3.avg_win_in_round_1_implied_prob AS avg_win_in_round_1_implied_prob_diff,
    t2.avg_win_in_round_2_odds - t3.avg_win_in_round_2_odds AS avg_win_in_round_2_odds_diff,
    t2.avg_win_in_round_2_implied_prob - t3.avg_win_in_round_2_implied_prob AS avg_win_in_round_2_implied_prob_diff,
    t2.avg_win_in_round_3_odds - t3.avg_win_in_round_3_odds AS avg_win_in_round_3_odds_diff,
    t2.avg_win_in_round_3_implied_prob - t3.avg_win_in_round_3_implied_prob AS avg_win_in_round_3_implied_prob_diff
FROM ufcstats_bouts AS t1
    LEFT JOIN cte7 AS t2 ON t1.red_fighter_id = t2.ufcstats_fighter_id
    AND t1.id = t2.ufcstats_bout_id
    LEFT JOIN cte7 AS t3 ON t1.blue_fighter_id = t3.ufcstats_fighter_id
    AND t1.id = t3.ufcstats_bout_id
WHERE event_id IN (
        SELECT id
        FROM ufcstats_events
        WHERE is_ufc_event = 1
            AND date >= '2008-04-19'
    )