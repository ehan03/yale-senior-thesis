# standard library imports
from io import StringIO

# third party imports
import pandas as pd
from scrapy.spiders import Spider

# local imports
from ..items import WikipediaEventItem


class WikipediaSpider(Spider):
    name = "wikipedia_spider"
    allowed_domains = ["en.wikipedia.org"]
    start_urls = ["https://en.wikipedia.org/wiki/List_of_UFC_events"]
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
            "scrapy_ufc.pipelines.wikipedia_pipelines.WikipediaItemPipeline": 100,
        },
        "CLOSESPIDER_ERRORCOUNT": 1,
    }

    def parse(self, response):
        table = (
            response.css("table[id='Past_events']")
            .get()
            .strip()
            .replace('2data-sort-value=""', "2")
        )
        table_df = pd.read_html(StringIO(table), header=0)[0][::-1]
        table_df = (
            table_df.loc[table_df["Attendance"] != "Canceled"]
            .drop(columns=["Ref."])
            .rename(
                columns={
                    "#": "id",
                    "Event": "name",
                    "Date": "date",
                    "Venue": "venue_name",
                    "Location": "location",
                    "Attendance": "attendance",
                }
            )
        )
        table_df["id"] = table_df["id"].astype(int)
        table_df["name"] = table_df["name"].str.replace("  ", " ")
        table_df["date"] = pd.to_datetime(table_df["date"]).dt.strftime("%Y-%m-%d")
        table_df["venue_name"] = table_df["venue_name"].str.replace("  ", " ")
        table_df["location"] = table_df["location"].str.replace("  ", " ")
        table_df["attendance"] = table_df["attendance"].apply(
            lambda x: int(x) if x != "—" else None
        )

        for row in table_df.itertuples(index=False):
            event = WikipediaEventItem(
                id=row.id,
                name=row.name,
                date=row.date,
                venue_name=row.venue_name,
                location=row.location,
                attendance=row.attendance,
            )
            yield event
