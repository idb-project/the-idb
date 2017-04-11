class AddLocationToInventory < ActiveRecord::Migration[4.0]
  def change
    add_column :inventories, :location, :string
  end
end
