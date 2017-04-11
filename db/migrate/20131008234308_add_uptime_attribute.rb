class AddUptimeAttribute < ActiveRecord::Migration[4.0]
  def change
    add_column :machines, :uptime, :integer
  end
end
