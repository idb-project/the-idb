# encoding: utf-8

require 'csv'

module Lexware
  class CSVParser < Struct.new(:input)
    FIELD_MAP = {
      customer_id: 'Kundennummer',
      firstname: 'Vorname',
      lastname: 'Name',
      company: 'Firma',
      contact_person: 'Ansprechpartner',
      street: 'Straße',
      zipcode: 'Postleitzahl',
      city: 'Ort',
      country: 'Land',
      phone: 'Telefon',
      email: 'EMAIL'
    }

    def process
      CSV.read(input, csv_options).map do |line|
        FIELD_MAP.each_with_object(Lexware::Customer.new) do |(key, val), customer|
          customer.send("#{key}=", line[val])
        end
      end
    end

    private

    def csv_options
      {
        headers: :first_row,
        col_sep: ';',
        quote_char: '"',
        encoding: 'ISO-8859-1'
      }
    end
  end
end
