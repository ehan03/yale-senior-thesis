# standard library imports

# local imports
from base import Base

# third party imports
from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String


class TapologyFighters(Base):
    __tablename__ = "tapology_fighters"

    id = Column(String, primary_key=True)
    ufc_id = Column(String, nullable=True)
    wikipedia_url = Column(String, nullable=True)
    name = Column(String, nullable=False)
    nickname = Column(String, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    height_inches = Column(Integer, nullable=True)
    reach_inches = Column(Float, nullable=True)
    nationality = Column(String, nullable=True)
    birth_location = Column(String, nullable=False)


class TapologyFighterHistories(Base):
    __tablename__ = "tapology_fighter_histories"

    fighter_id = Column(String, ForeignKey("tapology_fighters.id"), nullable=False)
    order = Column(Integer, nullable=False)
    bout_id = Column(String, nullable=True)
    bout_id_integer = Column(Integer, nullable=False)
    event_id = Column(String, nullable=True)
    event_name = Column(String, nullable=True)
    opponent_id = Column(String, nullable=True)
    billing = Column(String, nullable=True)
    round_time_format = Column(String, nullable=True)
    weight_class = Column(String, nullable=True)
    weight_class_lbs = Column(Float, nullable=True)
    outcome = Column(String, nullable=False)
    outcome_method = Column(String, nullable=True)
    outcome_method_details = Column(String, nullable=True)
    end_round = Column(Integer, nullable=True)
    end_round_time_seconds = Column(Integer, nullable=True)
    fighter_record = Column(String, nullable=True)
    opponent_record = Column(String, nullable=True)
    weigh_in_result_lbs = Column(Float, nullable=True)
    odds = Column(Integer, nullable=True)
    pick_em_percent = Column(Integer, nullable=True)

    __mapper_args__ = {"primary_key": [fighter_id, order]}


class TapologyFighterGyms(Base):
    __tablename__ = "tapology_fighter_gyms"

    fighter_id = Column(String, ForeignKey("tapology_fighters.id"), nullable=False)
    bout_id = Column(String, ForeignKey("tapology_bouts.id"), nullable=False)
    gym_id = Column(String, ForeignKey("tapology_gyms.id"), nullable=True)
    gym_name = Column(String, nullable=False)
    gym_purpose = Column(String, nullable=True)

    __mapper_args__ = {"primary_key": [fighter_id, bout_id, gym_name]}


class TapologyEvents(Base):
    __tablename__ = "tapology_events"

    id = Column(String, primary_key=True)
    ufc_id = Column(String, nullable=True)
    name = Column(String, nullable=False)


class TapologyBouts(Base):
    __tablename__ = "tapology_bouts"

    id = Column(String, primary_key=True)
    event_id = Column(String, ForeignKey("tapology_events.id"), nullable=False)
    bout_order = Column(Integer, nullable=False)
    fighter_1_id = Column(String, ForeignKey("tapology_fighters.id"), nullable=False)
    fighter_2_id = Column(String, ForeignKey("tapology_fighters.id"), nullable=False)
    billing = Column(String, nullable=False)
    weight_class_final_weight_lbs = Column(Integer, nullable=True)
    weight_class_original_weight_lbs = Column(Integer, nullable=True)
    outcome_method = Column(String, nullable=True)
    outcome_method_details = Column(String, nullable=True)
    fighter_1_odds = Column(Integer, nullable=True)
    fighter_2_odds = Column(Integer, nullable=True)
    fighter_1_weight_lbs = Column(Float, nullable=True)
    fighter_2_weight_lbs = Column(Float, nullable=True)


class TapologyCommunityPicks(Base):
    __tablename__ = "tapology_community_picks"

    bout_id = Column(String, ForeignKey("tapology_bouts.id"), nullable=False)
    fighter_id = Column(String, ForeignKey("tapology_fighters.id"), nullable=False)
    ko_tko_percentage = Column(Float, nullable=False)
    submission_percentage = Column(Float, nullable=False)
    decision_percentage = Column(Float, nullable=False)
    overall_percentage = Column(Integer, nullable=False)
    num_picks = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [bout_id, fighter_id]}


class TapologyGyms(Base):
    __tablename__ = "tapology_gyms"

    id = Column(String, primary_key=True)
    name = Column(String, nullable=False)
    name_alternative = Column(String, nullable=True)
    location = Column(String, nullable=True)
    parent_id = Column(String, ForeignKey("tapology_gyms.id"), nullable=True)


class TapologyRehydrationWeights(Base):
    __tablename__ = "tapology_rehydration_weights"

    bout_id = Column(String, ForeignKey("tapology_bouts.id"), nullable=False)
    fighter_id = Column(String, ForeignKey("tapology_fighters.id"), nullable=False)
    weigh_in_result_lbs = Column(Float, nullable=False)
    fight_night_weight_lbs = Column(Float, nullable=False)
    weight_gain_lbs = Column(Float, nullable=False)

    __mapper_args__ = {"primary_key": [bout_id, fighter_id]}
