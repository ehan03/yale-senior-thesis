# standard library imports
import os

# local imports
from data_models import Base

# third party imports
from sqlalchemy import create_engine

# class DatabaseCreator:
#     def __init__(self) -> None:
#         self.db_path = os.path.join(
#             os.path.dirname(__file__), "..", "..", "data", "ufc.db"
#         )


if __name__ == "__main__":
    db_path = os.path.join(os.path.dirname(__file__), "..", "..", "data", "ufc.db")
    engine = create_engine(f"sqlite:///{db_path}")
    Base.metadata.create_all(engine)
