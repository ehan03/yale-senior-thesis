# standard library imports
import os

# third party imports
import pandas as pd
from sqlalchemy import create_engine

# local imports


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
            WITH cte1 AS 
            (
                SELECT
                    ufcstats_bouts.id AS bout_id,
                    event_id,
                    date,
                    bout_mapping.fightoddsio_id AS fightoddsio_bout_id,
                    red_mapping.fightoddsio_id AS red_fighter_id,
                    blue_mapping.fightoddsio_id AS blue_fighter_id,
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
                WHERE
                    is_ufc_event = 1 
                    AND date >= '2021-01-01' 
            )
            , cte2 AS 
            (
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
                            full_name = 'BetOnline' 
                    )
                ORDER BY
                    fightoddsio_bouts.rowid ASC,
                    fightoddsio_moneyline_odds.rowid ASC 
            )
            ,
            cte3 AS 
            (
                SELECT
                    fightoddsio_bout_id,
                    fighter_1_id,
                    fighter_2_id,
                    CASE
                        WHEN
                            fightoddsio_bout_id = 'RmlnaHROb2RlOjUyNTg3' 
                        THEN
                            - 118 
                        WHEN
                            fightoddsio_bout_id = 'RmlnaHROb2RlOjU3MjM1' 
                        THEN
                            - 330 
                        ELSE
                            fighter_1_odds_current 
                    END
                    AS fighter_1_odds_current, fighter_2_odds_current 
                FROM
                    cte2 
                WHERE
                    rn = 1 
            )
            , cte4 AS 
            (
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
            )
            SELECT
                bout_id,
                event_id,
                date,
                red_win,
                CASE
                    WHEN
                        bout_id = 'dcc0c53100fa1dd2' 
                    THEN
                        - 270 
                    ELSE
                        red_mapping.odds 
                END
                AS red_odds, 
                CASE
                    WHEN
                        bout_id = 'dcc0c53100fa1dd2' 
                    THEN
                        222 
                    ELSE
                        blue_mapping.odds 
                END
                AS blue_odds 
            FROM
                cte1 
                LEFT JOIN
                    cte4 AS red_mapping 
                    ON cte1.fightoddsio_bout_id = red_mapping.fightoddsio_bout_id 
                    AND cte1.red_fighter_id = red_mapping.fightoddsio_fighter_id 
                LEFT JOIN
                    cte4 AS blue_mapping 
                    ON cte1.fightoddsio_bout_id = blue_mapping.fightoddsio_bout_id 
                    AND cte1.blue_fighter_id = blue_mapping.fightoddsio_fighter_id;
            """

            backtest_odds = pd.read_sql(backtest_odds_query, self.engine)
            backtest_odds["red_win"] = backtest_odds["red_win"].astype("Int64")
            backtest_odds.to_csv(backtest_odds_path, index=False)

    def __call__(self) -> None:
        self.create_backtest_data()


if __name__ == "__main__":
    backtest_framework = BacktestFramework()
    backtest_framework()
