class AddAutoUpdateToMachines < ActiveRecord::Migration
  def change
    add_column :machines, :auto_update, :boolean, default: false
  end
end
