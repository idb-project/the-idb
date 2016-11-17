class AddUniqueIndexOnSwitchPort < ActiveRecord::Migration
  def change
    add_index :switch_ports, [:number, :switch_id], unique: true
  end
end
