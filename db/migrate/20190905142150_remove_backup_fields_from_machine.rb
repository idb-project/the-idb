class RemoveBackupFieldsFromMachine < ActiveRecord::Migration[5.0]
  def change
    remove_column :machines, :backup_brand, :integer
    remove_column :machines, :backup_last_full_run, :string
    remove_column :machines, :backup_last_inc_run, :string
    remove_column :machines, :backup_last_diff_run, :string
    remove_column :machines, :backup_last_full_size, :bigint
    remove_column :machines, :backup_last_inc_size, :bigint
    remove_column :machines, :backup_last_diff_size, :bigint
  end
end
