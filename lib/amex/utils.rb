class String

  # Converts a String object into a simple as used on an Amex::CardAccount
  # object - the XML uses camelCase attributes, we want underscored ones
  # which we can convert to symbol (e.g. cardProduct to card_product)
  #
  # @return [String] the reformatted string
  #
  def underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
end