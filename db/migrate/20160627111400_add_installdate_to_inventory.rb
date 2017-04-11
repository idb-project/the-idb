class AddInstalldateToInventory < ActiveRecord::Migration[4.2]
  def change
    add_column :inventories, :install_date, :string
  end
end
