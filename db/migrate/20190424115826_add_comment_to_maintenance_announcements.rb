class AddCommentToMaintenanceAnnouncements < ActiveRecord::Migration[5.0]
  def change
    add_column :maintenance_announcements, :comment, :text
  end
end
