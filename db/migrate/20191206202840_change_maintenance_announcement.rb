class ChangeMaintenanceAnnouncement < ActiveRecord::Migration[5.0]
  def change
    add_column :maintenance_announcements, :ignore_deadlines, :boolean
    add_column :maintenance_announcements, :ignore_vms, :boolean
    remove_column :maintenance_announcements, :reason, :text
    remove_column :maintenance_announcements, :impact, :text
  end
end
