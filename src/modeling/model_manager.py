# standard library imports
import functools
import warnings

# third party imports
import lightgbm as lgb
import numpy as np
import optuna
import pandas as pd
from optuna.visualization import plot_optimization_history
from sklearn.feature_selection import (
    SelectKBest,
    VarianceThreshold,
    mutual_info_classif,
)
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import log_loss
from sklearn.model_selection import StratifiedKFold, cross_val_score
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

# local imports


class ModelManager:
    def __init__(self, initial_year_cutoff: int = 2019) -> None:
        self.initial_year_cutoff = initial_year_cutoff
        self.model_names = [
            "logistic_regression",
            "logistic_regression_no_odds",
            "va_logistic_regression",
            "va_logistic_regression_no_odds",
            "lightgbm",
            "lightgbm_no_odds",
            "va_lightgbm",
            "va_lightgbm_no_odds",
        ]
