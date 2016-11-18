# encoding: utf-8

require 'csv'

module InventoryImport
  class CSVParser < Struct.new(:input)
    FIELD_MAP = {
      inventory_number: 'Inventory Number',
      name: 'Device',
      serial: 'Serial-No',
      part_number: 'Part No',
      purchase_date: 'Purchase-Date',
      warranty_end: 'Warranty-Date',
      user: 'Handed out to',
      machine: 'Hostname',
      seller: 'Purchased-From',
      comment: ' Comment'
    }

    def process
      CSV.read(input, csv_options).map do |line|
        FIELD_MAP.each_with_object(InventoryImport::InventoryItem.new) do |(key, val), inventory|
          inventory.send("#{key}=", line[val])
        end
      end
    end

    private

    def csv_options
      {
        headers: :first_row,
        col_sep: ';',
        quote_char: '"',
        encoding: 'UTF-8'
      }
    end
  end
end
