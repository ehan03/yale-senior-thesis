# standard library imports
import itertools
import warnings
from typing import Tuple

# third party imports
import cvxpy as cp
import numpy as np
import scipy.sparse as sp

# local imports


class BaseKelly:
    def __init__(
        self,
        red_odds: np.ndarray,
        blue_odds: np.ndarray,
    ) -> None:
        self.red_odds = red_odds
        self.blue_odds = blue_odds

        assert len(red_odds) == len(blue_odds)
        self.n = len(red_odds)
        self.variations = np.array(list(itertools.product([1, 0], repeat=self.n)))

        self.no_bet = np.identity(2 * self.n + 1)[-1]

    def create_variations(self) -> np.ndarray:
        n = len(self.red_odds)

        return np.array(list(itertools.product([1, 0], repeat=n)))

    def create_returns_matrix(self) -> np.ndarray:
        R = np.zeros(shape=(2 * self.n + 1, self.variations.shape[0]))
        R[-1, :] = 1
        for j in range(self.n):
            R[2 * j, :] = np.where(self.variations[:, j] == 1, self.red_odds[j], 0)
            R[2 * j + 1, :] = np.where(self.variations[:, j] == 0, self.blue_odds[j], 0)

        return R

    def calculate_optimal_wagers(self) -> np.ndarray:
        raise NotImplementedError

    def __call__(self) -> Tuple[np.ndarray, np.ndarray]:
        proportions = self.calculate_optimal_wagers()
        proportions = np.where(proportions < 1e-6, 0, proportions)
        proportions = proportions[:-1]
        red_proportions, blue_proportions = proportions[::2], proportions[1::2]

        return red_proportions, blue_proportions


class SimultaneousKelly(BaseKelly):
    def __init__(
        self,
        red_probs: np.ndarray,
        blue_probs: np.ndarray,
        red_odds: np.ndarray,
        blue_odds: np.ndarray,
    ) -> None:
        super().__init__(red_odds, blue_odds)

        self.red_probs = red_probs
        self.blue_probs = blue_probs

    def create_probabilities_vector(self) -> np.ndarray:
        prob_vector = np.ones(shape=(1, self.variations.shape[0]))
        for j in range(self.n):
            prob_vector[0, :] = np.where(
                self.variations[:, j] == 1,
                prob_vector * self.red_probs[j],
                prob_vector * self.blue_probs[j],
            )

        return prob_vector

    def calculate_optimal_wagers(self) -> np.ndarray:
        R = self.create_returns_matrix()
        p = self.create_probabilities_vector()
        b = cp.Variable(2 * self.n + 1)

        objective = cp.Maximize(p @ cp.log(R.T @ b))
        constraints = [
            b >= 0,
            cp.sum(b) == 1,
        ]
        problem = cp.Problem(objective, constraints)
        try:
            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                problem.solve(solver=cp.CLARABEL)
                return b.value
        except:
            return self.no_bet


class DistributionalRobustKelly(BaseKelly):
    def __init__(
        self,
        p0_p1: np.ndarray,
        red_odds: np.ndarray,
        blue_odds: np.ndarray,
    ) -> None:
        super().__init__(red_odds, blue_odds)

        self.p0_p1 = p0_p1

    def get_inequality_constraints(self) -> Tuple:
        id_ = sp.identity(self.variations.shape[0], format="csr")
        A = sp.vstack((-id_, id_), format="csr")

        pi_l = np.ones(self.variations.shape[0])
        for j in range(self.n):
            pi_l = np.where(
                self.variations[:, j] == 1,
                pi_l * self.p0_p1[j, 0],
                pi_l * (1 - self.p0_p1[j, 1]),
            )

        pi_h = np.ones(self.variations.shape[0])
        for j in range(self.n):
            pi_h = np.where(
                self.variations[:, j] == 1,
                pi_h * self.p0_p1[j, 1],
                pi_h * (1 - self.p0_p1[j, 0]),
            )

        c = np.concatenate((-pi_l, pi_h))

        return A, c

    def calculate_optimal_wagers(self) -> np.ndarray:
        R = self.create_returns_matrix()
        b = cp.Variable(2 * self.n + 1)
        lmbda = cp.Variable(2 * self.variations.shape[0])
        A, c = self.get_inequality_constraints()

        wc_growth_rate = cp.min(cp.log(R.T @ b) + A.T @ lmbda) - c.T @ lmbda

        objective = cp.Maximize(wc_growth_rate)
        constraints = [
            cp.sum(b) == 1,
            b >= 0,
            lmbda >= 0,
        ]
        problem = cp.Problem(objective, constraints)

        try:
            with warnings.catch_warnings():
                warnings.simplefilter("ignore")
                problem.solve()
                return b.value
        except:
            return self.no_bet
