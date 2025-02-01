# standard library imports

# local imports
from base import Base

# third party imports
from sqlalchemy import Column, Date, ForeignKey, Integer, String


class SherdogFighters(Base):
    __tablename__ = "sherdog_fighters"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    nickname = Column(String, nullable=True)
    height_inches = Column(Integer, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    nationality = Column(String, nullable=True)
    pro_debut_date = Column(Date, nullable=True)


class SherdogFighterHistories(Base):
    __tablename__ = "sherdog_fighter_histories"

    fighter_id = Column(Integer, ForeignKey("sherdog_fighters.id"), nullable=False)
    order = Column(Integer, nullable=False)
    event_id = Column(Integer, ForeignKey("sherdog_events.id"), nullable=False)
    date = Column(Date, nullable=False)
    opponent_id = Column(Integer, ForeignKey("sherdog_fighters.id"), nullable=True)
    outcome = Column(String, nullable=False)
    outcome_method = Column(String, nullable=True)
    outcome_method_broad = Column(String, nullable=True)
    end_round = Column(Integer, nullable=True)
    end_round_time_seconds = Column(Integer, nullable=True)
    total_time_seconds = Column(Integer, nullable=True)


class SherdogEvents(Base):
    __tablename__ = "sherdog_events"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    date = Column(Date, nullable=False)
    location = Column(String, nullable=True)
    country = Column(String, nullable=True)
    is_ufc_event = Column(Integer, nullable=False)


class SherdogBouts(Base):
    __tablename__ = "sherdog_bouts"

    event_id = Column(Integer, ForeignKey("sherdog_events.id"), nullable=False)
    bout_order = Column(Integer, nullable=False)
    fighter_1_id = Column(Integer, ForeignKey("sherdog_fighters.id"), nullable=True)
    fighter_2_id = Column(Integer, ForeignKey("sherdog_fighters.id"), nullable=True)
    fighter_1_outcome = Column(String, nullable=True)
    fighter_2_outcome = Column(String, nullable=True)
    is_title_bout = Column(Integer, nullable=False)
    weight_class = Column(String, nullable=True)
    weight_class_lbs = Column(Integer, nullable=True)
    outcome_method = Column(String, nullable=True)
    outcome_method_broad = Column(String, nullable=True)
    end_round = Column(Integer, nullable=True)
    end_round_time_seconds = Column(Integer, nullable=True)
    total_time_seconds = Column(Integer, nullable=True)

    __mapper_args__ = {"primary_key": [event_id, bout_order]}
