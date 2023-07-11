class AddUsercountToKcloudreports < ActiveRecord::Migration[5.2]
  def change
    add_column :k_cloud_reports, :usercount, :integer
  end
end
