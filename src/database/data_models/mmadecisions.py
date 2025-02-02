# standard library imports

# local imports
from base import Base

# third party imports
from sqlalchemy import Column, Date, Float, ForeignKey, Integer, String


class MMADecisionsFighters(Base):
    __tablename__ = "mmadecisions_fighters"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    nicknames = Column(String, nullable=True)
    date_of_birth = Column(Date, nullable=True)
    birth_location = Column(String, nullable=True)
    height_inches = Column(Float, nullable=True)
    reach_inches = Column(Float, nullable=True)


class MMADecisionsEvents(Base):
    __tablename__ = "mmadecisions_events"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    promotion = Column(String, nullable=False)
    date = Column(Date, nullable=False)
    venue = Column(String, nullable=True)
    location = Column(String, nullable=False)


class MMADecisionsBouts(Base):
    __tablename__ = "mmadecisions_bouts"

    id = Column(Integer, primary_key=True)
    event_id = Column(Integer, ForeignKey("mmadecisions_events.id"), nullable=False)
    bout_order = Column(Integer, nullable=False)
    fighter_1_id = Column(
        Integer, ForeignKey("mmadecisions_fighters.id"), nullable=False
    )
    fighter_2_id = Column(
        Integer, ForeignKey("mmadecisions_fighters.id"), nullable=False
    )
    fighter_1_weight_lbs = Column(Float, nullable=True)
    fighter_2_weight_lbs = Column(Float, nullable=True)
    fighter_1_fighting_out_of = Column(String, nullable=True)
    fighter_2_fighting_out_of = Column(String, nullable=True)
    decision_type = Column(String, nullable=False)


class MMADecisionsJudges(Base):
    __tablename__ = "mmadecisions_judges"

    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)


class MMADecisionsJudgeScores(Base):
    __tablename__ = "mmadecisions_judge_scores"

    bout_id = Column(Integer, ForeignKey("mmadecisions_bouts.id"), nullable=False)
    round = Column(String, nullable=False)
    judge_id = Column(Integer, ForeignKey("mmadecisions_judges.id"), nullable=True)
    judge_order = Column(Integer, nullable=False)
    fighter_1_score = Column(Integer, nullable=True)
    fighter_2_score = Column(Integer, nullable=True)

    __mapper_args__ = {"primary_key": [bout_id, round, judge_order]}


class MMADecisionsMediaScores(Base):
    __tablename__ = "mmadecisions_media_scores"

    bout_id = Column(Integer, ForeignKey("mmadecisions_bouts.id"), nullable=False)
    person_name = Column(String, nullable=True)
    media_name = Column(String, nullable=True)
    fighter_1_score = Column(Integer, nullable=False)
    fighter_2_score = Column(Integer, nullable=False)
    order = Column(Integer, nullable=False)

    __mapper_args__ = {"primary_key": [bout_id, order]}


class MMADecisionsDeductions(Base):
    __tablename__ = "mmadecisions_deductions"

    bout_id = Column(Integer, ForeignKey("mmadecisions_bouts.id"), nullable=False)
    fighter_id = Column(Integer, ForeignKey("mmadecisions_fighters.id"), nullable=False)
    round_number = Column(Integer, nullable=False)
    points_deducted = Column(Integer, nullable=False)
    reason = Column(String, nullable=False)

    __mapper_args__ = {"primary_key": [bout_id, fighter_id, round_number]}
