# standard library imports
import json

# third party imports
import pandas as pd
from scrapy import Request
from scrapy.spiders import Spider

# local imports
from ..items.espn_items import ESPNBoutItem, ESPNEventItem, ESPNVenueItem


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
            # TODO: add pipeline
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        # self.bouts_path

    def start_requests(self):
        pass
