# standard library imports

# third party imports
from scrapy import Field

# local imports
from ._ordered import OrderedItem


class TapologyFighterItem(OrderedItem):
    id = Field()
    ufcstats_id = Field()
    sherdog_id = Field()
    bestfightodds_id = Field()
    ufc_id = Field()
    wikipedia_url = Field()
    name = Field()
    nickname = Field()
    date_of_birth = Field()
    height = Field()
    reach = Field()
    nationality = Field()
    birth_location = Field()


class TapologyFighterHistoryItem(OrderedItem):
    fighter_id = Field()
    order = Field()
    bout_id = Field()
    bout_id_int = Field()
    event_id = Field()
    event_name = Field()
    opponent_id = Field()
    billing = Field()
    round_time_format = Field()
    weight_class = Field()
    outcome = Field()
    outcome_details = Field()
    weight = Field()
    odds = Field()
    pick_em = Field()
    fighter_record = Field()
    opponent_record = Field()


class TapologyGymItem(OrderedItem):
    id = Field()
    name = Field()
    name_alternative = Field()
    location = Field()
    parent_id = Field()
    parent_name = Field()


class TapologyEventItem(OrderedItem):
    id = Field()
    ufcstats_id = Field()
    sherdog_id = Field()
    bestfightodds_id = Field()
    ufc_id = Field()
    wikipedia_url = Field()
    name = Field()
    event_order = Field()


class TapologyBoutItem(OrderedItem):
    id = Field()
    ufcstats_id = Field()
    event_id = Field()
    bout_order = Field()
    fighter_1_id = Field()
    fighter_2_id = Field()
    outcome_method = Field()
    end_round_time_info = Field()
    billing = Field()
    weight_class = Field()
    fighter_1_odds = Field()
    fighter_2_odds = Field()
    fighter_1_weight = Field()
    fighter_2_weight = Field()
    fighter_1_gym_info = Field()
    fighter_1_gym_ids = Field()
    fighter_2_gym_info = Field()
    fighter_2_gym_ids = Field()


class TapologyCommunityPickItem(OrderedItem):
    bout_id = Field()
    fighter_last_name = Field()
    ko_tko_percentage = Field()
    submission_percentage = Field()
    decision_percentage = Field()
    overall_percentage = Field()
    num_picks = Field()


class TapologyTempBoutItem(OrderedItem):
    url = Field()
    event_id = Field()
    bout_order = Field()


class TapologyTempFighterItem(OrderedItem):
    url = Field()


class TapologyTempGymItem(OrderedItem):
    url = Field()
