class ChangeBackupConfigAttributeType < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :backup_type, :integer, default: 0

    Machine.all.each do |m|
      if m.backup_config == true
        m.update_attribute(:backup_type, 1)
      else
        m.update_attribute(:backup_type, 0)
      end
    end

    remove_column :machines, :backup_config
  end
end
