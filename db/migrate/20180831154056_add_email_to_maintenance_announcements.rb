class AddEmailToMaintenanceAnnouncements < ActiveRecord::Migration[5.0]
  def change
    add_column :maintenance_announcements, :email, :string
  end
end
