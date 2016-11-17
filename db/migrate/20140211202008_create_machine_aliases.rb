class CreateMachineAliases < ActiveRecord::Migration
  def change
    create_table :machine_aliases do |t|
      t.string :name
      t.references :machine, index: true, null: false

      t.timestamps
    end

    add_index :machine_aliases, :name, unique: true
  end
end
