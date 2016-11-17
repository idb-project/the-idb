class AddInstalldateToInventory < ActiveRecord::Migration
  def change
    add_column :inventories, :install_date, :string
  end
end
