# standard library imports

# third party imports
from scrapy import Field

# local imports
from ._ordered import OrderedItem


class FightMatrixFighterItem(OrderedItem):
    id = Field()
    sherdog_id = Field()
    tapology_id = Field()
    name = Field()
    pro_debut_date = Field()
    ufc_debut_date = Field()


class FightMatrixFighterHistoryItem(OrderedItem):
    fighter_id = Field()
    temp_order = Field()
    bad_ordering_flag = Field()
    event_id = Field()
    date = Field()
    opponent_id = Field()
    outcome = Field()
    outcome_method = Field()
    end_round = Field()
    fighter_elo_k170_pre = Field()
    fighter_elo_k170_post = Field()
    fighter_elo_modified_pre = Field()
    fighter_elo_modified_post = Field()
    fighter_glicko_1_pre = Field()
    fighter_glicko_1_post = Field()
    opponent_elo_k170_pre = Field()
    opponent_elo_k170_post = Field()
    opponent_elo_modified_pre = Field()
    opponent_elo_modified_post = Field()
    opponent_glicko_1_pre = Field()
    opponent_glicko_1_post = Field()


class FightMatrixEventItem(OrderedItem):
    id = Field()
    name = Field()
    promotion = Field()
    date = Field()
    country = Field()
    is_ufc_event = Field()
    event_order = Field()


class FightMatrixBoutItem(OrderedItem):
    event_id = Field()
    bout_order = Field()
    fighter_1_id = Field()
    fighter_2_id = Field()
    fighter_1_outcome = Field()
    fighter_2_outcome = Field()
    fighter_1_elo_k170_pre = Field()
    fighter_1_elo_k170_post = Field()
    fighter_1_elo_modified_pre = Field()
    fighter_1_elo_modified_post = Field()
    fighter_1_glicko_1_pre = Field()
    fighter_1_glicko_1_post = Field()
    fighter_2_elo_k170_pre = Field()
    fighter_2_elo_k170_post = Field()
    fighter_2_elo_modified_pre = Field()
    fighter_2_elo_modified_post = Field()
    fighter_2_glicko_1_pre = Field()
    fighter_2_glicko_1_post = Field()
    weight_class = Field()
    outcome_method = Field()
    end_round = Field()


class FightMatrixRankingItem(OrderedItem):
    issue_date = Field()
    weight_class = Field()
    fighter_id = Field()
    rank = Field()
    points = Field()
