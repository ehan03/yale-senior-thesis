# standard library imports

# third party imports
import pandas as pd
import w3lib.html
from scrapy import Request
from scrapy.spiders import Spider

# local imports
from ..items.sherdog_items import (
    SherdogBoutItem,
    SherdogEventItem,
    SherdogFighterHistoryItem,
    SherdogFighterItem,
)
from ..utils import convert_height


class SherdogSpider(Spider):
    name = "sherdog_spider"
    allowed_domains = ["sherdog.com"]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "CONCURRENT_REQUESTS_PER_DOMAIN": 6,
        "CONCURRENT_REQUESTS": 6,
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
        "RETRY_TIMES": 10,
        "LOG_LEVEL": "INFO",
        "ITEM_PIPELINES": {
            "scrapy_ufc.pipelines.sherdog_pipelines.SherdogItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
        "DOWNLOAD_TIMEOUT": 600,
    }

    def start_requests(self):
        start_url = "https://www.sherdog.com/organizations/Ultimate-Fighting-Championship-UFC-2/recent-events/1"

        yield Request(
            url=start_url,
            callback=self.parse_recent_events_page,
            cb_kwargs={"event_urls_all": []},
        )

    def parse_recent_events_page(self, response, event_urls_all):
        table = response.css("div.single_tab#recent_tab > table.new_table.event")
        event_urls = table.css(
            "tr[itemtype='http://schema.org/Event'] > td > a::attr(href)"
        ).getall()
        event_names = table.css(
            "tr[itemtype='http://schema.org/Event'] > td > a > span[itemprop='name']::text"
        ).getall()
        locations = [
            x.strip()
            for x in table.css(
                "tr[itemtype='http://schema.org/Event'] > td[itemprop='location']::text"
            ).getall()
        ]

        event_urls_valid = []
        for event_url, event_name, location in zip(event_urls, event_names, locations):
            if "Road to UFC" not in event_name and not location.startswith(
                "EVENT CANCELED"
            ):
                event_urls_valid.append(event_url)
        event_urls_all.extend(event_urls_valid)

        pagination = response.css("div.footer > span.pagination")[0]
        pagination_url = pagination.css("a")[-1].attrib["href"]
        pagination_desc = pagination.css("a")[-1].css("::text").get()

        if pagination_desc == "Older Events »":
            yield response.follow(
                response.urljoin(pagination_url),
                callback=self.parse_recent_events_page,
                cb_kwargs={"event_urls_all": event_urls_all},
            )
        else:
            for i, event_url in enumerate(reversed(event_urls_all)):
                yield response.follow(
                    response.urljoin(event_url),
                    callback=self.parse_event,
                    cb_kwargs={
                        "is_ufc_event": 1,
                        "event_order": i + 1,
                    },
                )

    def parse_event(self, response, is_ufc_event, event_order):
        event_item = SherdogEventItem()

        event_id = int(response.url.split("/")[-1].split("-")[-1])
        name = response.css("h1 > span[itemprop='name']::text").get()
        date = response.css("span > meta[itemprop='startDate']::attr(content)").get()
        location = response.css("span > span[itemprop='location']::text").get()
        country = response.css("div.info > span > img::attr(alt)").get()

        if (location is not None and not location.startswith("EVENT CANCELED")) or (
            location is None
        ):
            event_item["id"] = event_id
            event_item["name"] = name.strip() if name else None
            event_item["date"] = (
                pd.to_datetime(date).strftime("%Y-%m-%d") if date else None
            )
            event_item["location"] = (
                location.strip().replace("\n", "") if location else None
            )
            event_item["country"] = country.strip() if country else None
            event_item["is_ufc_event"] = is_ufc_event
            event_item["event_order"] = event_order

            yield event_item

            # Handle event bouts
            fighter_urls = []
            main_event = response.css(
                "div[itemprop='subEvent'][itemtype='http://schema.org/Event']"
            )

            if main_event:
                # First handle main event separately
                main_event_bout_item = SherdogBoutItem()

                main_event_bout_item["event_id"] = event_id
                fighter_1_id = (
                    main_event.css(
                        "div.fighter.left_side > a[itemprop='url']::attr(href)"
                    )
                    .get()
                    .split("/")[-1]
                    .split("-")[-1]
                )
                main_event_bout_item["fighter_1_id"] = (
                    int(fighter_1_id) if fighter_1_id != "javascript:void();" else None
                )
                fighter_urls.append(
                    main_event.css(
                        "div.fighter.left_side > a[itemprop='url']::attr(href)"
                    ).get()
                    if fighter_1_id != "javascript:void();"
                    else None
                )
                fighter_2_id = (
                    main_event.css(
                        "div.fighter.right_side > a[itemprop='url']::attr(href)"
                    )
                    .get()
                    .split("/")[-1]
                    .split("-")[-1]
                )
                main_event_bout_item["fighter_2_id"] = (
                    int(fighter_2_id) if fighter_2_id != "javascript:void();" else None
                )
                fighter_urls.append(
                    main_event.css(
                        "div.fighter.right_side > a[itemprop='url']::attr(href)"
                    ).get()
                    if fighter_2_id != "javascript:void();"
                    else None
                )
                fighter_1_outcome = (
                    main_event.css("div.fighter.left_side > span.final_result::text")
                    .get()
                    .strip()
                    .lower()
                )
                main_event_bout_item["fighter_1_outcome"] = (
                    fighter_1_outcome if fighter_1_outcome else None
                )
                fighter_2_outcome = (
                    main_event.css("div.fighter.right_side > span.final_result::text")
                    .get()
                    .strip()
                    .lower()
                )
                main_event_bout_item["fighter_2_outcome"] = (
                    fighter_2_outcome if fighter_2_outcome else None
                )
                main_event_weight_class = main_event.css(
                    "div.versus > span.weight_class::text"
                )
                main_event_weight_class_clean = (
                    main_event_weight_class.get().strip()
                    if main_event_weight_class
                    else None
                )
                main_event_bout_item["weight_class"] = (
                    main_event_weight_class_clean
                    if main_event_weight_class_clean
                    else None
                )

                main_event_resume_td_tags = main_event.css(
                    "table.fight_card_resume > tr > td"
                )
                for td_tag in main_event_resume_td_tags:
                    td_text = td_tag.css("::text").getall()
                    if td_text[0] == "Match":
                        main_event_bout_item["bout_order"] = int(td_text[1])
                    elif td_text[0] == "Method":
                        main_method_full = td_text[1].strip() if td_text[1] else None
                        main_event_bout_item["outcome_method"] = (
                            main_method_full if main_method_full else None
                        )
                    elif td_text[0] == "Round":
                        end_round = int(td_text[1]) if td_text[1] else None
                        main_event_bout_item["end_round"] = end_round
                    elif td_text[0] == "Time":
                        end_round_time = td_text[1].strip() if td_text[1] else None
                        main_event_bout_item["end_round_time"] = (
                            end_round_time if end_round_time else None
                        )

                if main_event.css("span.title_fight"):
                    main_event_bout_item["is_title_bout"] = 1
                else:
                    main_event_bout_item["is_title_bout"] = 0

                yield main_event_bout_item

                # Handle remaining bouts
                card_table_rows = response.css(
                    """div.new_table_holder > table.new_table.result > tbody > 
                    tr[itemprop='subEvent'][itemtype='http://schema.org/Event']"""
                )
                for row in card_table_rows:
                    bout_item = SherdogBoutItem()

                    bout_item["event_id"] = event_id

                    tds = row.css("td")
                    bout_item["bout_order"] = int(
                        w3lib.html.remove_tags(tds[0].get()).strip()
                    )

                    fighter_1_id = (
                        tds[1]
                        .css(
                            "div.fighter_list.left > div.fighter_result_data > a[itemprop='url']::attr(href)"
                        )
                        .get()
                        .split("/")[-1]
                        .split("-")[-1]
                    )
                    bout_item["fighter_1_id"] = (
                        int(fighter_1_id)
                        if fighter_1_id != "javascript:void();"
                        else None
                    )
                    fighter_1_outcome = (
                        tds[1].css("span.final_result::text").get().strip().lower()
                    )
                    bout_item["fighter_1_outcome"] = (
                        fighter_1_outcome if fighter_1_outcome else None
                    )
                    fighter_urls.append(
                        tds[1]
                        .css(
                            "div.fighter_list.left > div.fighter_result_data > a[itemprop='url']::attr(href)"
                        )
                        .get()
                        if fighter_1_id != "javascript:void();"
                        else None
                    )

                    weight_class = tds[2].css("span.weight_class::text")
                    weight_class_clean = (
                        weight_class.get().strip() if weight_class else None
                    )
                    bout_item["weight_class"] = (
                        weight_class_clean if weight_class_clean else None
                    )

                    if tds[2].css("span.title_fight"):
                        bout_item["is_title_bout"] = 1
                    else:
                        bout_item["is_title_bout"] = 0

                    fighter_2_id = (
                        tds[3]
                        .css(
                            "div.fighter_list.right > div.fighter_result_data > a[itemprop='url']::attr(href)"
                        )
                        .get()
                        .split("/")[-1]
                        .split("-")[-1]
                    )
                    bout_item["fighter_2_id"] = (
                        int(fighter_2_id)
                        if fighter_2_id != "javascript:void();"
                        else None
                    )
                    fighter_2_outcome = (
                        tds[3].css("span.final_result::text").get().strip().lower()
                    )
                    bout_item["fighter_2_outcome"] = (
                        fighter_2_outcome if fighter_2_outcome else None
                    )
                    fighter_urls.append(
                        tds[3]
                        .css(
                            "div.fighter_list.right > div.fighter_result_data > a[itemprop='url']::attr(href)"
                        )
                        .get()
                        if fighter_2_id != "javascript:void();"
                        else None
                    )

                    method_full_text = tds[4].css("b::text").get()
                    method_full = method_full_text.strip() if method_full_text else None
                    bout_item["outcome_method"] = method_full if method_full else None

                    end_round = (
                        int(tds[5].css("::text").get().strip()) if tds[5] else None
                    )
                    bout_item["end_round"] = end_round

                    end_round_time = (
                        tds[6].css("::text").get().strip() if tds[6] else None
                    )
                    bout_item["end_round_time"] = (
                        end_round_time if end_round_time else None
                    )

                    yield bout_item

                if is_ufc_event == 1:
                    for fighter_url in fighter_urls:
                        yield response.follow(
                            response.urljoin(fighter_url),
                            callback=self.parse_fighter,
                        )

    def parse_fighter(self, response):
        fighter_item = SherdogFighterItem()

        fighter_id = int(response.url.split("/")[-1].split("-")[-1])
        fighter_item["id"] = fighter_id

        fighter_name = response.css(
            "div.fighter-line1 > h1[itemprop='name'] > span.fn::text"
        ).get()
        fighter_item["name"] = fighter_name

        nick = response.css("div.fighter-line2 > h1[itemprop='name'] > span.nickname")
        fighter_item["nickname"] = nick.css("em::text").get() if nick else None
        fighter_item["nationality"] = response.css(
            """div.fighter-nationality > span.item.birthplace > 
            strong[itemprop='nationality']::text"""
        ).get()

        dob = response.css(
            """div.fighter-data > div.bio-holder > table > tr > 
            td > span[itemprop='birthDate']::text"""
        ).get()
        fighter_item["date_of_birth"] = (
            pd.to_datetime(dob).strftime("%Y-%m-%d") if dob else None
        )

        height = response.css(
            "div.fighter-data > div.bio-holder > table > tr > td > b[itemprop='height']::text"
        ).get()
        fighter_item["height_inches"] = (
            convert_height(height.replace("'", "' ")) if height else None
        )

        fight_history_tables = response.css(
            "div.module.fight_history > div.new_table_holder > table.new_table.fighter"
        )
        if fight_history_tables:
            pro_fight_history_table = fight_history_tables[0]
            fight_history_rows = pro_fight_history_table.css(
                "tr:not([class='table_head'])"
            )

            pro_debut_date = None
            try:
                pro_debut_date = (
                    pd.to_datetime(
                        fight_history_rows[-1].css("td > span.sub_line::text").get()
                    ).strftime("%Y-%m-%d")
                    if fight_history_rows
                    else None
                )
            except:
                pass

            fighter_item["pro_debut_date"] = pro_debut_date

            # Professional fight history
            fighter_urls = []
            event_urls = []
            for i, row in enumerate(reversed(fight_history_rows)):
                fighter_history_item = SherdogFighterHistoryItem()

                fighter_history_item["fighter_id"] = fighter_id
                fighter_history_item["order"] = i + 1

                tds = row.css("td")

                outcome = tds[0].css("span.final_result::text").get().strip().lower()
                fighter_history_item["outcome"] = outcome if outcome else None
                fighter_history_item["opponent_id"] = (
                    int(tds[1].css("a::attr(href)").get().split("/")[-1].split("-")[-1])
                    if tds[1].css("a::attr(href)").get().split("/")[-1].split("-")[-1]
                    != "javascript:void();"
                    else None
                )
                fighter_urls.append(
                    tds[1].css("a::attr(href)").get()
                    if tds[1].css("a::attr(href)").get().split("/")[-1].split("-")[-1]
                    != "javascript:void();"
                    else None
                )

                fighter_history_item["event_id"] = int(
                    tds[2].css("a::attr(href)").get().split("/")[-1].split("-")[-1]
                )
                event_urls.append(tds[2].css("a::attr(href)").get())

                bout_date = None
                try:
                    bout_date = pd.to_datetime(
                        tds[2].css("span.sub_line::text").get()
                    ).strftime("%Y-%m-%d")
                except:
                    pass
                fighter_history_item["date"] = bout_date

                method_full = tds[3].css("b::text").get()
                method_full = method_full.strip() if method_full else None
                fighter_history_item["outcome_method"] = (
                    method_full if method_full else None
                )

                end_round = int(tds[4].css("::text").get().strip()) if tds[4] else None
                fighter_history_item["end_round"] = end_round

                end_round_time = tds[5].css("::text").get().strip() if tds[5] else None
                fighter_history_item["end_round_time"] = (
                    end_round_time if end_round_time else None
                )

                yield fighter_history_item

                for fighter_url in fighter_urls:
                    yield response.follow(
                        response.urljoin(fighter_url),
                        callback=self.parse_fighter,
                    )

                for event_url in event_urls:
                    yield response.follow(
                        response.urljoin(event_url),
                        callback=self.parse_event,
                        cb_kwargs={"is_ufc_event": 0, "event_order": None},
                    )
        else:
            fighter_item["pro_debut_date"] = None

        yield fighter_item
