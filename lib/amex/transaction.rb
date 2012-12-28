require 'nokogiri'

module Amex
  class Transaction
    attr_reader :date, :narrative, :amount, :extra_details

    # Generates an Amex::LoyaltyProgramme object from a Nokogiri object
    # representing <Transaction> element
    #
    # @param [Nokogiri::XML::Element] transaction A <Transaction> node taken
    #  the API XML request, parsed by Nokogiri
    # @return [Amex::Transaction] an object representing an individual
    #  transaction
    #
    def initialize(transaction)
      # Pass this a <Transaction> element, and it'll parse it
      @date = Date.strptime(transaction.css('TransChargeDate').text, '%m/%d/%y')
      @narrative = transaction.css('TransDesc').text
      @amount = transaction.css('TransAmount').text.to_f

      @extra_details = {}
      transaction.css('TransExtDetail ExtDetailElement').each do |element|
        @extra_details[element.attr('name')] = element.attr('formattedValue')
      end
    end

    # Returns whether the transaction was made abroad/in a foreign currency
    #
    # @return [Boolean] true if the transaction was made abroad/in a foreign
    #  currency, false otherwise
    #
    def is_foreign_transaction?
      return true if @extra_details.has_key?('currencyRate')
      false
    end

  end
end