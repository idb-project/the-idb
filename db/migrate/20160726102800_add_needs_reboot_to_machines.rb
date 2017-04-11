class AddNeedsRebootToMachines < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :needs_reboot, :integer
  end
end
