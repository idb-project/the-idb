class AddOwnerToLocation < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :owner_id, :integer
    add_column :location_levels, :owner_id, :integer
  end
end
