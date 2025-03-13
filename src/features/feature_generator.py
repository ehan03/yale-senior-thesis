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
    def __init__(self):
        self.data_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data")
        self.db_path = os.path.join(self.data_dir, "ufc.db")

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

    def fill_na_diffs(self, merged_df: pd.DataFrame) -> pd.DataFrame:
        for col in merged_df.columns:
            if col.endswith("_diff"):
                merged_df[col] = merged_df[col].fillna(0)

        return merged_df

    def __call__(self) -> None:
        df_list = self.run_queries()
        merged_df = self.merge_dataframes(df_list)
        merged_df = self.fill_na_diffs(merged_df)
        merged_df.to_pickle(
            os.path.join(self.data_dir, "features.pkl.xz"), compression="xz"
        )


if __name__ == "__main__":
    feature_generator = FeatureGenerator()
    feature_generator()
