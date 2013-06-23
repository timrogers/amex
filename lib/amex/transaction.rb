require 'nokogiri'

module Amex
  class Transaction
    attr_reader :date, :narrative, :amount, :extra_details, :description, :reference_number

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
      transChargeDate = transaction.css('TransChargeDate').text
      chargeDate = transaction.css('[name=chargeDate]').text
      if (!transChargeDate.empty?) then
        puts "using transChargeDate: #{transChargeDate}"
        @date = Date.strptime(transChargeDate, '%m/%d/%y')
      else 
        @date = Date.strptime(chargeDate, '%m/%d/%y')
      end

      @narrative = transaction.css('TransDesc').text
      @description = transaction.css('[name=transDesc]').text.strip
      @reference_number = transaction.css('[name=transRefNo]').text

      transAmount = transaction.css('TransAmount').text
      transactionAmt = transaction.css('[name=transcationAmt]').text

      if (!transAmount.empty?) then
        @amount = transAmount.to_f
      else
        @amount = transactionAmt.to_f
      end

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