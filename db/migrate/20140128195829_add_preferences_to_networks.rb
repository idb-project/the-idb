class AddPreferencesToNetworks < ActiveRecord::Migration[4.2]
  def change
    add_column :networks, :preferences, :text, limit: 4294967295
  end
end
