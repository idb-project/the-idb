class AddRawDataToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :raw_data_api, :text
    add_column :machines, :raw_data_puppetdb, :text
  end
end
