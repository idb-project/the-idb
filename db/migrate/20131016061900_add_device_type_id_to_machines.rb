class AddDeviceTypeIdToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :device_type_id, :integer
  end
end
