# standard library imports
import os

# third party imports
import pandas as pd

# local imports
from ..items.fightmatrix_items import (
    FightMatrixBoutItem,
    FightMatrixEventItem,
    FightMatrixFighterHistoryItem,
    FightMatrixFighterItem,
    FightMatrixRankingItem,
)


class FightMatrixMainItemPipeline:
    def __init__(self):
        self.fighters = []
        self.fighter_histories = []
        self.events = []
        self.bouts = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "Fight Matrix"
        )

    def process_item(self, item, spider):
        if isinstance(item, FightMatrixFighterItem):
            self.fighters.append(dict(item))
        elif isinstance(item, FightMatrixFighterHistoryItem):
            self.fighter_histories.append(dict(item))
        elif isinstance(item, FightMatrixEventItem):
            self.events.append(dict(item))
        elif isinstance(item, FightMatrixBoutItem):
            self.bouts.append(dict(item))
        return item

    def close_spider(self, spider):
        fighters_df = (
            pd.DataFrame(self.fighters).sort_values(by="id").reset_index(drop=True)
        )
        fighter_histories_df = (
            pd.DataFrame(self.fighter_histories)
            .sort_values(by=["fighter_id", "temp_order"])
            .reset_index(drop=True)
        )

        events_df = (
            pd.DataFrame(self.events)
            .sort_values(by=["date", "event_order"])
            .reset_index(drop=True)
        )
        event_ids = events_df["id"].values.tolist()

        bouts_df = (
            pd.DataFrame(self.bouts)
            .sort_values(
                by=["event_id", "bout_order"],
                key=lambda x: (
                    x if x.name != "event_id" else x.map(lambda e: event_ids.index(e))
                ),
            )
            .reset_index(drop=True)
        )

        # Reorder columns
        fighters_df = fighters_df[
            [
                "id",
                "sherdog_id",
                "tapology_id",
                "name",
                "pro_debut_date",
                "ufc_debut_date",
            ]
        ]
        fighter_histories_df = fighter_histories_df[
            [
                "fighter_id",
                "temp_order",
                "bad_ordering_flag",
                "event_id",
                "date",
                "opponent_id",
                "outcome",
                "outcome_method",
                "end_round",
                "fighter_elo_k170_pre",
                "fighter_elo_k170_post",
                "fighter_elo_modified_pre",
                "fighter_elo_modified_post",
                "fighter_glicko_1_pre",
                "fighter_glicko_1_post",
                "opponent_elo_k170_pre",
                "opponent_elo_k170_post",
                "opponent_elo_modified_pre",
                "opponent_elo_modified_post",
                "opponent_glicko_1_pre",
                "opponent_glicko_1_post",
            ]
        ]
        events_df = events_df[
            [
                "id",
                "name",
                "promotion",
                "date",
                "country",
                "is_ufc_event",
                "event_order",
            ]
        ]
        bouts_df = bouts_df[
            [
                "event_id",
                "bout_order",
                "fighter_1_id",
                "fighter_2_id",
                "fighter_1_outcome",
                "fighter_2_outcome",
                "fighter_1_elo_k170_pre",
                "fighter_1_elo_k170_post",
                "fighter_1_elo_modified_pre",
                "fighter_1_elo_modified_post",
                "fighter_1_glicko_1_pre",
                "fighter_1_glicko_1_post",
                "fighter_2_elo_k170_pre",
                "fighter_2_elo_k170_post",
                "fighter_2_elo_modified_pre",
                "fighter_2_elo_modified_post",
                "fighter_2_glicko_1_pre",
                "fighter_2_glicko_1_post",
                "weight_class",
                "outcome_method",
                "end_round",
            ]
        ]

        fighters_df.to_csv(os.path.join(self.dir_path, "fighters.csv"), index=False)
        fighter_histories_df.to_csv(
            os.path.join(self.dir_path, "fighter_histories.csv"), index=False
        )
        events_df.to_csv(os.path.join(self.dir_path, "events.csv"), index=False)
        bouts_df.to_csv(os.path.join(self.dir_path, "bouts.csv"), index=False)


class FightMatrixRankingsPipeline:
    def __init__(self):
        self.rankings = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "Fight Matrix"
        )

    def process_item(self, item, spider):
        if isinstance(item, FightMatrixRankingItem):
            self.rankings.append(dict(item))
        return item

    def close_spider(self, spider):
        rankings_df = (
            pd.DataFrame(self.rankings)
            .sort_values(by=["issue_date", "weight_class", "rank"])
            .drop_duplicates()
            .reset_index(drop=True)
        )
        rankings_df = rankings_df[
            ["issue_date", "weight_class", "fighter_id", "rank", "points"]
        ]

        rankings_df.to_csv(os.path.join(self.dir_path, "rankings.csv"), index=False)
