# standard library imports
import json
from collections import OrderedDict

# third party imports
import six
from scrapy import Item

# local imports


class OrderedItem(Item):
    def __init__(self, *args, **kwargs):
        self._values = OrderedDict()
        if args or kwargs:
            for k, v in six.iteritems(dict(*args, **kwargs)):
                self[k] = v

    def __repr__(self):
        return json.dumps(OrderedDict(self), ensure_ascii=False)
