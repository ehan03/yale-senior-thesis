# standard library imports
import os

# third party imports
import w3lib.html
from scrapy import Request
from scrapy.spiders import Spider

# local imports
from ..items.tapology_items import (
    TapologyBoutItem,
    TapologyCommunityPickItem,
    TapologyEventItem,
    TapologyFighterHistoryItem,
    TapologyFighterItem,
    TapologyGymItem,
    TapologyTempBoutItem,
    TapologyTempFighterItem,
    TapologyTempGymItem,
)


class TapologyEventSpider(Spider):
    name = "tapology_event_spider"
    allowed_domains = ["tapology.com"]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "DOWNLOAD_DELAY": 10,
        "RANDOMIZE_DOWNLOAD_DELAY": True,
        "DOWNLOAD_TIMEOUT": 600,
        "CONCURRENT_REQUESTS": 1,
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
        "RETRY_TIMES": 1,
        "LOG_LEVEL": "INFO",
        "ITEM_PIPELINES": {
            "scrapy_ufc.pipelines.tapology_pipelines.TapologyEventItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
        "FAKEUSERAGENT_PROVIDERS": [
            "scrapy_fake_useragent.providers.FakeUserAgentProvider",
            "scrapy_fake_useragent.providers.FakerProvider",
        ],
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.event_urls_path = os.path.join(
            os.path.dirname(__file__),
            "..",
            "..",
            "miscellaneous",
            "tapology_event_urls.txt",
        )

    def start_requests(self):
        with open(self.event_urls_path, "r") as file:
            for i, line in enumerate(file):
                url = line.strip()

                yield Request(
                    url=url, callback=self.parse_event, cb_kwargs={"event_order": i + 1}
                )

    def parse_event(self, response, event_order):
        event_item = TapologyEventItem()

        event_id = response.url.split("/")[-1]
        event_item["id"] = event_id

        event_links = set(
            response.css(
                "li[class='leading-normal py-1.5 md:py-2 px-1 md:text-xs'] > div > a::attr(href)"
            ).getall()
        )
        ufcstats_id = None
        sherdog_id = None
        bestfightodds_id = None
        ufc_id = None
        wikipedia_url = None
        for link in event_links:
            if "www.ufcstats.com/event-details/" in link:
                ufcstats_id = link.split("/")[-1]
            elif "www.sherdog.com/events/" in link:
                sherdog_id = int(link.split("/")[-1].split("-")[-1])
            elif "www.bestfightodds.com/events/" in link:
                bestfightodds_id = link.split("/")[-1]
            elif "www.ufc.com/event/" in link:
                ufc_id = link.split("/")[-1]
            elif "en.wikipedia.org/wiki/" in link:
                wikipedia_url = link
        event_item["ufcstats_id"] = ufcstats_id
        event_item["sherdog_id"] = sherdog_id
        event_item["bestfightodds_id"] = bestfightodds_id
        event_item["ufc_id"] = ufc_id
        event_item["wikipedia_url"] = wikipedia_url

        event_name = response.css("h2::text").get()
        event_name = event_name.strip() if event_name else None
        event_item["name"] = event_name if event_name else None

        event_item["event_order"] = event_order

        yield event_item

        # Bout and fighter links
        fight_card = response.css("div[id='sectionFightCard']")
        bout_lis = fight_card.css("ul > li")
        for i, li in enumerate(reversed(bout_lis)):
            links = set(li.css("*> a::attr(href)").getall())
            assert len(links) == 3

            bout_url = [link for link in links if "/fightcenter/bouts/" in link][0]
            fighter_urls = [link for link in links if "/fightcenter/fighters/" in link]

            temp_bout_item = TapologyTempBoutItem()

            temp_bout_item["url"] = response.urljoin(bout_url)
            temp_bout_item["event_id"] = event_id
            temp_bout_item["bout_order"] = i + 1

            yield temp_bout_item

            for fighter_url in fighter_urls:
                temp_fighter_item = TapologyTempFighterItem()

                temp_fighter_item["url"] = response.urljoin(fighter_url)

                yield temp_fighter_item


class TapologyFighterSpider(Spider):
    name = "tapology_fighter_spider"
    allowed_domains = ["tapology.com"]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "DOWNLOAD_DELAY": 5,
        "RANDOMIZE_DOWNLOAD_DELAY": True,
        "DOWNLOAD_TIMEOUT": 600,
        "CONCURRENT_REQUESTS": 1,
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
        "RETRY_TIMES": 1,
        "LOG_LEVEL": "INFO",
        "ITEM_PIPELINES": {
            "scrapy_ufc.pipelines.tapology_pipelines.TapologyFighterItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
        "FAKEUSERAGENT_PROVIDERS": [
            "scrapy_fake_useragent.providers.FakeUserAgentProvider",
            "scrapy_fake_useragent.providers.FakerProvider",
        ],
    }

    def __init__(self, *args, batch_num, **kwargs):
        super().__init__(*args, **kwargs)

        self.fighter_urls_path = os.path.join(
            os.path.dirname(__file__),
            "..",
            "..",
            "miscellaneous",
            "tapology_fighter_urls.txt",
        )

        # To avoid IP bans, we will scrape in batches of 1000 fighters
        self.batch_num = int(batch_num)

    def start_requests(self):
        with open(self.fighter_urls_path, "r") as file:
            fighter_urls = file.readlines()

        start = (self.batch_num - 1) * 1000
        end = self.batch_num * 1000

        for url in fighter_urls[start:end]:
            yield Request(url=url, callback=self.parse_fighter)

    def parse_fighter(self, response):
        fighter_item = TapologyFighterItem()

        fighter_id = response.url.split("/")[-1]
        fighter_item["id"] = fighter_id

        page_header = response.css("div[id='fighterPageHeader']")
        fighter_item["name"] = (
            page_header.css(
                "div > div[class='div text-tap_3 text-[26px] leading-tight md:leading-none font-bold']::text"
            )
            .get()
            .strip()
        )
        fighter_item["nationality"] = page_header.css(
            "div > a > img::attr(title)"
        ).get()

        details = response.css("div[id='standardDetails']")
        fighter_item["date_of_birth"] = details.css(
            "span[data-controller='age-calc']::text"
        ).get()

        divs = details.css("div.flex.items-center")
        nickname = None
        height = None
        reach = None
        birth_location = None
        for div in divs:
            div_text = w3lib.html.remove_tags(div.get()).strip()
            if div_text.startswith("Nickname:"):
                nickname = div.css("span::text").get().strip()
            elif div_text.startswith("Height:"):
                height, reach = div.css("span::text").getall()
            elif div_text.startswith("Born:"):
                birth_location = div.css("span::text").get().strip()
        fighter_item["nickname"] = nickname
        fighter_item["height"] = height
        fighter_item["reach"] = reach
        fighter_item["birth_location"] = birth_location

        links = details.css("div > a::attr(href)").getall()
        ufcstats_id = None
        sherdog_id = None
        bestfightodds_id = None
        ufc_id = None
        wikipedia_url = None
        for link in links:
            if "www.ufcstats.com/fighter-details/" in link:
                ufcstats_id = link.split("/")[-1]
            elif "www.sherdog.com/fighter/" in link:
                sherdog_id = int(link.split("/")[-1].split("-")[-1])
            elif "www.bestfightodds.com/fighters/" in link:
                bestfightodds_id = link.split("/")[-1]
            elif "www.ufc.com/athlete/" in link:
                ufc_id = link.split("/")[-1]
            elif "en.wikipedia.org/wiki/" in link:
                wikipedia_url = link.replace(" ", "_")
        fighter_item["ufcstats_id"] = ufcstats_id
        fighter_item["sherdog_id"] = sherdog_id
        fighter_item["bestfightodds_id"] = bestfightodds_id
        fighter_item["ufc_id"] = ufc_id
        fighter_item["wikipedia_url"] = wikipedia_url

        yield fighter_item

        # Fighter history
        pro_results = response.css("div[id='proResults']")
        bout_divs = pro_results.css("div[data-division='pro']")
        for i, bout_div in enumerate(reversed(bout_divs)):
            fighter_history_item = TapologyFighterHistoryItem()

            fighter_history_item["fighter_id"] = fighter_id
            fighter_history_item["order"] = i + 1

            bout_id_int = int(bout_div.css("::attr(data-bout-id)").get())
            fighter_history_item["bout_id_int"] = bout_id_int

            fighter_history_item["outcome"] = bout_div.css("::attr(data-status)").get()
            fighter_history_item["outcome_details"] = bout_div.css(
                "a[title='Bout Page']::text"
            ).get()

            history_links = set(bout_div.css("a::attr(href)").getall())
            bout_url = [link for link in history_links if "/fightcenter/bouts/" in link]
            fighter_history_item["bout_id"] = (
                bout_url[0].split("/")[-1] if bout_url else None
            )
            event_url = [
                link for link in history_links if "/fightcenter/events/" in link
            ]
            fighter_history_item["event_id"] = (
                event_url[0].split("/")[-1] if event_url else None
            )
            opponent_url = [
                link for link in history_links if "/fightcenter/fighters/" in link
            ]
            fighter_history_item["opponent_id"] = (
                opponent_url[0].split("/")[-1] if opponent_url else None
            )

            display_weight_info = [
                x.strip()
                for x in bout_div.css("div.displayWeight > div > span::text").getall()
            ]
            weight = None
            for info in display_weight_info:
                if info.startswith("Weigh-In:"):
                    weight = info.replace("Weigh-In: ", "").strip()
            fighter_history_item["weight"] = weight

            display_odds_info = [
                x.strip()
                for x in bout_div.css(
                    "div.displayOdds > div > div > span::text"
                ).getall()
            ]
            odds = None
            pick_em = None
            for info in display_odds_info:
                if info.startswith("+") or info.startswith("-"):
                    odds = info
                elif info.endswith("%"):
                    pick_em = info
            fighter_history_item["odds"] = odds
            fighter_history_item["pick_em"] = pick_em

            bout_details = bout_div.css(f"div[id='detail-rows-{bout_id_int}']")
            bout_details_divs = bout_details.css("div > div")
            event_name = None
            billing = None
            round_time_format = None
            weight_class = None
            for div in bout_details_divs:
                div_text = w3lib.html.remove_tags(div.get()).strip()
                if div_text.startswith("Event:"):
                    event_name = div_text.replace("Event:", "").strip()
                elif div_text.startswith("Billing:"):
                    billing = div_text.replace("Billing:", "").strip()
                elif div_text.startswith("Duration:"):
                    round_time_format = div_text.replace("Duration:", "").strip()
                elif div_text.startswith("Weight:"):
                    weight_class = (
                        div_text.replace("Weight:", "").replace("\n", "").strip()
                    )
            fighter_history_item["event_name"] = event_name if event_name else None
            fighter_history_item["billing"] = billing if billing else None
            fighter_history_item["round_time_format"] = (
                round_time_format if round_time_format else None
            )
            fighter_history_item["weight_class"] = (
                weight_class if weight_class else None
            )

            fighter_history_item["fighter_record"] = bout_div.css(
                "span[title='Fighter Record Before Fight']::text"
            ).get()
            fighter_history_item["opponent_record"] = bout_div.css(
                "span[title='Opponent Record Before Fight']::text"
            ).get()

            yield fighter_history_item


class TapologyBoutSpider(Spider):
    name = "tapology_bout_spider"
    allowed_domains = ["tapology.com"]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "DOWNLOAD_DELAY": 5,
        "RANDOMIZE_DOWNLOAD_DELAY": True,
        "DOWNLOAD_TIMEOUT": 600,
        "CONCURRENT_REQUESTS": 1,
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
        "RETRY_TIMES": 1,
        "LOG_LEVEL": "INFO",
        "ITEM_PIPELINES": {
            "scrapy_ufc.pipelines.tapology_pipelines.TapologyBoutItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
        "FAKEUSERAGENT_PROVIDERS": [
            "scrapy_fake_useragent.providers.FakeUserAgentProvider",
            "scrapy_fake_useragent.providers.FakerProvider",
        ],
    }

    def __init__(self, *args, batch_num, **kwargs):
        super().__init__(*args, **kwargs)

        self.bout_urls_path = os.path.join(
            os.path.dirname(__file__),
            "..",
            "..",
            "miscellaneous",
            "tapology_bout_urls.txt",
        )

        # To avoid IP bans, we will scrape in batches of 1000 bouts
        self.batch_num = int(batch_num)

    def start_requests(self):
        with open(self.bout_urls_path, "r") as file:
            bout_urls = file.readlines()

        start = (self.batch_num - 1) * 1000
        end = self.batch_num * 1000

        for line in bout_urls[start:end]:
            url, event_id, bout_order = line.strip().split(",")
            bout_order = int(bout_order)

            yield Request(
                url=url,
                callback=self.parse_bout,
                cb_kwargs={"event_id": event_id, "bout_order": bout_order},
            )

    def parse_bout(self, response, event_id, bout_order):
        bout_item = TapologyBoutItem()

        bout_id = response.url.split("/")[-1]
        bout_item["id"] = bout_id
        bout_item["event_id"] = event_id
        bout_item["bout_order"] = bout_order

        result_info = (
            response.css("div[id='boutResultHolder']")[0]
            .css("div.rounded > span.text-center::text")
            .getall()
        )
        assert len(result_info) == 2 or len(result_info) == 0

        if result_info:
            bout_item["outcome_method"] = result_info[0]
            bout_item["end_round_time_info"] = result_info[1]
        else:
            bout_item["outcome_method"] = None
            bout_item["end_round_time_info"] = None

        matchup = response.css("div[id='boutMatchup']")
        fighter_urls = matchup.css(
            "a[class='link-primary-red hidden md:inline']::attr(href)"
        ).getall()
        assert len(fighter_urls) == 2

        bout_item["fighter_1_id"] = fighter_urls[0].split("/")[-1]
        bout_item["fighter_2_id"] = fighter_urls[1].split("/")[-1]

        comparison_table = response.css("table[id='boutComparisonTable']")
        rows = comparison_table.css("tr[class='']")

        fighter_1_odds = None
        fighter_2_odds = None
        fighter_1_weight = None
        fighter_2_weight = None
        fighter_1_gym_info = None
        fighter_1_gym_ids = None
        fighter_2_gym_info = None
        fighter_2_gym_ids = None
        gym_urls = set()
        for row in rows:
            category = row.css(
                "td[class='p-1 md:p-1.5 w-[16%] md:w-[194px] text-xs11 md:text-xs font-bold align-middle uppercase text-tap_gold md:text-tap_7f']::text"
            ).get()
            category = category.strip() if category else None

            if category == "Betting Odds":
                div_texts = [
                    x.strip()
                    for x in row.css("div[class='div hidden md:inline']::text").getall()
                ]
                assert len(div_texts) == 2

                fighter_1_odds = div_texts[0]
                fighter_2_odds = div_texts[1]
            elif category == "Weigh-In Result":
                div_texts = [
                    x.strip()
                    for x in row.css("div[class='div hidden md:inline']::text").getall()
                ]
                assert len(div_texts) == 2

                fighter_1_weight = div_texts[0]
                fighter_2_weight = div_texts[1]
            elif category == "Gym":
                tds = row.css("td.text-neutral-950")
                assert len(tds) == 2

                gym_1_texts = [
                    x.strip() for x in tds[0].css("::text").getall() if x.strip()
                ]
                gym_1_texts_cleaned = []
                for text in gym_1_texts:
                    if text.startswith("("):
                        gym_1_texts_cleaned[-1] += f" {text}"
                    else:
                        gym_1_texts_cleaned.append(text)
                fighter_1_gym_info = (
                    "; ".join(gym_1_texts_cleaned) if gym_1_texts else None
                )

                gym_2_texts = [
                    x.strip() for x in tds[1].css("::text").getall() if x.strip()
                ]
                gym_2_texts_cleaned = []
                for text in gym_2_texts:
                    if text.startswith("("):
                        gym_2_texts_cleaned[-1] += f" {text}"
                    else:
                        gym_2_texts_cleaned.append(text)
                fighter_2_gym_info = (
                    "; ".join(gym_2_texts_cleaned) if gym_2_texts else None
                )

                gym_1_urls = tds[0].css("a::attr(href)").getall()
                gym_2_urls = tds[1].css("a::attr(href)").getall()

                fighter_1_gym_ids = (
                    "; ".join([url.split("/")[-1] for url in gym_1_urls])
                    if gym_1_urls
                    else None
                )
                fighter_2_gym_ids = (
                    "; ".join([url.split("/")[-1] for url in gym_2_urls])
                    if gym_2_urls
                    else None
                )

                gym_urls.update([response.urljoin(url) for url in gym_1_urls])
                gym_urls.update([response.urljoin(url) for url in gym_2_urls])

        bout_item["fighter_1_odds"] = fighter_1_odds
        bout_item["fighter_2_odds"] = fighter_2_odds
        bout_item["fighter_1_weight"] = fighter_1_weight
        bout_item["fighter_2_weight"] = fighter_2_weight
        bout_item["fighter_1_gym_info"] = fighter_1_gym_info
        bout_item["fighter_1_gym_ids"] = fighter_1_gym_ids
        bout_item["fighter_2_gym_info"] = fighter_2_gym_info
        bout_item["fighter_2_gym_ids"] = fighter_2_gym_ids

        bout_lis = response.css(
            "div > ul > li[class='even:bg-tap_f2 leading-normal py-1.5 md:py-2 px-1 md:text-xs']"
        )
        ufcstats_id = None
        billing = None
        weight_class = None
        for li in bout_lis:
            label = li.css("span.font-bold.text-neutral-900::text").get().strip()

            if label == "Bout Links:":
                bout_links = bout_lis[-1].css("a::attr(href)").getall()
                for link in bout_links:
                    if "www.ufcstats.com/fight-details/" in link:
                        ufcstats_id = link.split("/")[-1]
            elif label == "Bout Billing:":
                li_texts = [
                    x.strip() for x in li.css("span::text").getall() if x.strip()
                ]
                billing = " ".join(li_texts)
                billing = billing.replace("Bout Billing:", "").strip()
                billing = billing if billing else None
            elif label == "Weight:":
                li_texts = [
                    x.strip() for x in li.css("span::text").getall() if x.strip()
                ]
                weight_class = " ".join(li_texts)
                weight_class = weight_class.replace("Weight:", "").strip()
                weight_class = weight_class if weight_class else None

        bout_item["ufcstats_id"] = ufcstats_id
        bout_item["billing"] = billing
        bout_item["weight_class"] = weight_class

        yield bout_item

        # Community picks items
        community_picks = response.css("div[id='boutPagePicks']")
        num_picks = (
            int(
                community_picks.css("h4::text")
                .get()
                .replace("Tapology Community Picks: ", "")
                .replace(",", "")
                .strip()
            )
            if community_picks.css("h4")
            else None
        )
        chart_rows = community_picks.css("div.chartRow")
        for row in chart_rows:
            community_pick_item = TapologyCommunityPickItem()

            community_pick_item["bout_id"] = bout_id
            community_pick_item["fighter_last_name"] = row.css(
                "div.chartLabel::text"
            ).get()
            community_pick_item["ko_tko_percentage"] = (
                float(
                    row.css("div.tko_bar::attr(title)")
                    .get()
                    .replace("by KO/TKO", "")
                    .replace("%", "")
                    .strip()
                )
                if row.css("div.tko_bar")
                else None
            )
            community_pick_item["submission_percentage"] = (
                float(
                    row.css("div.sub_bar::attr(title)")
                    .get()
                    .replace("by Submission", "")
                    .replace("%", "")
                    .strip()
                )
                if row.css("div.sub_bar")
                else None
            )
            community_pick_item["decision_percentage"] = (
                float(
                    row.css("div.dec_bar::attr(title)")
                    .get()
                    .replace("by Decision", "")
                    .replace("%", "")
                    .strip()
                )
                if row.css("div.dec_bar")
                else None
            )
            community_pick_item["overall_percentage"] = (
                float(row.css("div.number::text").get().replace("%", "").strip())
                if row.css("div.number")
                else None
            )
            community_pick_item["num_picks"] = num_picks

            yield community_pick_item

        # Yield temp gym items
        for url in gym_urls:
            temp_gym_item = TapologyTempGymItem()

            temp_gym_item["url"] = url

            yield temp_gym_item


class TapologyGymSpider(Spider):
    name = "tapology_gym_spider"
    allowed_domains = ["tapology.com"]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "DOWNLOAD_DELAY": 5,
        "RANDOMIZE_DOWNLOAD_DELAY": True,
        "DOWNLOAD_TIMEOUT": 600,
        "CONCURRENT_REQUESTS": 1,
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
        "RETRY_TIMES": 1,
        "LOG_LEVEL": "INFO",
        "ITEM_PIPELINES": {
            "scrapy_ufc.pipelines.tapology_pipelines.TapologyGymItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
        "FAKEUSERAGENT_PROVIDERS": [
            "scrapy_fake_useragent.providers.FakeUserAgentProvider",
            "scrapy_fake_useragent.providers.FakerProvider",
        ],
    }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.gym_urls_path = os.path.join(
            os.path.dirname(__file__),
            "..",
            "..",
            "miscellaneous",
            "tapology_gym_urls.txt",
        )

    def start_requests(self):
        with open(self.gym_urls_path) as file:
            gym_urls = file.readlines()

        for url in gym_urls:
            yield Request(url=url, callback=self.parse_gym)

    def parse_gym(self, response):
        gym_item = TapologyGymItem()

        gym_item["id"] = response.url.split("/")[-1]

        name = response.css("h1::text").get().strip()
        gym_item["name"] = name if name else None

        details = response.css("div.gymBasicDetails")
        gym_lis = details.css("ul > li")
        location = None
        name_alt = None
        parent_name = None
        parent_id = None
        for li in gym_lis:
            category = li.css("strong::text").get().strip()
            if category == "Location:":
                location = li.css("span::text").get()
                location = location.strip() if location else None
                location = location if location else None
            elif category == "AKA:":
                name_alt = li.css("span::text").get()
                name_alt = name_alt.strip() if name_alt else None
                name_alt = name_alt if name_alt else None
            elif category == "Parent Gym:":
                parent_name = w3lib.html.remove_tags(li.css("span").get()).strip()
                parent_name = parent_name if parent_name else None

                parent_link = li.css("a::attr(href)").get()
                parent_id = parent_link.split("/")[-1] if parent_link else None
        gym_item["location"] = location
        gym_item["name_alternative"] = name_alt
        gym_item["parent_name"] = parent_name
        gym_item["parent_id"] = parent_id

        yield gym_item
