require File.expand_path('../lib/amex/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'amex'
  gem.version = Amex::VERSION.dup
  gem.authors = ['Tim Rogers']
  gem.email = ['tim@tim-rogers.co.uk']
  gem.summary = 'A library for accessing data on an American Express account'
  gem.homepage = 'https://github.com/timrogers/amex'

  gem.add_runtime_dependency "httparty"

  gem.files = ["lib/amex.rb", "lib/amex/card_account.rb", "lib/amex/client.rb",
    "lib/amex/loyalty_programme.rb", "lib/amex/utils.rb", "lib/amex/version.rb",
    "lib/amex/data/request.xml"]
end