# standard library imports
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), "..", ".."))

# third party imports
import pandas as pd

# local imports
from src.evaluation.backtester import Backtester
from src.evaluation.monte_carlo import MonteCarloSimulator


class BacktestFramework:
    def __init__(self, model_name: str, strategy: str) -> None:
        self.model_name = model_name
        self.strategy = strategy
        self.model_files_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "model_files"
        )
        self.data_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data")

    def construct_bet_info_df(self) -> pd.DataFrame:
        bet_proportions_df = pd.read_csv(
            os.path.join(
                self.model_files_path,
                self.model_name,
                f"kelly_{self.strategy}_bet_proportions.csv",
            )
        )
        backtest_odds_df = pd.read_csv(
            os.path.join(self.data_dir, "backtesting", "backtest_odds.csv")
        )

        # Convert American to decimal
        backtest_odds_df["red_odds"] = backtest_odds_df["red_odds"].apply(
            lambda x: 1 + x / 100 if x > 0 else 1 - 100 / x
        )
        backtest_odds_df["blue_odds"] = backtest_odds_df["blue_odds"].apply(
            lambda x: 1 + x / 100 if x > 0 else 1 - 100 / x
        )

        # Merge two dataframes on bout_id and event_id
        bet_info_df = pd.merge(
            bet_proportions_df, backtest_odds_df, on=["bout_id", "event_id"]
        )

        return bet_info_df

    def run_backtests(self) -> None:
        bet_info_df = self.construct_bet_info_df()

        kelly_fractions = [0.25, 0.15, 0.10]
        for kelly_fraction in kelly_fractions:
            backtester = Backtester(
                bet_info_df=bet_info_df, kelly_fraction=kelly_fraction
            )
            results_df = backtester.run()

            results_df.to_csv(
                os.path.join(
                    self.model_files_path,
                    self.model_name,
                    f"backtest_actual_{self.strategy}_{kelly_fraction}.csv",
                ),
                index=False,
            )

            mc_simulator = MonteCarloSimulator(
                bet_info_df=bet_info_df, kelly_fraction=kelly_fraction
            )
            mc_results_df = mc_simulator.run_mc_simulations()

            mc_results_df.to_csv(
                os.path.join(
                    self.model_files_path,
                    self.model_name,
                    f"backtest_mc_{self.strategy}_{kelly_fraction}.csv",
                ),
                index=False,
            )


if __name__ == "__main__":
    model_names = [
        "lr",
        "lr_no_odds",
        "va_lr",
        "va_lr_no_odds",
        "lightgbm",
        "lightgbm_no_odds",
        "va_lightgbm",
        "va_lightgbm_no_odds",
    ]
    for model_name in model_names:
        backtest_framework = BacktestFramework(model_name, "simultaneous")
        backtest_framework.run_backtests()

        if model_name.startswith("va_"):
            backtest_framework = BacktestFramework(model_name, "distributional_robust")
            backtest_framework.run_backtests()
