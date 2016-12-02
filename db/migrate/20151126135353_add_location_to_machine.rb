class AddLocationToMachine < ActiveRecord::Migration
  def change
    add_column :machines, :power_feed_a, :integer
    add_column :machines, :power_feed_b, :integer
  end
end
