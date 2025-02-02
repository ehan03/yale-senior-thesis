# standard library imports

# third party imports
from sqlalchemy import Column, Date, ForeignKey, Integer, String

# local imports
from .base import Base


class UFCStatsFighters(Base):
    __tablename__ = "ufcstats_fighters"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    nickname = Column(String, nullable=True)
    height_inches = Column(Integer, nullable=True)
    reach_inches = Column(Integer, nullable=True)
    stance = Column(String, nullable=True)
    date_of_birth = Column(Date, nullable=True)


class UFCStatsFighterHistories(Base):
    __tablename__ = "ufcstats_fighter_histories"

    fighter_id = Column(String, ForeignKey("ufcstats_fighters.id"), nullable=False)
    order = Column(Integer, nullable=False)
    bout_id = Column(String, ForeignKey("ufcstats_bouts.id"), nullable=False)
    opponent_id = Column(String, ForeignKey("ufcstats_fighters.id"), nullable=False)

    __mapper_args__ = {"primary_key": [fighter_id, order]}


class UFCStatsEvents(Base):
    __tablename__ = "ufcstats_events"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    date = Column(Date, nullable=False)
    location = Column(String, nullable=False)
    is_ufc_event = Column(Integer, nullable=False)


class UFCStatsBouts(Base):
    __tablename__ = "ufcstats_bouts"

    id = Column(String, primary_key=True)
    event_id = Column(String, ForeignKey("ufcstats_events.id"), nullable=False)
    bout_order = Column(Integer, nullable=False)
    red_fighter_id = Column(String, ForeignKey("ufcstats_fighters.id"), nullable=False)
    blue_fighter_id = Column(String, ForeignKey("ufcstats_fighters.id"), nullable=False)
    red_outcome = Column(String, nullable=False)
    blue_outcome = Column(String, nullable=False)
    weight_class = Column(String, nullable=True)
    type_verbose = Column(String, nullable=False)
    performance_bonus = Column(Integer, nullable=False)
    outcome_method = Column(String, nullable=False)
    outcome_method_details = Column(String, nullable=True)
    end_round = Column(Integer, nullable=False)
    end_round_time_seconds = Column(Integer, nullable=False)
    round_time_format = Column(String, nullable=False)
    total_time_seconds = Column(Integer, nullable=False)


class UFCStatsRoundStats(Base):
    __tablename__ = "ufcstats_round_stats"

    bout_id = Column(String, ForeignKey("ufcstats_bouts.id"), nullable=False)
    round_number = Column(Integer, nullable=False)
    fighter_id = Column(String, ForeignKey("ufcstats_fighters.id"), nullable=False)
    round_time_seconds = Column(Integer, nullable=False)
    knockdowns_scored = Column(Integer, nullable=False)
    total_strikes_landed = Column(Integer, nullable=False)
    total_strikes_attempted = Column(Integer, nullable=False)
    takedowns_landed = Column(Integer, nullable=False)
    takedowns_attempted = Column(Integer, nullable=False)
    submissions_attempted = Column(Integer, nullable=False)
    reversals_scored = Column(Integer, nullable=False)
    control_time_seconds = Column(Integer, nullable=True)
    significant_strikes_landed = Column(Integer, nullable=False)
    significant_strikes_attempted = Column(Integer, nullable=False)
    significant_strikes_head_landed = Column(Integer, nullable=False)
    significant_strikes_head_attempted = Column(Integer, nullable=False)
    significant_strikes_body_landed = Column(Integer, nullable=False)
    significant_strikes_body_attempted = Column(Integer, nullable=False)
    significant_strikes_leg_landed = Column(Integer, nullable=False)
    significant_strikes_leg_attempted = Column(Integer, nullable=False)
    significant_strikes_distance_landed = Column(Integer, nullable=False)
    significant_strikes_distance_attempted = Column(Integer, nullable=False)
    significant_strikes_clinch_landed = Column(Integer, nullable=False)
    significant_strikes_clinch_attempted = Column(Integer, nullable=False)
    significant_strikes_ground_landed = Column(Integer, nullable=False)
    significant_strikes_ground_attempted = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [bout_id, round_number, fighter_id]}
