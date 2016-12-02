class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.string :inventory_number
      t.string :name
      t.string :serial
      t.string :part_number
      t.string :purchase_date
      t.string :warranty_end
      t.string :seller
      t.integer :status, default: 0

      t.timestamps
    end
    add_column :inventories, :user_id, :integer
    add_column :inventories, :machine_id, :integer
    add_column :inventories, :deleted_at, :datetime
  end
end
