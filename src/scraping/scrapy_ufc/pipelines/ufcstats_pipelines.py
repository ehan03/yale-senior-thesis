# standard library imports
import os

# third party imports
import pandas as pd

# local imports
from ..items.ufcstats_items import (
    UFCStatsBoutItem,
    UFCStatsEventItem,
    UFCStatsFighterHistoryItem,
    UFCStatsFighterItem,
    UFCStatsRoundStatsItem,
)


class UFCStatsItemPipeline:
    def __init__(self):
        self.fighters = []
        self.fighter_histories = []
        self.events = []
        self.bouts = []
        self.round_stats = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "UFC Stats"
        )

    def process_item(self, item, spider):
        if isinstance(item, UFCStatsFighterItem):
            self.fighters.append(dict(item))
        elif isinstance(item, UFCStatsFighterHistoryItem):
            self.fighter_histories.append(dict(item))
        elif isinstance(item, UFCStatsEventItem):
            self.events.append(dict(item))
        elif isinstance(item, UFCStatsBoutItem):
            self.bouts.append(dict(item))
        elif isinstance(item, UFCStatsRoundStatsItem):
            self.round_stats.append(dict(item))
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
        bout_ids = bouts_df["id"].values.tolist()

        round_stats_df = (
            pd.DataFrame(self.round_stats)
            .sort_values(
                by=["bout_id", "round_number"],
                key=lambda x: (
                    x if x.name != "bout_id" else x.map(lambda b: bout_ids.index(b))
                ),
            )
            .reset_index(drop=True)
        )

        fighters_df.to_csv(os.path.join(self.dir_path, "fighters.csv"), index=False)
        fighter_histories_df.to_csv(
            os.path.join(self.dir_path, "fighter_histories.csv"), index=False
        )
        events_df.to_csv(os.path.join(self.dir_path, "events.csv"), index=False)
        bouts_df.to_csv(os.path.join(self.dir_path, "bouts.csv"), index=False)
        round_stats_df.to_csv(
            os.path.join(self.dir_path, "round_stats.csv"), index=False
        )
