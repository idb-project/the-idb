class AddIndexForMac < ActiveRecord::Migration[4.0]
  def change
    add_index :nics, :mac
  end
end
