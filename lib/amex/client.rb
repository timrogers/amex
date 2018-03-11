require 'erb'
require 'httparty'
require 'nokogiri'
require 'date'
require 'uuid'

module Amex
  class Client
    attr_accessor :locale, :urls

    include HTTParty

    # Generates an Amex::Client object from a username and password
    #
    # @param [String] username Your American Express online services username
    # @param [String] password Your American Express online services password
    # @param [String] locale, either 'en_GB' or 'en_US'
    # @return [Amex::Client] an object representing an American Express online
    #  account
    #
    def initialize(username, password, locale)
      @username = username
      @password = password
      @locale = locale

      all_urls = {
        'en_GB' => {
          :base_uri => 'https://global.americanexpress.com/',
          :accounts => '/myca/intl/moblclient/emea/ws.do?Face='+@locale,
        },
        'en_US' => {
          :base_uri => 'https://online.americanexpress.com/',
          :accounts => '/myca/moblclient/us/v2/ws.do',
        }
      }

      @urls = all_urls[@locale]
      self.class.base_uri @urls[:base_uri]

      @uuid_generator = UUID.new
    end

    # Fetches the cards on an American Express online services account
    #
    # @return [Array<Amex::CardAccount>] an array of `Amex::CardAccount` objects
    #
    def accounts
      options = { :body => { "PayLoadText" => request_xml }}
      response = self.class.post(
        @urls[:accounts], options
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
          account_details = {client: self} # All the attributes from the XML go in here
          # For each of the CardAccount objects, let's first go through
          # the CardData to pull out lots of nice information
          item.css('CardData param').each do |attribute|
            account_details[attribute.attr('name')] = attribute.text
          end

          # Now let's go through the AccountSummaryData to find all the
          # various bits of balance information
          item.css('AccountSummaryData param').each do |attribute|
            account_details[attribute.attr('name')] = attribute.text
          end

          # We have all the attributes ready to go, so let's make an
          # Amex::CardAccount object
          account = Amex::CardAccount.new(account_details)

          # Finally, let's rip out all the loyalty balances...
          item.css('LoyaltyData RewardsData param').each do |element|
            account.loyalty_programmes << Amex::LoyaltyProgramme.new(
              element.attr('label'), element.attr('formattedValue').gsub(",", "").to_i
            )
          end
          accounts << account

        end
        accounts

      end

    end

    # Generates the XML to send in a request to fetch transactions for a card
    #
    # @param [Integer] card_index The index of the card you're looking up
    #  in your account (see Amex::CardAccount#card_index)
    # @param [Integer] billing_period The billing period to look at, with "0"
    #  being transactions since your last statement, "1" being your last
    #  statement, "2" the statement before that and so on....
    # @param [enum] transaction_type either :pending or :recent (pending or recent transactions)
    #
    #
    # @return [String] XML to be sent in the request
    #
    def transactions_request_xml(card_index, billing_period=0, transaction_type=:recent)
      xml_filename = (transaction_type == :pending) ? '/data/pending_transactions_request.xml' : '/data/statement_request.xml'
      xml = File.read(
        File.expand_path(File.dirname(__FILE__) + xml_filename)
      )
      locale = @locale
      security_token = @security_token
      ERB.new(xml).result(binding)
    end



    private

    # Generates the XML to send in a request to fetch cards for an account
    #
    # @return [String] XML to be sent in the request
    #
    def request_xml
      xml = File.read(
        File.expand_path(File.dirname(__FILE__) + '/data/request.xml')
      )

      username = @username
      password = @password
      timestamp = Time.now.to_i
      locale = @locale

      ERB.new(xml).result(binding)
    end

    # Generates a HardwareId to be sent in requests, in an attempt to
    # hide what requests to the API are coming from this gem
    #
    # @return [String] a uuid
    #
    def hardware_id
      @uuid_generator.generate
    end


    def advertisement_id
      @uuid_generator.generate
    end

  end
end