# standard library imports
import json
from collections import OrderedDict

# third party imports
import six
from scrapy import Field, Item

# local imports


class OrderedItem(Item):
    def __init__(self, *args, **kwargs):
        self._values = OrderedDict()
        if args or kwargs:
            for k, v in six.iteritems(dict(*args, **kwargs)):
                self[k] = v

    def __repr__(self):
        return json.dumps(OrderedDict(self), ensure_ascii=False)


# UFC Stats items
class UFCStatsFighterItem(OrderedItem):
    id = Field()
    name = Field()
    nickname = Field()
    height_inches = Field()
    reach_inches = Field()
    stance = Field()
    date_of_birth = Field()


class UFCStatsFighterHistoryItem(OrderedItem):
    fighter_id = Field()
    order = Field()
    bout_id = Field()
    opponent_id = Field()


class UFCStatsEventItem(OrderedItem):
    id = Field()
    name = Field()
    date = Field()
    location = Field()
    is_ufc_event = Field()
    event_order = Field()


class UFCStatsBoutItem(OrderedItem):
    id = Field()
    event_id = Field()
    bout_order = Field()
    red_fighter_id = Field()
    blue_fighter_id = Field()
    red_outcome = Field()
    blue_outcome = Field()
    weight_class = Field()
    type_verbose = Field()
    performance_bonus = Field()
    outcome_method = Field()
    outcome_method_details = Field()
    end_round = Field()
    end_round_time_seconds = Field()
    round_time_format = Field()
    total_time_seconds = Field()


class UFCStatsRoundStatsItem(OrderedItem):
    bout_id = Field()
    round_number = Field()
    fighter_id = Field()
    knockdowns_scored = Field()
    total_strikes_landed = Field()
    total_strikes_attempted = Field()
    takedowns_landed = Field()
    takedowns_attempted = Field()
    submissions_attempted = Field()
    reversals_scored = Field()
    control_time_seconds = Field()
    significant_strikes_landed = Field()
    significant_strikes_attempted = Field()
    significant_strikes_head_landed = Field()
    significant_strikes_head_attempted = Field()
    significant_strikes_body_landed = Field()
    significant_strikes_body_attempted = Field()
    significant_strikes_leg_landed = Field()
    significant_strikes_leg_attempted = Field()
    significant_strikes_distance_landed = Field()
    significant_strikes_distance_attempted = Field()
    significant_strikes_clinch_landed = Field()
    significant_strikes_clinch_attempted = Field()
    significant_strikes_ground_landed = Field()
    significant_strikes_ground_attempted = Field()
    round_time_seconds = Field()
