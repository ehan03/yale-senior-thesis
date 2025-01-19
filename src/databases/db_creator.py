# standard library imports
import os
import sqlite3

# third party imports

# local imports


class DatabaseCreator:
    def __init__(self) -> None:
        self.db_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "data", "ufc.db"
        )
        self.schemas_dir = os.path.join(os.path.dirname(__file__), "schemas")

    def create_tables(self):
        conn = sqlite3.connect(self.db_path)

        for schema_file in os.listdir(self.schemas_dir):
            with open(os.path.join(self.schemas_dir, schema_file), "r") as file:
                schema = file.read()
                conn.executescript(schema)

        conn.commit()
        conn.close()
