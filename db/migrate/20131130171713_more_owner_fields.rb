class MoreOwnerFields < ActiveRecord::Migration
  def change
    add_column :owners, :nickname, :string
    add_column :owners, :customer_id, :string

    add_index :owners, :nickname, unique: true
    add_index :owners, :customer_id, unique: true
  end
end
