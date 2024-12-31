# standard library imports
import json

# third party imports
from scrapy import Request
from scrapy.spiders import Spider

# local imports
from ..gql_queries import (
    EVENT_FIGHTS_QUERY,
    EVENT_QUERY,
    EVENTS_RECENT_QUERY,
    FIGHTER_QUERY,
)
from ..items.fightoddsio_items import (
    FightOddsIOBoutItem,
    FightOddsIOEventItem,
    FightOddsIOFighterItem,
)


class FightOddsIOSpider(Spider):
    name = "fightoddsio_spider"
    allowed_domains = ["fightodds.io"]
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
        "RETRY_TIMES": 1,
        "LOG_LEVEL": "INFO",
        "LOG_FORMATTER": "scrapy_ufc.logformatter.PoliteLogFormatter",
        "ITEM_PIPELINES": {
            # TODO: add pipeline
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.gql_url = "https://api.fightinsider.io/gql"
        self.headers = {
            "X-Requested-With": "XMLHttpRequest",
            "Content-Type": "application/json",
        }
        self.latest_date = "2024-12-31"

        # Weird cases as a result of the website and its DB having awful design
        self.bad_event_pks = {
            4262,
            1075,
            753,
            4261,
            620,
            4260,
            4259,
            1471,
            1592,
            4258,
            2305,
            2971,
            2982,
            3016,
            3027,
            2983,
            3042,
            3055,
            3730,
        }
        self.edge_case_bout_slugs = {
            "gegard-mousasi-vs-mark-munoz-9476",
            "cb-dollaway-vs-francis-carmont-9528",
            "sean-strickland-vs-luke-barnatt-9586",
            "niklas-backstrom-vs-tom-niinimaki-9641",
            "nick-hein-vs-drew-dober-9701",
            "magnus-cedenblad-vs-krzysztof-jotko-9760",
            "iuri-alcantara-vs-vaughan-lee-9816",
            "peter-sobotta-vs-pawel-pawlak-9873",
            "maximo-blanco-vs-andy-ogle-9925",
            "ruslan-magomedov-vs-viktor-pesta-9981",
        }
        self.duplicates = {
            "ross-pearson-vs-george-sotiropoulos-9465",
            "robert-whittaker-vs-bradley-scott-9516",
            "norman-parke-vs-colin-fletcher-9575",
            "hector-lombard-vs-rousimar-palhares-9631",
            "chad-mendes-vs-yaotzin-meza-9688",
            "joey-beltran-vs-igor-pokrajac-9747",
            "mike-pierce-vs-seth-baczynski-9802",
            "benny-alloway-vs-manuel-rodriguez-9861",
            "mike-wilkinson-vs-brendan-loughnane-9914",
            "cody-donovan-vs-nick-penner-9968",
            "anthony-macias-vs-he-man-ali-gipson-265",
            "heather-clark-vs-bec-rawlings-9842",
            "masio-fullen-vs-alex-torres-10056",
        }
        self.dont_exist = {
            "ken-shamrock-vs-tito-ortiz-8826",
            "pascal-krauss-vs-adam-khaliev-9215",
            "pascal-krauss-vs-adam-aliev-9279",
            "ion-cutelaba-vs-luiz-philipe-lins-49546",
            "justin-willis-vs-allen-crowder-20870",
        }
        self.falsely_cancelled = {
            "alexander-hernandez-vs-beneil-dariush-22185",
            "cm-punk-vs-mike-jackson-22023",
        }

    def start_requests(self):
        payload = json.dumps(
            {
                "query": EVENTS_RECENT_QUERY,
                "variables": {
                    "promotionSlug": "ufc",
                    "dateLt": self.latest_date,
                    "after": "",
                    "first": 100,
                    "orderBy": "-date",
                },
            }
        )

        yield Request(
            url=self.gql_url,
            method="POST",
            headers=self.headers,
            body=payload,
            callback=self.parse_infinite_scroll,
            dont_filter=True,
            cb_kwargs={"event_pks_all": []},
        )

    def parse_infinite_scroll(self, response, event_pks_all):
        json_resp = json.loads(response.body)
        events = json_resp["data"]["promotion"]["events"]
        edges = events["edges"]
        event_pks = [edge["node"]["pk"] for edge in edges]

        for edge, pk in zip(edges, event_pks):
            event_name = edge["node"]["name"]

            if "UFC" not in event_name and "The Ultimate Fighter" not in event_name:
                continue

            if pk in self.bad_event_pks:
                continue

            event_pks_all.append(pk)

        has_next_page = events["pageInfo"]["hasNextPage"]
        if has_next_page:
            cursor_pos = events["pageInfo"]["endCursor"]
            payload_pagination = json.dumps(
                {
                    "query": EVENTS_RECENT_QUERY,
                    "variables": {
                        "promotionSlug": "ufc",
                        "dateLt": self.latest_date,
                        "after": cursor_pos,
                        "first": 100,
                        "orderBy": "-date",
                    },
                }
            )

            yield Request(
                url=self.gql_url,
                method="POST",
                headers=self.headers,
                body=payload_pagination,
                callback=self.parse_infinite_scroll,
                dont_filter=True,
                cb_kwargs={"event_pks_all": event_pks_all},
            )
        else:
            for i, pk in enumerate(reversed(event_pks_all)):
                # Get event metadata
                payload_event = json.dumps(
                    {"query": EVENT_QUERY, "variables": {"eventPk": pk}}
                )

                yield Request(
                    url=self.gql_url,
                    method="POST",
                    headers=self.headers,
                    body=payload_event,
                    callback=self.parse_event,
                    dont_filter=True,
                    cb_kwargs={"event_order": i + 1},
                )

                # Get bouts for event
                payload_fights = json.dumps(
                    {"query": EVENT_FIGHTS_QUERY, "variables": {"eventPk": pk}}
                )

                yield Request(
                    url=self.gql_url,
                    method="POST",
                    headers=self.headers,
                    body=payload_fights,
                    callback=self.parse_event_bouts,
                    dont_filter=True,
                )

    def parse_event(self, response, event_order):
        json_resp = json.loads(response.body)
        event = json_resp["data"]["event"]

        if event:
            event_item = FightOddsIOEventItem()

            event_item["id"] = event["id"] if event["id"] else None
            event_item["pk"] = event["pk"] if event["pk"] else None
            event_item["slug"] = event["slug"] if event["slug"] else None
            event_item["name"] = event["name"] if event["name"] else None
            event_item["date"] = event["date"] if event["date"] else None
            event_item["location"] = event["city"] if event["city"] else None
            event_item["venue"] = event["venue"] if event["venue"] else None
            event_item["event_order"] = event_order

            if event_item["slug"] == "ufc-fight-night-65-miocic-vs-hunt":
                event_item["location"] = "Adelaide, South Australia, Australia"
                event_item["venue"] = "Adelaide Entertainment Centre"
            elif event_item["slug"] == "ufc-fight-night-98-dos-anjos-vs-ferguson":
                event_item["venue"] = "Mexico City Arena"

            yield event_item

    def parse_event_bouts(self, response):
        json_resp = json.loads(response.body)
        bouts = json_resp["data"]["event"]["fights"]
        event_id = json_resp["data"]["event"]["id"]
        event_pk = json_resp["data"]["event"]["pk"]
        event_slug = json_resp["data"]["event"]["slug"]

        fighter_slugs = []
        for bout in bouts:
            if (
                bout["node"]["slug"] in self.duplicates
                or bout["node"]["slug"] in self.dont_exist
            ):
                continue

            bout_item = FightOddsIOBoutItem()

            bout_node = bout["node"]
            bout_item["id"] = bout_node["id"] if bout_node["id"] else None
            bout_item["pk"] = bout_node["pk"] if bout_node["pk"] else None
            bout_item["slug"] = bout_node["slug"] if bout_node["slug"] else None
            bout_item["event_id"] = event_id if event_id else None
            bout_item["event_pk"] = event_pk if event_pk else None
            bout_item["event_slug"] = event_slug if event_slug else None
            bout_item["fighter_1_id"] = (
                bout_node["fighter1"]["id"] if bout_node["fighter1"]["id"] else None
            )
            bout_item["fighter_1_pk"] = (
                bout_node["fighter1"]["pk"] if bout_node["fighter1"]["pk"] else None
            )
            f1_slug = bout_node["fighter1"]["slug"]
            bout_item["fighter_1_slug"] = f1_slug if f1_slug else None

            if f1_slug is not None and f1_slug not in fighter_slugs:
                fighter_slugs.append(f1_slug)

            bout_item["fighter_2_id"] = (
                bout_node["fighter2"]["id"] if bout_node["fighter2"]["id"] else None
            )
            bout_item["fighter_2_pk"] = (
                bout_node["fighter2"]["pk"] if bout_node["fighter2"]["pk"] else None
            )
            f2_slug = bout_node["fighter2"]["slug"]
            bout_item["fighter_2_slug"] = f2_slug if f2_slug else None

            if f2_slug is not None and f2_slug not in fighter_slugs:
                fighter_slugs.append(f2_slug)

            if bout_node["fighterWinner"]:
                bout_item["winner_id"] = (
                    bout_node["fighterWinner"]["id"]
                    if bout_node["fighterWinner"]["id"]
                    else None
                )
                bout_item["winner_pk"] = (
                    bout_node["fighterWinner"]["pk"]
                    if bout_node["fighterWinner"]["pk"]
                    else None
                )
                bout_item["winner_slug"] = (
                    bout_node["fighterWinner"]["slug"]
                    if bout_node["fighterWinner"]["slug"]
                    else None
                )

            bout_item["bout_type"] = (
                bout_node["fightType"] if bout_node["fightType"] else None
            )

            if bout_node["weightClass"]:
                bout_item["weight_class"] = (
                    bout_node["weightClass"]["weightClass"]
                    if bout_node["weightClass"]["weightClass"]
                    else None
                )
                bout_item["weight_lbs"] = (
                    bout_node["weightClass"]["weight"]
                    if bout_node["weightClass"]["weight"]
                    else None
                )

            bout_item["outcome_method"] = (
                bout_node["methodOfVictory1"] if bout_node["methodOfVictory1"] else None
            )
            bout_item["outcome_method_details"] = (
                bout_node["methodOfVictory2"] if bout_node["methodOfVictory2"] else None
            )
            bout_item["end_round"] = bout_node["round"] if bout_node["round"] else None
            bout_item["end_round_time"] = (
                bout_node["duration"] if bout_node["duration"] else None
            )
            bout_item["fighter_1_odds"] = (
                bout_node["fighter1Odds"] if bout_node["fighter1Odds"] else None
            )
            bout_item["fighter_2_odds"] = (
                bout_node["fighter2Odds"] if bout_node["fighter2Odds"] else None
            )

            if bout_node["isCancelled"] is not None:
                bout_item["is_cancelled"] = 1 if bout_node["isCancelled"] is True else 0
            else:
                bout_item["is_cancelled"] = None

            # Handle edge cases
            if bout_item["slug"] in self.edge_case_bout_slugs:
                bout_item["event_id"] = "RXZlbnROb2RlOjE0ODI="
                bout_item["event_pk"] = 1482
                bout_item["event_slug"] = "ufc-fight-night-41-munoz-vs-mousasi"

            if bout_item["slug"] in self.falsely_cancelled:
                bout_item["is_cancelled"] = 0

            if bout_item["end_round"] is None and bout_item["end_round_time"] is None:
                bout_item["is_cancelled"] = 1

            yield bout_item

            # Odds stuff

        # Get fighter metadata
        for fighter_slug in fighter_slugs:
            payload_fighter = json.dumps(
                {"query": FIGHTER_QUERY, "variables": {"fighterSlug": fighter_slug}}
            )

            yield Request(
                url=self.gql_url,
                method="POST",
                headers=self.headers,
                body=payload_fighter,
                callback=self.parse_fighter,
                dont_filter=True,
            )

    def parse_fighter(self, response):
        json_resp = json.loads(response.body)
        fighter_data = json_resp["data"]["fighter"]

        fighter_item = FightOddsIOFighterItem()

        fighter_item["id"] = fighter_data["id"] if fighter_data["id"] else None
        fighter_item["pk"] = fighter_data["pk"] if fighter_data["pk"] else None
        fighter_item["slug"] = fighter_data["slug"] if fighter_data["slug"] else None
        fighter_item["name"] = (
            f"{fighter_data['firstName']} {fighter_data['lastName']}".strip()
        )
        fighter_item["nickname"] = (
            fighter_data["nickName"] if fighter_data["nickName"] else None
        )
        fighter_item["date_of_birth"] = (
            fighter_data["birthDate"]
            if fighter_data["birthDate"] and fighter_data["birthDate"] != "1970-01-01"
            else None
        )
        fighter_item["height_centimeters"] = (
            float(fighter_data["height"])
            if fighter_data["height"] and fighter_data["height"] != "0.0"
            else None
        )
        fighter_item["reach_inches"] = (
            float(fighter_data["reach"])
            if fighter_data["reach"] and fighter_data["reach"] != "0.0"
            else None
        )
        fighter_item["leg_reach_inches"] = (
            float(fighter_data["legReach"])
            if fighter_data["legReach"] and fighter_data["legReach"] != "0.0"
            else None
        )
        fighter_item["fighting_style"] = (
            fighter_data["fightingStyle"] if fighter_data["fightingStyle"] else None
        )
        fighter_item["stance"] = (
            fighter_data["stance"] if fighter_data["stance"] else None
        )
        fighter_item["nationality"] = (
            fighter_data["nationality"] if fighter_data["nationality"] else None
        )

        yield fighter_item
