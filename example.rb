require 'rubygems'
require 'amex'

# Bring in the settings.rb file - this isn't included in the repository,
# but it should just contain two class variables, `username` and `password`
require "#{File.dirname(__FILE__)}/settings.rb"

# Instantiate an Amex::Client object
client = Amex::Client.new(@username, @password, "en_US")

# Execute the #accounts method on the client, which will return an array
# of Amex::CardAccount objects
accounts = client.accounts

# Let's take a look at your first account...
account = accounts.first
puts account.inspect

# We can find out the transactions since the last statement
recent_transactions = account.transactions(0, :recent)
puts "There have been #{recent_transactions.length} transactions since your " +
"last statement."

pending_transactions = account.transactions(0, :pending)
puts "There are #{pending_transactions.length} pending transactions since your " +
"last statement."

# and then look at individual statements to see their transactions...
last_statement = account.transactions(1)
puts "There were #{last_statement.length} transactions on your last statement."

# Let's view transactions from now to the end of your last statement, and
# then find out how many were made abroad...
foreign_transactions = account.transactions(0..1).keep_if do |tx|
  tx.is_foreign_transaction?
end
puts "#{foreign_transactions.length} transactions since the start of your " +
"last statement period were made abroad."
