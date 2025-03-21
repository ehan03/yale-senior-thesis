# standard library imports
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), "..", ".."))

# third party imports
import pandas as pd
from sqlalchemy import create_engine

# local imports
from src.betting import DistributionalRobustKelly, NaiveKelly


class BacktestFramework:
    def __init__(self) -> None:
        self.data_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data")
        self.db_string = f"sqlite:///{os.path.join(self.data_dir, 'ufc.db')}"
        self.engine = create_engine(self.db_string)

    def create_backtest_data(self) -> None:
        backtest_odds_path = os.path.join(
            self.data_dir, "backtesting", "backtest_odds.csv"
        )
        if not os.path.exists(backtest_odds_path):
            backtest_odds_query = """
            WITH cte1 AS (
                SELECT
                    ufcstats_bouts.id AS bout_id,
                    event_id,
                    date,
                    bout_mapping.fightoddsio_id AS fightoddsio_bout_id,
                    red_mapping.fightoddsio_id AS red_fighter_id,
                    blue_mapping.fightoddsio_id AS blue_fighter_id,
                    event_mapping.bestfightodds_id AS bestfightodds_event_id,
                    red_mapping.bestfightodds_id AS bestfightodds_red_fighter_id,
                    blue_mapping.bestfightodds_id AS bestfightodds_blue_fighter_id,
                    CASE
                        WHEN
                            red_outcome = 'W' 
                        THEN
                            1 
                        WHEN
                            red_outcome = 'L' 
                        THEN
                            0 
                        ELSE
                            NULL 
                    END
                    AS red_win 
                FROM
                    ufcstats_bouts 
                    LEFT JOIN
                        ufcstats_events 
                        ON ufcstats_bouts.event_id = ufcstats_events.id 
                    LEFT JOIN
                        bout_mapping 
                        ON ufcstats_bouts.id = bout_mapping.ufcstats_id 
                    LEFT JOIN
                        fighter_mapping AS red_mapping 
                        ON ufcstats_bouts.red_fighter_id = red_mapping.ufcstats_id 
                    LEFT JOIN
                        fighter_mapping AS blue_mapping 
                        ON ufcstats_bouts.blue_fighter_id = blue_mapping.ufcstats_id
                    LEFT JOIN
                        event_mapping
                        ON ufcstats_events.id = event_mapping.ufcstats_id
                WHERE
                    is_ufc_event = 1 
                    AND date >= '2017-01-01' 
            ), 
            cte2 AS (
                SELECT
                    ROW_NUMBER() OVER (PARTITION BY bout_id 
                ORDER BY
                    fightoddsio_moneyline_odds.rowid DESC) AS rn,
                    bout_id AS fightoddsio_bout_id,
                    fighter_1_id,
                    fighter_2_id,
                    fighter_1_odds_current,
                    fighter_2_odds_current 
                FROM
                    fightoddsio_moneyline_odds 
                    LEFT JOIN
                        fightoddsio_bouts 
                        ON fightoddsio_moneyline_odds.bout_id = fightoddsio_bouts.id 
                WHERE
                    sportsbook_id = 
                    (
                        SELECT
                            id 
                        FROM
                            fightoddsio_sportsbooks 
                        WHERE
                            full_name = 'Bovada' 
                    )
                ORDER BY
                    fightoddsio_bouts.rowid ASC,
                    fightoddsio_moneyline_odds.rowid ASC 
            ), 
            cte3 AS (
                SELECT
                    fightoddsio_bout_id,
                    fighter_1_id,
                    fighter_2_id,
                    fighter_1_odds_current, fighter_2_odds_current 
                FROM
                    cte2 
                WHERE
                    rn = 1 
            ), 
            cte4 AS (
                SELECT
                    fightoddsio_bout_id,
                    fighter_1_id AS fightoddsio_fighter_id,
                    fighter_1_odds_current AS odds 
                FROM
                    cte3
                UNION
                SELECT
                    fightoddsio_bout_id,
                    fighter_2_id AS fightoddsio_fighter_id,
                    fighter_2_odds_current AS odds 
                FROM
                    cte3
            ),
            cte5 AS (
                SELECT
                    ROW_NUMBER() OVER (PARTITION BY bout_id 
                ORDER BY
                    fightoddsio_moneyline_odds.rowid DESC) AS rn,
                    bout_id AS fightoddsio_bout_id,
                    fighter_1_id,
                    fighter_2_id,
                    fighter_1_odds_current,
                    fighter_2_odds_current 
                FROM
                    fightoddsio_moneyline_odds 
                    LEFT JOIN
                        fightoddsio_bouts 
                        ON fightoddsio_moneyline_odds.bout_id = fightoddsio_bouts.id 
                WHERE
                    sportsbook_id = 
                    (
                        SELECT
                            id 
                        FROM
                            fightoddsio_sportsbooks 
                        WHERE
                            full_name = 'Pinnacle Sports' 
                    )
                ORDER BY
                    fightoddsio_bouts.rowid ASC,
                    fightoddsio_moneyline_odds.rowid ASC 
            ), 
            cte6 AS (
                SELECT
                    fightoddsio_bout_id,
                    fighter_1_id,
                    fighter_2_id,
                    fighter_1_odds_current, fighter_2_odds_current 
                FROM
                    cte5
                WHERE
                    rn = 1 
            ), 
            cte7 AS (
                SELECT
                    fightoddsio_bout_id,
                    fighter_1_id AS fightoddsio_fighter_id,
                    fighter_1_odds_current AS odds 
                FROM
                    cte6
                UNION
                SELECT
                    fightoddsio_bout_id,
                    fighter_2_id AS fightoddsio_fighter_id,
                    fighter_2_odds_current AS odds 
                FROM
                    cte6
            ),
            cte8 AS (
                SELECT
                    event_id,
                    fighter_id,
                    timestamp,
                    ROW_NUMBER() OVER (
                        PARTITION BY event_id, fighter_id
                        ORDER BY timestamp DESC
                    ) AS rn,
                    odds
                FROM
                    bestfightodds_moneyline_odds
                WHERE
                    betsite = 'BetOnline'
            ),
            cte9 AS (
                SELECT
                    event_id,
                    fighter_id,
                    odds
                FROM
                    cte8
                WHERE
                    rn = 1
            )
            SELECT
                bout_id,
                cte1.event_id,
                date,
                CASE
                    WHEN red_mapping1.odds IS NOT NULL AND blue_mapping1.odds IS NOT NULL THEN 'Bovada'
                    WHEN red_mapping2.odds IS NOT NULL AND blue_mapping2.odds IS NOT NULL THEN 'Pinnacle Sports'
                    ELSE 'BetOnline'
                END AS sportsbook,
                CASE
                    WHEN red_mapping1.odds IS NOT NULL AND blue_mapping1.odds IS NOT NULL THEN red_mapping1.odds
                    WHEN red_mapping2.odds IS NOT NULL AND blue_mapping2.odds IS NOT NULL THEN red_mapping2.odds
                    ELSE red_mapping3.odds
                END AS red_odds,
                CASE
                    WHEN blue_mapping1.odds IS NOT NULL AND red_mapping1.odds IS NOT NULL THEN blue_mapping1.odds
                    WHEN blue_mapping2.odds IS NOT NULL AND red_mapping2.odds IS NOT NULL THEN blue_mapping2.odds
                    ELSE blue_mapping3.odds
                END AS blue_odds,
                red_win
            FROM
                cte1  
                LEFT JOIN
                    cte4 AS red_mapping1 
                    ON cte1.fightoddsio_bout_id = red_mapping1.fightoddsio_bout_id 
                    AND cte1.red_fighter_id = red_mapping1.fightoddsio_fighter_id 
                LEFT JOIN
                    cte4 AS blue_mapping1 
                    ON cte1.fightoddsio_bout_id = blue_mapping1.fightoddsio_bout_id 
                    AND cte1.blue_fighter_id = blue_mapping1.fightoddsio_fighter_id
                LEFT JOIN
                    cte7 AS red_mapping2
                    ON cte1.fightoddsio_bout_id = red_mapping2.fightoddsio_bout_id
                    AND cte1.red_fighter_id = red_mapping2.fightoddsio_fighter_id
                LEFT JOIN
                    cte7 AS blue_mapping2
                    ON cte1.fightoddsio_bout_id = blue_mapping2.fightoddsio_bout_id
                    AND cte1.blue_fighter_id = blue_mapping2.fightoddsio_fighter_id
                LEFT JOIN
                    cte9 AS red_mapping3
                    ON cte1.bestfightodds_event_id = red_mapping3.event_id
                    AND cte1.bestfightodds_red_fighter_id = red_mapping3.fighter_id
                LEFT JOIN
                    cte9 AS blue_mapping3
                    ON cte1.bestfightodds_event_id = blue_mapping3.event_id
                    AND cte1.bestfightodds_blue_fighter_id = blue_mapping3.fighter_id;
            """

            backtest_odds = pd.read_sql(backtest_odds_query, self.engine)
            backtest_odds["red_win"] = backtest_odds["red_win"].astype("Int64")
            backtest_odds.to_csv(backtest_odds_path, index=False)

    def __call__(self) -> None:
        self.create_backtest_data()


if __name__ == "__main__":
    backtest_framework = BacktestFramework()
    backtest_framework()
