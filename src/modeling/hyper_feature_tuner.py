# standard library imports
import os
import sys
import warnings
from functools import partial

sys.path.append(os.path.join(os.path.dirname(__file__), "..", ".."))

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
from sklearn.model_selection import StratifiedKFold
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

# local imports
from src.modeling.venn_abers import VennAbersCV


class HyperFeatureTuner:
    def __init__(
        self,
        model_name: str,
        X_train: pd.DataFrame,
        y_train: pd.Series,
        training_cutoff_year: int,
    ) -> None:
        self.model_name = model_name
        self.X_train = X_train
        self.y_train = y_train
        self.training_cutoff_year = training_cutoff_year
        self.cv = StratifiedKFold(n_splits=10, shuffle=True, random_state=42)

    def pre_compute_mutual_info(self, X_train: pd.DataFrame, y_train: pd.Series):
        mi_dict = {}
        for fold_idx, (train_idx, _) in enumerate(self.cv.split(X_train, y_train)):
            X_train_fold = X_train.iloc[train_idx]
            y_train_fold = y_train.iloc[train_idx]

            var_threshold = VarianceThreshold(threshold=0.05)
            X_train_fold = var_threshold.fit_transform(X_train_fold)

            mi_scores = mutual_info_classif(
                X=X_train_fold,
                y=y_train_fold,
                n_neighbors=5,
                random_state=42,
                n_jobs=-1,  # type: ignore
            )

            mi_dict[fold_idx] = mi_scores

        return mi_dict

    def get_objective_function(self):

        def objective(trial, X_train: pd.DataFrame, y_train: pd.Series, mi_dict: dict):
            k = trial.suggest_int("k", 10, 100)

            if self.model_name in [
                "lr",
                "lr_no_odds",
                "va_lr",
                "va_lr_no_odds",
            ]:
                params = {
                    "penalty": "l2",
                    "C": trial.suggest_float("C", 1e-4, 1e2, log=True),
                    "max_iter": 300,
                    "random_state": 42,
                }
                estimator = Pipeline(
                    steps=[
                        ("scaler", StandardScaler()),
                        ("lr", LogisticRegression(**params)),
                    ]
                )
                if self.model_name.startswith("va_"):
                    clf = VennAbersCV(
                        estimator=estimator,
                        n_splits=10,
                        random_state=492,
                        shuffle=True,
                    )
                else:
                    clf = estimator
            elif self.model_name in [
                "lightgbm",
                "lightgbm_no_odds",
                "va_lightgbm",
                "va_lightgbm_no_odds",
            ]:
                params = {
                    "objective": "binary",
                    "metric": "binary_logloss",
                    "boosting_type": "gbdt",
                    "learning_rate": 0.005,
                    "n_estimators": trial.suggest_int("n_estimators", 100, 1000),
                    "num_leaves": trial.suggest_int("num_leaves", 8, 32),
                    "max_depth": trial.suggest_int("max_depth", 3, 6),
                    "min_child_samples": trial.suggest_int(
                        "min_child_samples", 100, 300
                    ),
                    "subsample": trial.suggest_float("subsample", 0.4, 1.0),
                    "subsample_freq": trial.suggest_int("subsample_freq", 0, 10),
                    "colsample_bytree": trial.suggest_float(
                        "colsample_bytree", 0.4, 1.0
                    ),
                    "reg_alpha": trial.suggest_float("reg_alpha", 1e-3, 10.0, log=True),
                    "reg_lambda": trial.suggest_float(
                        "reg_lambda", 1e-3, 10.0, log=True
                    ),
                    "random_state": 42,
                }
                estimator = lgb.LGBMClassifier(verbosity=-1, **params)
                if self.model_name.startswith("va_"):
                    clf = VennAbersCV(
                        estimator=estimator,
                        n_splits=10,
                        random_state=492,
                        shuffle=True,
                    )
                else:
                    clf = estimator
            else:
                raise ValueError(f"Model {self.model_name} not recognized.")

            # Create dummy mutual information function that just returns precomputed scores
            # Thank you sklearn for not caching the results of mutual_info_classif (sarcasm)
            def fake_mutual_info_classif(X, y, fold_idx, mi_dict):
                return mi_dict[fold_idx]

            cv_scores = []
            for fold_idx, (train_idx, val_idx) in enumerate(
                self.cv.split(X_train, y_train)
            ):
                X_train_fold, y_train_fold = (
                    X_train.iloc[train_idx].to_numpy(),
                    y_train.iloc[train_idx].to_numpy(),
                )
                X_val_fold, y_val_fold = (
                    X_train.iloc[val_idx].to_numpy(),
                    y_train.iloc[val_idx].to_numpy(),
                )

                var_threshold = VarianceThreshold(threshold=0.05)
                X_train_fold = var_threshold.fit_transform(X_train_fold)

                mutual_info_func = partial(
                    fake_mutual_info_classif, fold_idx=fold_idx, mi_dict=mi_dict
                )
                selector = SelectKBest(mutual_info_func, k=k)
                X_train_fold_selected = selector.fit_transform(
                    X_train_fold, y_train_fold
                )
                clf.fit(X_train_fold_selected, y_train_fold)

                X_val_fold = var_threshold.transform(X_val_fold)
                X_val_fold_selected = selector.transform(X_val_fold)
                y_val_fold_pred = clf.predict_proba(X_val_fold_selected)

                loss = log_loss(y_val_fold, y_val_fold_pred)  # type: ignore
                cv_scores.append(loss)

            return np.mean(cv_scores)

        # Make local copies of X_train and y_train to avoid modifying the original data
        X_train = self.X_train.copy()
        y_train = self.y_train.copy()

        # Pre-compute mutual information scores for each fold
        mi_dict = self.pre_compute_mutual_info(X_train, y_train)

        return partial(objective, X_train=X_train, y_train=y_train, mi_dict=mi_dict)

    def optimize_hyperparameters_and_select_features(self):
        objective_function = self.get_objective_function()

        sampler = optuna.samplers.TPESampler(seed=42)
        study = optuna.create_study(direction="minimize", sampler=sampler)

        with warnings.catch_warnings():
            # Suppress warnings from LightGBM
            warnings.simplefilter("ignore", category=UserWarning)

            # Suppress warnings from Venn-Abers
            warnings.simplefilter("ignore", category=RuntimeWarning)

            study.optimize(objective_function, n_trials=200)  # type: ignore

        # Plot the optimization history and save it to a file
        opt_history = plot_optimization_history(study)
        fig_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "..",
            "..",
            "figures",
            "optuna_optimization_history",
            f"{self.model_name}_{self.training_cutoff_year}.png",
        )
        opt_history.write_image(fig_path)

        return study.best_params, study.best_value
