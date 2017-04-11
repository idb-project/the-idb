class AddOwnerToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_column :attachments, :owner_id, :integer
  end
end
