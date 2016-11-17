require 'virtus'

module InventoryImport
  class InventoryItem
    include Virtus.model

    attribute :inventory_number, String
    attribute :name, String
    attribute :serial, String
    attribute :part_number, String
    attribute :purchase_date, String
    attribute :warranty_end, String
    attribute :seller, String
    attribute :comment, String
    attribute :user, String
    attribute :machine, String
  end
end
