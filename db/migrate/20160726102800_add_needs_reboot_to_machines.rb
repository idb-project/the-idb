class AddNeedsRebootToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :needs_reboot, :integer
  end
end
