class RemoveIndexFromNameAndMachineId < ActiveRecord::Migration[5.2]
  def change
    remove_index :nics, name: "index_nics_on_name_and_machine_id"
  end
end
