module Amex
  class LoyaltyProgramme
    attr_accessor :name, :balance

    # Generates an Amex::LoyaltyProgramme object from a programme name and
    # balance, grabbed from the XML
    #
    # @param [String] name The name of the reward programme
    # @param [Fixnum] balance The balance of the reward programme
    # @return [Amex::LoyaltyProgramme] an object representing a loyalty
    #  programme
    #
    def initialize(name, balance)
      @name = name
      @balance = balance
    end
  end
end