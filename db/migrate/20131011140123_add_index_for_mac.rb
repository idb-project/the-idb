class AddIndexForMac < ActiveRecord::Migration[4.2]
  def change
    add_index :nics, :mac
  end
end
