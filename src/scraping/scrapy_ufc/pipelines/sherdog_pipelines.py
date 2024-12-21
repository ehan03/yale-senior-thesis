# standard library imports
import os

# third party imports
import pandas as pd

# local imports
from ..items.sherdog_items import (
    SherdogBoutItem,
    SherdogEventItem,
    SherdogFighterHistoryItem,
    SherdogFighterItem,
)


class SherdogItemPipeline:
    def __init__(self):
        self.fighters = []
        self.fighter_histories = []
        self.events = []
        self.bouts = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "Sherdog"
        )

    def process_item(self, item, spider):
        if isinstance(item, SherdogFighterItem):
            self.fighters.append(dict(item))
        elif isinstance(item, SherdogFighterHistoryItem):
            self.fighter_histories.append(dict(item))
        elif isinstance(item, SherdogEventItem):
            self.events.append(dict(item))
        elif isinstance(item, SherdogBoutItem):
            self.bouts.append(dict(item))
        return item

    def close_spider(self, spider):
        fighters_df = (
            pd.DataFrame(self.fighters).sort_values(by="id").reset_index(drop=True)
        )

        fighter_histories_df = (
            pd.DataFrame(self.fighter_histories)
            .sort_values(by=["fighter_id", "order"])
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
                "name",
                "nickname",
                "height_inches",
                "date_of_birth",
                "nationality",
                "pro_debut_date",
            ]
        ]
        fighter_histories_df = fighter_histories_df[
            [
                "fighter_id",
                "order",
                "event_id",
                "date",
                "opponent_id",
                "outcome",
                "outcome_method",
                "end_round",
                "end_round_time",
            ]
        ]
        events_df = events_df[
            ["id", "name", "date", "location", "country", "is_ufc_event", "event_order"]
        ]
        bouts_df = bouts_df[
            [
                "event_id",
                "bout_order",
                "fighter_1_id",
                "fighter_2_id",
                "fighter_1_outcome",
                "fighter_2_outcome",
                "is_title_bout",
                "weight_class",
                "outcome_method",
                "end_round",
                "end_round_time",
            ]
        ]

        fighters_df.to_csv(os.path.join(self.dir_path, "fighters.csv"), index=False)
        fighter_histories_df.to_csv(
            os.path.join(self.dir_path, "fighter_histories.csv"), index=False
        )
        events_df.to_csv(os.path.join(self.dir_path, "events.csv"), index=False)
        bouts_df.to_csv(os.path.join(self.dir_path, "bouts.csv"), index=False)
