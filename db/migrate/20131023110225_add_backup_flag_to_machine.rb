class AddBackupFlagToMachine < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :backup_config, :boolean, default: false
  end
end
