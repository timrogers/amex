module Amex
  class LoyaltyProgramme
    attr_accessor :name, :balance

    def initialize(name, balance)
      @name = name
      @balance = balance
    end
  end
end