# standard library imports
import multiprocessing as mp
import os
import sys
from functools import partial
from typing import Optional

sys.path.append(os.path.join(os.path.dirname(__file__), "..", ".."))

# third party imports
import numpy as np
import pandas as pd
from tqdm import tqdm

# local imports
from src.evaluation.backtester import Backtester


class MonteCarloSimulator:
    def __init__(
        self,
        bet_info_df: pd.DataFrame,
        kelly_fraction: float,
        n_simulations: int = 10000,
        n_processes: Optional[int] = None,
    ) -> None:
        self.bet_info_df = bet_info_df.drop(columns=["red_win"])
        self.kelly_fraction = kelly_fraction
        self.n_simulations = n_simulations
        self.n_processes = n_processes or mp.cpu_count()

    def calculate_implied_probs(
        self, red_odds: np.ndarray, blue_odds: np.ndarray
    ) -> np.ndarray:
        red_probs = 1 / red_odds
        blue_probs = 1 / blue_odds
        devigged_probs = red_probs / (red_probs + blue_probs)

        return devigged_probs

    def simulate_outcomes(
        self, devigged_probs: np.ndarray, random_seed: int
    ) -> np.ndarray:
        np.random.seed(random_seed)
        random_numbers = np.random.rand(len(devigged_probs))
        simulated_red_win = np.where(random_numbers < devigged_probs, 1, 0)

        return simulated_red_win

    def _run_single_simulation(self, sim_idx: int, devigged_probs: np.ndarray) -> tuple:
        simulated_red_win = self.simulate_outcomes(devigged_probs, sim_idx)
        bet_info_df_copy = self.bet_info_df.copy()
        bet_info_df_copy["red_win"] = simulated_red_win

        backtester = Backtester(
            bet_info_df=bet_info_df_copy, kelly_fraction=self.kelly_fraction
        )
        results_df = backtester.run()

        return sim_idx, results_df["bankroll"].values.tolist()

    def run_mc_simulations(self) -> pd.DataFrame:
        devigged_probs = self.calculate_implied_probs(
            self.bet_info_df["red_odds"].values,  # type: ignore
            self.bet_info_df["blue_odds"].values,  # type: ignore
        )

        event_ids = self.bet_info_df["event_id"].unique().tolist()

        # Create a dictionary to store results
        mc_results = {
            "event_id": event_ids,
        }

        # Create a partial function with fixed arguments
        worker_func = partial(
            self._run_single_simulation, devigged_probs=devigged_probs
        )

        # Create simulation indices
        sim_indices = list(range(self.n_simulations))

        # Use a process pool to parallelize simulations
        with mp.Pool(processes=self.n_processes) as pool:
            # Use tqdm to show progress
            results = list(
                tqdm(pool.imap(worker_func, sim_indices), total=self.n_simulations)
            )

        # Sort results by simulation index before adding to dictionary
        results.sort(key=lambda x: x[0])

        # Process results in order
        for sim_idx, bankroll in results:
            mc_results[f"bankroll_{sim_idx}"] = bankroll

        mc_results_df = pd.DataFrame(mc_results)
        return mc_results_df
