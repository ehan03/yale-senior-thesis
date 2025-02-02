# standard library imports

# local imports
from base import Base

# third party imports
from sqlalchemy import Column, ForeignKey, Integer, String


class BestFightOddsFighters(Base):
    __tablename__ = "bestfightodds_fighters"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    nickname = Column(String, nullable=True)


class BestFightOddsEvents(Base):
    __tablename__ = "bestfightodds_events"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)


class BestFightOddsMoneylineOdds(Base):
    __tablename__ = "bestfightodds_moneyline_odds"

    event_id = Column(Integer, ForeignKey("bestfightodds_events.id"), nullable=False)
    fighter_id = Column(
        Integer, ForeignKey("bestfightodds_fighters.id"), nullable=False
    )
    betsite = Column(String, nullable=False)
    timestamp = Column(Integer, nullable=False)
    odds = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [event_id, fighter_id, betsite, timestamp]}


class BestFightOddsEventPropositionOdds(Base):
    __tablename__ = "bestfightodds_event_proposition_odds"

    event_id = Column(Integer, ForeignKey("bestfightodds_events.id"), nullable=False)
    description = Column(String, nullable=False)
    is_not = Column(Integer, nullable=False)
    betsite = Column(String, nullable=False)
    odds = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [event_id, description, is_not, betsite]}


class BestFightOddsBoutPropositionOdds(Base):
    __tablename__ = "bestfightodds_bout_proposition_odds"

    tapology_bout_id = Column(Integer, ForeignKey("tapology_bouts.id"), nullable=False)
    event_id = Column(Integer, ForeignKey("bestfightodds_events.id"), nullable=False)
    fighter_id = Column(Integer, ForeignKey("bestfightodds_fighters.id"), nullable=True)
    description = Column(String, nullable=False)
    is_not = Column(Integer, nullable=False)
    betsite = Column(String, nullable=False)
    odds = Column(Integer, nullable=False)

    __mapper_args__ = {
        "primary_key": [
            tapology_bout_id,
            event_id,
            fighter_id,
            description,
            is_not,
            betsite,
        ]
    }
