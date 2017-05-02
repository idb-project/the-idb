class AddCategoryToInventory < ActiveRecord::Migration[4.2]
  def change
    add_column :inventories, :category, :string
  end
end
