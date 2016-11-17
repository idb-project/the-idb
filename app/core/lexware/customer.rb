require 'virtus'

module Lexware
  class Customer
    include Virtus.model

    attribute :customer_id, Integer
    attribute :firstname, String
    attribute :lastname, String
    attribute :company, String
    attribute :contact_person, String
    attribute :street, String
    attribute :zipcode, String
    attribute :city, String
    attribute :country, String
    attribute :phone, String
    attribute :email, String
  end
end
