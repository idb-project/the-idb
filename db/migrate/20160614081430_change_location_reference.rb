class ChangeLocationReference < ActiveRecord::Migration
  def change
    rename_column :inventories, :location, :place
    add_column :inventories, :location_id, :integer
  end
end
