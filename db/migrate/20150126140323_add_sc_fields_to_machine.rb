class AddScFieldsToMachine < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :config_instructions, :text
    add_column :machines, :sw_characteristics, :text
    add_column :machines, :business_purpose, :text
  end
end
