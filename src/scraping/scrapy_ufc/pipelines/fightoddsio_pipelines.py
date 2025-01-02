# standard library imports
import os

# third party imports
import pandas as pd

# local imports
from ..items.fightoddsio_items import (
    FightOddsIOBoutItem,
    FightOddsIOEventItem,
    FightOddsIOExpectedOutcomeSummaryItem,
    FightOddsIOFighterItem,
    FightOddsIOMoneylineOddsSummaryItem,
    FightOddsIOSportsbookItem,
)


class FightOddsIOItemPipeline:
    def __init__(self):
        self.fighters = []
        self.events = []
        self.bouts = []
        self.moneyline_odds_summaries = []
        self.expected_outcome_summaries = []
        self.sportsbooks = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "FightOdds.io"
        )

    def process_item(self, item, spider):
        if isinstance(item, FightOddsIOFighterItem):
            self.fighters.append(dict(item))
        elif isinstance(item, FightOddsIOEventItem):
            self.events.append(dict(item))
        elif isinstance(item, FightOddsIOBoutItem):
            self.bouts.append(dict(item))
        elif isinstance(item, FightOddsIOMoneylineOddsSummaryItem):
            self.moneyline_odds_summaries.append(dict(item))
        elif isinstance(item, FightOddsIOExpectedOutcomeSummaryItem):
            self.expected_outcome_summaries.append(dict(item))
        elif isinstance(item, FightOddsIOSportsbookItem):
            self.sportsbooks.append(dict(item))
        return item

    def close_spider(self, spider):
        fighters_df = (
            pd.DataFrame(self.fighters)
            .sort_values(by="id")
            .drop_duplicates()
            .reset_index(drop=True)
        )

        events_df = (
            pd.DataFrame(self.events)
            .sort_values(by="event_order")
            .reset_index(drop=True)
        )
        event_ids = events_df["id"].values.tolist()

        bouts_df = (
            pd.DataFrame(self.bouts)
            .sort_values(
                by="event_id",
                key=lambda x: (
                    x if x.name != "event_id" else x.map(lambda e: event_ids.index(e))
                ),
            )
            .reset_index(drop=True)
        )
        bout_ids = bouts_df["id"].values.tolist()

        moneyline_odds_summaries_df = (
            pd.DataFrame(self.moneyline_odds_summaries)
            .sort_values(
                by="bout_id",
                key=lambda x: (
                    x if x.name != "bout_id" else x.map(lambda b: bout_ids.index(b))
                ),
            )
            .reset_index(drop=True)
        )

        expected_outcome_summaries_df = (
            pd.DataFrame(self.expected_outcome_summaries)
            .sort_values(
                by="bout_id",
                key=lambda x: (
                    x if x.name != "bout_id" else x.map(lambda b: bout_ids.index(b))
                ),
            )
            .reset_index(drop=True)
        )

        sportsbooks_df = (
            pd.DataFrame(self.sportsbooks)
            .sort_values(by="id")
            .drop_duplicates()
            .reset_index(drop=True)
        )

        fighters_df = fighters_df[
            [
                "id",
                "pk",
                "slug",
                "name",
                "nickname",
                "date_of_birth",
                "height_centimeters",
                "reach_inches",
                "leg_reach_inches",
                "fighting_style",
                "stance",
                "nationality",
            ]
        ]
        events_df = events_df[
            [
                "id",
                "pk",
                "slug",
                "name",
                "date",
                "location",
                "venue",
                "event_order",
            ]
        ]
        bouts_df = bouts_df[
            [
                "id",
                "pk",
                "slug",
                "event_id",
                "fighter_1_id",
                "fighter_2_id",
                "winner_id",
                "bout_type",
                "weight_class",
                "weight_lbs",
                "outcome_method",
                "outcome_method_details",
                "end_round",
                "end_round_time",
                "fighter_1_odds",
                "fighter_2_odds",
                "is_cancelled",
            ]
        ]
        moneyline_odds_summaries_df = moneyline_odds_summaries_df[
            [
                "id",
                "bout_id",
                "sportsbook_id",
                "outcome_1_id",
                "fighter_1_odds_open",
                "fighter_1_odds_worst",
                "fighter_1_odds_current",
                "fighter_1_odds_best",
                "outcome_2_id",
                "fighter_2_odds_open",
                "fighter_2_odds_worst",
                "fighter_2_odds_current",
                "fighter_2_odds_best",
            ]
        ]
        expected_outcome_summaries_df = expected_outcome_summaries_df[
            [
                "bout_id",
                "offer_type_id",
                "is_not",
                "average_odds",
                "fighter_pk",
                "description",
                "not_description",
            ]
        ]
        sportsbooks_df = sportsbooks_df[
            [
                "id",
                "slug",
                "short_name",
                "full_name",
                "website_url",
            ]
        ]

        fighters_df.to_csv(os.path.join(self.dir_path, "fighters.csv"), index=False)
        events_df.to_csv(os.path.join(self.dir_path, "events.csv"), index=False)
        bouts_df.to_csv(os.path.join(self.dir_path, "bouts.csv"), index=False)
        moneyline_odds_summaries_df.to_csv(
            os.path.join(self.dir_path, "moneyline_odds_summaries.csv"), index=False
        )
        expected_outcome_summaries_df.to_csv(
            os.path.join(self.dir_path, "expected_outcome_summaries.csv"), index=False
        )
        sportsbooks_df.to_csv(
            os.path.join(self.dir_path, "sportsbooks.csv"), index=False
        )
