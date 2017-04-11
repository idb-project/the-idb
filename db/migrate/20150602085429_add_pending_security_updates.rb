class AddPendingSecurityUpdates < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :pending_updates, :integer
    add_column :machines, :pending_security_updates, :integer
    add_column :machines, :pending_updates_sum, :integer
  end
end
