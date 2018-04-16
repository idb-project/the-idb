class ChangeDateToBeginDateInMaintenanceAnnouncements < ActiveRecord::Migration[5.0]
  def change
    rename_column :maintenance_announcements, :date, :begin_date
    change_column :maintenance_announcements, :begin_date, :datetime
  end
end
