# standard library imports
import os

# third party imports
import pandas as pd

# local imports
from ..items.espn_items import ESPNBoutItem, ESPNEventItem, ESPNVenueItem


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
