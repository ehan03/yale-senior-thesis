# standard library imports
import glob
import os

# third party imports
import pandas as pd

# local imports
from data_models import Base
from sqlalchemy import create_engine


class DatabaseCreator:
    def __init__(self) -> None:
        self.data_dir = os.path.join(os.path.dirname(__file__), "..", "..", "data")
        self.db_path = os.path.join(os.path.dirname(__file__), self.data_dir, "ufc.db")
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

    def prepare_dataframe(self, df: pd.DataFrame, table_name: str) -> pd.DataFrame:
        if table_name == "betmma_fighters":
            df = df.drop(columns=["ufcstats_id", "sherdog_id"])
        elif table_name in [
            "betmma_events",
            "espn_events",
            "fightmatrix_events",
            "fightoddsio_events",
            "mmadecisions_events",
            "sherdog_events",
            "ufcstats_events",
        ]:
            df = df.drop(columns=["event_order"])
        elif table_name == "fightmatrix_fighters":
            df = df.drop(columns=["sherdog_id", "tapology_id"])
        elif table_name == "tapology_fighters":
            df = df.drop(columns=["ufcstats_id", "sherdog_id", "bestfightodds_id"])
        elif table_name == "tapology_events":
            df = df.drop(
                columns=["ufcstats_id", "sherdog_id", "bestfightodds_id", "event_order"]
            )
        elif table_name == "tapology_bouts":
            df = df.drop(columns=["ufcstats_id"])

        return df

    def populate_db(self) -> None:
        # Populate association tables first
        for name in ["bout_mapping", "event_mapping", "fighter_mapping"]:
            df = pd.read_csv(os.path.join(self.data_dir, "clean", f"{name}.csv"))
            df.to_sql(name.upper(), self.engine, index=False, if_exists="append")

        # Populate source tables
        for source_name, table_prefix in self.source_name_map.items():
            folder_path = os.path.join(self.data_dir, "clean", source_name)
            for file_path in glob.glob(os.path.join(folder_path, "*.csv")):
                table_name = (
                    f"{table_prefix}_{os.path.basename(file_path).split('.')[0]}"
                )
                df = pd.read_csv(file_path)
                df = self.prepare_dataframe(df, table_name)
                df.to_sql(table_name, self.engine, index=False, if_exists="append")


if __name__ == "__main__":
    db_creator = DatabaseCreator()
    db_creator.create_db()
    db_creator.populate_db()
