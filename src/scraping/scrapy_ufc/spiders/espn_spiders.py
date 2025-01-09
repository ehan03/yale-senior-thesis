# standard library imports
import json
import os

# third party imports
import pandas as pd
from scrapy import Request
from scrapy.spiders import Spider

# local imports
from ..items.espn_items import (
    ESPNBoutItem,
    ESPNEventItem,
    ESPNFighterBoutStatisticsItem,
    ESPNFighterHistoryItem,
    ESPNFighterItem,
    ESPNTeamItem,
    ESPNVenueItem,
)


class ESPNEventSpider(Spider):
    name = "espn_event_spider"
    allowed_domains = ["espn.com"]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "CONCURRENT_REQUESTS_PER_DOMAIN": 4,
        "CONCURRENT_REQUESTS": 4,
        "COOKIES_ENABLED": False,
        "DOWNLOADER_MIDDLEWARES": {
            "scrapy.downloadermiddlewares.useragent.UserAgentMiddleware": None,
            "scrapy_user_agents.middlewares.RandomUserAgentMiddleware": 400,
        },
        "REQUEST_FINGERPRINTER_IMPLEMENTATION": "2.7",
        "TWISTED_REACTOR": "twisted.internet.asyncioreactor.AsyncioSelectorReactor",
        "FEED_EXPORT_ENCODING": "utf-8",
        "DEPTH_PRIORITY": 1,
        "SCHEDULER_DISK_QUEUE": "scrapy.squeues.PickleFifoDiskQueue",
        "SCHEDULER_MEMORY_QUEUE": "scrapy.squeues.FifoMemoryQueue",
        "RETRY_TIMES": 0,
        "LOG_LEVEL": "INFO",
        "ITEM_PIPELINES": {
            "scrapy_ufc.pipelines.espn_pipelines.ESPNEventPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.headers = {"Content-Type": "application/json"}
        self.event_ids_by_year = {}

        self.wrong_event_ids = {400254579, 400876180, 401219517, 401219513}

    def start_requests(self):
        seasons = range(1993, 2025)
        for season in seasons:
            url = f"https://site.web.api.espn.com/apis/common/v3/sports/mma/ufc/fightcenter/menu?season={season}"

            yield Request(
                url,
                headers=self.headers,
                callback=self.parse_menu,
                cb_kwargs={"year": season},
            )

    def parse_menu(self, response, year):
        json_resp = json.loads(response.body)

        for menu in json_resp["menus"]:
            if menu["name"] == "event":
                event_options = menu["options"]
                event_ids = []
                for event in event_options:
                    event_id = int(event["value"])
                    event_name = event["displayValue"]

                    if (
                        event_name.startswith("Dana White's Contender Series")
                        or "Semifinal" in event_name
                        or event_id in self.wrong_event_ids
                    ):
                        continue

                    event_ids.append(event_id)

                self.event_ids_by_year[year] = event_ids
                break

        year_range = range(1993, 2025)
        if len(self.event_ids_by_year) == len(year_range):
            event_ids_all = []
            for year in year_range:
                event_ids_all.extend(self.event_ids_by_year[year])

            for i, event_id in enumerate(event_ids_all):
                url = f"https://site.web.api.espn.com/apis/common/v3/sports/mma/ufc/fightcenter/{event_id}"

                yield Request(
                    url=url,
                    headers=self.headers,
                    callback=self.parse_event,
                    cb_kwargs={"event_id": event_id, "event_order": i + 1},
                )

    def parse_event(self, response, event_id, event_order):
        json_resp = json.loads(response.body)

        # Event
        event_item = ESPNEventItem()

        event_item["id"] = event_id
        event_item["name"] = json_resp["event"]["name"]
        event_item["date"] = json_resp["event"]["date"]

        venue_id = None
        if "venue" in json_resp:
            venue_id = int(json_resp["venue"]["id"])

        event_item["venue_id"] = venue_id
        event_item["event_order"] = event_order

        yield event_item

        # Venue
        if "venue" in json_resp:
            venue_item = ESPNVenueItem()

            venue_item["id"] = venue_id
            venue_item["name"] = json_resp["venue"]["fullName"]
            venue_item["city"] = (
                json_resp["venue"]["address"]["city"]
                if "city" in json_resp["venue"]["address"]
                else None
            )
            venue_item["state"] = (
                json_resp["venue"]["address"]["state"]
                if "state" in json_resp["venue"]["address"]
                else None
            )
            venue_item["country"] = (
                json_resp["venue"]["address"]["country"]
                if "country" in json_resp["venue"]["address"]
                else None
            )
            venue_item["is_indoor"] = 1 if json_resp["venue"]["indoor"] else 0

            yield venue_item

        # Bouts
        if "cards" in json_resp:
            bouts_list = []
            cards = json_resp["cards"]
            possible_keys = ["main", "prelims1", "prelims2"]
            for key in possible_keys:
                if key in cards:
                    competitions = cards[key]["competitions"]
                    bouts_list.extend(competitions)

            for i, bout in enumerate(reversed(bouts_list)):
                bout_item = ESPNBoutItem()

                bout_item["id"] = int(bout["id"])
                bout_item["event_id"] = event_id
                bout_item["bout_order"] = i + 1

                competitors = bout["competitors"]
                assert len(competitors) == 2

                winner_id = None
                for competitor in competitors:
                    if competitor["order"] == 1:
                        bout_item["red_fighter_id"] = int(competitor["id"])
                    else:
                        bout_item["blue_fighter_id"] = int(competitor["id"])

                    if competitor["winner"]:
                        winner_id = int(competitor["id"])

                bout_item["winner_id"] = winner_id
                bout_item["card_segment"] = bout["cardSegment"]["description"]

                yield bout_item


class ESPNFighterSpider(Spider):
    name = "espn_fighter_spider"
    allowed_domains = ["espn.com"]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "CONCURRENT_REQUESTS_PER_DOMAIN": 4,
        "CONCURRENT_REQUESTS": 4,
        "COOKIES_ENABLED": False,
        "DOWNLOADER_MIDDLEWARES": {
            "scrapy.downloadermiddlewares.useragent.UserAgentMiddleware": None,
            "scrapy.downloadermiddlewares.retry.RetryMiddleware": None,
            "scrapy_fake_useragent.middleware.RandomUserAgentMiddleware": 400,
            "scrapy_fake_useragent.middleware.RetryUserAgentMiddleware": 401,
        },
        "REQUEST_FINGERPRINTER_IMPLEMENTATION": "2.7",
        "TWISTED_REACTOR": "twisted.internet.asyncioreactor.AsyncioSelectorReactor",
        "FEED_EXPORT_ENCODING": "utf-8",
        "DEPTH_PRIORITY": 1,
        "SCHEDULER_DISK_QUEUE": "scrapy.squeues.PickleFifoDiskQueue",
        "SCHEDULER_MEMORY_QUEUE": "scrapy.squeues.FifoMemoryQueue",
        "RETRY_TIMES": 10,
        "LOG_LEVEL": "INFO",
        "ITEM_PIPELINES": {
            "scrapy_ufc.pipelines.espn_pipelines.ESPNFighterPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
        "DOWNLOAD_DELAY": 3,
        "FAKEUSERAGENT_PROVIDERS": [
            "scrapy_fake_useragent.providers.FakeUserAgentProvider",
            "scrapy_fake_useragent.providers.FakerProvider",
        ],
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.bouts_path = os.path.join(
            os.path.dirname(__file__),
            "..",
            "..",
            "..",
            "..",
            "data",
            "ESPN",
            "bouts.csv",
        )

    def start_requests(self):
        bouts_df = pd.read_csv(self.bouts_path)
        red_fighter_ids = bouts_df["red_fighter_id"].unique().tolist()
        blue_fighter_ids = bouts_df["blue_fighter_id"].unique().tolist()

        fighter_ids = set(red_fighter_ids + blue_fighter_ids)
        print(f"Number of fighters: {len(fighter_ids)}")
        for fighter_id in fighter_ids:
            base_url = f"https://site.web.api.espn.com/apis/common/v3/sports/mma/athletes/{fighter_id}"
            stats_url = f"https://site.web.api.espn.com/apis/common/v3/sports/mma/athletes/{fighter_id}/stats"

            yield Request(
                base_url,
                callback=self.parse_fighter_bio_and_history,
                cb_kwargs={"fighter_id": fighter_id, "depth": 0},
            )

            yield Request(
                stats_url,
                callback=self.parse_fighter_stats,
                cb_kwargs={"fighter_id": fighter_id},
            )

    def parse_fighter_bio_and_history(self, response, fighter_id, depth):
        json_resp = json.loads(response.body)

        if "athlete" in json_resp:
            fighter_item = ESPNFighterItem()

            fighter_item["id"] = fighter_id
            fighter_item["name"] = (
                json_resp["athlete"]["displayName"]
                if "displayName" in json_resp["athlete"]
                else None
            )
            fighter_item["nickname"] = (
                json_resp["athlete"]["nickname"]
                if "nickname" in json_resp["athlete"]
                else None
            )
            fighter_item["date_of_birth"] = (
                json_resp["athlete"]["displayDOB"]
                if "displayDOB" in json_resp["athlete"]
                else None
            )
            fighter_item["height"] = (
                json_resp["athlete"]["displayHeight"]
                if "displayHeight" in json_resp["athlete"]
                else None
            )
            fighter_item["reach"] = (
                json_resp["athlete"]["displayReach"]
                if "displayReach" in json_resp["athlete"]
                else None
            )

            stance = None
            if "stance" in json_resp["athlete"]:
                stance = (
                    json_resp["athlete"]["stance"]["text"]
                    if "text" in json_resp["athlete"]["stance"]
                    else None
                )
            fighter_item["stance"] = stance

            team_id = None
            team_name = None
            if "association" in json_resp["athlete"]:
                team_id = int(json_resp["athlete"]["association"]["id"])
                team_name = (
                    json_resp["athlete"]["association"]["name"]
                    if "name" in json_resp["athlete"]["association"]
                    else None
                )
            fighter_item["team_id"] = team_id if team_id != 0 else None

            fighter_item["nationality"] = (
                json_resp["athlete"]["citizenship"]
                if "citizenship" in json_resp["athlete"]
                else None
            )
            fighter_item["fighting_style"] = (
                json_resp["athlete"]["displayFightingStyle"]
                if "displayFightingStyle" in json_resp["athlete"]
                else None
            )

            yield fighter_item

            # Team information
            if team_id is not None and team_id != 0:
                team_item = ESPNTeamItem()

                team_item["id"] = team_id
                team_item["name"] = team_name

                yield team_item

        opponent_ids = []
        if "eventsMap" in json_resp:
            events_map = json_resp["eventsMap"]
            for i, event_dict in enumerate(reversed(events_map.values())):
                fighter_history_item = ESPNFighterHistoryItem()

                fighter_history_item["fighter_id"] = fighter_id
                fighter_history_item["order"] = i + 1
                fighter_history_item["bout_id"] = (
                    int(event_dict["uid"].split(":")[-1])
                    if "uid" in event_dict
                    else None
                )
                fighter_history_item["event_id"] = (
                    int(event_dict["id"]) if "id" in event_dict else None
                )
                fighter_history_item["event_name"] = (
                    event_dict["name"] if "name" in event_dict else None
                )
                fighter_history_item["date"] = (
                    event_dict["gameDate"] if "gameDate" in event_dict else None
                )

                opponent_id = None
                if "opponent" in event_dict:
                    opponent_id = (
                        int(event_dict["opponent"]["id"])
                        if "id" in event_dict["opponent"]
                        else None
                    )
                fighter_history_item["opponent_id"] = opponent_id
                fighter_history_item["outcome"] = (
                    event_dict["gameResult"] if "gameResult" in event_dict else None
                )

                outcome_method = None
                end_round = None
                end_round_time = None
                if "status" in event_dict:
                    end_round = (
                        event_dict["status"]["period"]
                        if "period" in event_dict["status"]
                        else None
                    )
                    end_round_time = (
                        event_dict["status"]["displayClock"]
                        if "displayClock" in event_dict["status"]
                        else None
                    )

                    if "result" in event_dict["status"]:
                        outcome_method = (
                            event_dict["status"]["result"]["displayName"]
                            if "displayName" in event_dict["status"]["result"]
                            else None
                        )
                fighter_history_item["outcome_method"] = outcome_method
                fighter_history_item["end_round"] = end_round
                fighter_history_item["end_round_time"] = end_round_time

                if "titleFight" in event_dict:
                    fighter_history_item["is_title_bout"] = (
                        1 if event_dict["titleFight"] else 0
                    )
                else:
                    fighter_history_item["is_title_bout"] = None

                yield fighter_history_item

                if opponent_id is not None:
                    opponent_ids.append(opponent_id)

        opponent_ids = set(opponent_ids)
        if depth < 1:
            for opponent_id in opponent_ids:
                base_url = f"https://site.web.api.espn.com/apis/common/v3/sports/mma/athletes/{opponent_id}"
                stats_url = f"https://site.web.api.espn.com/apis/common/v3/sports/mma/athletes/{opponent_id}/stats"

                yield Request(
                    base_url,
                    callback=self.parse_fighter_bio_and_history,
                    cb_kwargs={"fighter_id": opponent_id, "depth": depth + 1},
                )

                yield Request(
                    stats_url,
                    callback=self.parse_fighter_stats,
                    cb_kwargs={"fighter_id": opponent_id},
                )

    def parse_fighter_stats(self, response, fighter_id):
        json_resp = json.loads(response.body)

        if "categories" in json_resp:
            categories = json_resp["categories"]
            assert len(categories) == 3

            striking = [
                cat for cat in categories if cat["displayName"].lower() == "striking"
            ][0]
            clinch = [
                cat for cat in categories if cat["displayName"].lower() == "clinch"
            ][0]
            ground = [
                cat for cat in categories if cat["displayName"].lower() == "ground"
            ][0]

            striking_stats = striking["statistics"]
            clinch_stats = clinch["statistics"]
            ground_stats = ground["statistics"]
            assert len(striking_stats) == len(clinch_stats) == len(ground_stats)

            for i, (event_striking, event_clinch, event_ground) in enumerate(
                reversed(
                    list(
                        zip(
                            striking_stats,
                            clinch_stats,
                            ground_stats,
                        )
                    )
                )
            ):
                fighter_stats_item = ESPNFighterBoutStatisticsItem()

                fighter_stats_item["fighter_id"] = fighter_id
                fighter_stats_item["order"] = i + 1
                fighter_stats_item["bout_id"] = (
                    int(event_striking["uid"].split(":")[-1])
                    if "uid" in event_striking
                    else None
                )
                fighter_stats_item["event_id"] = (
                    int(event_striking["eventId"])
                    if "eventId" in event_striking
                    else None
                )

                assert len(event_striking["stats"]) == 12
                assert len(event_clinch["stats"]) == 12
                assert len(event_ground["stats"]) == 12

                fighter_stats_item["knockdowns_scored"] = (
                    int(event_striking["stats"][8])
                    if event_striking["stats"][8] != "-"
                    else None
                )
                fighter_stats_item["total_strikes_landed"] = (
                    int(event_striking["stats"][3])
                    if event_striking["stats"][3] != "-"
                    else None
                )
                fighter_stats_item["total_strikes_attempted"] = (
                    int(event_striking["stats"][4])
                    if event_striking["stats"][4] != "-"
                    else None
                )
                fighter_stats_item["takedowns_landed"] = (
                    int(event_clinch["stats"][8])
                    if event_clinch["stats"][8] != "-"
                    else None
                )
                fighter_stats_item["takedowns_slams_landed"] = (
                    int(event_clinch["stats"][10])
                    if event_clinch["stats"][10] != "-"
                    else None
                )
                fighter_stats_item["takedowns_attempted"] = (
                    int(event_clinch["stats"][9])
                    if event_clinch["stats"][9] != "-"
                    else None
                )
                fighter_stats_item["reversals_scored"] = (
                    int(event_clinch["stats"][6])
                    if event_clinch["stats"][6] != "-"
                    else None
                )
                (
                    fighter_stats_item["significant_strikes_distance_head_landed"],
                    fighter_stats_item["significant_strikes_distance_head_attempted"],
                ) = (
                    [int(x) for x in event_striking["stats"][1].split("/")]
                    if event_striking["stats"][1] != "-"
                    else [None, None]
                )
                (
                    fighter_stats_item["significant_strikes_distance_body_landed"],
                    fighter_stats_item["significant_strikes_distance_body_attempted"],
                ) = (
                    [int(x) for x in event_striking["stats"][0].split("/")]
                    if event_striking["stats"][0] != "-"
                    else [None, None]
                )
                (
                    fighter_stats_item["significant_strikes_distance_leg_landed"],
                    fighter_stats_item["significant_strikes_distance_leg_attempted"],
                ) = (
                    [int(x) for x in event_striking["stats"][2].split("/")]
                    if event_striking["stats"][2] != "-"
                    else [None, None]
                )
                fighter_stats_item["significant_strikes_clinch_head_landed"] = (
                    int(event_clinch["stats"][2])
                    if event_clinch["stats"][2] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_clinch_head_attempted"] = (
                    int(event_clinch["stats"][3])
                    if event_clinch["stats"][3] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_clinch_body_landed"] = (
                    int(event_clinch["stats"][0])
                    if event_clinch["stats"][0] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_clinch_body_attempted"] = (
                    int(event_clinch["stats"][1])
                    if event_clinch["stats"][1] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_clinch_leg_landed"] = (
                    int(event_clinch["stats"][4])
                    if event_clinch["stats"][4] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_clinch_leg_attempted"] = (
                    int(event_clinch["stats"][5])
                    if event_clinch["stats"][5] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_ground_head_landed"] = (
                    int(event_ground["stats"][2])
                    if event_ground["stats"][2] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_ground_head_attempted"] = (
                    int(event_ground["stats"][3])
                    if event_ground["stats"][3] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_ground_body_landed"] = (
                    int(event_ground["stats"][0])
                    if event_ground["stats"][0] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_ground_body_attempted"] = (
                    int(event_ground["stats"][1])
                    if event_ground["stats"][1] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_ground_leg_landed"] = (
                    int(event_ground["stats"][4])
                    if event_ground["stats"][4] != "-"
                    else None
                )
                fighter_stats_item["significant_strikes_ground_leg_attempted"] = (
                    int(event_ground["stats"][5])
                    if event_ground["stats"][5] != "-"
                    else None
                )
                fighter_stats_item["advances"] = (
                    int(event_ground["stats"][6])
                    if event_ground["stats"][6] != "-"
                    else None
                )
                fighter_stats_item["advances_to_back"] = (
                    int(event_ground["stats"][7])
                    if event_ground["stats"][7] != "-"
                    else None
                )
                fighter_stats_item["advances_to_half_guard"] = (
                    int(event_ground["stats"][8])
                    if event_ground["stats"][8] != "-"
                    else None
                )
                fighter_stats_item["advances_to_mount"] = (
                    int(event_ground["stats"][9])
                    if event_ground["stats"][9] != "-"
                    else None
                )
                fighter_stats_item["advances_to_side"] = (
                    int(event_ground["stats"][10])
                    if event_ground["stats"][10] != "-"
                    else None
                )
                fighter_stats_item["submissions_attempted"] = (
                    int(event_ground["stats"][11])
                    if event_ground["stats"][11] != "-"
                    else None
                )

                yield fighter_stats_item
