## Amex *[(view on RubyGems.org)](http://rubygems.org/gems/amex)*

Welcome to the last continuation of my Ruby-based assault on various online
banking systems, much like my
[Lloyds TSB screen scraper](https://github.com/timrogers/lloydstsb).

However, this one doesn't rely on nasty screen-scraping. Instead, it uses
the previous unknown internal API used by American Express for their
"Amex UK" iPhone app. I suspect it works elsewhere, but I haven't tested.

This allows you to fetch the details of all the cards on your American
Express login, as well as the most recent statement's transactions.

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

### Data models

An `Amex::CardAccount` is created by `Amex::CardAccount.new` passing in a hash
of the parsed XML. The parsing is done by `Amex::Client`.

An __Amex::CardAccount__ instance has the following attributes:

* __product (string)__ - the type of card (e.g. "The Preferred Rewards Gold Card®")
* __card_number_suffix (string)__ - the last five digits of your card number
* __card_index (integer)__ - the internal number of the card on your account
in the Amex system, starting from 0 *(used internally by the gem)*
* __lending_type (string)__ - either "Charge" or "Credit", depending on the type of credit arrangement you have
* __card_member_name (string)__ - your name, as recorded as the account holder
* __past_due (boolean)__ - is the card past its due payment date?
* __cancelled?__ (boolean)__ - has the account been cancelled?
* __is_basic/centurion/platinum/premium] (boolean)__ - which type of account does this conform to?
* __market (string)__ - the market that your card is registered too, e.g. "en_GB"
* __card__art (string)__ - a URL for an image of your card
* __loyalty_indicator (boolean)__ - does this card have some
kind of loyalty scheme active? (e.g. Membership Rewards)
* __loyalty_programmes (array of Amex::LoyaltyProgramme objects)__ - the loyalty programmes this card belongs to
* __loyalty_balances (hash)__ - the loyalty balances on this card - the key is the name of the programme (string), and the balance is the value, as an integer
* __statement_balance (float)__ - the amount of the last statement on your account
* __payment_credits (float)__ - the combination of current payments and credits on your account
* __recent_charges (float)__ - charges since your last statement was issued (I believe)
* __total_balance (float)__ - what American Express refer to as your total balance, whatever that is!
* __payment_due (float)__ - the amount of money you need to pay before `payment_due_date`
* __payment_due_date (DateTime)__ - when the `payment_due` needs to be paid by
* __transactions (array)__ - an array of Amex::Transaction objects)

There are lots of extra useful methods here to make accessing
some of the various properties easier. They're very self-explanatory - check `lib/amex/card_account.rb`.

A __Amex::LoyaltyProgramme has just two attributes:

* __name (string)__ - The name of the programme, most often "Membership Rewards"
* __balance (integer)__ - The balance of the programme

An __Amex::Transaction represents a transaction in your most recent American
Express statement. It has four attributes:

* __amount (float)__ - The amount of the transaction
* __date (Date)__ - The date that the transaction was recorded
* __narrative (string)__ - The description shown on your statement, usually
contaning the name of the merchant and their location
* __extra_details (hash)__ - This hash contains any extra pieces of information
provided by American Express...for instance, foreign transactions have their
exchange rate and commission. The name of the attribute will be the key, and
its formatted value in the value in the hash.

There's one helper method currently available here, `is_foreign_transaction?`,
which returns a boolean representing whether the transaction was foreign (i.e.
in a non-native currency).

### Limitations

* You can only view transactions from the most recent statement. I intend
to change this in due course to support pagination of some description.

### License

Use this for what you will, as long as it isn't evil. If you make any changes or cool improvements, please let me know at <tim+amex@tim-rogers.co.uk>.

