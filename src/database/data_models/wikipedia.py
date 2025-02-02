# standard library imports

# third party imports
from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String

# local imports
from .base import Base


class WikipediaEvents(Base):
    __tablename__ = "wikipedia_events"

    id = Column(Integer, primary_key=True)
    date = Column(Date, nullable=False)
    name = Column(String, nullable=False)
    venue_id = Column(Integer, ForeignKey("wikipedia_venues.id"), nullable=False)
    location = Column(String, nullable=False)
    attendance = Column(Integer, nullable=True)


class WikipediaVenues(Base):
    __tablename__ = "wikipedia_venues"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    elevation_meters = Column(Float, nullable=True)
    capacity = Column(Integer, nullable=True)
