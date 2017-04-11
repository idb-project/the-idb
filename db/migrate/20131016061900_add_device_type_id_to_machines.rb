class AddDeviceTypeIdToMachines < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :device_type_id, :integer
  end
end
