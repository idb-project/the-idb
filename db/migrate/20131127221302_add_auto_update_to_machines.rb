class AddAutoUpdateToMachines < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :auto_update, :boolean, default: false
  end
end
