begin
  require "#{File.dirname(__FILE__)}/lib/amex.rb"
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
puts account.inspect