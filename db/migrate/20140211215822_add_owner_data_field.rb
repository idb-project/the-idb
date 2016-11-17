class AddOwnerDataField < ActiveRecord::Migration
  def change
    add_column :owners, :data, :text, limit: 4294967295
  end
end
