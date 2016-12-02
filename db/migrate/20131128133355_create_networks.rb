class CreateNetworks < ActiveRecord::Migration
  def change
    create_table :networks do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.text :description, limit: 4294967295
      t.references :owner, index: true

      t.timestamps
    end

    add_index :networks, :name, unique: true
    add_index :networks, :address, unique: true
  end
end
