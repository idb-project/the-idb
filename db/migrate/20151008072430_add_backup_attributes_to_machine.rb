class AddBackupAttributesToMachine < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :backup_brand, :integer, default: 0
    add_column :machines, :backup_last_run, :string
  end
end
