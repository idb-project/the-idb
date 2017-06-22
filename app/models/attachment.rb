class Attachment < ActiveRecord::Base
  belongs_to :inventory
  belongs_to :owner
  belongs_to :machine

  # the digest configuration is not available in current stable 5.1.0
  # that is why the after_save callback is needed
  has_attached_file :attachment,
    :path => ":rails_root/public/attachments/:id/:filename",
    :url  => "/attachments/:id/:filename",
    :adapter_options => { hash_digest: Digest::SHA256 }

  do_not_validate_attachment_file_type :attachment

  after_save :check_sha256_fingerprint

  def self.default_scope
    if User.current.nil? || User.current.is_admin?
      nil
    else
      -> { where(owner: User.current.owners) }
    end
  end

  private

  def check_sha256_fingerprint
    sha256_fingerprint = Digest::SHA256.file(attachment.path).to_s
    if attachment_fingerprint != sha256_fingerprint
      update_attribute("attachment_fingerprint", sha256_fingerprint)
    end
  end
end
