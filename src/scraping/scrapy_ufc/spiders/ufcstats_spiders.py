# standard library imports

# third party imports
import pandas as pd
import w3lib.html
from scrapy.spiders import Spider

# local imports
from ..items import (
    UFCStatsBoutItem,
    UFCStatsEventItem,
    UFCStatsFighterHistoryItem,
    UFCStatsFighterItem,
    UFCStatsRoundStatsItem,
)
from ..utils import (
    compute_control_time,
    compute_fight_times,
    convert_height,
    extract_landed_attempted,
)


class UFCStatsSpider(Spider):
    name = "ufcstats_spider"
    allowed_domains = ["ufcstats.com"]
    start_urls = [
        "http://ufcstats.com/statistics/events/completed?page=all",
    ]
    custom_settings = {
        "ROBOTSTXT_OBEY": False,
        "CONCURRENT_REQUESTS_PER_DOMAIN": 8,
        "CONCURRENT_REQUESTS": 8,
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
            "scrapy_ufc.pipelines.ufcstats_pipelines.UFCStatsItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
    }

    def parse(self, response):
        event_urls = ["http://ufcstats.com/event-details/6420efac0578988b"]
        event_urls.extend(
            reversed(
                response.css(
                    """tr.b-statistics__table-row >
                td.b-statistics__table-col >
                i.b-statistics__table-content >
                a.b-link.b-link_style_black::attr(href)"""
                ).getall()
            )
        )

        for i, event_url in enumerate(event_urls):
            event_order = i + 1
            yield response.follow(
                event_url,
                self.parse_event,
                cb_kwargs={"is_ufc_event": 1, "event_order": event_order},
            )

    def parse_event(self, response, is_ufc_event, event_order):
        event_item = UFCStatsEventItem()

        event_id = response.url.split("/")[-1]
        name = (
            response.css(
                """h2.b-content__title > 
                span.b-content__title-highlight::text"""
            )
            .get()
            .strip()
        )
        date, location = [
            x.strip()
            for i, x in enumerate(
                response.css("li.b-list__box-list-item::text").getall()
            )
            if i % 2 == 1
        ]

        event_item["id"] = event_id
        event_item["name"] = name
        event_item["date"] = pd.to_datetime(date).strftime("%Y-%m-%d")
        event_item["location"] = location
        event_item["is_ufc_event"] = is_ufc_event
        event_item["event_order"] = event_order

        yield event_item

        rows = response.css(
            "tr.b-fight-details__table-row.b-fight-details__table-row__hover.js-fight-details-click"
        )
        bout_urls = []
        weight_classes = []
        for row in rows:
            bout_urls.append(
                row.css(
                    """td.b-fight-details__table-col.b-fight-details__table-col_style_align-top >
                    p.b-fight-details__table-text > a.b-flag::attr(href)"""
                ).get()
            )
            weight_classes.append(
                row.css(
                    """td.b-fight-details__table-col.l-page_align_left:not([style='width:100px']) >
                    p.b-fight-details__table-text::text"""
                )
                .get()
                .strip()
            )
        assert len(bout_urls) == len(weight_classes)

        for i, (bout_url, weight_class) in enumerate(
            zip(reversed(bout_urls), reversed(weight_classes))
        ):
            bout_order = i + 1
            yield response.follow(
                bout_url,
                self.parse_bout,
                cb_kwargs={
                    "event_id": event_id,
                    "bout_order": bout_order,
                    "weight_class": weight_class,
                },
            )

        fighter_urls = response.css(
            """td[style='width:100px'].b-fight-details__table-col.l-page_align_left >
            p.b-fight-details__table-text >
            a.b-link.b-link_style_black::attr(href)
            """
        ).getall()

        yield from response.follow_all(fighter_urls, self.parse_fighter)

    def parse_bout(self, response, event_id, bout_order, weight_class):
        bout_item = UFCStatsBoutItem()

        bout_item["id"] = response.url.split("/")[-1]
        bout_item["event_id"] = event_id
        bout_item["bout_order"] = bout_order

        fighter_urls = response.css(
            "a.b-link.b-fight-details__person-link::attr(href)"
        ).getall()
        bout_item["red_fighter_id"] = fighter_urls[0].split("/")[-1]
        bout_item["blue_fighter_id"] = fighter_urls[1].split("/")[-1]

        outcomes = response.css("i.b-fight-details__person-status::text").getall()
        bout_item["red_outcome"] = outcomes[0].strip()
        bout_item["blue_outcome"] = outcomes[1].strip()

        bout_item["weight_class"] = weight_class
        bout_item["type_verbose"] = [
            x.strip()
            for x in response.css("i.b-fight-details__fight-title::text").getall()
            if x.strip()
        ][0]

        bonus_img_src = response.css(
            "i.b-fight-details__fight-title > img::attr(src)"
        ).getall()
        if bonus_img_src:
            bonus_img_names = [x.split("/")[-1] for x in bonus_img_src]
            if any(x in ["perf.png", "sub.png", "ko.png"] for x in bonus_img_names):
                bout_item["performance_bonus"] = 1
            else:
                bout_item["performance_bonus"] = 0
        else:
            bout_item["performance_bonus"] = 0

        method_info = response.css("i.b-fight-details__text-item_first").getall()
        bout_item["outcome_method"] = (
            w3lib.html.remove_tags(method_info[0]).replace("Method:", "").strip()
        )

        details = response.css("p.b-fight-details__text").getall()
        method_details = " ".join(
            w3lib.html.remove_tags(details[1]).replace("Details:", "").strip().split()
        )
        bout_item["outcome_method_details"] = method_details if method_details else None

        time_format_info = response.css("i.b-fight-details__text-item").getall()
        bout_item["end_round"] = int(
            w3lib.html.remove_tags(time_format_info[0]).replace("Round:", "").strip()
        )
        end_round_time_split = (
            w3lib.html.remove_tags(time_format_info[1])
            .replace("Time:", "")
            .strip()
            .split(":")
        )
        bout_item["end_round_time_seconds"] = int(end_round_time_split[0]) * 60 + int(
            end_round_time_split[1]
        )
        bout_item["round_time_format"] = (
            w3lib.html.remove_tags(time_format_info[2])
            .replace("Time format:", "")
            .replace("  ", " ")
            .strip()
        )
        total_time_seconds, per_round_times = compute_fight_times(
            bout_item["round_time_format"],
            bout_item["end_round"],
            bout_item["end_round_time_seconds"],
        )
        bout_item["total_time_seconds"] = total_time_seconds

        assert len(per_round_times) == bout_item["end_round"]

        yield bout_item

        tables = response.css("tbody.b-fight-details__table-body")
        if tables:
            stats_by_round_rows = tables[1].css("tr.b-fight-details__table-row")
            sig_stats_by_round_rows = tables[3].css("tr.b-fight-details__table-row")

            assert len(stats_by_round_rows) == len(sig_stats_by_round_rows)

            for i in range(len(stats_by_round_rows)):
                red_round_stats_item = UFCStatsRoundStatsItem()
                blue_round_stats_item = UFCStatsRoundStatsItem()

                red_round_stats_item["bout_id"] = bout_item["id"]
                blue_round_stats_item["bout_id"] = bout_item["id"]
                red_round_stats_item["round_number"] = i + 1
                blue_round_stats_item["round_number"] = i + 1
                red_round_stats_item["fighter_id"] = bout_item["red_fighter_id"]
                blue_round_stats_item["fighter_id"] = bout_item["blue_fighter_id"]
                red_round_stats_item["round_time_seconds"] = per_round_times[i]
                blue_round_stats_item["round_time_seconds"] = per_round_times[i]

                stats_for_round = [
                    x.strip()
                    for x in stats_by_round_rows[i]
                    .css("p.b-fight-details__table-text::text")
                    .getall()
                ]
                red_round_stats_item["knockdowns_scored"] = int(stats_for_round[4])
                blue_round_stats_item["knockdowns_scored"] = int(stats_for_round[5])
                (
                    red_round_stats_item["total_strikes_landed"],
                    red_round_stats_item["total_strikes_attempted"],
                ) = extract_landed_attempted(stats_for_round[10])
                (
                    blue_round_stats_item["total_strikes_landed"],
                    blue_round_stats_item["total_strikes_attempted"],
                ) = extract_landed_attempted(stats_for_round[11])
                (
                    red_round_stats_item["takedowns_landed"],
                    red_round_stats_item["takedowns_attempted"],
                ) = extract_landed_attempted(stats_for_round[12])
                (
                    blue_round_stats_item["takedowns_landed"],
                    blue_round_stats_item["takedowns_attempted"],
                ) = extract_landed_attempted(stats_for_round[13])
                red_round_stats_item["submissions_attempted"] = int(stats_for_round[16])
                blue_round_stats_item["submissions_attempted"] = int(
                    stats_for_round[17]
                )
                red_round_stats_item["reversals_scored"] = int(stats_for_round[18])
                blue_round_stats_item["reversals_scored"] = int(stats_for_round[19])
                red_round_stats_item["control_time_seconds"] = compute_control_time(
                    stats_for_round[20]
                )
                blue_round_stats_item["control_time_seconds"] = compute_control_time(
                    stats_for_round[21]
                )

                sig_stats_for_round = [
                    x.strip()
                    for x in sig_stats_by_round_rows[i]
                    .css("p.b-fight-details__table-text::text")
                    .getall()
                ]
                (
                    red_round_stats_item["significant_strikes_landed"],
                    red_round_stats_item["significant_strikes_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[4])
                (
                    blue_round_stats_item["significant_strikes_landed"],
                    blue_round_stats_item["significant_strikes_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[5])
                (
                    red_round_stats_item["significant_strikes_head_landed"],
                    red_round_stats_item["significant_strikes_head_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[8])
                (
                    blue_round_stats_item["significant_strikes_head_landed"],
                    blue_round_stats_item["significant_strikes_head_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[9])
                (
                    red_round_stats_item["significant_strikes_body_landed"],
                    red_round_stats_item["significant_strikes_body_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[10])
                (
                    blue_round_stats_item["significant_strikes_body_landed"],
                    blue_round_stats_item["significant_strikes_body_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[11])
                (
                    red_round_stats_item["significant_strikes_leg_landed"],
                    red_round_stats_item["significant_strikes_leg_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[12])
                (
                    blue_round_stats_item["significant_strikes_leg_landed"],
                    blue_round_stats_item["significant_strikes_leg_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[13])
                (
                    red_round_stats_item["significant_strikes_distance_landed"],
                    red_round_stats_item["significant_strikes_distance_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[14])
                (
                    blue_round_stats_item["significant_strikes_distance_landed"],
                    blue_round_stats_item["significant_strikes_distance_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[15])
                (
                    red_round_stats_item["significant_strikes_clinch_landed"],
                    red_round_stats_item["significant_strikes_clinch_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[16])
                (
                    blue_round_stats_item["significant_strikes_clinch_landed"],
                    blue_round_stats_item["significant_strikes_clinch_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[17])
                (
                    red_round_stats_item["significant_strikes_ground_landed"],
                    red_round_stats_item["significant_strikes_ground_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[18])
                (
                    blue_round_stats_item["significant_strikes_ground_landed"],
                    blue_round_stats_item["significant_strikes_ground_attempted"],
                ) = extract_landed_attempted(sig_stats_for_round[19])

                yield red_round_stats_item
                yield blue_round_stats_item

    def parse_fighter(self, response):
        fighter_item = UFCStatsFighterItem()

        fighter_item["id"] = response.url.split("/")[-1]
        fighter_item["name"] = (
            response.css("span.b-content__title-highlight::text").get().strip()
        )
        nick = response.css("p.b-content__Nickname::text").get().strip()
        fighter_item["nickname"] = nick if nick else None

        info = [
            x.strip()
            for i, x in enumerate(
                response.css(
                    "li.b-list__box-list-item.b-list__box-list-item_type_block::text"
                ).getall()
            )
            if (i % 2 == 1 and i != 19)
        ]
        fighter_item["height_inches"] = convert_height(info[0])
        fighter_item["reach_inches"] = (
            int(info[2].replace('"', "")) if info[2] != "--" else None
        )
        fighter_item["stance"] = info[3] if info[3] else None
        fighter_item["date_of_birth"] = (
            pd.to_datetime(info[4]).strftime("%Y-%m-%d") if info[4] != "--" else None
        )

        yield fighter_item

        history_rows = response.css(
            "tr.b-fight-details__table-row.b-fight-details__table-row__hover.js-fight-details-click"
        )
        event_urls = []
        for i, row in enumerate(reversed(history_rows)):
            history_item = UFCStatsFighterHistoryItem()

            history_item["fighter_id"] = fighter_item["id"]
            history_item["order"] = i + 1
            history_item["bout_id"] = (
                row.css(
                    "td.b-fight-details__table-col > p.b-fight-details__table-text > a.b-flag::attr(href)"
                )
                .get()
                .split("/")[-1]
            )

            urls = row.css(
                "td.b-fight-details__table-col.l-page_align_left > p.b-fight-details__table-text > a.b-link.b-link_style_black::attr(href)"
            ).getall()
            assert len(urls) == 3

            history_item["opponent_id"] = urls[1].split("/")[-1]

            yield history_item

            event_urls.append(urls[2])

        yield from response.follow_all(
            event_urls,
            self.parse_event,
            cb_kwargs={"is_ufc_event": 0, "event_order": None},
        )
