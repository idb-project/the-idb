class AddAnnouncementContactToOwners < ActiveRecord::Migration[5.0]
  def change
    add_column :owners, :announcement_contact, :string
  end
end
