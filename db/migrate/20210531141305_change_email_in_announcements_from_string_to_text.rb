class ChangeEmailInAnnouncementsFromStringToText < ActiveRecord::Migration[5.2]
  def change
    change_column :maintenance_announcements, :email, :text
  end
end
