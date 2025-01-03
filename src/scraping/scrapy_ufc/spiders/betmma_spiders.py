# standard library imports
import re
from urllib.parse import parse_qs, urlparse

# third party imports
import pandas as pd
import w3lib.html
from scrapy import FormRequest
from scrapy.spiders import Spider

# local imports
from ..items.betmma_items import (
    BetMMABoutItem,
    BetMMAEventItem,
    BetMMAFighterHistoryItem,
    BetMMAFighterItem,
    BetMMALateReplacementItem,
    BetMMAMissedWeightItem,
)


class BetMMASpider(Spider):
    name = "betmma_spider"
    allowed_domains = ["betmma.tips"]
    start_urls = ["https://www.betmma.tips/past_mma_handicapper_performance_all.php"]
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
            "scrapy_ufc.pipelines.betmma_pipelines.BetMMAItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
        "DOWNLOAD_TIMEOUT": 600,
        "DOWNLOAD_DELAY": 0.3,
    }

    def parse(self, response):
        events_table = response.css(
            "td[style='border-bottom:#ffffff solid 10px; padding:20px;'] > table"
        )
        rows = events_table.css("tr")
        for i, row in enumerate(reversed(rows[1:-1])):
            event_url = row.css("td > a::attr(href)").get()
            event_name = row.css("td > a::text").get().strip()

            yield FormRequest(
                url=response.urljoin(event_url),
                formdata={"sel_filter": "1"},
                callback=self.parse_event,
                cb_kwargs={"temp_order": i + 1},
            )

            # Don't need to go beyond UFC Fight Night: Covington vs. Buckley
            if event_name == "UFC Fight Night: Covington vs. Buckley":
                break

    def parse_event(self, response, temp_order):
        # Fix broken HTML
        response = response.replace(
            body=re.sub(
                r"(ufc_betting_advice\.php\?).*?(Fight=\d+)", r"\1\2", response.text
            )
        )

        parsed = urlparse(response.url)

        event_item = BetMMAEventItem()
        event_id = int(parse_qs(parsed.query)["Event"][0])
        event_item["id"] = event_id

        event_name = response.css("h1::text").get().strip()
        event_item["name"] = event_name if event_name else None

        location_date = response.css("h2::text").get().strip()
        location_date_split = [x.strip() for x in location_date.split(";")]
        assert len(location_date_split) == 2

        event_item["location"] = (
            location_date_split[0] if location_date_split[0] else None
        )
        event_item["date"] = (
            pd.to_datetime(location_date_split[1]).strftime("%Y-%m-%d")
            if location_date_split[1]
            else None
        )

        if event_name.startswith("UFC ") or event_name.startswith("TUF "):
            event_item["is_ufc_event"] = 1
        else:
            event_item["is_ufc_event"] = 0

        event_item["temp_order"] = temp_order

        yield event_item

        bout_tds = response.css("table > tr > td[rowspan='3']")
        fighter_ids_all = []
        counter = 1
        for bout_td in reversed(bout_tds):
            # Handle cancelled bouts
            td_text = bout_td.css("::text").getall()
            td_text = [x.strip() for x in td_text if x.strip()]

            if "Result: NC / Cancelled" in td_text:
                continue

            fighter_urls = [
                response.urljoin(x)
                for x in bout_td.css("a::attr(href)").getall()
                if x.startswith("fighter_profile.php?FID=")
            ]
            assert 2 <= len(fighter_urls) <= 3

            bout_url = [
                response.urljoin(x)
                for x in bout_td.css("a::attr(href)").getall()
                if x.startswith("ufc_betting_advice.php?")
            ][0]

            bout_id = int(parse_qs(urlparse(bout_url).query)["Fight"][0])

            try:
                fighter_1_id = int(parse_qs(urlparse(fighter_urls[0]).query)["FID"][0])
            except:
                fighter_1_id = None

            try:
                fighter_2_id = int(parse_qs(urlparse(fighter_urls[1]).query)["FID"][0])
            except:
                fighter_2_id = None

            # Handle edge case where both fighters are None or identical
            # Likely a cancelled bout or human error
            if fighter_1_id == fighter_2_id:
                continue

            bout_item = BetMMABoutItem()
            bout_item["id"] = bout_id
            bout_item["event_id"] = event_id
            bout_item["bout_order"] = counter
            bout_item["fighter_1_id"] = fighter_1_id
            bout_item["fighter_2_id"] = fighter_2_id

            yield bout_item

            counter += 1

            fighter_ids_all.extend(
                [
                    fighter_id
                    for fighter_id in [fighter_1_id, fighter_2_id]
                    if fighter_id is not None
                ]
            )

        # Crawl fighter profiles
        for fighter_id in fighter_ids_all:
            fighter_url = (
                f"https://www.betmma.tips/fighter_profile.php?FID={fighter_id}"
            )

            yield response.follow(
                url=fighter_url,
                callback=self.parse_fighter,
                cb_kwargs={"fighter_id": fighter_id},
            )

    def parse_fighter(self, response, fighter_id):
        fighter_item = BetMMAFighterItem()

        fighter_item["id"] = fighter_id
        fighter_item["name"] = response.css("h1::text").get().strip()

        fighter_links = response.css("h1 > a::attr(href)").getall()
        wikipedia_url = None
        sherdog_id = None
        ufcstats_id = None
        for link in fighter_links:
            if "wikipedia" in link:
                wikipedia_url = link
            elif "sherdog" in link:
                if fighter_id == 7208:
                    sherdog_id = 228919
                else:
                    sherdog_id = int(link.split("/")[-1].split("-")[-1])
            elif "ufcstats" in link or "fightmetric" in link:
                ufcstats_id = link.split("/")[-1].strip()

        fighter_item["wikipedia_url"] = wikipedia_url
        fighter_item["sherdog_id"] = sherdog_id
        fighter_item["ufcstats_id"] = ufcstats_id

        form = response.css("form[id='form1']")
        form_text = form.get().split("<br>")
        form_text = [w3lib.html.remove_tags(x).strip() for x in form_text]
        height = None
        reach = None
        stance = None
        nationality = None
        for text in form_text:
            if text.startswith("Country:"):
                nationality = text.replace("Country:", "").strip()
            elif text.startswith("Height:"):
                height = text.replace("Height:", "").strip()
            elif text.startswith("Reach:"):
                reach = text.replace("Reach:", "").replace("inches", "").strip()
            elif text.startswith("Stance:"):
                stance = text.replace("Stance:", "").strip()

        fighter_item["height"] = height if height else None
        fighter_item["reach"] = reach if reach else None
        fighter_item["stance"] = stance if stance else None
        fighter_item["nationality"] = nationality if nationality else None

        yield fighter_item

        # Fighter history
        fighter_history_table = response.css(
            """td[bgcolor='#F7F7F7'][style='border-bottom:#ffffff solid 10px; padding:10px;'] >
            table[width='100%'][cellspacing='0'][cellpadding='0']"""
        )
        rows = fighter_history_table.css("tr")
        event_ids = []
        opponent_ids = []
        for i, row in enumerate(rows[1:-1]):
            fighter_history_item = BetMMAFighterHistoryItem()

            fighter_history_item["fighter_id"] = fighter_id
            fighter_history_item["order"] = i + 1

            tds = row.css("td")
            assert len(tds) == 9

            bout_url = [
                response.urljoin(x)
                for x in tds[8].css("a::attr(href)").getall()
                if x.startswith("ufc_betting_advice.php?")
            ]
            assert len(bout_url) == 1
            bout_id = int(parse_qs(urlparse(bout_url[0]).query)["Fight"][0])

            fighter_history_item["bout_id"] = bout_id

            opponent_url = [
                response.urljoin(x)
                for x in tds[2].css("a::attr(href)").getall()
                if x.startswith("fighter_profile.php?")
            ]
            assert len(opponent_url) == 1
            opponent_id = int(parse_qs(urlparse(opponent_url[0]).query)["FID"][0])
            opponent_ids.append(opponent_id)

            fighter_history_item["opponent_id"] = opponent_id
            fighter_history_item["outcome"] = tds[3].css("::text").get().strip()
            fighter_history_item["outcome_method"] = tds[4].css("::text").get().strip()
            fighter_history_item["end_round"] = int(tds[5].css("::text").get().strip())
            fighter_history_item["end_round_time"] = tds[6].css("::text").get().strip()

            odds = tds[7].css("::text").get().strip()
            fighter_history_item["odds"] = (
                int(odds.replace(",", "")) if odds and "inf" not in odds else None
            )

            yield fighter_history_item

            # Get event ID
            event_url = [
                response.urljoin(x)
                for x in tds[1].css("a::attr(href)").getall()
                if x.startswith("mma_event_betting_history.php?")
            ]
            assert len(event_url) == 1
            event_id = int(parse_qs(urlparse(event_url[0]).query)["Event"][0])
            event_ids.append(event_id)

            # Late replacement
            late_replacement = tds[8].css(
                "a[href='ufc_late_replacement_fight_stats.php']"
            )
            if late_replacement:
                late_replacement_desc = late_replacement.css("img::attr(title)").get()
                notice_time_days = int(
                    late_replacement_desc.split("booked ")[-1].split(" ")[0]
                )

                late_replacement_item = BetMMALateReplacementItem()
                late_replacement_item["fighter_id"] = fighter_id
                late_replacement_item["bout_id"] = bout_id
                late_replacement_item["notice_time_days"] = notice_time_days

                yield late_replacement_item

            # Missed weight
            missed_weight = tds[8].css("a[href='ufc_fighters_who_missed_weight.php']")
            if missed_weight:
                missed_weight_desc = missed_weight.css("img::attr(title)").get()
                weight_lbs = float(
                    missed_weight_desc.split("weighing in at ")[-1]
                    .replace("lbs.", "")
                    .replace("lbs", "")
                )

                missed_weight_item = BetMMAMissedWeightItem()
                missed_weight_item["fighter_id"] = fighter_id
                missed_weight_item["bout_id"] = bout_id
                missed_weight_item["weight_lbs"] = weight_lbs

                yield missed_weight_item

        # Crawl event pages
        for event_id in event_ids:
            event_url = f"https://www.betmma.tips/mma_event_betting_history.php?Event={event_id}"

            yield FormRequest(
                url=event_url,
                formdata={"sel_filter": "1"},
                callback=self.parse_event,
                cb_kwargs={"temp_order": None},
            )

        # Crawl opponent pages
        for opponent_id in opponent_ids:
            opponent_url = (
                f"https://www.betmma.tips/fighter_profile.php?FID={opponent_id}"
            )

            yield response.follow(
                url=opponent_url,
                callback=self.parse_fighter,
                cb_kwargs={"fighter_id": opponent_id},
            )
