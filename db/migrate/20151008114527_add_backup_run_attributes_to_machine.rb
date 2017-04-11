class AddBackupRunAttributesToMachine < ActiveRecord::Migration[4.2]
  def change
    remove_column :machines, :backup_last_run
    add_column :machines, :backup_last_full_run, :string
    add_column :machines, :backup_last_inc_run, :string
    add_column :machines, :backup_last_diff_run, :string
  end
end
