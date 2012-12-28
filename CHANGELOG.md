## Changelog

__v0.1.0__ - Original version

__v0.2.0__ - Support for multiple American Express cards, parsing using
Nokogiri

__v0.3.0__ - Adds support for loading the transactions from the most recent statement
(but it's broken because I forgot to change something from testing :( )

__v0.3.1__ - Working version of v0.3.0 that will successfully load transactions
from the most recent statement

__v0.3.2__ - Generates a fake HardwareId in the first request, since I'm
paranoid about American Express blocking 'dummy_device_id'

__v0.4.0__ - Improves transactions - adds support for lazy-loading and
pagination from Amex::CardAccount#transactions

__v0.4.1__ - Adds YARD documentation