class AddUsersToOwners < ActiveRecord::Migration[5.0]
  def change
    create_table :owners_users, id: false do |t|
      t.belongs_to :owner, index: true
      t.belongs_to :user, index: true
    end
  end
end
