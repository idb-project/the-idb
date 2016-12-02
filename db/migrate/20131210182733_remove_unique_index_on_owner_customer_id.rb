class RemoveUniqueIndexOnOwnerCustomerId < ActiveRecord::Migration
  def change
    remove_index :owners, :customer_id
    add_index :owners, :customer_id
  end
end
