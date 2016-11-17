class AddOwnerToAttachments < ActiveRecord::Migration
  def change
    add_column :attachments, :owner_id, :integer
  end
end
