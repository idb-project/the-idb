class ChangeDataTypeForMachinesRawPuppetdbData < ActiveRecord::Migration
  def change
    change_column :machines, :raw_data_puppetdb, :longtext
    change_column :machines, :raw_data_api, :longtext
  end
end
