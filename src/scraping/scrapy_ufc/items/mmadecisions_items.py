# standard library imports

# third party imports
from scrapy import Field

# local imports
from ._ordered import OrderedItem


class MMADecisionsFighterItem(OrderedItem):
    id = Field()
    name = Field()
    nicknames = Field()
    date_of_birth = Field()
    birth_location = Field()
    height = Field()
    reach_inches = Field()


class MMADecisionsEventItem(OrderedItem):
    id = Field()
    name = Field()
    promotion = Field()
    date = Field()
    venue = Field()
    location = Field()
    event_order = Field()


class MMADecisionsBoutItem(OrderedItem):
    id = Field()
    event_id = Field()
    bout_order = Field()
    fighter_1_id = Field()
    fighter_2_id = Field()
    fighter_1_weight_lbs = Field()
    fighter_2_weight_lbs = Field()
    fighter_1_fighting_out_of = Field()
    fighter_2_fighting_out_of = Field()
    decision_type = Field()


class MMADecisionsJudgeScoreItem(OrderedItem):
    bout_id = Field()
    round = Field()
    judge_id = Field()
    judge_order = Field()
    fighter_1_score = Field()
    fighter_2_score = Field()


class MMADecisionsDeductionItem(OrderedItem):
    bout_id = Field()
    fighter_id = Field()
    round_number = Field()
    points_deducted = Field()
    reason = Field()


class MMADecisionsMediaScoreItem(OrderedItem):
    bout_id = Field()
    person_name = Field()
    media_name = Field()
    fighter_1_score = Field()
    fighter_2_score = Field()


class MMADecisionsJudgeItem(OrderedItem):
    id = Field()
    name = Field()
