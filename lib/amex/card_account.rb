module Amex
  class CardAccount
    attr_accessor :card_product, :card_number_suffix, :card_index,
      :lending_type, :card_member_name, :past_due, :cancelled, :is_basic,
      :is_centurion, :is_platinum, :is_premium, :market, :card_art,
      :loyalty_indicator, :stmt_balance, :payment_credits, :recent_charges,
      :total_balance, :payment_due, :payment_due_date, :loyalty_programmes,
      :client, :out_standing_balance

    # Generates a CardAccount object from XML properties grabbed by the client
    #
    # @param [Hash] options A Hash containing XML properties pulled directly
    #  from the API XML
    # @return [Amex::CardAccount] an object representing an American Express
    #  card
    #
    def initialize(options)
      options.each do |key, value|
        method = key.to_s.underscore + "="
        send(key.to_s.underscore + "=", value) if respond_to? method.to_sym
      end
      @loyalty_programmes = []
    end

    # Fetches transactions on an American Express card
    #
    # @param [Fixnum, Range] billing_period The billing period(s) to fetch
    #  transactions for, as either a single billing period (e.g. 0 or 1) or
    #  a range of periods to fetch (e.g. 0..3)
    # @param [enum] transaction_type either :pending or :recent
    # @return [Array<Amex::Transaction>] an array of `Amex::Transaction` objects
    # @note This can fetch either a single billing period or a range
    #  of billing periods, e.g:
    #  => account.transaction(0)
    #  fetches transactions since the last statement (default)
    #  => account.transaction(0..5)
    #  fetches transactions between now and five statements ago
    #
    def transactions(billing_period=0, transaction_type=:pending)
      result = []

      # Build an array of billing periods we need to fetch - this is almost
      # certainly woefully inefficient code.
      billing_periods = []
      if billing_period.class == Fixnum
        billing_periods << billing_period
      elsif billing_period.class == Range
        billing_period.each { |n| billing_periods << n }
      else
        raise "The passed in billing period option must be a number or a range"
      end

      billing_periods.each do |n|
        options = { :body => {
          "PayLoadText" => @client.transactions_request_xml(@card_index, n, transaction_type)
        }}

        response = @client.class.post(
          '/myca/moblclient/us/ws.do?Face=en_US', options
          #'/myca/intl/moblclient/emea/ws.do?Face=en_GB', options
        )
        xml = Nokogiri::XML(response.body)
        xml = xml.css("XMLResponse")

        xml.css('Transaction').each do |transaction|
          result << Amex::Transaction.new(transaction)
        end
      end

      result
    end

    # Returns the balance of the most recent statement
    #
    # @return [Float] the balance of the most recent statement
    #
    def statement_balance
      @stmt_balance
    end

    # Returns the name of the card product that your card conforms to (e.g.
    # "American Express Preferred Rewards Gold")
    #
    # @return [String] the name of the card product that your card conforms to
    #
    def product
      @card_product
    end

    # Returns whether the card account is cancelled
    #
    # @return [Boolean] the cancellation status of this card, either true or
    #  false
    def cancelled?
      @cancelled
    end

    # Returns the date that the next payment on the card is due
    #
    # @return [DateTime] the date when the next payment against this account
    #  is due
    def payment_due_date
      # Overrides attr_accessor so it actually returns a DateTime, not String
      if (@payment_due_date.empty? || @payment_due_date == '')
        ''
      else
        DateTime.strptime(@payment_due_date  , '%m/%d/%y')
      end
    end

    # Returns the type of account this card conforms to (generally not useful,
    #  probably largely used internally by American Express
    #
    # @return [:basic, :platinum, :centurion, :premium, :unknown] a symbol
    #  representing the 'type' of your card
    #
    def type
      return :basic if @is_basic
      return :platinum if @is_platinum
      return :centurion if @is_centurion
      return :premium if @is_premium
      :unknown
    end

    # Returns whether this account is a credit card
    #
    # @return [Boolean] true if the account is a credit card, false otherwise
    #
    def is_credit_card?
      return true if @lending_type == "Credit"
      false
    end

    # Returns whether this account is a charge card
    #
    # @return [Boolean] true if the account is a charge card, false otherwise
    #
    def is_charge_card?
      return true if @lending_type == "Charge"
      false
    end

    # Returns whether payment on this account is overdue
    #
    # @return [Boolean] true if the account is overdue, false otherwise
    #
    def overdue?
      return true if @past_due
      false
    end

    # Returns whether this account has a due payment (i.e. whether you need
    # to pay American Express anything) (see #overdue?)
    #
    # @return [Boolean] true if the account has a due payment, false otherwise
    #
    def due?
      return true if @payment_due.to_f > 0
      false
    end

    # Returns whether this account has any kind of loyalty scheme attached
    #
    # @return [Boolean] true if the account has a loyalty scheme, false
    #  otherwise
    #
    def loyalty_enabled?
      @loyalty_indicator
    end


    # Returns a hash of loyalty scheme balances for this account
    #
    # @return [Hash{String => String}] the loyalty balances for this account,
    #  with the key being the name of the loyalty scheme, and the value its
    #  balance
    #
    def loyalty_balances
      result = {}
      @loyalty_programmes.each do |programme|
        result[programme.name] = programme.balance
      end
      result
    end



  end
end