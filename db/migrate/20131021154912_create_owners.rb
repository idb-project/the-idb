class CreateOwners < ActiveRecord::Migration[4.0]
  def change
    create_table :owners do |t|
      t.string :name
      t.text :description, limit: 4294967295

      t.timestamps
    end
  end
end
