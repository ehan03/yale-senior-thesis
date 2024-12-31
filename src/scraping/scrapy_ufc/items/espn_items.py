# standard library imports

# third party imports
from scrapy import Field

# local imports
from ._ordered import OrderedItem


class ESPNFighterItem(OrderedItem):
    id = Field()
    name = Field()
    nickname = Field()
    date_of_birth = Field()
    height_inches = Field()
    stance = Field()


class ESPNFighterHistoryItem(OrderedItem):
    fighter_id = Field()
    order = Field()
    event_id = Field()
    event_name = Field()
    date = Field()
    opponent_id = Field()
    outcome = Field()
    outcome_method = Field()
    end_round = Field()
    end_round_time_seconds = Field()


class ESPNFighterBoutStatisticsItem(OrderedItem):
    fighter_id = Field()
    order = Field()
    event_id = Field()
    event_name = Field()
    date = Field()
    opponent_id = Field()
    outcome = Field()
    knockdowns_scored = Field()
    total_strikes_landed = Field()
    total_strikes_attempted = Field()
    takedowns_landed = Field()
    takedowns_slams_landed = Field()
    takedowns_attempted = Field()
    reversals_scored = Field()
    significant_strikes_landed = Field()
    significant_strikes_attempted = Field()
    significant_strikes_distance_head_landed = Field()
    significant_strikes_distance_head_attempted = Field()
    significant_strikes_distance_body_landed = Field()
    significant_strikes_distance_body_attempted = Field()
    significant_strikes_distance_leg_landed = Field()
    significant_strikes_distance_leg_attempted = Field()
    significant_strikes_clinch_head_landed = Field()
    significant_strikes_clinch_head_attempted = Field()
    significant_strikes_clinch_body_landed = Field()
    significant_strikes_clinch_body_attempted = Field()
    significant_strikes_clinch_leg_landed = Field()
    significant_strikes_clinch_leg_attempted = Field()
    significant_strikes_ground_head_landed = Field()
    significant_strikes_ground_head_attempted = Field()
    significant_strikes_ground_body_landed = Field()
    significant_strikes_ground_body_attempted = Field()
    significant_strikes_ground_leg_landed = Field()
    significant_strikes_ground_leg_attempted = Field()
    advances = Field()
    advances_to_back = Field()
    advances_to_half_guard = Field()
    advances_to_mount = Field()
    advances_to_side = Field()
    submissions_attempted = Field()


class ESPNEventItem(OrderedItem):
    id = Field()
    name = Field()
    date = Field()
    location = Field()
    is_ufc_event = Field()
    event_order = Field()


class ESPNBoutItem(OrderedItem):
    id = Field()
    event_id = Field()
    bout_order = Field()
    red_fighter_id = Field()
    blue_fighter_id = Field()
    winner_id = Field()
    weight_class = Field()
    card_segment = Field()
    outcome_method = Field()
