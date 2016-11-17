class AddBackupSizeToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :backup_last_full_size, :bigint
    add_column :machines, :backup_last_inc_size, :bigint
    add_column :machines, :backup_last_diff_size, :bigint
  end
end
