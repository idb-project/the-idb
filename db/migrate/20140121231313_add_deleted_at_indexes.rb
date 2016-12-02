class AddDeletedAtIndexes < ActiveRecord::Migration
  def change
    add_index :machines, :deleted_at
    add_index :owners, :deleted_at
    add_index :ip_addresses, :deleted_at
    add_index :nics, :deleted_at
    add_index :maintenance_records, :deleted_at
    add_index :users, :deleted_at
  end
end
