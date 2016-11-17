class AddLocationToInventory < ActiveRecord::Migration
  def change
    add_column :inventories, :location, :string
  end
end
