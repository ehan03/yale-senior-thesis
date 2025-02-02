# standard library imports

# third party imports
from sqlalchemy import Column, ForeignKey, Integer, String

# local imports
from .base import Base


class FighterAssociation(Base):
    __tablename__ = "FIGHTER_MAPPING"

    ufcstats_id = Column(String, ForeignKey("ufcstats_fighters.id"), primary_key=True)
    bestfightodds_id = Column(
        Integer, ForeignKey("bestfightodds_fighters.id"), nullable=True
    )
    betmma_id = Column(Integer, ForeignKey("betmma_fighters.id"), nullable=True)
    espn_id = Column(Integer, ForeignKey("espn_fighters.id"), nullable=False)
    fightmatrix_id = Column(
        Integer, ForeignKey("fightmatrix_fighters.id"), nullable=False
    )
    fightoddsio_id = Column(
        String, ForeignKey("fightoddsio_fighters.id"), nullable=False
    )
    mmadecisions_id = Column(
        Integer, ForeignKey("mmadecisions_fighters.id"), nullable=True
    )
    sherdog_id = Column(Integer, ForeignKey("sherdog_fighters.id"), nullable=False)
    tapology_id = Column(String, ForeignKey("tapology_fighters.id"), nullable=False)


class EventAssociation(Base):
    __tablename__ = "EVENT_MAPPING"

    ufcstats_id = Column(String, ForeignKey("ufcstats_events.id"), primary_key=True)
    bestfightodds_id = Column(
        Integer, ForeignKey("bestfightodds_events.id"), nullable=True
    )
    betmma_id = Column(Integer, ForeignKey("betmma_events.id"), nullable=True)
    espn_id = Column(Integer, ForeignKey("espn_events.id"), nullable=False)
    fightmatrix_id = Column(
        Integer, ForeignKey("fightmatrix_events.id"), nullable=False
    )
    fightoddsio_id = Column(String, ForeignKey("fightoddsio_events.id"), nullable=False)
    mmadecisions_id = Column(
        Integer, ForeignKey("mmadecisions_events.id"), nullable=True
    )
    sherdog_id = Column(Integer, ForeignKey("sherdog_events.id"), nullable=False)
    tapology_id = Column(String, ForeignKey("tapology_events.id"), nullable=False)
    wikipedia_id = Column(Integer, ForeignKey("wikipedia_events.id"), nullable=False)


class BoutAssociation(Base):
    __tablename__ = "BOUT_MAPPING"

    ufcstats_id = Column(String, ForeignKey("ufcstats_bouts.id"), primary_key=True)
    betmma_id = Column(Integer, ForeignKey("betmma_bouts.id"), nullable=True)
    espn_id = Column(Integer, ForeignKey("espn_bouts.id"), nullable=False)
    fightoddsio_id = Column(String, ForeignKey("fightoddsio_bouts.id"), nullable=True)
    mmadecisions_id = Column(
        Integer, ForeignKey("mmadecisions_bouts.id"), nullable=True
    )
    tapology_id = Column(String, ForeignKey("tapology_bouts.id"), nullable=False)
