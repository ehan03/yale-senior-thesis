# standard library imports
import os

# local imports
from data_models import Base

# third party imports
from sqlalchemy import create_engine


class DatabaseCreator:
    def __init__(self) -> None:
        self.db_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "data", "ufc.db"
        )
        self.engine = create_engine(f"sqlite:///{self.db_path}")
        self.source_name_map = {
            "Best Fight Odds": "bestfightodds",
            "Bet MMA": "betmma",
            "ESPN": "espn",
            "Fight Matrix": "fightmatrix",
            "FightOdds.io": "fightoddsio",
            "MMA Decisions": "mmadecisions",
            "Sherdog": "sherdog",
            "Tapology": "tapology",
            "UFC Stats": "ufcstats",
            "Wikipedia": "wikipedia",
        }

    def create_db(self) -> None:
        Base.metadata.create_all(self.engine)

    def populate_db(self) -> None:
        pass


if __name__ == "__main__":
    db_creator = DatabaseCreator()
    db_creator.create_db()
    db_creator.populate_db()
