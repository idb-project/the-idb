class CreateMaintenanceTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :maintenance_templates do |t|
      t.text :template
      t.string :name

      t.timestamps
    end
  end
end
