class AddUptimeAttribute < ActiveRecord::Migration
  def change
    add_column :machines, :uptime, :integer
  end
end
