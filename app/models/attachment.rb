class Attachment < ActiveRecord::Base
  belongs_to :inventory
  belongs_to :owner
  belongs_to :machine

  has_attached_file :attachment,
    :path => ":rails_root/public/attachments/:id/:filename",
    :url  => "/attachments/:id/:filename"

  do_not_validate_attachment_file_type :attachment
end
