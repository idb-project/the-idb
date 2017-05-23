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

  private

  def check_sha256_fingerprint
    sha256_fingerprint = Digest::SHA256.file(attachment.path).to_s
    if attachment_fingerprint != sha256_fingerprint
      update_attribute("attachment_fingerprint", sha256_fingerprint)
    end
  end
  
  class Entity < Grape::Entity
    expose :description, documentation: { type: "String", desc: "Attachment description" }
    expose :attachment, documentation: { type: "String", desc: "Path to attachment, from IDB base URL" }
    expose :inventory, documentation: { type: "String", desc: "Inventory number this attachment belongs to" }
    expose :created_at, documentation: { type: "String", desc: "Creation date RFC3999 formatted" }
    expose :updated_at, documentation: { type: "String", desc: "Update date RFC3999 formatted" }
    expose :attachment_file_name, documentation: { type: "String", desc: "Attachment file name" }
    expose :attachment_content_type, documentation: { type: "String", desc: "Attachment mime type" }
    expose :attachment_file_size, documentation: { type: "Integer", desc: "File size in bytes" }
    expose :attachment_updated_at, documentation: { type: "String", desc: "Update date RFC3999 formatted" }
    expose :machine, documentation: { type: "String", desc: "FQDN of the machine this attachment belongs to" }
    expose :attachment_fingerprint, documentation: { type: "String", desc: "SHA256 fingerprint of the attachment" }

    def machine
      m = Machine.find_by_id(object.machine_id)
      unless m
	return nil
      end
      m.fqdn
    end

    def inventory
      m = Inventory.find_by_id(object.inventory_id)
      unless m
	return nil
      end
      m.inventory_number
    end
  end
end
