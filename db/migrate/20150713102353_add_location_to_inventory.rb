class AddLocationToInventory < ActiveRecord::Migration[4.2]
  def change
    add_column :inventories, :location, :string
  end
end
