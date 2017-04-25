class AddRawDataToMachines < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :raw_data_api, :text
    add_column :machines, :raw_data_puppetdb, :text
  end
end
