class AddAutoUpdateToMachines < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :auto_update, :boolean, default: false
  end
end
