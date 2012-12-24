module Amex
  class CardAccount
    attr_accessor product, number_suffix, lending_type, cardmember_name
      past_due, cancelled, type, market, image, loyalty,
      payment_history_eligible, payment_eligible, statement_balance
      payments_and_credits, recent_charges, total_balance, payment_due,
      payment_due_date, loyalty_programmes

    def initialize(options)
      options.each do |key, value|
        self.send key.underscore.to_sym, value
      end
      @loyalty_programmes = []
    end
  end
end