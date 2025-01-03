# standard library imports

# third party imports
from scrapy import Field

# local imports
from ._ordered import OrderedItem


class BetMMAFighterItem(OrderedItem):
    id = Field()
    name = Field()
    wikipedia_url = Field()
    sherdog_id = Field()
    ufcstats_id = Field()
    height = Field()
    reach = Field()
    stance = Field()
    nationality = Field()


class BetMMAFighterHistoryItem(OrderedItem):
    fighter_id = Field()
    order = Field()
    bout_id = Field()
    opponent_id = Field()
    outcome = Field()
    outcome_method = Field()
    end_round = Field()
    end_round_time = Field()
    odds = Field()


class BetMMALateReplacementItem(OrderedItem):
    fighter_id = Field()
    bout_id = Field()
    notice_time_days = Field()


class BetMMAMissedWeightItem(OrderedItem):
    fighter_id = Field()
    bout_id = Field()
    weight_lbs = Field()


class BetMMAEventItem(OrderedItem):
    id = Field()
    name = Field()
    date = Field()
    location = Field()
    is_ufc_event = Field()
    temp_order = Field()


class BetMMABoutItem(OrderedItem):
    id = Field()
    event_id = Field()
    bout_order = Field()
    fighter_1_id = Field()
    fighter_2_id = Field()
