class AddAttachmentToAttachments < ActiveRecord::Migration[4.2]
  def change
    add_attachment :attachments, :attachment
  end
end
