class AddSoftwareToMachines < ActiveRecord::Migration[5.0]
  def change
    add_column :machines, :software, :json
  end
end
