require 'nokogiri'

module Amex
  class Transaction
    attr_reader :date, :narrative, :amount, :extra_details

    def initialize(transaction)
      # Pass this a <Transaction> element, and it'll parse it
      @date = Date.strptime(transaction.css('TransChargeDate').text, '%m/%d/%Y')
      @narrative = transaction.css('TransDesc').text
      @amount = transaction.css('TransAmount').text.to_f

      @extra_details = {}
      transaction.css('TransExtDetail ExtDetailElement').each do |element|
        @extra_details[element.attr('name')] = element.attr('formattedValue')
      end
    end

    def is_foreign_transaction?
      return true if @extra_details.has_key?('currencyRate')
      false
    end

  end
end