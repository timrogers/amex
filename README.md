## Amex *[(view on RubyGems.org)](http://rubygems.org/gems/amex)*

Welcome to the last continuation of my Ruby-based assault on various online
banking systems, much like my
[Lloyds TSB screen scraper](https://github.com/timrogers/lloydstsb).

However, this one doesn't rely on nasty screen-scraping. Instead, it uses
the previous unknown internal API used by American Express for their
"Amex UK" iPhone app. I suspect it works elsewhere, but I haven't tested.

This allows you to fetch the details of all the cards on your American
Express login, as well as transactions on each card.

### Changelog

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


### Usage

The file `example.rb` provides a very simple example of how the code works, but here's a step by step:

1. Ensure the gem is installed, and then include it in your Ruby file, or in your Gemfile where appropriate:

```
$ gem install amex
...
require 'rubygems'
require 'amex'
```

2. You'll just need two variables, @username and @password, each unsurprisingly corresponding to different authentication details used

```
@username = "chuck_norris"
@password = "roundhousekick123"
```

3. Instantiate a new instance of the `Amex::Client` object, passing in the
username and password - this is used to perform the authentication required.

`client = Amex::Client.new(@username, @password)`

4. Call the `account` method of the object you just made - it'll take a few seconds, and will return an Amex::CardAccount object. There'll only be one, since this
only supports one card at a time right now.

```
accounts = client.accounts
my_account = accounts.first
puts my_account.product
puts my_account.type
puts my_account.transactions.inspect
```

### Documentation

You can view the full YARD documentation [here](http://rubydoc.info/github/timrogers/amex/master/frames).

### Examples

* __[amex_alerts](https://github.com/timrogers/amex-alerts)__, a script
designed to be run as a cron which tracks and alerts you on your rewards
balances

### License

Use this for what you will, as long as it isn't evil. If you make any changes or cool improvements, please let me know at <tim+amex@tim-rogers.co.uk>.

