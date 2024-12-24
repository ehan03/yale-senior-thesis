# standard library imports

# third party imports
import pandas as pd
import w3lib.html
from scrapy import Request
from scrapy.spiders import Spider

# local imports
from ..items.mmadecisions_items import (
    MMADecisionsBoutItem,
    MMADecisionsDeductionItem,
    MMADecisionsEventItem,
    MMADecisionsFighterItem,
    MMADecisionsJudgeItem,
    MMADecisionsJudgeScoreItem,
    MMADecisionsMediaScoreItem,
)


class MMADecisionsSpider(Spider):
    name = "mmadecisions_spider"
    allowed_domains = ["mmadecisions.com"]
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
        "RETRY_TIMES": 10,
        "LOG_LEVEL": "INFO",
        "ITEM_PIPELINES": {
            "scrapy_ufc.pipelines.mmadecisions_pipelines.MMADecisionsItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
    }

    def __init__(self, *args, **kwargs):
        super(MMADecisionsSpider, self).__init__(*args, **kwargs)

        self.bout_ids_same_fighter_last_name = [4640, 7207]

    def start_requests(self):
        start_url = "https://mmadecisions.com/decisions-by-event/1995/"

        yield Request(
            url=start_url,
            callback=self.parse_events_by_year_page,
            cb_kwargs={"event_urls_all": []},
        )

    def parse_events_by_year_page(self, response, event_urls_all):
        event_urls = reversed(
            response.css("tr.decision > td.list > a::attr(href)").getall()
        )
        event_names = reversed(response.css("tr.decision > td.list > a::text").getall())

        for event_url, event_name in zip(event_urls, event_names):
            if event_name.startswith("Boxing"):
                continue
            event_urls_all.append(f"{event_url}/")

        year = int(response.url.split("/")[-2])
        if year < 2024:
            next_year = year + 1
            next_url = f"https://mmadecisions.com/decisions-by-event/{next_year}/"

            yield response.follow(
                url=next_url,
                callback=self.parse_events_by_year_page,
                cb_kwargs={"event_urls_all": event_urls_all},
            )
        else:
            for i, event_url in enumerate(event_urls_all):
                yield response.follow(
                    url=event_url,
                    callback=self.parse_event,
                    cb_kwargs={"event_order": i + 1},
                )

    def parse_event(self, response, event_order):
        event_item = MMADecisionsEventItem()

        event_item["event_order"] = event_order
        event_item["id"] = int(response.url.split("/")[-3])
        event_item["name"] = (
            response.css("table > tr.top-row > td.decision-top2 > b::text")
            .get()
            .strip()
        )

        venue_location_list = [
            x.strip()
            for x in response.css(
                "table > tr.top-row > td.decision-top2::text"
            ).getall()
        ]
        assert len(venue_location_list) == 3
        assert venue_location_list[0] == ""

        event_item["venue"] = venue_location_list[1] if venue_location_list[1] else None
        event_item["location"] = (
            venue_location_list[2] if venue_location_list[2] else None
        )

        date = (
            response.css("table > tr.bottom-row > td.decision-bottom2::text")
            .get()
            .strip()
        )
        event_item["date"] = pd.to_datetime(date).strftime("%Y-%m-%d")

        event_item["promotion"] = (
            response.css("table > tr.top-row > td.decision-top2::attr(style)")
            .get()
            .strip()
            .split("/")[-1]
            .split("_")[0]
            .upper()
        )

        yield event_item

        bout_urls = [
            f"{x.strip()}/"
            for x in response.css("table > tr > td.list2 > b > a::attr(href)").getall()
            if x.startswith("decision")
        ]
        for i, bout_url in enumerate(reversed(bout_urls)):
            yield response.follow(
                url=response.urljoin(bout_url),
                callback=self.parse_bout,
                cb_kwargs={"event_id": event_item["id"], "bout_order": i + 1},
            )

        judge_urls = list(
            set(
                [
                    f"{x.strip()}/"
                    for x in response.css(
                        "table > tr > td.list > b > a::attr(href)"
                    ).getall()
                    if x.startswith("judge")
                ]
            )
        )
        for judge_url in judge_urls:
            yield response.follow(
                url=response.urljoin(judge_url), callback=self.parse_judge
            )

    def parse_bout(self, response, event_id, bout_order):
        bout_item = MMADecisionsBoutItem()

        bout_id = int(response.url.split("/")[-3])
        bout_item["id"] = bout_id
        bout_item["event_id"] = event_id
        bout_item["bout_order"] = bout_order

        main_table = response.css(
            "table[border='0'][width='965px'][cellspacing='0'][cellpadding='2'][align='center']"
        )

        # Bout item
        bout_info_table = main_table.css(
            """tr > td[width='765px'][valign='top'][align='center'][style='border-right: 1px solid #999;'] >
            table[style='border: 0px; border-spacing: 0px; width: 100%'] > tr >
            td[width='60%'][align='left'][valign='top'] > table[style='border: 0px; border-spacing: 0px; width: 100%']"""
        )
        tale_of_the_tape_table = main_table.css(
            """tr > td[width='765px'][valign='top'][align='center'][style='border-right: 1px solid #999;'] > 
            table[style='border: 0px; border-spacing: 0px; width: 100%'] > tr >
            td[width='40%'][align='right'][valign='bottom'] > table[style='border: 0px; width: 97%']"""
        )

        fighter_1_id = int(
            bout_info_table.css("tr.top-row > td.decision-top > a::attr(href)")
            .get()
            .strip()
            .split("/")[-2]
        )
        fighter_1_url = f"{bout_info_table.css("tr.top-row > td.decision-top > a::attr(href)").get().strip()}/"
        fighter_1_name = (
            bout_info_table.css("tr.top-row > td.decision-top > a::text")
            .get()
            .strip()
            .replace("\xa0", " ")
        )
        fighter_2_id = int(
            bout_info_table.css("tr.bottom-row > td.decision-bottom > a::attr(href)")
            .get()
            .strip()
            .split("/")[-2]
        )
        fighter_2_url = f"{bout_info_table.css("tr.bottom-row > td.decision-bottom > a::attr(href)").get().strip()}/"
        fighter_2_name = (
            bout_info_table.css("tr.bottom-row > td.decision-bottom > a::text")
            .get()
            .strip()
            .replace("\xa0", " ")
        )
        decision_type = bout_info_table.css("tr > th.event2 > i::text").get().strip()

        fighters_last_names = [
            x.strip()
            for x in tale_of_the_tape_table.css(
                "tr.top-row > td.decision-top2 > b::text"
            ).getall()
        ]
        assert len(fighters_last_names) == 2

        last_name_to_fighter_num = {}
        if bout_id not in self.bout_ids_same_fighter_last_name:
            assert fighters_last_names[0] != fighters_last_names[1]

            if fighter_1_name.endswith(
                fighters_last_names[0]
            ) and not fighter_2_name.endswith(fighters_last_names[0]):
                last_name_to_fighter_num[fighters_last_names[0]] = 1
                last_name_to_fighter_num[fighters_last_names[1]] = 2
            elif fighter_2_name.endswith(
                fighters_last_names[0]
            ) and not fighter_1_name.endswith(fighters_last_names[0]):
                last_name_to_fighter_num[fighters_last_names[0]] = 2
                last_name_to_fighter_num[fighters_last_names[1]] = 1
            else:
                raise ValueError("Fighter last name not found or ambiguous")

        fighter_1_weight_lbs = None
        fighter_2_weight_lbs = None
        fighter_1_fighting_out_of = None
        fighter_2_fighting_out_of = None
        matchup_rows = tale_of_the_tape_table.css("tr.decision")
        for row in matchup_rows:
            tds = row.css("td")
            assert len(tds) == 3

            category = tds[1].css("b::text").get().strip()
            info_1 = tds[0].css("::text").get()
            info_2 = tds[2].css("::text").get()
            if category == "WEIGHT":
                info_1 = info_1.replace("lbs.", "").strip() if info_1 else None
                info_2 = info_2.replace("lbs.", "").strip() if info_2 else None
                if (
                    last_name_to_fighter_num.get(fighters_last_names[0], None) == 1
                    or bout_id in self.bout_ids_same_fighter_last_name
                ):
                    fighter_1_weight_lbs = float(info_1) if info_1 else None
                    fighter_2_weight_lbs = float(info_2) if info_2 else None
                elif last_name_to_fighter_num.get(fighters_last_names[0], None) == 2:
                    fighter_1_weight_lbs = float(info_2) if info_2 else None
                    fighter_2_weight_lbs = float(info_1) if info_1 else None
                else:
                    raise ValueError("Fighter last name not found or ambiguous")
            elif category == "FIGHTING":
                info_1 = info_1.strip() if info_1 else None
                info_2 = info_2.strip() if info_2 else None
                if (
                    last_name_to_fighter_num.get(fighters_last_names[0], None) == 1
                    or bout_id in self.bout_ids_same_fighter_last_name
                ):
                    fighter_1_fighting_out_of = info_1 if info_1 else None
                    fighter_2_fighting_out_of = info_2 if info_2 else None
                elif last_name_to_fighter_num.get(fighters_last_names[0], None) == 2:
                    fighter_1_fighting_out_of = info_2 if info_2 else None
                    fighter_2_fighting_out_of = info_1 if info_1 else None
                else:
                    raise ValueError("Fighter last name not found or ambiguous")

        bout_item["fighter_1_id"] = fighter_1_id
        bout_item["fighter_2_id"] = fighter_2_id
        bout_item["fighter_1_weight_lbs"] = fighter_1_weight_lbs
        bout_item["fighter_2_weight_lbs"] = fighter_2_weight_lbs
        bout_item["fighter_1_fighting_out_of"] = fighter_1_fighting_out_of
        bout_item["fighter_2_fighting_out_of"] = fighter_2_fighting_out_of
        bout_item["decision_type"] = decision_type

        yield bout_item

        # Scrape fighter info
        for fighter_url in [fighter_1_url, fighter_2_url]:
            yield response.follow(
                url=response.urljoin(fighter_url),
                callback=self.parse_fighter,
            )

        # Judge score items
        judge_score_tables = main_table.css(
            """tr > td[width='765px'][valign='top'][align='center'][style='border-right: 1px solid #999;'] > 
            table[style='border: 0px; border-spacing: 0px; width: 100%'] > tr >
            td[colspan='2'] > table[style='width: 100%; border: 0'] > tr > td[width='33%'] >
            table[style='border-spacing: 1px; width: 100%']"""
        )
        for i, judge_score_table in enumerate(judge_score_tables):
            judge_url = judge_score_table.css(
                "tr.top-row > td.judge > a::attr(href)"
            ).get()
            judge_id = int(judge_url.split("/")[-2]) if judge_url else None
            judge_order = i + 1

            scorecard_fighters_last_names = [
                x.strip()
                for x in judge_score_table.css(
                    "tr.top-row > td.top-cell > b::text"
                ).getall()
            ]
            assert len(scorecard_fighters_last_names) == 2

            if bout_id not in self.bout_ids_same_fighter_last_name:
                assert (
                    scorecard_fighters_last_names[0] != scorecard_fighters_last_names[1]
                )
                assert last_name_to_fighter_num[scorecard_fighters_last_names[0]] == 1
                assert last_name_to_fighter_num[scorecard_fighters_last_names[1]] == 2

            round_rows = judge_score_table.css("tr.decision")
            for round_row in round_rows:
                td_values = [x.strip() for x in round_row.css("td.list::text").getall()]
                assert len(td_values) == 3

                judge_score_item = MMADecisionsJudgeScoreItem()
                judge_score_item["bout_id"] = bout_id
                judge_score_item["round"] = td_values[0]
                judge_score_item["judge_id"] = judge_id
                judge_score_item["judge_order"] = judge_order
                judge_score_item["fighter_1_score"] = (
                    int(td_values[1]) if td_values[1] != "-" else None
                )
                judge_score_item["fighter_2_score"] = (
                    int(td_values[2]) if td_values[2] != "-" else None
                )

                yield judge_score_item

            total_scores = judge_score_table.css(
                "tr.bottom-row > td.bottom-cell > b::text"
            ).getall()
            extra_scores = None
            if len(total_scores) == 4:
                extra_scores = total_scores[2:]
                total_scores = total_scores[:2]
            assert len(total_scores) == 2

            judge_score_total_item = MMADecisionsJudgeScoreItem()
            judge_score_total_item["bout_id"] = bout_id
            judge_score_total_item["round"] = "Total"
            judge_score_total_item["judge_id"] = judge_id
            judge_score_total_item["judge_order"] = judge_order
            judge_score_total_item["fighter_1_score"] = (
                int(total_scores[0]) if total_scores[0] != "-" else None
            )
            judge_score_total_item["fighter_2_score"] = (
                int(total_scores[1]) if total_scores[1] != "-" else None
            )

            yield judge_score_total_item

            if extra_scores:
                judge_score_extra_item = MMADecisionsJudgeScoreItem()
                judge_score_extra_item["bout_id"] = bout_id
                judge_score_extra_item["round"] = "Extra"
                judge_score_extra_item["judge_id"] = judge_id
                judge_score_extra_item["judge_order"] = judge_order
                judge_score_extra_item["fighter_1_score"] = (
                    int(extra_scores[0]) if extra_scores[0] != "-" else None
                )
                judge_score_extra_item["fighter_2_score"] = (
                    int(extra_scores[1]) if extra_scores[1] != "-" else None
                )

                yield judge_score_extra_item

        # Point deduction items
        deductions_table = main_table.css(
            """tr > td[width='765px'][valign='top'][align='center'][style='border-right: 1px solid #999;'] > 
            table[style='border: 0px; border-spacing: 0px; width: 100%'] > tr > 
            td[colspan='2'][align='center'] > table"""
        )
        deductions = [
            w3lib.html.remove_tags(x).strip()
            for x in deductions_table.css("tr > td").getall()
        ]
        for deduction in deductions:
            deduction = (
                deduction.replace("was deducted", "|")
                .replace("points in round", "|")
                .replace("point in round", "|")
                .replace(": ", "|")
            )
            deduction_split = [x.strip() for x in deduction.split("|")]
            assert len(deduction_split) == 4

            deduction_item = MMADecisionsDeductionItem()
            deduction_item["bout_id"] = bout_id

            fighter_last_name = deduction_split[0]
            if last_name_to_fighter_num[fighter_last_name] == 1:
                deduction_item["fighter_id"] = fighter_1_id
            elif last_name_to_fighter_num[fighter_last_name] == 2:
                deduction_item["fighter_id"] = fighter_2_id
            else:
                raise ValueError("Fighter last name not found or ambiguous")

            deduction_item["round_number"] = int(deduction_split[2])
            deduction_item["points_deducted"] = int(deduction_split[1])
            deduction_item["reason"] = deduction_split[3]

            yield deduction_item

        # Media score items
        media_scores_table = main_table.css(
            """tr > td[width='765px'][valign='top'][align='center'][style='border-right: 1px solid #999;'] >
            table[style='border-spacing: 0px; width: 100%; border: 0'] > tr >
            td[width='34%'][valign='top'] > table[style='border-spacing: 0px; width: 100%']"""
        )
        media_score_rows = media_scores_table.css("tr.decision")
        for row in media_score_rows:
            tds = row.css("td")
            assert len(tds) == 3

            person_name = tds[0].css("::text").get()
            person_name = (
                person_name.strip().replace("\xa0", " ") if person_name else None
            )
            media_name = tds[0].css("a::text").get()
            media_name = media_name.strip() if media_name else None
            scores = [int(x) for x in tds[1].css("a::text").get().strip().split("-")]
            reference = w3lib.html.remove_tags(tds[2].get()).strip()

            media_score_item = MMADecisionsMediaScoreItem()
            media_score_item["bout_id"] = bout_id
            media_score_item["person_name"] = person_name if person_name else None
            media_score_item["media_name"] = media_name if media_name else None

            if (
                reference == "DRAW"
                or last_name_to_fighter_num.get(reference, None) == 1
                or bout_id in self.bout_ids_same_fighter_last_name
            ):
                media_score_item["fighter_1_score"] = scores[0]
                media_score_item["fighter_2_score"] = scores[1]
            elif last_name_to_fighter_num.get(reference, None) == 2:
                media_score_item["fighter_1_score"] = scores[1]
                media_score_item["fighter_2_score"] = scores[0]
            else:
                raise ValueError("Fighter last name not found or ambiguous")

            yield media_score_item

    def parse_fighter(self, response):
        fighter_item = MMADecisionsFighterItem()

        fighter_id = int(response.url.split("/")[-3])
        fighter_item["id"] = fighter_id
        fighter_item["name"] = (
            response.css("table > tr > td > table > tr.top-row > td.judge2::text")
            .get()
            .strip()
            .replace("\xa0", " ")
        )

        tables = response.css("table > tr > td > table")
        tds = tables[0].css("tr.top-row > td.top-cell, tr > td.list")

        born_info = []
        height = None
        reach_inches = None
        nicknames = []

        current_category = None
        for td in tds:
            class_name = td.css("::attr(class)").get()

            if class_name == "top-cell":
                current_category = td.css("b::text").get().strip()
            elif class_name == "list" and current_category:
                text_value = td.css("::text").get().strip()
                text_value = " ".join(text_value.split())

                if current_category == "BORN" and text_value != "No data available":
                    born_info.append(text_value)
                elif current_category == "HEIGHT" and text_value != "n/a":
                    height = text_value if text_value else None
                elif current_category == "REACH" and text_value != "n/a":
                    reach_inches = float(text_value.replace('"', ""))
                elif current_category == "NICKNAME(S)":
                    nicknames.append(text_value)

        fighter_item["date_of_birth"] = None
        fighter_item["birth_location"] = None
        if born_info:
            month_names = [
                "January",
                "February",
                "March",
                "April",
                "May",
                "June",
                "July",
                "August",
                "September",
                "October",
                "November",
                "December",
            ]
            for b in born_info:
                if any([b.startswith(month) for month in month_names]):
                    fighter_item["date_of_birth"] = pd.to_datetime(
                        b.split("(")[0].strip()
                    ).strftime("%Y-%m-%d")
                else:
                    fighter_item["birth_location"] = b

        fighter_item["height"] = height
        fighter_item["reach_inches"] = reach_inches

        fighter_item["nicknames"] = "; ".join(nicknames) if nicknames else None

        yield fighter_item

    def parse_judge(self, response):
        judge_item = MMADecisionsJudgeItem()

        judge_item["id"] = int(response.url.split("/")[-3])
        judge_item["name"] = (
            response.css("title::text")
            .get()
            .split("::")[0]
            .strip()
            .replace("\xa0", " ")
        )

        yield judge_item
