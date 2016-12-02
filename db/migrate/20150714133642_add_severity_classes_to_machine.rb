class AddSeverityClassesToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :severity_class, :text
  end
end
