module Amex
  class CardAccount
    attr_accessor :card_product, :card_number_suffix, :card_index,
      :lending_type, :card_member_name, :past_due, :cancelled, :is_basic,
      :is_centurion, :is_platinum, :is_premium, :market, :card_art,
      :loyalty_indicator, :stmt_balance, :payment_credits, :recent_charges,
      :total_balance, :payment_due, :payment_due_date, :loyalty_programmes,
      :client

    def initialize(options)
      options.each do |key, value|
        method = key.to_s.underscore + "="
        send(key.to_s.underscore + "=", value) if respond_to? method.to_sym
      end
      @loyalty_programmes = []
    end

    def transactions(billing_period=0)
      # Fetch the transactions for this account based upon the passed in
      # options - this can fetch either a single billing period or a range
      # of billing periods, e.g:
      #
      # => account.transaction(0) fetches transactions since the last statement
      # (default)
      # => account.transaction(0..5) fetches transactions between now and
      # five statements ago
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
          "PayLoadText" => @client.statement_request_xml(@card_index, n)
        }}
        response = @client.class.post(
          '/myca/intl/moblclient/emea/ws.do?Face=en_GB', options
        )
        xml = Nokogiri::XML(response.body)
        xml = xml.css("XMLResponse")

        xml.css('Transaction').each do |transaction|
          result << Amex::Transaction.new(transaction)
        end
      end

      result
    end

    def statement_balance
      @stmt_balance
    end

    def product
      @card_product
    end

    def cancelled?
      @cancelled
    end

    def payment_due_date
      # Overrides attr_accessor so it actually returns a DateTime, not String
      DateTime.parse(@payment_due_date)
    end

    def type
      return :basic if @is_basic
      return :platinum if @is_platinum
      return :centurion if @is_centurion
      return :premium if @is_premium
      :unknown
    end

    def is_credit_card?
      return true if @lending_type == "Credit"
      false
    end

    def is_charge_card?
      return true if @lending_type == "Charge"
      false
    end

    def overdue?
      return true if @past_due
      false
    end

    def due?
      return true if @payment_due.to_f > 0
      false
    end

    def loyalty_enabled?
      @loyalty_indicator
    end

    def loyalty_balances
      result = {}
      @loyalty_programmes.each do |programme|
        result[programme.name] = programme.balance
      end
      result
    end



  end
end