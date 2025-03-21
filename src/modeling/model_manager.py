# standard library imports
import json
import logging
import os
import sqlite3
import sys
import warnings
from functools import partial
from typing import List

sys.path.append(os.path.join(os.path.dirname(__file__), "..", ".."))

# third party imports
import lightgbm as lgb
import pandas as pd
from sklearn.feature_selection import (
    SelectKBest,
    VarianceThreshold,
    mutual_info_classif,
)
from sklearn.linear_model import LogisticRegression
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler

from src.modeling.hyper_feature_tuner import HyperFeatureTuner

# local imports
from src.modeling.venn_abers import VennAbersCV


class ModelManager:
    def __init__(self, initial_cutoff_year: int = 2016) -> None:
        self.initial_cutoff_year = initial_cutoff_year
        self.model_names = [
            "lr",  # Logistic regression
            "lr_no_odds",  # Logistic regression without opening odds feature
            "va_lr",  # Venn-Abers calibrated logistic regression
            "va_lr_no_odds",  # Venn-Abers calibrated logistic regression without opening odds feature
            "lightgbm",  # LightGBM gradient boosting model
            "lightgbm_no_odds",  # LightGBM gradient boosting model without opening odds feature
            "va_lightgbm",  # Venn-Abers calibrated LightGBM model
            "va_lightgbm_no_odds",  # Venn-Abers calibrated LightGBM model without opening odds feature
        ]
        self.model_files_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "model_files"
        )
        self.data_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data")
        self.db_path = os.path.join(self.data_dir, "ufc.db")
        self.features_df = pd.read_pickle(
            os.path.join(self.data_dir, "features.pkl.xz"), compression="xz"
        )
        self.logger = logging.getLogger("model_manager")
        self.logger.info("ModelManager initialized")

    def get_train_bout_ids(self, cutoff_year: int) -> List[str]:
        with sqlite3.connect(self.db_path) as conn:
            df = pd.read_sql_query(
                """
                SELECT id
                FROM ufcstats_bouts
                WHERE event_id IN (
                    SELECT id
                    FROM ufcstats_events
                    WHERE is_ufc_event = 1
                        AND date >= '2008-04-19'
                        AND date <= :cutoff_date
                ) AND red_outcome IN ('W', 'L');
                """,
                conn,
                params={
                    "cutoff_date": f"{cutoff_year}-12-31",
                },
            )

        bout_ids = df["id"].tolist()

        return bout_ids

    def get_backtest_year_metadata(self, cutoff_year: int) -> pd.DataFrame:
        with sqlite3.connect(self.db_path) as conn:
            df = pd.read_sql_query(
                """
                SELECT t1.event_id, t1.id AS bout_id
                FROM ufcstats_bouts AS t1
                LEFT JOIN event_mapping AS t2 ON t1.event_id = t2.ufcstats_id
                WHERE t1.event_id IN (
                    SELECT id
                    FROM ufcstats_events
                    WHERE is_ufc_event = 1
                        AND date >= :backtest_start_date
                        AND date <= :backtest_end_date
                )
                ORDER BY t2.wikipedia_id, t1.bout_order;
                """,
                conn,
                params={
                    "backtest_start_date": f"{cutoff_year + 1}-01-01",
                    "backtest_end_date": f"{cutoff_year + 1}-12-31",
                },
            )

        return df

    def get_trainable_bouts_from_event(self, event_id: str) -> List[str]:
        with sqlite3.connect(self.db_path) as conn:
            df = pd.read_sql_query(
                """
                SELECT id
                FROM ufcstats_bouts
                WHERE event_id = :event_id
                    AND red_outcome IN ('W', 'L');
                """,
                conn,
                params={
                    "event_id": event_id,
                },
            )

        bout_ids = df["id"].tolist()

        return bout_ids

    def get_clf(self, model_name: str, best_params: dict):
        mutual_info_func = partial(mutual_info_classif, n_neighbors=5, random_state=42, n_jobs=-1)  # type: ignore

        if model_name in [
            "lr",
            "lr_no_odds",
            "va_lr",
            "va_lr_no_odds",
        ]:
            params = {
                "penalty": "l2",
                "C": best_params["C"],
                "max_iter": 300,
                "random_state": 42,
            }
            estimator = Pipeline(
                steps=[
                    ("scaler", StandardScaler()),
                    ("lr", LogisticRegression(**params)),
                ]
            )
            if model_name.startswith("va_"):
                clf = Pipeline(
                    steps=[
                        ("var_threshold", VarianceThreshold(threshold=0.05)),
                        (
                            "mutual_info",
                            SelectKBest(
                                score_func=mutual_info_func, k=best_params["k"]
                            ),
                        ),
                        (
                            "estimator",
                            VennAbersCV(
                                estimator=estimator,
                                n_splits=10,
                                random_state=492,
                                shuffle=True,
                            ),
                        ),
                    ]
                )
            else:
                clf = Pipeline(
                    steps=[
                        ("var_threshold", VarianceThreshold(threshold=0.05)),
                        (
                            "mutual_info",
                            SelectKBest(
                                score_func=mutual_info_func, k=best_params["k"]
                            ),
                        ),
                        ("estimator", estimator),
                    ]
                )
        elif model_name in [
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
                "n_estimators": best_params["n_estimators"],
                "num_leaves": best_params["num_leaves"],
                "max_depth": best_params["max_depth"],
                "min_child_samples": best_params["min_child_samples"],
                "subsample": best_params["subsample"],
                "subsample_freq": best_params["subsample_freq"],
                "colsample_bytree": best_params["colsample_bytree"],
                "reg_alpha": best_params["reg_alpha"],
                "reg_lambda": best_params["reg_lambda"],
                "random_state": 42,
            }
            estimator = lgb.LGBMClassifier(verbosity=-1, **params)
            if model_name.startswith("va_"):
                clf = Pipeline(
                    steps=[
                        ("var_threshold", VarianceThreshold(threshold=0.05)),
                        (
                            "mutual_info",
                            SelectKBest(
                                score_func=mutual_info_func, k=best_params["k"]
                            ),
                        ),
                        (
                            "estimator",
                            VennAbersCV(
                                estimator=estimator,
                                n_splits=10,
                                random_state=492,
                                shuffle=True,
                            ),
                        ),
                    ]
                )
            else:
                clf = Pipeline(
                    steps=[
                        ("var_threshold", VarianceThreshold(threshold=0.05)),
                        (
                            "mutual_info",
                            SelectKBest(
                                score_func=mutual_info_func, k=best_params["k"]
                            ),
                        ),
                        ("estimator", estimator),
                    ]
                )
        else:
            raise ValueError(f"Model {model_name} not recognized.")

        return clf

    def run_train_inference_pipeline(self, model_name: str) -> None:
        tuning_results = []
        predictions = []

        with warnings.catch_warnings():
            # Suppress warnings from LightGBM
            warnings.simplefilter("ignore", category=UserWarning)

            # Suppress warnings from Venn-Abers
            warnings.simplefilter("ignore", category=RuntimeWarning)

            for cutoff_year in range(self.initial_cutoff_year, 2024):
                self.logger.info(f"Optimizing model on data up to end of {cutoff_year}")

                # Get training data
                train_bout_ids = self.get_train_bout_ids(cutoff_year)
                train_df: pd.DataFrame = self.features_df.loc[
                    self.features_df["id"].isin(train_bout_ids)
                ]
                train_df = train_df.drop(columns=["id"])

                X_train = train_df.drop(columns=["red_win"])
                y_train = train_df["red_win"]

                if "no_odds" in model_name:
                    X_train = X_train.drop(
                        columns=["mean_devigged_opening_implied_prob_diff"]
                    )

                # Run hyperparameter tuning and feature selection
                tuner = HyperFeatureTuner(
                    model_name=model_name,
                    X_train=X_train,
                    y_train=y_train,
                    training_cutoff_year=cutoff_year,
                )
                best_params, best_score = (
                    tuner.optimize_hyperparameters_and_select_features()
                )

                # Parse best parameters and selected features
                tuning_results.append(
                    {
                        "cutoff_year": cutoff_year,
                        "best_params": best_params,
                        "log_loss": best_score,
                    }
                )

                # Get classifier
                clf = self.get_clf(model_name, best_params)

                # Get backtest data
                meta_df = self.get_backtest_year_metadata(cutoff_year)
                event_ids = meta_df["event_id"].unique().tolist()
                for event_id in event_ids:
                    self.logger.info(
                        f"Refitting model and predicting for event {event_id}"
                    )

                    # Train on all bouts (that ended in a win or loss) prior to the event
                    clf.fit(X_train, y_train.to_numpy(copy=True))

                    # Bout ids to predict on
                    bout_ids_to_predict = meta_df.loc[
                        meta_df["event_id"] == event_id, "bout_id"
                    ]
                    inference_df: pd.DataFrame = self.features_df.loc[
                        self.features_df["id"].isin(bout_ids_to_predict)
                    ]
                    inference_df = inference_df.drop(columns=["id"])

                    X_inference = inference_df.drop(columns=["red_win"])

                    if "no_odds" in model_name:
                        X_inference = X_inference.drop(
                            columns=["mean_devigged_opening_implied_prob_diff"]
                        )

                    # Predict on the inference data
                    if model_name.startswith("va_"):
                        y_pred, p0_p1 = clf.predict_proba(
                            X_inference, p0_p1_output=True
                        )
                        predictions.append(
                            pd.DataFrame.from_dict(
                                {
                                    "bout_id": bout_ids_to_predict,
                                    "y_pred": y_pred[:, 1],
                                    "y_pred_low": p0_p1[:, 0],
                                    "y_pred_high": p0_p1[:, 1],
                                }
                            )
                        )
                    else:
                        y_pred = clf.predict_proba(X_inference)
                        predictions.append(
                            pd.DataFrame.from_dict(
                                {
                                    "bout_id": bout_ids_to_predict,
                                    "y_pred": y_pred[:, 1],
                                }
                            )
                        )

                    # Append new fights to training data for next iteration
                    new_bout_ids = self.get_trainable_bouts_from_event(event_id)
                    new_train_df: pd.DataFrame = self.features_df.loc[
                        self.features_df["id"].isin(new_bout_ids)
                    ]
                    new_train_df = new_train_df.drop(columns=["id"])
                    X_new_train = new_train_df.drop(columns=["red_win"])
                    y_new_train = new_train_df["red_win"]

                    if "no_odds" in model_name:
                        X_new_train = X_new_train.drop(
                            columns=["mean_devigged_opening_implied_prob_diff"]
                        )

                    # Append new training data to existing training data
                    X_train = pd.concat([X_train, X_new_train], ignore_index=True)
                    y_train = pd.concat([y_train, y_new_train], ignore_index=True)

        # Save tuning results to CSV
        tuning_results_df = pd.DataFrame(tuning_results)
        tuning_results_df["best_params"] = tuning_results_df["best_params"].apply(
            lambda x: json.dumps(x)
        )
        tuning_results_df.to_csv(
            os.path.join(self.model_files_path, model_name, "tuning_results.csv"),
            index=False,
        )

        # Save predictions to CSV
        predictions_df = pd.concat(predictions, ignore_index=True)
        predictions_df.to_csv(
            os.path.join(self.model_files_path, model_name, "predictions.csv"),
            index=False,
        )

        self.logger.info(f"Process completed for model {model_name}")

    def __call__(self, model_name: str) -> None:
        if model_name not in self.model_names:
            raise ValueError(f"Model {model_name} not recognized.")

        self.logger.info(f"Running training and inference for model {model_name}")
        self.run_train_inference_pipeline(model_name)
        self.logger.info(f"Completed training and inference for model {model_name}")


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

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

    model_manager = ModelManager(initial_cutoff_year=2016)
    for model_name in model_names:
        model_manager(model_name)
