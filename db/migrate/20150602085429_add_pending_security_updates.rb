class AddPendingSecurityUpdates < ActiveRecord::Migration
  def change
    add_column :machines, :pending_updates, :integer
    add_column :machines, :pending_security_updates, :integer
    add_column :machines, :pending_updates_sum, :integer
  end
end
