# standard library imports
from typing import List, Optional, Tuple

# local imports

# third party imports


def convert_height(height: str) -> Optional[int]:
    if height != "--":
        feet, inches = height.split()
        return 12 * int(feet[:-1]) + int(inches[:-1])
    else:
        return None


def compute_fight_times(
    format: str, end_round: int, end_round_time_seconds: int
) -> Tuple[int, List[int]]:
    one_round = {
        "No Time Limit",
        "1 Rnd (20)",
        "1 Rnd (30)",
        "1 Rnd (15)",
        "1 Rnd (18)",
        "1 Rnd (10)",
        "1 Rnd (12)",
    }
    uniform_rounds = {
        "3 Rnd (2-2-2)",
        "2 Rnd (3-3)",
        "3 Rnd (3-3-3)",
        "5 Rnd (3-3-3-3-3)",
        "3 Rnd (4-4-4)",
        "5 Rnd (4-4-4-4-4)",
        "2 Rnd (5-5)",
        "3 Rnd (5-5-5)",
        "5 Rnd (5-5-5-5-5)",
        "3 Rnd + OT (5-5-5-5)",
        "3 Rnd (8-8-8)",
        "2 Rnd (10-10)",
        "3 Rnd (10-10-10)",
        "4 Rnd (10-10-10-10)",
        "Unlimited Rnd (10)",
        "Unlimited Rnd (15)",
        "Unlimited Rnd (20)",
    }
    others = {
        "1 Rnd + OT (12-3)",
        "1 Rnd + OT (15-3)",
        "1 Rnd + OT (15-10)",
        "1 Rnd + OT (27-3)",
        "1 Rnd + OT (30-3)",
        "1 Rnd + OT (30-5)",
        "1 Rnd + OT (31-5)",
        "1 Rnd + 2OT (15-3-3)",
        "1 Rnd + 2OT (24-3-3)",
        "2 Rnd (10-5)",
        "3 Rnd (10-5-5)",
        "3 Rnd (10-10-5)",
    }

    if format in one_round:
        return end_round_time_seconds, [end_round_time_seconds]
    elif format in uniform_rounds:
        round_length = int(
            format.split(" ")[-1].replace("(", "").replace(")", "").split("-")[0]
        )
        return end_round_time_seconds + round_length * 60 * (end_round - 1), [
            round_length * 60
        ] * (end_round - 1) + [end_round_time_seconds]
    elif format in others:
        round_lengths = [
            int(x)
            for x in format.split(" ")[-1].replace("(", "").replace(")", "").split("-")
        ]
        return end_round_time_seconds + sum(round_lengths[: end_round - 1]) * 60, [
            x * 60 for x in round_lengths[: end_round - 1]
        ] + [end_round_time_seconds]
    else:
        raise ValueError(f"Unknown format: {format}")


def extract_landed_attempted(landed_attempted: str) -> Tuple[int, int]:
    splitted = landed_attempted.split(" of ")

    return (int(splitted[0]), int(splitted[1]))


def compute_control_time(time: str) -> Optional[int]:
    if time == "--":
        return None
    else:
        temp = time.split(":")

        return 60 * int(temp[0]) + int(temp[1])
