# standard library imports
import math
import os
import sqlite3
from functools import reduce
from typing import List, Tuple

# third party imports
import pandas as pd

# local imports


class FeatureGenerator:
    def __init__(self, split_date: str = "2021-01-01"):
        self.data_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data")
        self.db_path = os.path.join(self.data_dir, "ufc.db")
        self.split_date = split_date

    def run_queries(self) -> List[pd.DataFrame]:

        def safe_sqrt(x):
            if x is None or x < 0:
                return None

            return math.sqrt(x)

        queries_dir = os.path.join(os.path.dirname(__file__), "queries")
        df_list = []
        with sqlite3.connect(self.db_path) as conn:
            # add math functions
            conn.create_function("ACOS", 1, math.acos)
            conn.create_function("COS", 1, math.cos)
            conn.create_function("SIN", 1, math.sin)
            conn.create_function("RADIANS", 1, math.radians)
            conn.create_function("DEGREES", 1, math.degrees)
            conn.create_function("LOG", 1, math.log)
            conn.create_function("SQRT", 1, safe_sqrt)

            for filename in os.listdir(queries_dir):
                if filename.endswith(".sql"):
                    with open(os.path.join(queries_dir, filename), "r") as file:
                        query = file.read()
                        df = pd.read_sql(query, conn)
                        df_list.append(df)

        return df_list

    def merge_dataframes(self, df_list: List[pd.DataFrame]) -> pd.DataFrame:
        merged_df = reduce(
            lambda left, right: pd.merge(left, right, on=["id", "red_win"]), df_list
        )

        return merged_df

    def create_train_test_split(
        self, merged_df: pd.DataFrame
    ) -> Tuple[pd.DataFrame, pd.DataFrame]:
        with sqlite3.connect(self.db_path) as conn:
            train_indices = pd.read_sql(
                """
                SELECT id
                FROM ufcstats_bouts
                WHERE event_id IN (
                        SELECT id
                        FROM ufcstats_events
                        WHERE is_ufc_event = 1
                            AND date >= '2008-04-19'
                            AND date < :split_date
                    )
                    AND red_outcome IN ('W', 'L')
                    AND outcome_method != 'DQ';
                """,
                conn,
                params={"split_date": self.split_date},
            )["id"].values

            test_indices = pd.read_sql(
                """
                SELECT id
                FROM ufcstats_bouts
                WHERE event_id IN (
                        SELECT id
                        FROM ufcstats_events
                        WHERE is_ufc_event = 1
                            AND date >= :split_date
                );
                """,
                conn,
                params={"split_date": self.split_date},
            )["id"].values

        train_df = merged_df.loc[merged_df["id"].isin(train_indices)]
        test_df = merged_df.loc[merged_df["id"].isin(test_indices)]

        return train_df, test_df

    def __call__(self) -> None:
        """
        Run the feature generation process.
        """
        df_list = self.run_queries()
        merged_df = self.merge_dataframes(df_list)
        train_df, test_df = self.create_train_test_split(merged_df)

        # Save the dataframes to CSV files
        train_df.to_csv(os.path.join(self.data_dir, "train.csv"), index=False)
        # test_df.to_csv(os.path.join(self.data_dir, "test.csv"), index=False)


if __name__ == "__main__":
    feature_generator = FeatureGenerator()
    feature_generator()
