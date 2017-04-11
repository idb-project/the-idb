class AddDeletedAtToModels < ActiveRecord::Migration[4.0]
  def change
    add_column :owners, :deleted_at, :datetime
    add_column :ip_addresses, :deleted_at, :datetime
    add_column :nics, :deleted_at, :datetime
    add_column :maintenance_records, :deleted_at, :datetime
    add_column :users, :deleted_at, :datetime
  end
end
