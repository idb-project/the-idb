class RemoveUniqueIndexOnOwnerCustomerId < ActiveRecord::Migration[4.0]
  def change
    remove_index :owners, :customer_id
    add_index :owners, :customer_id
  end
end
