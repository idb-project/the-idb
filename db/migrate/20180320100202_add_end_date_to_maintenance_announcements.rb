class AddEndDateToMaintenanceAnnouncements < ActiveRecord::Migration[5.0]
  def change
    add_column :maintenance_announcements, :end_date, :datetime
  end
end
