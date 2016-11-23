class CreateInventoryStatus < ActiveRecord::Migration[5.0]
  def change
    create_table :inventory_statuses do |t|
      t.string :name
      t.boolean :inactive, default: false
    end

    add_column :inventories, :inventory_status_id, :integer

    Inventory.all.each do |i|
      status_string = ""
      inactive = false
      case i.status
        when 0
          status_string = "active"
        when 1
          status_string = "broken"
          inactive = true
        when 2
          status_string = "sold"
          inactive = true
        else
          status_string = "active"
      end

      i_status = InventoryStatus.find_by_name(status_string)
      i_status = InventoryStatus.create!(name: status_string, inactive: inactive) if i_status.nil?
      i.inventory_status = i_status
      i.save!(validate: false)
    end

    remove_column :inventories, :status, :integer
  end
end
