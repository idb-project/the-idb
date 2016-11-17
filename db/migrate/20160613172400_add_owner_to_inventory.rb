class AddOwnerToInventory < ActiveRecord::Migration
  def change
    add_column :inventories, :owner_id, :integer
  end
end
