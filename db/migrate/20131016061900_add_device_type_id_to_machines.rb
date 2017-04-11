class AddDeviceTypeIdToMachines < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :device_type_id, :integer
  end
end
