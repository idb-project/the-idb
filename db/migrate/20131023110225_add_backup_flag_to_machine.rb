class AddBackupFlagToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :backup_config, :boolean, default: false
  end
end
