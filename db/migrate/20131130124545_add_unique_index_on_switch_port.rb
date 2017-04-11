class AddUniqueIndexOnSwitchPort < ActiveRecord::Migration[4.0]
  def change
    add_index :switch_ports, [:number, :switch_id], unique: true
  end
end
