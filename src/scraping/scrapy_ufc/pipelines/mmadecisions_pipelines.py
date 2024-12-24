# standard library imports
import os

# third party imports
import pandas as pd

# local imports
from ..items.mmadecisions_items import (
    MMADecisionsBoutItem,
    MMADecisionsDeductionItem,
    MMADecisionsEventItem,
    MMADecisionsFighterItem,
    MMADecisionsJudgeItem,
    MMADecisionsJudgeScoreItem,
    MMADecisionsMediaScoreItem,
)


class MMADecisionsItemPipeline:
    def __init__(self):
        self.fighters = []
        self.events = []
        self.bouts = []
        self.judges = []
        self.judge_scores = []
        self.media_scores = []
        self.deductions = []

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "MMA Decisions"
        )

    def process_item(self, item, spider):
        if isinstance(item, MMADecisionsFighterItem):
            self.fighters.append(dict(item))
        elif isinstance(item, MMADecisionsEventItem):
            self.events.append(dict(item))
        elif isinstance(item, MMADecisionsBoutItem):
            self.bouts.append(dict(item))
        elif isinstance(item, MMADecisionsJudgeItem):
            self.judges.append(dict(item))
        elif isinstance(item, MMADecisionsJudgeScoreItem):
            self.judge_scores.append(dict(item))
        elif isinstance(item, MMADecisionsMediaScoreItem):
            self.media_scores.append(dict(item))
        elif isinstance(item, MMADecisionsDeductionItem):
            self.deductions.append(dict(item))
        return item

    def close_spider(self, spider):
        fighters_df = (
            pd.DataFrame(self.fighters).sort_values(by="id").reset_index(drop=True)
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
                by=["event_id", "bout_order"],
                key=lambda x: (
                    x if x.name != "event_id" else x.map(lambda e: event_ids.index(e))
                ),
            )
            .reset_index(drop=True)
        )
        bout_ids = bouts_df["id"].values.tolist()

        judges_df = (
            pd.DataFrame(self.judges).sort_values(by="id").reset_index(drop=True)
        )

        judge_scores_df = (
            pd.DataFrame(self.judge_scores)
            .sort_values(
                by=["bout_id", "judge_order", "round"],
                key=lambda x: (
                    x if x.name != "bout_id" else x.map(lambda b: bout_ids.index(b))
                ),
            )
            .reset_index(drop=True)
        )
        media_scores_df = (
            pd.DataFrame(self.media_scores)
            .sort_values(
                by="bout_id",
                key=lambda x: (
                    x if x.name != "bout_id" else x.map(lambda b: bout_ids.index(b))
                ),
            )
            .reset_index(drop=True)
        )

        deductions_df = (
            pd.DataFrame(self.deductions)
            .sort_values(
                by=["bout_id", "round_number"],
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
                "nicknames",
                "date_of_birth",
                "birth_location",
                "height",
                "reach_inches",
            ]
        ]
        events_df = events_df[
            ["id", "name", "promotion", "date", "venue", "location", "event_order"]
        ]
        bouts_df = bouts_df[
            [
                "id",
                "event_id",
                "bout_order",
                "fighter_1_id",
                "fighter_2_id",
                "fighter_1_weight_lbs",
                "fighter_2_weight_lbs",
                "fighter_1_fighting_out_of",
                "fighter_2_fighting_out_of",
                "decision_type",
            ]
        ]
        judges_df = judges_df[["id", "name"]]
        judge_scores_df = judge_scores_df[
            [
                "bout_id",
                "round",
                "judge_id",
                "judge_order",
                "fighter_1_score",
                "fighter_2_score",
            ]
        ]
        media_scores_df = media_scores_df[
            [
                "bout_id",
                "person_name",
                "media_name",
                "fighter_1_score",
                "fighter_2_score",
            ]
        ]
        deductions_df = deductions_df[
            ["bout_id", "fighter_id", "round_number", "points_deducted", "reason"]
        ]

        fighters_df.to_csv(os.path.join(self.dir_path, "fighters.csv"), index=False)
        events_df.to_csv(os.path.join(self.dir_path, "events.csv"), index=False)
        bouts_df.to_csv(os.path.join(self.dir_path, "bouts.csv"), index=False)
        judges_df.to_csv(os.path.join(self.dir_path, "judges.csv"), index=False)
        judge_scores_df.to_csv(
            os.path.join(self.dir_path, "judge_scores.csv"), index=False
        )
        media_scores_df.to_csv(
            os.path.join(self.dir_path, "media_scores.csv"), index=False
        )
        deductions_df.to_csv(os.path.join(self.dir_path, "deductions.csv"), index=False)
