class AddUptimeAttribute < ActiveRecord::Migration[4.2]
  def change
    add_column :machines, :uptime, :integer
  end
end
