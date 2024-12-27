# standard library imports
import time

# third party imports
import pandas as pd
import w3lib.html
from scrapy.spiders import Spider

# local imports
from ..items.fightmatrix_items import (
    FightMatrixBoutItem,
    FightMatrixEventItem,
    FightMatrixFighterHistoryItem,
    FightMatrixFighterItem,
    FightMatrixRankingItem,
)


class FightMatrixMainSpider(Spider):
    name = "fightmatrix_main_spider"
    allowed_domains = ["fightmatrix.com"]
    start_urls = ["https://www.fightmatrix.com/past-events-search/?org=UFC"]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "CONCURRENT_REQUESTS_PER_DOMAIN": 1,
        "CONCURRENT_REQUESTS": 1,
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
            "scrapy_ufc.pipelines.fightmatrix_pipelines.FightMatrixMainItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
        "DOWNLOAD_DELAY": 1.5,
        "AUTOTHROTTLE_ENABLED": True,
        "AUTOTHROTTLE_START_DELAY": 1.5,
        "AUTOTHROTTLE_TARGET_CONCURRENCY": 1,
        "AUTOTHROTTLE_MAX_DELAY": 5,
    }

    def parse(self, response):
        events = response.css(
            """table.tblRank[style='width:945px; border-collapse: collapse; border: 1px solid black'] 
            > tr"""
        )

        event_links = []
        for event in events[1:]:
            event_link = event.css(
                """td[style='border: 0px solid black; text-align: left'] 
                > a.redLink::attr(href)"""
            ).get()
            event_name = (
                event.css(
                    """td[style='border: 0px solid black; text-align: left']
                    > a.redLink::text"""
                )
                .get()
                .strip()
            )

            if "Road to UFC" in event_name:
                continue

            event_id = int(event_link.split("/")[-2])
            event_links.append(f"/event/.../{event_id}/")

        for i, event_link in enumerate(reversed(event_links)):
            event_order = i + 1
            yield response.follow(
                response.urljoin(event_link),
                callback=self.parse_event,
                cb_kwargs={"is_ufc_event": 1, "event_order": event_order},
            )

    def parse_event(self, response, is_ufc_event, event_order):
        event_item = FightMatrixEventItem()

        event_id = int(response.url.split("/")[-2])
        name = response.css("H2 > a[style='text-decoration: none']::text").get()
        name = name.strip() if name else None

        h3_text = w3lib.html.remove_tags(
            response.css("H3[style='font-size: 18px;']").get()
        ).strip()
        h3_split = [x.strip() for x in h3_text.split(",")]
        if len(h3_split) > 3:
            h3_split = [", ".join(h3_split[:-2]), h3_split[-2], h3_split[-1]]

        assert len(h3_split) == 3

        promotion = h3_split[0] if h3_split[0] else None
        date = pd.to_datetime(h3_split[2]).strftime("%Y-%m-%d") if h3_split[2] else None

        flag_src = response.css("H3[style='font-size: 18px;'] > img::attr(src)").get()
        country = flag_src.split("/")[-1].split(".")[0].upper() if flag_src else None

        event_item["id"] = event_id
        event_item["name"] = name
        event_item["promotion"] = promotion
        event_item["date"] = date
        event_item["country"] = country
        event_item["is_ufc_event"] = is_ufc_event
        event_item["event_order"] = event_order

        yield event_item

        table = response.css("table.tblRank")
        rows = table.css("tr")[1:]

        for i, row in enumerate(reversed(rows)):
            bout_item = FightMatrixBoutItem()

            bout_item["event_id"] = event_id
            bout_item["bout_order"] = i + 1

            tds = row.css("td")
            bout_item["fighter_1_id"] = int(
                tds[1].css("a::attr(href)").get().split("/")[-2]
            )

            f1_elo_string_split = (
                w3lib.html.remove_tags(tds[1].css("::attr(onmouseover)").get().strip())
                .replace("LoadCustomData('stat','|", "")
                .replace("|'); TagToTip('tip_div')", "")
            ).split("|")
            assert len(f1_elo_string_split) == 6

            bout_item["fighter_1_elo_k170_pre"] = int(f1_elo_string_split[0])
            bout_item["fighter_1_elo_k170_post"] = int(f1_elo_string_split[1])
            bout_item["fighter_1_elo_modified_pre"] = int(f1_elo_string_split[2])
            bout_item["fighter_1_elo_modified_post"] = int(f1_elo_string_split[3])
            bout_item["fighter_1_glicko_1_pre"] = int(f1_elo_string_split[4])
            bout_item["fighter_1_glicko_1_post"] = int(f1_elo_string_split[5])

            outcome_split = [
                x.strip() for x in tds[1].css("p::text").get().split(" - ")
            ]
            if len(outcome_split) > 3:
                outcome_split = [
                    outcome_split[0],
                    " - ".join(outcome_split[1:-1]),
                    outcome_split[-1],
                ]

            assert len(outcome_split) == 3

            bout_item["fighter_1_outcome"] = outcome_split[0]
            bout_item["fighter_2_outcome"] = (
                "L" if outcome_split[0] == "W" else outcome_split[0]
            )
            bout_item["outcome_method"] = outcome_split[1]
            bout_item["end_round"] = int(outcome_split[2].split(" ")[-1])

            bout_item["fighter_2_id"] = int(
                tds[3].css("a::attr(href)").get().split("/")[-2]
            )

            f2_elo_string_split = (
                w3lib.html.remove_tags(tds[3].css("::attr(onmouseover)").get().strip())
                .replace("LoadCustomData('stat','|", "")
                .replace("|'); TagToTip('tip_div')", "")
            ).split("|")
            assert len(f2_elo_string_split) == 6

            bout_item["fighter_2_elo_k170_pre"] = int(f2_elo_string_split[0])
            bout_item["fighter_2_elo_k170_post"] = int(f2_elo_string_split[1])
            bout_item["fighter_2_elo_modified_pre"] = int(f2_elo_string_split[2])
            bout_item["fighter_2_elo_modified_post"] = int(f2_elo_string_split[3])
            bout_item["fighter_2_glicko_1_pre"] = int(f2_elo_string_split[4])
            bout_item["fighter_2_glicko_1_post"] = int(f2_elo_string_split[5])

            bout_item["weight_class"] = tds[4].css("::text").get().strip()

            yield bout_item

        if is_ufc_event == 1:
            fighter_links = response.css("a.sherLink::attr(href)").getall()

            yield from response.follow_all(
                [
                    response.urljoin(link)
                    for link in fighter_links
                    if "fighter-profile" in link
                ],
                self.parse_fighter,
            )

    def parse_fighter(self, response):
        fighter_item = FightMatrixFighterItem()

        fighter_id = int(response.url.split("/")[-2])
        fighter_item["id"] = fighter_id
        fighter_item["name"] = (
            response.css("header.entry-header > h1.entry-title > a::text").get().strip()
        )

        links = response.css("td.tdRankHead > div.leftCol *> a::attr(href)").getall()
        sherdog_id = None
        tapology_id = None
        for link in links:
            if "sherdog" in link:
                sherdog_id = int(link.split("/")[-1].strip().split("-")[-1])
            elif "tapology" in link:
                tapology_id = link.split("/")[-1].strip()
        fighter_item["sherdog_id"] = sherdog_id
        fighter_item["tapology_id"] = tapology_id

        pro_debut_date = None
        td_rank_head_divs = response.css(
            """td.tdRankHead[style='text-align: left; border: 0px; width: 100%; font-weight: normal'] 
            > div.rightCol"""
        )
        for div in td_rank_head_divs:
            label = div.css("::text").get().strip()
            if label == "Pro Debut Date:":
                pro_debut_date = pd.to_datetime(
                    div.css("strong::text").get().strip()
                ).strftime("%Y-%m-%d")
                break
        fighter_item["pro_debut_date"] = pro_debut_date

        ufc_debut_date = None
        td_rank_alt_divs = response.css(
            """tr > td.tdRankAlt[style='border: 1px solid black; text-align: left; '] 
            > div.leftCol"""
        )
        for div in td_rank_alt_divs:
            label = div.css("::text").get().strip()
            if label == "UFC Debut:":
                ufc_debut_date = pd.to_datetime(
                    div.css("strong::text").get().strip()
                ).strftime("%Y-%m-%d")
                break
        fighter_item["ufc_debut_date"] = ufc_debut_date

        # Edge cases
        if fighter_id == 1002:
            fighter_item["ufc_debut_date"] = "1999-01-08"
        elif fighter_id in [1614, 21940]:
            fighter_item["ufc_debut_date"] = "1999-03-05"

        yield fighter_item

        # Deal with fighter history
        fighter_history_table = response.css(
            "div[style='overflow-x:auto; overflow-y: auto'].xma_desktop > table.tblRank"
        )
        if fighter_history_table:
            rows = fighter_history_table.css("tr")[1:]

            fighter_urls = []
            event_urls = []
            item_dict_list = []
            date_counts = {}
            for row in reversed(rows):
                data_split = (
                    w3lib.html.remove_tags(row.css("::attr(onmouseover)").get().strip())
                    .replace("LoadCustomData('stat','", "")
                    .replace("'); TagToTip('tip_div')", "")
                ).split("|")
                assert len(data_split) == 18

                elo_only_split = data_split[6:]

                tds = row.css("td")
                assert len(tds) == 4

                outcome = tds[0].css("b::text").get().strip()

                opponent_url = tds[1].css("a::attr(href)").get()
                opponent_id = int(opponent_url.split("/")[-2])
                fighter_urls.append(opponent_url)

                event_id = int(tds[2].css("a::attr(href)").get().split("/")[-2])
                event_urls.append(f"/event/.../{event_id}/")

                date = pd.to_datetime(tds[2].css("em::text").get().strip()).strftime(
                    "%Y-%m-%d"
                )
                if date in date_counts:
                    date_counts[date] += 1
                else:
                    date_counts[date] = 1

                method_round_split = tds[3].css("::text").getall()
                assert len(method_round_split) == 2

                method_round_split_clean = [x.strip() for x in method_round_split]

                item_dict = {
                    "fighter_id": fighter_id,
                    "event_id": event_id,
                    "date": date,
                    "opponent_id": opponent_id,
                    "outcome": outcome,
                    "outcome_method": method_round_split_clean[0],
                    "end_round": int(method_round_split_clean[1].split(" ")[-1]),
                    "fighter_elo_k170_pre": int(elo_only_split[0]),
                    "fighter_elo_k170_post": int(elo_only_split[1]),
                    "fighter_elo_modified_pre": int(elo_only_split[4]),
                    "fighter_elo_modified_post": int(elo_only_split[5]),
                    "fighter_glicko_1_pre": int(elo_only_split[8]),
                    "fighter_glicko_1_post": int(elo_only_split[9]),
                    "opponent_elo_k170_pre": int(elo_only_split[2]),
                    "opponent_elo_k170_post": int(elo_only_split[3]),
                    "opponent_elo_modified_pre": int(elo_only_split[6]),
                    "opponent_elo_modified_post": int(elo_only_split[7]),
                    "opponent_glicko_1_pre": int(elo_only_split[10]),
                    "opponent_glicko_1_post": int(elo_only_split[11]),
                }
                item_dict_list.append(item_dict)

            for i, item_dict in enumerate(item_dict_list):
                date = item_dict["date"]
                if date_counts[date] > 1:
                    item_dict["bad_ordering_flag"] = 1
                else:
                    item_dict["bad_ordering_flag"] = 0

                item_dict["temp_order"] = i + 1

                yield FightMatrixFighterHistoryItem(**item_dict)

            for fighter_url in fighter_urls:
                yield response.follow(response.urljoin(fighter_url), self.parse_fighter)

            for event_url in event_urls:
                yield response.follow(
                    response.urljoin(event_url),
                    self.parse_event,
                    cb_kwargs={"is_ufc_event": 0, "event_order": None},
                )


class FightMatrixRankingsSpider(Spider):
    name = "fightmatrix_rankings_spider"
    allowed_domains = ["fightmatrix.com"]
    start_urls = [
        "https://www.fightmatrix.com/historical-mma-rankings/ranking-snapshots/"
    ]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "CONCURRENT_REQUESTS_PER_DOMAIN": 1,
        "CONCURRENT_REQUESTS": 1,
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
            "scrapy_ufc.pipelines.fightmatrix_pipelines.FightMatrixRankingsPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
        "DOWNLOAD_DELAY": 1.5,
        "AUTOTHROTTLE_ENABLED": True,
        "AUTOTHROTTLE_START_DELAY": 1.5,
        "AUTOTHROTTLE_TARGET_CONCURRENCY": 1,
        "AUTOTHROTTLE_MAX_DELAY": 5,
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.weight_class_map = {
            "1": "Heavyweight",
            "2": "Light Heavyweight",
            "3": "Middleweight",
            "4": "Welterweight",
            "5": "Lightweight",
            "6": "Featherweight",
            "7": "Bantamweight",
            "8": "Flyweight",
            "9": ["Women (All)", "Strawweight"],
            "12": "Women's Atomweight",
            "13": "Women's Strawweight",
            "14": "Women's Flyweight",
            "15": "Women's Bantamweight",
            "16": "Women's Featherweight",
        }
        self.weight_class_expansion_date = "2010-10-01"

    def parse(self, response):
        filtertable_td = response.css("table#filterTable *> td")
        issues = filtertable_td[0].css("option::attr(value)").getall()[1:]
        dates = filtertable_td[0].css("option::text").getall()[1:]
        dates = [pd.to_datetime(x).strftime("%Y-%m-%d") for x in dates]
        assert len(issues) == len(dates)

        for issue, date in zip(issues, dates):
            for division, weight_class in self.weight_class_map.items():
                if time.strptime(date, "%Y-%m-%d") < time.strptime(
                    self.weight_class_expansion_date, "%Y-%m-%d"
                ) and division in {"12", "13" "14", "15", "16"}:
                    continue

                if division == "9":
                    if time.strptime(date, "%Y-%m-%d") < time.strptime(
                        self.weight_class_expansion_date, "%Y-%m-%d"
                    ):
                        weight_class = weight_class[0]
                    else:
                        weight_class = weight_class[1]

                assert type(weight_class) == str and len(weight_class) > 0

                yield response.follow(
                    f"https://www.fightmatrix.com/historical-mma-rankings/ranking-snapshots/?Issue={issue}&Division={division}",
                    callback=self.parse_ranking_page,
                    cb_kwargs={"date": date, "weight_class": weight_class},
                )

    def parse_ranking_page(self, response, date, weight_class):
        rows = response.css("table.tblRank > tbody > tr")
        for row in rows[1:]:
            ranking_item = FightMatrixRankingItem()
            ranking_item["issue_date"] = date
            ranking_item["weight_class"] = weight_class

            cells = row.css("td")

            ranking_item["rank"] = int(cells[0].css("::text").get().strip())

            fighter_link = cells[2].css("a::attr(href)").get()
            fighter_id = fighter_link.replace("/fighter-profile/", "")

            if fighter_id == "//":
                # Edge case for missing fighter
                continue

            fighter_id = int(fighter_id.split("/")[-2])
            ranking_item["fighter_id"] = fighter_id
            ranking_item["points"] = int(cells[3].css("div.tdBar::text").get().strip())

            yield ranking_item

        pager_atags = response.css(
            "span[style='font-size: 14pt'] > a[style='text-decoration: none']"
        )
        if pager_atags:
            for atag in pager_atags:
                arrow = atag.css("b::text").get().strip()
                href = atag.css("::attr(href)").get()
                if arrow == ">":
                    yield response.follow(
                        response.urljoin(href),
                        callback=self.parse_ranking_page,
                        cb_kwargs={"date": date, "weight_class": weight_class},
                    )

                    break
