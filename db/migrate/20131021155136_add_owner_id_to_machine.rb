class AddOwnerIdToMachine < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :owner_id, :integer
  end
end
