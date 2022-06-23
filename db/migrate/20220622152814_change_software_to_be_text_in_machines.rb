class ChangeSoftwareToBeTextInMachines < ActiveRecord::Migration[5.2]
  def change
    change_column :machines, :software, :text
  end
end
