# standard library imports

# third party imports
from scrapy import Field

# local imports
from ._ordered import OrderedItem


class SherdogFighterItem(OrderedItem):
    id = Field()
    name = Field()
    nickname = Field()
    height_inches = Field()
    date_of_birth = Field()
    nationality = Field()
    pro_debut_date = Field()


class SherdogFighterHistoryItem(OrderedItem):
    fighter_id = Field()
    order = Field()
    event_id = Field()
    date = Field()
    opponent_id = Field()
    outcome = Field()
    outcome_method = Field()
    end_round = Field()
    end_round_time = Field()


class SherdogEventItem(OrderedItem):
    id = Field()
    name = Field()
    date = Field()
    location = Field()
    country = Field()
    is_ufc_event = Field()
    event_order = Field()


class SherdogBoutItem(OrderedItem):
    event_id = Field()
    bout_order = Field()
    fighter_1_id = Field()
    fighter_2_id = Field()
    fighter_1_outcome = Field()
    fighter_2_outcome = Field()
    is_title_bout = Field()
    weight_class = Field()
    outcome_method = Field()
    end_round = Field()
    end_round_time = Field()
