# standard library imports
import os

# third party imports
import pandas as pd

# local imports
from ..items.tapology_items import (
    TapologyBoutItem,
    TapologyCommunityPickItem,
    TapologyEventItem,
    TapologyFighterHistoryItem,
    TapologyFighterItem,
    TapologyGymItem,
    TapologyTempBoutItem,
    TapologyTempFighterItem,
    TapologyTempGymItem,
)


class TapologyEventItemPipeline:
    def __init__(self):
        self.events = []
        self.fighter_urls = set()
        self.bouts = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "raw", "Tapology"
        )
        self.misc_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "miscellaneous"
        )

    def process_item(self, item, spider):
        if isinstance(item, TapologyEventItem):
            self.events.append(dict(item))
        elif isinstance(item, TapologyTempFighterItem):
            self.fighter_urls.add(item["url"])
        elif isinstance(item, TapologyTempBoutItem):
            self.bouts.append(dict(item))
        return item

    def close_spider(self, spider):
        events_df = (
            pd.DataFrame(self.events)
            .sort_values(by="event_order")
            .reset_index(drop=True)
        )
        event_ids = events_df["id"].values.tolist()

        temp_bouts_df = (
            pd.DataFrame(self.bouts)
            .sort_values(
                by=["event_id", "bout_order"],
                key=lambda x: (
                    x if x.name != "event_id" else x.map(lambda e: event_ids.index(e))
                ),
            )
            .reset_index(drop=True)
        )

        events_df = events_df[
            [
                "id",
                "ufcstats_id",
                "sherdog_id",
                "bestfightodds_id",
                "ufc_id",
                "wikipedia_url",
                "name",
                "event_order",
            ]
        ]
        temp_bouts_df = temp_bouts_df[
            [
                "url",
                "event_id",
                "bout_order",
            ]
        ]

        events_df.to_csv(os.path.join(self.dir_path, "events.csv"), index=False)
        temp_bouts_df.to_csv(
            os.path.join(self.misc_path, "tapology_bout_urls.txt"),
            header=False,
            index=False,
        )

        with open(os.path.join(self.misc_path, "tapology_fighter_urls.txt"), "w") as f:
            for url in sorted(self.fighter_urls):
                f.write(url + "\n")


class TapologyFighterItemPipeline:
    def __init__(self):
        self.fighters = []
        self.fighter_histories = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "raw", "Tapology"
        )

    def process_item(self, item, spider):
        if isinstance(item, TapologyFighterItem):
            self.fighters.append(dict(item))
        elif isinstance(item, TapologyFighterHistoryItem):
            self.fighter_histories.append(dict(item))
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

        fighters_df = fighters_df[
            [
                "id",
                "ufcstats_id",
                "sherdog_id",
                "bestfightodds_id",
                "ufc_id",
                "wikipedia_url",
                "name",
                "nickname",
                "date_of_birth",
                "height",
                "reach",
                "nationality",
                "birth_location",
            ]
        ]
        fighter_histories_df = fighter_histories_df[
            [
                "fighter_id",
                "order",
                "bout_id",
                "bout_id_int",
                "event_id",
                "event_name",
                "opponent_id",
                "billing",
                "round_time_format",
                "weight_class",
                "outcome",
                "outcome_details",
                "weight",
                "odds",
                "pick_em",
                "fighter_record",
                "opponent_record",
            ]
        ]

        if os.path.exists(os.path.join(self.dir_path, "fighters.csv")):
            old_fighters_df = pd.read_csv(os.path.join(self.dir_path, "fighters.csv"))
            fighters_df = pd.concat(
                [old_fighters_df, fighters_df], axis=0, ignore_index=True
            ).drop_duplicates(subset=["id"], keep="last")
            fighters_df = fighters_df.sort_values(by="id").reset_index(drop=True)
        if os.path.exists(os.path.join(self.dir_path, "fighter_histories.csv")):
            old_fighter_histories_df = pd.read_csv(
                os.path.join(self.dir_path, "fighter_histories.csv")
            )
            fighter_histories_df = pd.concat(
                [old_fighter_histories_df, fighter_histories_df],
                axis=0,
                ignore_index=True,
            ).drop_duplicates(subset=["fighter_id", "order"], keep="last")
            fighter_histories_df = fighter_histories_df.sort_values(
                by=["fighter_id", "order"]
            ).reset_index(drop=True)

        fighters_df.to_csv(os.path.join(self.dir_path, "fighters.csv"), index=False)
        fighter_histories_df.to_csv(
            os.path.join(self.dir_path, "fighter_histories.csv"), index=False
        )


class TapologyBoutItemPipeline:
    def __init__(self):
        self.bouts = []
        self.community_picks = []
        self.gym_urls = set()

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "raw", "Tapology"
        )
        self.misc_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "miscellaneous"
        )

    def process_item(self, item, spider):
        if isinstance(item, TapologyBoutItem):
            self.bouts.append(dict(item))
        elif isinstance(item, TapologyCommunityPickItem):
            self.community_picks.append(dict(item))
        elif isinstance(item, TapologyTempGymItem):
            self.gym_urls.add(item["url"])
        return item

    def close_spider(self, spider):
        events_df = pd.read_csv(os.path.join(self.dir_path, "events.csv"))
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

        if self.community_picks:
            community_picks_df = (
                pd.DataFrame(self.community_picks)
                .sort_values(
                    by="bout_id",
                    key=lambda x: (
                        x if x.name != "bout_id" else x.map(lambda b: bout_ids.index(b))
                    ),
                )
                .reset_index(drop=True)
            )

        bouts_df = bouts_df[
            [
                "id",
                "ufcstats_id",
                "event_id",
                "bout_order",
                "fighter_1_id",
                "fighter_2_id",
                "outcome_method",
                "end_round_time_info",
                "billing",
                "weight_class",
                "fighter_1_odds",
                "fighter_2_odds",
                "fighter_1_weight",
                "fighter_2_weight",
                "fighter_1_gym_info",
                "fighter_1_gym_ids",
                "fighter_2_gym_info",
                "fighter_2_gym_ids",
            ]
        ]

        if self.community_picks:
            community_picks_df = community_picks_df[
                [
                    "bout_id",
                    "fighter_last_name",
                    "ko_tko_percentage",
                    "submission_percentage",
                    "decision_percentage",
                    "overall_percentage",
                    "num_picks",
                ]
            ]

        if os.path.exists(os.path.join(self.dir_path, "bouts.csv")):
            old_bouts_df = pd.read_csv(os.path.join(self.dir_path, "bouts.csv"))
            bouts_df = pd.concat(
                [old_bouts_df, bouts_df], axis=0, ignore_index=True
            ).drop_duplicates(subset=["id"], keep="last")
            bouts_df = bouts_df.sort_values(
                by=["event_id", "bout_order"],
                key=lambda x: (
                    x if x.name != "event_id" else x.map(lambda e: event_ids.index(e))
                ),
            ).reset_index(drop=True)

            bout_ids = bouts_df["id"].values.tolist()
        if os.path.exists(os.path.join(self.dir_path, "community_picks.csv")):
            old_community_picks_df = pd.read_csv(
                os.path.join(self.dir_path, "community_picks.csv")
            )

            if self.community_picks:
                community_picks_df = pd.concat(
                    [old_community_picks_df, community_picks_df],
                    axis=0,
                    ignore_index=True,
                ).drop_duplicates(keep="last")
                community_picks_df = community_picks_df.sort_values(
                    by=["bout_id"],
                    key=lambda x: (
                        x if x.name != "bout_id" else x.map(lambda b: bout_ids.index(b))
                    ),
                ).reset_index(drop=True)
        if os.path.exists(os.path.join(self.misc_path, "tapology_gym_urls.txt")):
            with open(os.path.join(self.misc_path, "tapology_gym_urls.txt"), "r") as f:
                for line in f:
                    self.gym_urls.add(line.strip())

        bouts_df.to_csv(os.path.join(self.dir_path, "bouts.csv"), index=False)

        if self.community_picks:
            community_picks_df.to_csv(
                os.path.join(self.dir_path, "community_picks.csv"), index=False
            )

        with open(os.path.join(self.misc_path, "tapology_gym_urls.txt"), "w") as f:
            for url in sorted(self.gym_urls):
                f.write(url + "\n")


class TapologyGymItemPipeline:
    def __init__(self):
        self.gyms = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "raw", "Tapology"
        )

    def process_item(self, item, spider):
        if isinstance(item, TapologyGymItem):
            self.gyms.append(dict(item))
        return item

    def close_spider(self, spider):
        gyms_df = pd.DataFrame(self.gyms).sort_values(by="id").reset_index(drop=True)
        gyms_df = gyms_df[
            ["id", "name", "name_alternative", "location", "parent_id", "parent_name"]
        ]

        gyms_df.to_csv(os.path.join(self.dir_path, "gyms.csv"), index=False)
