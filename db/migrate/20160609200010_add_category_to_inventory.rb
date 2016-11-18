class AddCategoryToInventory < ActiveRecord::Migration
  def change
    add_column :inventories, :category, :string
  end
end
