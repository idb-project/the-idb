class AddOwnerDataField < ActiveRecord::Migration[4.2]
  def change
    add_column :owners, :data, :text, limit: 4294967295
  end
end
