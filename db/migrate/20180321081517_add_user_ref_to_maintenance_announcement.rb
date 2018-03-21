class AddUserRefToMaintenanceAnnouncement < ActiveRecord::Migration[5.0]
  def change
    add_reference :maintenance_announcements, :user, foreign_key: true
  end
end
