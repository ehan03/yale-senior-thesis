# standard library imports
import os

# third party imports
import pandas as pd

# local imports


class FightOddsIOItemPipeline:
    def __init__(self):
        #

        self.dir_path = os.path.join(
            os.path.dirname(__file__), "..", "..", "..", "..", "data", "FightOdds.io"
        )
