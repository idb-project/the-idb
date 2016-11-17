class AddIndexForMac < ActiveRecord::Migration
  def change
    add_index :nics, :mac
  end
end
