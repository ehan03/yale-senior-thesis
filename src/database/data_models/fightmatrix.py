# standard library imports

# local imports
from base import Base

# third party imports
from sqlalchemy import Column, Date, ForeignKey, Integer, String


class FightMatrixFighters(Base):
    __tablename__ = "fightmatrix_fighters"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    pro_debut_date = Column(Date, nullable=True)
    ufc_debut_date = Column(Date, nullable=True)


class FightMatrixFighterHistories(Base):
    __tablename__ = "fightmatrix_fighter_histories"

    fighter_id = Column(Integer, nullable=False)
    order = Column(Integer, nullable=False)
    event_id = Column(Integer, ForeignKey("fightmatrix_events.id"), nullable=False)
    date = Column(Date, nullable=False)
    opponent_id = Column(Integer, nullable=False)
    outcome = Column(String, nullable=False)
    outcome_method = Column(String, nullable=True)
    end_round = Column(Integer, nullable=False)
    fighter_elo_k170_pre = Column(Integer, nullable=False)
    fighter_elo_k170_post = Column(Integer, nullable=False)
    fighter_elo_modified_pre = Column(Integer, nullable=False)
    fighter_elo_modified_post = Column(Integer, nullable=False)
    fighter_glicko_1_pre = Column(Integer, nullable=False)
    fighter_glicko_1_post = Column(Integer, nullable=False)
    opponent_elo_k170_pre = Column(Integer, nullable=False)
    opponent_elo_k170_post = Column(Integer, nullable=False)
    opponent_elo_modified_pre = Column(Integer, nullable=False)
    opponent_elo_modified_post = Column(Integer, nullable=False)
    opponent_glicko_1_pre = Column(Integer, nullable=False)
    opponent_glicko_1_post = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [fighter_id, order]}


class FightMatrixEvents(Base):
    __tablename__ = "fightmatrix_events"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    promotion = Column(String, nullable=True)
    date = Column(Date, nullable=False)
    country = Column(String, nullable=True)
    is_ufc_event = Column(Integer, nullable=False)


class FightMatrixBouts(Base):
    __tablename__ = "fightmatrix_bouts"

    event_id = Column(Integer, ForeignKey("fightmatrix_events.id"), nullable=False)
    bout_order = Column(Integer, nullable=False)
    fighter_1_id = Column(Integer, nullable=False)
    fighter_2_id = Column(Integer, nullable=False)
    fighter_1_outcome = Column(String, nullable=False)
    fighter_2_outcome = Column(String, nullable=False)
    fighter_1_elo_k170_pre = Column(Integer, nullable=True)
    fighter_1_elo_k170_post = Column(Integer, nullable=True)
    fighter_1_elo_modified_pre = Column(Integer, nullable=True)
    fighter_1_elo_modified_post = Column(Integer, nullable=True)
    fighter_1_glicko_1_pre = Column(Integer, nullable=True)
    fighter_1_glicko_1_post = Column(Integer, nullable=True)
    fighter_2_elo_k170_pre = Column(Integer, nullable=True)
    fighter_2_elo_k170_post = Column(Integer, nullable=True)
    fighter_2_elo_modified_pre = Column(Integer, nullable=True)
    fighter_2_elo_modified_post = Column(Integer, nullable=True)
    fighter_2_glicko_1_pre = Column(Integer, nullable=True)
    fighter_2_glicko_1_post = Column(Integer, nullable=True)
    weight_class = Column(String, nullable=True)
    outcome_method = Column(String, nullable=True)
    end_round = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [event_id, bout_order]}


class FightMatrixRankings(Base):
    __tablename__ = "fightmatrix_rankings"

    issue_date = Column(Date, nullable=False)
    weight_class = Column(String, nullable=False)
    fighter_id = Column(Integer, nullable=False)
    rank = Column(Integer, nullable=False)
    points = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [issue_date, weight_class, fighter_id]}
