# Try to bring in the Amex gem
begin
  require 'amex'
rescue Exception => e
  puts "Unable to load Amex gem from installed gems"
  puts "Message: #{e.message}"
  puts "Backtrace: #{e.backtrace.inspect}"
end

# ...but if we don't have it, we can  safely attempt to pull it in
begin
  Dir["#{File.dirname(__FILE__)}/lib/**/*.rb"].each { |f| require(f) }
rescue Exception => e
  puts "Unable to load Amex gem from lib/amex directory"
  puts "Message: #{e.message}"
  puts "Backtrace: #{e.backtrace.inspect}"
end

# Bring in the settings.rb file - this isn't included in the repository,
# but it should just contain two class variables, `username` and `password`
require "#{File.dirname(__FILE__)}/settings.rb"

client = Amex::Client.new(@username, @password)
account = client.fetch