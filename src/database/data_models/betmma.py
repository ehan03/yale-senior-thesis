# standard library imports

# local imports
from base import Base

# third party imports
from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String


class BetMMAFighters(Base):
    __tablename__ = "betmma_fighters"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    height_inches = Column(Float, nullable=True)
    reach_inches = Column(Float, nullable=True)
    stance = Column(String, nullable=True)
    nationality = Column(String, nullable=True)


class BetMMAFighterHistories(Base):
    __tablename__ = "betmma_fighter_histories"

    fighter_id = Column(Integer, ForeignKey("betmma_fighters.id"), nullable=False)
    order = Column(Integer, nullable=False)
    bout_id = Column(Integer, ForeignKey("betmma_bouts.id"), nullable=False)
    opponent_id = Column(Integer, ForeignKey("betmma_fighters.id"), nullable=False)
    outcome = Column(String, nullable=False)
    outcome_method = Column(String, nullable=False)
    end_round = Column(Integer, nullable=True)
    end_round_time_seconds = Column(Integer, nullable=True)
    total_time_seconds = Column(Integer, nullable=True)
    odds = Column(Integer, nullable=True)

    __mapper_args__ = {"primary_key": [fighter_id, order]}


class BetMMAEvents(Base):
    __tablename__ = "betmma_events"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    date = Column(Date, nullable=False)
    location = Column(String, nullable=True)
    is_ufc_event = Column(Integer, nullable=False)


class BetMMABouts(Base):
    __tablename__ = "betmma_bouts"

    id = Column(Integer, primary_key=True)
    event_id = Column(Integer, ForeignKey("betmma_events.id"), nullable=False)
    bout_order = Column(Integer, nullable=False)
    fighter_1_id = Column(Integer, ForeignKey("betmma_fighters.id"), nullable=False)
    fighter_2_id = Column(Integer, ForeignKey("betmma_fighters.id"), nullable=False)


class BetMMALateReplacements(Base):
    __tablename__ = "betmma_late_replacements"

    fighter_id = Column(Integer, ForeignKey("betmma_fighters.id"), nullable=False)
    bout_id = Column(Integer, ForeignKey("betmma_bouts.id"), nullable=False)
    notice_time_days = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [fighter_id, bout_id]}


class BetMMAMissedWeights(Base):
    __tablename__ = "betmma_missed_weights"

    fighter_id = Column(Integer, ForeignKey("betmma_fighters.id"), nullable=False)
    bout_id = Column(Integer, ForeignKey("betmma_bouts.id"), nullable=False)
    weight_lbs = Column(Float, nullable=False)

    __mapper_args__ = {"primary_key": [fighter_id, bout_id]}
