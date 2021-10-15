class AddCustomFieldsToMaintenanceAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :maintenance_announcements, :custom_body, :text
    add_column :maintenance_announcements, :custom_subject, :text
  end
end
