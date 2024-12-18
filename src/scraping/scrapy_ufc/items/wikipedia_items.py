# standard library imports

# third party imports
from scrapy import Field

# local imports
from ._ordered import OrderedItem


class WikipediaEventItem(OrderedItem):
    id = Field()
    name = Field()
    date = Field()
    venue_name = Field()
    location = Field()
    attendance = Field()
