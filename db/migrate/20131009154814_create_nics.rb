class CreateNics < ActiveRecord::Migration[4.0]
  def change
    create_table :nics do |t|
      t.string :name
      t.string :mac
      t.references :machine, index: true

      t.timestamps
    end
    add_index :nics, :mac, unique: true
    add_index :nics, [:name, :machine_id], unique: true
  end
end
