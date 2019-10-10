class AddDeletedAtToMaintenanceTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :maintenance_templates, :deleted_at, :datetime
    add_index :maintenance_templates, :deleted_at
  end
end
