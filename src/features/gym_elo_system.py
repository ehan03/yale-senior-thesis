# standard library imports
import os
import sqlite3

# third party imports
import numpy as np
import pandas as pd

# local imports


class GymEloSystem:
    def __init__(self, k_factor: int = 100) -> None:
        self.data_dir = os.path.join(os.path.dirname("__file__"), "..", "..", "data")
        self.db_path = os.path.join(self.data_dir, "ufc.db")
        self.misc_db_path = os.path.join(self.data_dir, "misc.db")

        self.k_factor = k_factor
        self.elo_ratings = {}

    def create_misc_db(self) -> None:
        with sqlite3.connect(self.misc_db_path) as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS gym_elo_ratings (
                    bout_id TEXT PRIMARY KEY,
                    event_id TEXT NOT NULL,
                    red_outcome TEXT NOT NULL,
                    red_gym_id TEXT,
                    blue_gym_id TEXT,
                    red_gym_elo REAL,
                    blue_gym_elo REAL           
                );
            """
            )
            conn.commit()

    def get_gym_matchups(self) -> pd.DataFrame:
        query = """
        WITH cte1 AS (
            SELECT
                fighter_id,
                bout_id,
                CASE
                    WHEN gym_id IS NOT NULL THEN gym_id
                    ELSE gym_name
                END AS gym_id,
                ROW_NUMBER() OVER (PARTITION BY fighter_id, bout_id ORDER BY t1.rowid) AS gym_rank
            FROM
                tapology_fighter_gyms t1
            WHERE
                gym_purpose = 'Primary'
        ),
        cte2 AS (
            SELECT
                *,
                ROW_NUMBER() OVER (PARTITION BY fighter_id, bout_id ORDER BY gym_rank) AS primary_gym_rank
            FROM
                cte1 AS t1
        ),
        cte3 AS (
            SELECT
                *
            FROM cte2
            WHERE primary_gym_rank = 1
        ),
        cte4 AS (
            SELECT
                t1.fighter_id,
                t1.bout_id,
                CASE
                    WHEN t1.gym_id IS NOT NULL THEN t1.gym_id
                    ELSE t1.gym_name
                END AS gym_id,
                COUNT(t1.gym_name) OVER (PARTITION BY t1.fighter_id, t1.bout_id) AS gym_count,
                ROW_NUMBER() OVER (PARTITION BY t1.fighter_id, t1.bout_id ORDER BY t1.rowid) AS gym_rank
            FROM
                tapology_fighter_gyms AS t1
        ),
        cte5 AS (
            SELECT
                t1.fighter_id,
                t1.bout_id,
                t1.gym_id,
                t1.gym_count,
                t1.gym_rank,
                CASE
                    WHEN t2.fighter_id IS NOT NULL AND t2.bout_id IS NOT NULL THEN 1
                    ELSE 0
                END AS has_primary_flag,
                t3.primary_gym_rank
            FROM
                cte4 AS t1
            LEFT JOIN cte3 AS t2 ON t1.fighter_id = t2.fighter_id AND t1.bout_id = t2.bout_id
            LEFT JOIN cte3 AS t3 ON t1.fighter_id = t3.fighter_id AND t1.bout_id = t3.bout_id AND t1.gym_id = t3.gym_id
        ),
        cte6 AS (
            SELECT
                fighter_id,
                bout_id,
                gym_id
            FROM
                cte5
            WHERE
                gym_count = 1
            UNION
            SELECT
                fighter_id,
                bout_id,
                gym_id
            FROM
                cte5
            WHERE
                gym_count > 1 AND has_primary_flag = 1 AND primary_gym_rank = 1
            UNION
            SELECT
                fighter_id,
                bout_id,
                gym_id
            FROM
                cte5
            WHERE
                gym_count > 1 AND has_primary_flag = 0 AND gym_rank = 1
        ),
        fighter_gyms AS (
            SELECT
                t2.ufcstats_id AS fighter_id,
                t3.ufcstats_id AS bout_id,
                CASE
                    WHEN t4.parent_id IS NOT NULL THEN t4.parent_id
                    ELSE t1.gym_id
                END AS gym_id
            FROM
                cte6 AS t1
            INNER JOIN fighter_mapping AS t2 ON t1.fighter_id = t2.tapology_id
            INNER JOIN bout_mapping AS t3 ON t1.bout_id = t3.tapology_id
            LEFT JOIN tapology_gyms AS t4 ON t1.gym_id = t4.id
        )
        SELECT
            t1.id AS bout_id,
            t1.event_id,
            t1.red_outcome,
            t3.gym_id AS red_gym_id,
            t4.gym_id AS blue_gym_id
        FROM
            ufcstats_bouts AS t1
        INNER JOIN
            event_mapping AS t2 ON t1.event_id = t2.ufcstats_id
        LEFT JOIN
            fighter_gyms AS t3 ON t3.fighter_id = t1.red_fighter_id AND t3.bout_id = t1.id
        LEFT JOIN
            fighter_gyms AS t4 ON t4.fighter_id = t1.blue_fighter_id AND t4.bout_id = t1.id
        ORDER BY
            t2.wikipedia_id, t1.bout_order
        """

        with sqlite3.connect(self.db_path) as conn:
            df = pd.read_sql_query(query, conn)

        return df

    def initialize_gym(self, gym_id: str) -> None:
        if gym_id not in self.elo_ratings and gym_id is not None:
            self.elo_ratings[gym_id] = 1000.0

    def get_median_rating(self):
        if len(self.elo_ratings) == 0:
            return 1000.0

        elo_values = np.array(list(self.elo_ratings.values()))
        median_rating = np.median(elo_values)

        return median_rating

    def calculate_expected_score(self, rating_a, rating_b) -> float:
        return 1 / (1 + 10 ** ((rating_b - rating_a) / 400))

    def update_gym_rating(
        self, gym_id: str, expected_score_total, actual_score_total
    ) -> None:
        if gym_id is not None:
            self.elo_ratings[gym_id] += self.k_factor * (
                actual_score_total - expected_score_total
            )

    def simulate_event(self, event_df: pd.DataFrame) -> pd.DataFrame:
        gym_ids = set(event_df["red_gym_id"]) | set(event_df["blue_gym_id"])
        for gym_id in gym_ids:
            self.initialize_gym(gym_id)

        red_gym_elo_list = []
        blue_gym_elo_list = []

        expected_scores = {}
        actual_scores = {}
        for _, row in event_df.iterrows():
            red_gym_id = row["red_gym_id"]
            blue_gym_id = row["blue_gym_id"]
            red_outcome = row["red_outcome"]

            red_gym_elo = (
                self.elo_ratings[red_gym_id]
                if red_gym_id is not None
                else self.get_median_rating()
            )
            blue_gym_elo = (
                self.elo_ratings[blue_gym_id]
                if blue_gym_id is not None
                else self.get_median_rating()
            )
            red_gym_elo_list.append(red_gym_elo)
            blue_gym_elo_list.append(blue_gym_elo)

            if red_outcome == "NC":
                continue

            red_expected_score = self.calculate_expected_score(
                red_gym_elo, blue_gym_elo
            )
            blue_expected_score = self.calculate_expected_score(
                blue_gym_elo, red_gym_elo
            )
            red_actual_score = (
                1 if red_outcome == "W" else 0.5 if red_outcome == "D" else 0
            )
            blue_actual_score = 1 - red_actual_score

            if red_gym_id is not None:
                expected_scores[red_gym_id] = (
                    expected_scores.get(red_gym_id, 0) + red_expected_score
                )
                actual_scores[red_gym_id] = (
                    actual_scores.get(red_gym_id, 0) + red_actual_score
                )

            if blue_gym_id is not None:
                expected_scores[blue_gym_id] = (
                    expected_scores.get(blue_gym_id, 0) + blue_expected_score
                )
                actual_scores[blue_gym_id] = (
                    actual_scores.get(blue_gym_id, 0) + blue_actual_score
                )

        result_df = event_df.copy()
        result_df["red_gym_elo"] = red_gym_elo_list
        result_df["blue_gym_elo"] = blue_gym_elo_list

        assert len(expected_scores) == len(
            actual_scores
        ), "Expected and actual scores mismatch"
        for gym_id in expected_scores.keys():
            expected_score_total = expected_scores[gym_id]
            actual_score_total = actual_scores[gym_id]

            self.update_gym_rating(gym_id, expected_score_total, actual_score_total)

        return result_df

    def simulate_all_events(self, df: pd.DataFrame) -> None:
        event_ids = df["event_id"].unique()
        result_list = []
        for event_id in event_ids:
            event_df = df.loc[df["event_id"] == event_id].copy()
            result_df = self.simulate_event(event_df)
            result_list.append(result_df)

        result_df = pd.concat(result_list, ignore_index=True).reset_index(drop=True)

        with sqlite3.connect(self.misc_db_path) as conn:
            result_df.to_sql("gym_elo_ratings", conn, if_exists="replace", index=False)
            conn.commit()

    def __call__(self) -> None:
        self.create_misc_db()
        df = self.get_gym_matchups()
        self.simulate_all_events(df)


if __name__ == "__main__":
    gym_elo_system = GymEloSystem()
    gym_elo_system()
