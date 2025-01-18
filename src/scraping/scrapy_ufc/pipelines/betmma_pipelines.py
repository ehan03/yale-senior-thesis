# standard library imports
import os

# third party imports
import pandas as pd

# local imports
from ..items.betmma_items import (
    BetMMABoutItem,
    BetMMAEventItem,
    BetMMAFighterHistoryItem,
    BetMMAFighterItem,
    BetMMALateReplacementItem,
    BetMMAMissedWeightItem,
)


class BetMMAItemPipeline:
    def __init__(self):
        self.fighters = []
        self.fighter_histories = []
        self.late_replacements = []
        self.missed_weights = []
        self.events = []
        self.bouts = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "raw", "Bet MMA"
        )

    def process_item(self, item, spider):
        if isinstance(item, BetMMAFighterItem):
            self.fighters.append(dict(item))
        elif isinstance(item, BetMMAFighterHistoryItem):
            self.fighter_histories.append(dict(item))
        elif isinstance(item, BetMMALateReplacementItem):
            self.late_replacements.append(dict(item))
        elif isinstance(item, BetMMAMissedWeightItem):
            self.missed_weights.append(dict(item))
        elif isinstance(item, BetMMAEventItem):
            self.events.append(dict(item))
        elif isinstance(item, BetMMABoutItem):
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
            .sort_values(by=["date", "temp_order"])
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
        bout_ids = bouts_df["id"].values.tolist()

        late_replacements_df = (
            pd.DataFrame(self.late_replacements)
            .sort_values(
                by="bout_id",
                key=lambda x: (
                    x if x.name != "bout_id" else x.map(lambda b: bout_ids.index(b))
                ),
            )
            .reset_index(drop=True)
        )
        missed_weights_df = (
            pd.DataFrame(self.missed_weights)
            .sort_values(
                by="bout_id",
                key=lambda x: (
                    x if x.name != "bout_id" else x.map(lambda b: bout_ids.index(b))
                ),
            )
            .reset_index(drop=True)
        )

        fighters_df = fighters_df[
            [
                "id",
                "name",
                "wikipedia_url",
                "sherdog_id",
                "ufcstats_id",
                "height",
                "reach",
                "stance",
                "nationality",
            ]
        ]
        fighter_histories_df = fighter_histories_df[
            [
                "fighter_id",
                "order",
                "bout_id",
                "opponent_id",
                "outcome",
                "outcome_method",
                "end_round",
                "end_round_time",
                "odds",
            ]
        ]
        late_replacements_df = late_replacements_df[
            ["fighter_id", "bout_id", "notice_time_days"]
        ]
        missed_weights_df = missed_weights_df[["fighter_id", "bout_id", "weight_lbs"]]
        events_df = events_df[
            ["id", "name", "date", "location", "is_ufc_event", "temp_order"]
        ]
        bouts_df = bouts_df[
            ["id", "event_id", "bout_order", "fighter_1_id", "fighter_2_id"]
        ]

        fighters_df.to_csv(os.path.join(self.dir_path, "fighters.csv"), index=False)
        fighter_histories_df.to_csv(
            os.path.join(self.dir_path, "fighter_histories.csv"), index=False
        )
        late_replacements_df.to_csv(
            os.path.join(self.dir_path, "late_replacements.csv"), index=False
        )
        missed_weights_df.to_csv(
            os.path.join(self.dir_path, "missed_weights.csv"), index=False
        )
        events_df.to_csv(os.path.join(self.dir_path, "events.csv"), index=False)
        bouts_df.to_csv(os.path.join(self.dir_path, "bouts.csv"), index=False)
