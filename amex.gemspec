require File.expand_path('../lib/amex/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = 'amex'
  gem.version = Amex::VERSION.dup
  gem.authors = ['Tim Rogers']
  gem.email = ['tim@tim-rogers.co.uk']
  gem.summary = 'A library for accessing data on an American Express account'
  gem.homepage = 'https://github.com/timrogers/amex'

  gem.add_runtime_dependency "httparty"
  gem.add_runtime_dependency "nokogiri"
  gem.add_runtime_dependency "uuid"

  gem.files = `git ls-files`.split("\n")
end