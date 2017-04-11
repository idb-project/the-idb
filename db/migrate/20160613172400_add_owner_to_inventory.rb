class AddOwnerToInventory < ActiveRecord::Migration[4.2]
  def change
    add_column :inventories, :owner_id, :integer
  end
end
