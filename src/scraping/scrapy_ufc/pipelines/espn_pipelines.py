# standard library imports
import os

# third party imports
import pandas as pd

# local imports
from ..items.espn_items import (
    ESPNBoutItem,
    ESPNEventItem,
    ESPNFighterBoutStatisticsItem,
    ESPNFighterHistoryItem,
    ESPNFighterItem,
    ESPNTeamItem,
    ESPNVenueItem,
)


class ESPNEventPipeline:
    def __init__(self):
        self.events = []
        self.venues = []
        self.bouts = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "ESPN"
        )

    def process_item(self, item, spider):
        if isinstance(item, ESPNEventItem):
            self.events.append(dict(item))
        elif isinstance(item, ESPNVenueItem):
            self.venues.append(dict(item))
        elif isinstance(item, ESPNBoutItem):
            self.bouts.append(dict(item))
        return item

    def close_spider(self, spider):
        events_df = (
            pd.DataFrame(self.events)
            .sort_values(by="event_order")
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

        venues_df = (
            pd.DataFrame(self.venues)
            .drop_duplicates(subset="id")
            .sort_values(by="id")
            .reset_index(drop=True)
        )

        events_df = events_df[["id", "name", "date", "venue_id", "event_order"]]
        bouts_df = bouts_df[
            [
                "id",
                "event_id",
                "bout_order",
                "red_fighter_id",
                "blue_fighter_id",
                "winner_id",
                "card_segment",
            ]
        ]
        venues_df = venues_df[["id", "name", "city", "state", "country", "is_indoor"]]

        events_df.to_csv(os.path.join(self.dir_path, "events.csv"), index=False)
        bouts_df.to_csv(os.path.join(self.dir_path, "bouts.csv"), index=False)
        venues_df.to_csv(os.path.join(self.dir_path, "venues.csv"), index=False)


class ESPNFighterPipeline:
    def __init__(self):
        self.fighters = []
        self.fighter_histories = []
        self.fighter_bout_statistics = []
        self.teams = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "ESPN"
        )

    def process_item(self, item, spider):
        if isinstance(item, ESPNFighterItem):
            self.fighters.append(dict(item))
        elif isinstance(item, ESPNFighterHistoryItem):
            self.fighter_histories.append(dict(item))
        elif isinstance(item, ESPNFighterBoutStatisticsItem):
            self.fighter_bout_statistics.append(dict(item))
        elif isinstance(item, ESPNTeamItem):
            self.teams.append(dict(item))
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
        fighter_bout_statistics_df = (
            pd.DataFrame(self.fighter_bout_statistics)
            .sort_values(by=["fighter_id", "order"])
            .reset_index(drop=True)
        )
        teams_df = (
            pd.DataFrame(self.teams)
            .sort_values(by="id")
            .drop_duplicates(subset="id")
            .reset_index(drop=True)
        )

        fighters_df.to_csv(os.path.join(self.dir_path, "fighters.csv"), index=False)
        fighter_histories_df.to_csv(
            os.path.join(self.dir_path, "fighter_histories.csv"), index=False
        )
        fighter_bout_statistics_df.to_csv(
            os.path.join(self.dir_path, "fighter_bout_statistics.csv"), index=False
        )
        teams_df.to_csv(os.path.join(self.dir_path, "teams.csv"), index=False)
