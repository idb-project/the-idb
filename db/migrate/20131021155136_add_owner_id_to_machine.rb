class AddOwnerIdToMachine < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :owner_id, :integer
  end
end
