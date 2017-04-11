class CreateSwitchPorts < ActiveRecord::Migration[4.2]
  def change
    create_table :switch_ports do |t|
      t.integer :number, index: true, null: false
      t.string  :identifier
      t.integer :nic_id, index: true, null: false
      t.integer :switch_id, index: true, null: false

      t.timestamps
    end
  end
end
