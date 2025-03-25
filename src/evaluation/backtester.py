# standard library imports

# third party imports
import numpy as np
import pandas as pd

# local imports


class Backtester:
    def __init__(
        self,
        bet_info_df: pd.DataFrame,
        kelly_fraction: float,
        initial_bankroll: float = 1000.0,
        min_bet: float = 0.50,
    ) -> None:
        self.bet_info_df = bet_info_df
        self.kelly_fraction = kelly_fraction
        self.initial_bankroll = initial_bankroll
        self.min_bet = min_bet

    def calculate_return(
        self,
        red_wagers: np.ndarray,
        blue_wagers: np.ndarray,
        red_odds: np.ndarray,
        blue_odds: np.ndarray,
        red_win: np.ndarray,
    ):
        red_return = np.where(
            np.isnan(red_win), red_wagers, red_wagers * red_odds * red_win
        )
        blue_return = np.where(
            np.isnan(red_win), blue_wagers, blue_wagers * blue_odds * (1 - red_win)
        )

        return np.round(np.sum(red_return + blue_return), 2)

    def run(self) -> pd.DataFrame:
        event_ids = self.bet_info_df["event_id"].unique()

        current_bankroll = self.initial_bankroll
        cumulative_bets = 0
        cumulative_wagered = 0.0
        cumulative_return = 0.0
        backtest_results = []

        for event_id in event_ids:
            event_df = self.bet_info_df.loc[self.bet_info_df["event_id"] == event_id]

            red_wagers = (
                event_df["red_bet_proportion"].values
                * current_bankroll
                * self.kelly_fraction
            )
            red_wagers = np.where(
                (red_wagers > 0) & (red_wagers < self.min_bet), 0, red_wagers
            )
            red_wagers = np.round(red_wagers, 2)

            blue_wagers = (
                event_df["blue_bet_proportion"].values
                * current_bankroll
                * self.kelly_fraction
            )
            blue_wagers = np.where(
                (blue_wagers > 0) & (blue_wagers < self.min_bet), 0, blue_wagers
            )
            blue_wagers = np.round(blue_wagers, 2)

            n_bets = np.count_nonzero(red_wagers) + np.count_nonzero(blue_wagers)
            total_wagered = np.round(np.sum(red_wagers) + np.sum(blue_wagers), 2)

            total_return = self.calculate_return(
                red_wagers=red_wagers,
                blue_wagers=blue_wagers,
                red_odds=event_df["red_odds"].values,
                blue_odds=event_df["blue_odds"].values,
                red_win=event_df["red_win"].values,
            )

            current_bankroll = np.round(
                current_bankroll + total_return - total_wagered, 2
            )
            cumulative_bets = np.round(cumulative_bets + n_bets, 2)
            cumulative_wagered = np.round(cumulative_wagered + total_wagered, 2)
            cumulative_return = np.round(cumulative_return + total_return, 2)

            backtest_results.append(
                {
                    "event_id": event_id,
                    "bankroll": current_bankroll,
                    "cumulative_bets": cumulative_bets,
                    "cumulative_wagered": cumulative_wagered,
                    "cumulative_return": cumulative_return,
                }
            )

        backtest_results_df = pd.DataFrame(backtest_results)

        return backtest_results_df
