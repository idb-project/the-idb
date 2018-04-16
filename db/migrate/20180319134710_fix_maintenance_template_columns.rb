class FixMaintenanceTemplateColumns < ActiveRecord::Migration[5.0]
  def change
    rename_column :maintenance_templates, :template, :body
    add_column :maintenance_templates, :subject, :string
  end
end
