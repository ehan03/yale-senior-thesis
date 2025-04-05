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

    def get_bout_ids_both_experienced(self) -> List[str]:
        query = """
        WITH cte1 AS (
            SELECT fighter_id, t1.'order', bout_id FROM ufcstats_fighter_histories t1
            INNER JOIN bout_mapping t2 ON t1.bout_id = t2.ufcstats_id
        ),
        cte2 AS (
            SELECT fighter_id, bout_id, ROW_NUMBER() OVER (PARTITION BY fighter_id ORDER BY t1.'order') AS ufc_order FROM cte1 t1
        ),
        cte3 AS (
            SELECT
                id,
                t3.ufc_order AS red_ufc_order,
                t4.ufc_order AS blue_ufc_order
            FROM ufcstats_bouts t1
            INNER JOIN bout_mapping t2 ON t1.id = t2.ufcstats_id
            LEFT JOIN cte2 t3 ON t1.id = t3.bout_id AND t1.red_fighter_id = t3.fighter_id
            LEFT JOIN cte2 t4 ON t1.id = t4.bout_id AND t1.blue_fighter_id = t4.fighter_id
        )
        SELECT id FROM cte3 WHERE
            red_ufc_order > 1 AND blue_ufc_order > 1
        """

        with sqlite3.connect(self.db_path) as conn:
            query_res = pd.read_sql_query(query, conn)
        exp_level_bout_ids = query_res["id"].tolist()

        return exp_level_bout_ids

    def __call__(self) -> None:
        df_list = self.run_queries()
        merged_df = self.merge_dataframes(df_list)
        merged_df = self.fill_na_diffs(merged_df)
        merged_df.to_pickle(
            os.path.join(self.data_dir, "features.pkl.xz"), compression="xz"
        )

        # Case study subset
        exp_level_bout_ids = self.get_bout_ids_both_experienced()
        merged_case_study = (
            merged_df.loc[
                (merged_df["id"].isin(exp_level_bout_ids))
                & (merged_df["is_female"] == 0)
            ]
            .copy()
            .reset_index(drop=True)
        )
        merged_case_study.to_pickle(
            os.path.join(self.data_dir, "features_case_study.pkl.xz"), compression="xz"
        )


if __name__ == "__main__":
    feature_generator = FeatureGenerator()
    feature_generator()
