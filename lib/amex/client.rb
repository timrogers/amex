require 'erb'
require 'httparty'
require 'nokogiri'

module Amex
  class Client
    include HTTParty
    base_uri 'https://global.americanexpress.com/'

    def initialize(username, password)
      @username = username
      @password = password
    end

    def request_xml
      xml = File.read(
        File.expand_path(File.dirname(__FILE__) + '/data/request.xml')
      )

      username = @username
      password = @password
      timestamp = Time.now.to_i

      ERB.new(xml).result(binding)
    end

    def account
      # This only supports one account for now, because I'm lazy and I
      # hate traversing XML...
      options = { :body => { "PayLoadText" => request_xml }}
      response = self.class.post(
        '/myca/intl/moblclient/emea/ws.do?Face=en_GB', options
      )

      xml = MultiXml.parse(response)['XMLResponse']

      if xml['ServiceResponse']['Status'] != "success"
        raise "There was a problem logging in to American Express."
      else
        account_details = {}
        xml["CardAccounts"]["CardAccount"]["CardData"]["param"].each do |item|
          account_details[item['name']] = item['__content__']
        end

        xml["CardAccounts"]["CardAccount"]["AccountSummaryData"]["SummaryElement"].each do |item|
          account_details[item['name']] = item['value'] ? item['value'].to_f : item['formattedValue']
        end

        account = Amex::CardAccount.new(account_details)

        xml["CardAccounts"]["CardAccount"]["LoyaltyProgramData"].each do |item|
          item.each do |part|
            next if part.class == String
            account.loyalty_programmes << Amex::LoyaltyProgramme.new(part['label'], part['formattedValue'].gsub(",", "").to_i)
          end
        end

        account
      end

    end

  end
end