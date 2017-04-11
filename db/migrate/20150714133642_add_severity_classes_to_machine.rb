class AddSeverityClassesToMachine < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :severity_class, :text
  end
end
