# standard library imports
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), "..", ".."))

# third party imports
import numpy as np
import pandas as pd
from sqlalchemy import create_engine
from tqdm import tqdm

# local imports
from src.betting.kelly import DistributionalRobustKelly, SimultaneousKelly


class BetSimulator:
    def __init__(self, model_name: str, strategy: str):
        if model_name not in [
            "lr",
            "lr_no_odds",
            "va_lr",
            "va_lr_no_odds",
            "lightgbm",
            "lightgbm_no_odds",
            "va_lightgbm",
            "va_lightgbm_no_odds",
        ]:
            raise ValueError(f"Invalid model name: {model_name}")

        if strategy not in ["simultaneous", "distributional_robust"]:
            raise ValueError(f"Invalid strategy: {strategy}")
        if not model_name.startswith("va_") and strategy == "distributional_robust":
            raise ValueError(
                f"Distributional robust strategy is only available for Venn-Abers calibrated model pipelines"
            )

        self.model_name = model_name
        self.strategy = strategy

        self.data_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data")
        self.db_string = f"sqlite:///{os.path.join(self.data_dir, 'ufc.db')}"
        self.engine = create_engine(self.db_string)

        self.backtest_odds_path = os.path.join(
            self.data_dir, "backtesting", "backtest_odds.csv"
        )

        self.model_files_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "model_files"
        )

    def get_historical_odds(self) -> None:
        if not os.path.exists(self.backtest_odds_path):
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
            backtest_odds.to_csv(self.backtest_odds_path, index=False)

    def convert_american_to_decimal(self, odds: np.ndarray) -> np.ndarray:
        return np.where(odds > 0, 1 + odds / 100, 1 - 1 / odds)

    def calculate_kelly_proportions(self) -> None:
        backtest_odds = pd.read_csv(self.backtest_odds_path)
        model_preds = pd.read_csv(
            os.path.join(self.model_files_path, self.model_name, "predictions.csv")
        )

        assert backtest_odds["bout_id"].equals(
            model_preds["bout_id"]
        ), "Bout IDs do not match"

        bet_props = []
        event_ids = backtest_odds["event_id"].unique()
        for event_id in tqdm(event_ids):
            event_data = backtest_odds.loc[backtest_odds["event_id"] == event_id]
            red_odds = self.convert_american_to_decimal(event_data["red_odds"].values)
            blue_odds = self.convert_american_to_decimal(event_data["blue_odds"].values)

            bout_ids = event_data["bout_id"].values
            event_preds = model_preds.loc[model_preds["bout_id"].isin(bout_ids)]

            if self.strategy == "simultaneous":
                red_probs = event_preds["y_pred"].values
                assert isinstance(red_probs, np.ndarray)
                blue_probs = 1 - red_probs

                simultaneous_kelly = SimultaneousKelly(
                    red_probs=red_probs,
                    blue_probs=blue_probs,
                    red_odds=red_odds,
                    blue_odds=blue_odds,
                )
                red_proportions, blue_proportions = simultaneous_kelly()
            elif self.strategy == "distributional_robust":
                p0_p1 = event_preds[["y_pred_low", "y_pred_high"]].values

                distributional_robust_kelly = DistributionalRobustKelly(
                    p0_p1=p0_p1, red_odds=red_odds, blue_odds=blue_odds
                )
                red_proportions, blue_proportions = distributional_robust_kelly()

            for bout_id, red_prop, blue_prop in zip(
                bout_ids, red_proportions, blue_proportions
            ):
                bet_props.append(
                    {
                        "bout_id": bout_id,
                        "event_id": event_id,
                        "red_bet_proportion": red_prop,
                        "blue_bet_proportion": blue_prop,
                    }
                )

        bet_props_df = pd.DataFrame(bet_props)
        bet_props_df.to_csv(
            os.path.join(
                self.model_files_path,
                self.model_name,
                f"kelly_{self.strategy}_bet_proportions.csv",
            ),
            index=False,
        )

    def __call__(self) -> None:
        self.get_historical_odds()
        self.calculate_kelly_proportions()


if __name__ == "__main__":
    model_name = sys.argv[1]
    strategy = sys.argv[2]
    bet_simulator = BetSimulator(model_name, strategy)
    bet_simulator()
