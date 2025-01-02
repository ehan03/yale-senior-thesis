# standard library imports

# third party imports
from scrapy import Field

# local imports
from ._ordered import OrderedItem


class FightOddsIOFighterItem(OrderedItem):
    id = Field()
    pk = Field()
    slug = Field()
    name = Field()
    nickname = Field()
    date_of_birth = Field()
    height_centimeters = Field()
    reach_inches = Field()
    leg_reach_inches = Field()
    fighting_style = Field()
    stance = Field()
    nationality = Field()


class FightOddsIOEventItem(OrderedItem):
    id = Field()
    pk = Field()
    slug = Field()
    name = Field()
    date = Field()
    location = Field()
    venue = Field()
    event_order = Field()


class FightOddsIOBoutItem(OrderedItem):
    id = Field()
    pk = Field()
    slug = Field()
    event_id = Field()
    fighter_1_id = Field()
    fighter_2_id = Field()
    winner_id = Field()
    bout_type = Field()
    weight_class = Field()
    weight_lbs = Field()
    outcome_method = Field()
    outcome_method_details = Field()
    end_round = Field()
    end_round_time = Field()
    fighter_1_odds = Field()
    fighter_2_odds = Field()
    is_cancelled = Field()


class FightOddsIOSportsbookItem(OrderedItem):
    id = Field()
    slug = Field()
    short_name = Field()
    full_name = Field()
    website_url = Field()


class FightOddsIOMoneylineOddsSummaryItem(OrderedItem):
    id = Field()
    bout_id = Field()
    sportsbook_id = Field()
    outcome_1_id = Field()
    fighter_1_odds_open = Field()
    fighter_1_odds_worst = Field()
    fighter_1_odds_current = Field()
    fighter_1_odds_best = Field()
    outcome_2_id = Field()
    fighter_2_odds_open = Field()
    fighter_2_odds_worst = Field()
    fighter_2_odds_current = Field()
    fighter_2_odds_best = Field()


class FightOddsIOExpectedOutcomeSummaryItem(OrderedItem):
    bout_id = Field()
    offer_type_id = Field()
    is_not = Field()
    average_odds = Field()
    fighter_pk = Field()
    description = Field()
    not_description = Field()
