require 'erb'
require 'httparty'
require 'nokogiri'
require 'date'

module Amex
  class Client
    include HTTParty
    base_uri 'https://global.americanexpress.com/'

    def initialize(username, password)
      @username = username
      @password = password
    end

    def accounts
      # This only supports one account for now, because I'm lazy and I
      # hate traversing XML...
      options = { :body => { "PayLoadText" => request_xml }}
      response = self.class.post(
        '/myca/intl/moblclient/emea/ws.do?Face=en_GB', options
      )

      xml = Nokogiri::XML(response.body)
      xml = xml.css("XMLResponse")

      if xml.css('ServiceResponse Status').text != "success"
        raise "There was a problem logging in to American Express."
      else
        # Store the security token - we need this for further requests
        @security_token = xml.css('ClientSecurityToken').text

        accounts = [] # We'll store all the accounts in here!

        xml.css('CardAccounts CardAccount').each do |item|
          account_details = {} # All the attributes from the XML go in here
          # For each of the CardAccount objects, let's first go through
          # the CardData to pull out lots of nice information
          item.css('CardData param').each do |attribute|
            account_details[attribute.attr('name')] = attribute.text
          end

          # Now let's go through the AccountSummaryData to find all the
          # various bits of balance information
          item.css('AccountSummaryData SummaryElement').each do |attribute|
            account_details[attribute.attr('name')] = attribute.attr('value') ? attribute.attr('value').to_f : attribute.attr('formattedValue')
          end

          # We have all the attributes ready to go, so let's make an
          # Amex::CardAccount object
          account = Amex::CardAccount.new(account_details)

          # Finally, let's rip out all the loyalty balances...
          item.css('LoyaltyProgramData LoyaltyElement').each do |element|
            account.loyalty_programmes << Amex::LoyaltyProgramme.new(
              element.attr('label'), element.attr('formattedValue').gsub(",", "").to_i
            )
          end

          # Now we can fetch the transactions...
          options = { :body => {
            "PayLoadText" => statement_request_xml(account.card_index)
          }}
          response = self.class.post(
            '/myca/intl/moblclient/emea/ws.do?Face=en_GB', options
          )
          xml = Nokogiri::XML(response.body)
          xml = xml.css("XMLResponse")

          xml.css('Transaction').each do |transaction|
            account.transactions << Amex::Transaction.new(transaction)
          end

          accounts << account

        end

        accounts
      end

    end

    private

    def request_xml
      # Generates XML for the first request for account information, taking
      # an XML template and interpolating some parts with ERB

      xml = File.read(
        File.expand_path(File.dirname(__FILE__) + '/data/request.xml')
      )

      username = @username
      password = @password
      timestamp = Time.now.to_i

      ERB.new(xml).result(binding)
    end

    def statement_request_xml(card_index)
      # Generates XML for grabbing the last statement's transactions for a
      # card, using the card_index attribute from an account's XML

      xml = File.read(
        File.expand_path(File.dirname(__FILE__) + '/data/statement_request.xml')
      )

      security_token = @security_token
      ERB.new(xml).result(binding)
    end

    def hardware_id
      # Generates a fake HardwareId - a 40 character alphanumeric lower-case
      # string, which is passed in with the original API request

      chars = 'abcdefghjkmnpqrstuvwxyz1234567890'
      id = ''
      40.times { id << chars[rand(chars.size)] }
      id
    end

  end
end