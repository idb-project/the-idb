class AddOwnerIdToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :owner_id, :integer
  end
end
