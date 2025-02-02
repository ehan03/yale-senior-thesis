# standard library imports

# third party imports
from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String

# local imports
from .base import Base


class FightOddsIOFighters(Base):
    __tablename__ = "fightoddsio_fighters"

    id = Column(String, primary_key=True)
    pk = Column(Integer, nullable=False, unique=True)
    slug = Column(String, nullable=False, unique=True)
    name = Column(String, nullable=False)
    nickname = Column(String, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    height_centimeters = Column(Float, nullable=True)
    reach_inches = Column(Float, nullable=True)
    leg_reach_inches = Column(Integer, nullable=True)
    fighting_style = Column(String, nullable=True)
    stance = Column(String, nullable=True)
    nationality = Column(String, nullable=True)


class FightOddsIOEvents(Base):
    __tablename__ = "fightoddsio_events"

    id = Column(String, primary_key=True)
    pk = Column(Integer, nullable=False, unique=True)
    slug = Column(String, nullable=False, unique=True)
    name = Column(String, nullable=False)
    date = Column(Date, nullable=False)
    location = Column(String, nullable=False)
    venue = Column(String, nullable=False)


class FightOddsIOBouts(Base):
    __tablename__ = "fightoddsio_bouts"

    id = Column(String, primary_key=True)
    pk = Column(Integer, nullable=False, unique=True)
    slug = Column(String, nullable=False, unique=True)
    event_id = Column(String, ForeignKey("fightoddsio_events.id"), nullable=False)
    fighter_1_id = Column(String, ForeignKey("fightoddsio_fighters.id"), nullable=False)
    fighter_2_id = Column(String, ForeignKey("fightoddsio_fighters.id"), nullable=False)
    winner_id = Column(String, ForeignKey("fightoddsio_fighters.id"), nullable=True)
    bout_type = Column(String, nullable=True)
    weight_class = Column(String, nullable=True)
    weight_lbs = Column(Integer, nullable=True)
    outcome_method = Column(String, nullable=True)
    outcome_method_details = Column(String, nullable=True)
    end_round = Column(Integer, nullable=True)
    end_round_time = Column(String, nullable=True)
    fighter_1_odds = Column(Integer, nullable=True)
    fighter_2_odds = Column(Integer, nullable=True)


class FightOddsIOSportsbooks(Base):
    __tablename__ = "fightoddsio_sportsbooks"

    id = Column(String, primary_key=True)
    slug = Column(String, nullable=False, unique=True)
    short_name = Column(String, nullable=False)
    full_name = Column(String, nullable=False)
    website_url = Column(String, nullable=False)


class FightOddsIOMoneylineOdds(Base):
    __tablename__ = "fightoddsio_moneyline_odds"

    id = Column(String, primary_key=True)
    bout_id = Column(String, ForeignKey("fightoddsio_bouts.id"), nullable=False)
    sportsbook_id = Column(
        String, ForeignKey("fightoddsio_sportsbooks.id"), nullable=False
    )
    outcome_1_id = Column(String, nullable=True)
    fighter_1_odds_open = Column(Integer, nullable=True)
    fighter_1_odds_worst = Column(Integer, nullable=True)
    fighter_1_odds_current = Column(Integer, nullable=True)
    fighter_1_odds_best = Column(Integer, nullable=True)
    outcome_2_id = Column(String, nullable=True)
    fighter_2_odds_open = Column(Integer, nullable=True)
    fighter_2_odds_worst = Column(Integer, nullable=True)
    fighter_2_odds_current = Column(Integer, nullable=True)
    fighter_2_odds_best = Column(Integer, nullable=True)
