class AddAttachmentToAttachments < ActiveRecord::Migration
  def change
    add_attachment :attachments, :attachment
  end
end
