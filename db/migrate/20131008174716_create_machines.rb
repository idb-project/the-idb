class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :fqdn
      t.string :os
      t.string :arch
      t.integer :ram
      t.integer :cores
      t.string :vmhost
      t.datetime :serviced_at
      t.text :description, limit: 4294967295
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :machines, :fqdn, unique: true
  end
end
