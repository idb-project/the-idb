class InventorySerializer < ActiveModel::Serializer
  attributes :id, :inventory_number, :name, :serial, :part_number, :purchase_date, :warranty_end, :seller, :created_at, :updated_at, :user_id, :machine_id, :deleted_at, :comment, :place, :category, :location_id, :install_date, :inventory_status_id
end
