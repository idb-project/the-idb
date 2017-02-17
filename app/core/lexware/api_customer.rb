require 'virtus'

module Lexware
  class APICustomer
    include Virtus.model

    attribute :salutation, Integer
    attribute :matchcode, String
    attribute :firstname, String
    attribute :lastname, String
    attribute :companyName, String
    attribute :email, String
    attribute :customerNumber, String
    attribute :vatID, String
    attribute :addressStreet, String
    attribute :addressNumber, String
    attribute :addressCity, String
    attribute :addressPostalcode, String
    attribute :addressCountry, String
  end
end
