class AddPreferencesToNetworks < ActiveRecord::Migration
  def change
    add_column :networks, :preferences, :text, limit: 4294967295
  end
end
