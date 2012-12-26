module Amex
  class CardAccount
    attr_accessor :card_product, :card_number_suffix,
      :lending_type, :card_member_name, :past_due, :cancelled, :is_basic,
      :is_centurion, :is_platinum, :is_premium, :market, :card_art,
      :loyalty_indicator, :stmt_balance, :payment_credits, :recent_charges,
      :total_balance, :payment_due, :payment_due_date, :loyalty_programmes

    def initialize(options)
      options.each do |key, value|
        method = key.underscore + "="
        send(key.underscore + "=", value) if respond_to? method.to_sym
      end
      @loyalty_programmes = []
    end

    def product
      @card_product
    end

    def cancelled?
      @cancelled.to_bool
    end

    def payment_due_date
      # Overrides attr_accessor so it actually returns a DateTime, not String
      DateTime.parse(@payment_due_date)
    end

    def type
      return :basic if @is_basic.to_bool
      return :platinum if @is_platinum.to_bool
      return :centurion if @is_centurion.to_bool
      return :premium if @is_premium.to_bool
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
      return true if @past_due.to_bool
      false
    end

    def due?
      return true if @payment_due.to_f > 0
      false
    end

    def loyalty_enabled?
      @loyalty_indicator.to_bool
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