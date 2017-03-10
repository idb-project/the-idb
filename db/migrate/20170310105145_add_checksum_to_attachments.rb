class AddChecksumToAttachments < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :attachment_fingerprint, :string

    Attachment.all.each do |a|
      sha256_fingerprint = Digest::SHA256.file(a.attachment.path).to_s
      a.update_attribute("attachment_fingerprint", sha256_fingerprint)
    end
  end
end
