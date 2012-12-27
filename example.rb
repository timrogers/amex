require 'rubygems'
require 'amex'

# Bring in the settings.rb file - this isn't included in the repository,
# but it should just contain two class variables, `username` and `password`
require "#{File.dirname(__FILE__)}/settings.rb"

client = Amex::Client.new(@username, @password)
accounts = client.accounts
puts accounts.first.inspect