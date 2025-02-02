# standard library imports

# third party imports
from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String

# local imports
from .base import Base


class ESPNFighters(Base):
    __tablename__ = "espn_fighters"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    nickname = Column(String, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    reach_inches = Column(Float, nullable=True)
    height_inches = Column(Integer, nullable=True)
    stance = Column(String, nullable=True)
    team_id = Column(Integer, ForeignKey("espn_teams.id"), nullable=True)
    nationality = Column(String, nullable=True)
    fighting_style = Column(String, nullable=True)


class ESPNFighterHistories(Base):
    __tablename__ = "espn_fighter_histories"

    fighter_id = Column(Integer, nullable=False)
    order = Column(Integer, nullable=False)
    bout_id = Column(Integer, nullable=False)
    event_id = Column(Integer, nullable=False)
    event_name = Column(String, nullable=True)
    date = Column(Date, nullable=False)
    hour_utc = Column(Integer, nullable=False)
    opponent_id = Column(Integer, nullable=True)
    outcome = Column(String, nullable=False)
    outcome_method = Column(String, nullable=True)
    end_round = Column(Integer, nullable=True)
    end_round_time_seconds = Column(Integer, nullable=True)
    total_time_seconds = Column(Integer, nullable=True)
    is_title_bout = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [fighter_id, order]}


class ESPNEvents(Base):
    __tablename__ = "espn_events"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    date = Column(Date, nullable=False)
    hour_utc = Column(Integer, nullable=False)
    venue_id = Column(Integer, ForeignKey("espn_venues.id"), nullable=True)


class ESPNBouts(Base):
    __tablename__ = "espn_bouts"

    id = Column(Integer, primary_key=True)
    event_id = Column(Integer, ForeignKey("espn_events.id"), nullable=False)
    bout_order = Column(Integer, nullable=False)
    fighter_1_id = Column(Integer, ForeignKey("espn_fighters.id"), nullable=False)
    fighter_2_id = Column(Integer, ForeignKey("espn_fighters.id"), nullable=False)
    winner_id = Column(Integer, ForeignKey("espn_fighters.id"), nullable=True)
    card_segment = Column(String, nullable=False)


class ESPNBoutStats(Base):
    __tablename__ = "espn_bout_stats"

    bout_id = Column(Integer, nullable=False)
    fighter_id = Column(Integer, nullable=False)
    knockdowns_scored = Column(Integer, nullable=True)
    total_strikes_landed = Column(Integer, nullable=True)
    total_strikes_attempted = Column(Integer, nullable=True)
    takedowns_landed = Column(Integer, nullable=True)
    takedowns_slams_landed = Column(Integer, nullable=True)
    takedowns_attempted = Column(Integer, nullable=True)
    reversals_scored = Column(Integer, nullable=True)
    significant_strikes_distance_head_landed = Column(Integer, nullable=True)
    significant_strikes_distance_head_attempted = Column(Integer, nullable=True)
    significant_strikes_distance_body_landed = Column(Integer, nullable=True)
    significant_strikes_distance_body_attempted = Column(Integer, nullable=True)
    significant_strikes_distance_leg_landed = Column(Integer, nullable=True)
    significant_strikes_distance_leg_attempted = Column(Integer, nullable=True)
    significant_strikes_clinch_head_landed = Column(Integer, nullable=True)
    significant_strikes_clinch_head_attempted = Column(Integer, nullable=True)
    significant_strikes_clinch_body_landed = Column(Integer, nullable=True)
    significant_strikes_clinch_body_attempted = Column(Integer, nullable=True)
    significant_strikes_clinch_leg_landed = Column(Integer, nullable=True)
    significant_strikes_clinch_leg_attempted = Column(Integer, nullable=True)
    significant_strikes_ground_head_landed = Column(Integer, nullable=True)
    significant_strikes_ground_head_attempted = Column(Integer, nullable=True)
    significant_strikes_ground_body_landed = Column(Integer, nullable=True)
    significant_strikes_ground_body_attempted = Column(Integer, nullable=True)
    significant_strikes_ground_leg_landed = Column(Integer, nullable=True)
    significant_strikes_ground_leg_attempted = Column(Integer, nullable=True)
    advances = Column(Integer, nullable=True)
    advances_to_back = Column(Integer, nullable=True)
    advances_to_half_guard = Column(Integer, nullable=True)
    advances_to_mount = Column(Integer, nullable=True)
    advances_to_side = Column(Integer, nullable=True)
    submissions_attempted = Column(Integer, nullable=True)

    __mapper_args__ = {"primary_key": [bout_id, fighter_id]}


class ESPNTeams(Base):
    __tablename__ = "espn_teams"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)


class ESPNVenues(Base):
    __tablename__ = "espn_venues"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    city = Column(String, nullable=False)
    state = Column(String, nullable=True)
    country = Column(String, nullable=True)
    is_indoor = Column(Integer, nullable=False)
