class AddPreviewToMaintenanceAnnouncements < ActiveRecord::Migration[5.0]
  def change
    add_column :maintenance_announcements, :preview, :boolean
  end
end
