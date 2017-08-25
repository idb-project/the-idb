class Inventory < ActiveRecord::Base
  acts_as_paranoid

  has_paper_trail

  belongs_to :user
  belongs_to :machine
  belongs_to :owner
  belongs_to :location
  belongs_to :inventory_status
  has_many :attachments, :dependent => :destroy

  validates :purchase_date, format: { with: /\d{4}\-\d{2}\-\d{2}/,
    message: "has to be of format YYYY-MM-DD" }, :allow_blank => true
  validates :warranty_end, format: { with: /\d{4}\-\d{2}\-\d{2}/,
    message: "has to be of format YYYY-MM-DD" }, :allow_blank => true
  validates :install_date, format: { with: /\d{4}\-\d{2}\-\d{2}/,
    message: "has to be of format YYYY-MM-DD" }, :allow_blank => true

  def self.owned_by(o)
    where(owner: o)
  end

  def status_string
    inventory_status.nil? ? "" : inventory_status.name
  end

  def ordered_versions
    PaperTrail::Version.with_item_keys(self.class.name, id).order(created_at: :desc)
  end

  def active?
    inventory_status.nil? ? false : !inventory_status.inactive
  end

  def self.default_scope
    if User.current.nil? || User.current.is_admin?
      nil
    else
      -> { where(owner: User.current.owners) }
    end
  end
  
  class Entity < Grape::Entity
    expose :id, documentation: { type: "Integer", desc: "Id" }
    expose :inventory_number, documentation: { type: "String", desc: "Inventory Number" }
    expose :name, documentation: { type: "String", desc: "Name" }
    expose :serial, documentation: { type: "String", desc: "Factory serial number" }
    expose :part_number, documentation: { type: "String", desc: "Factory part number" }
    expose :purchase_date, documentation: { type: "String", desc: "Purchase date as YYYY-MM-DD" }
    expose :warranty_end, documentation: { type: "String", desc: "Warranty end date as YYYY-MM-DD" }
    expose :seller, documentation: { type: "String", desc: "Seller" }
    expose :created_at, documentation: { type: "String", desc: "Creation date RFC3999 formatted" }
    expose :updated_at, documentation: { type: "String", desc: "Update date RFC3999 formatted" }
    expose :user_id
    expose :machine, documentation: { type: "String", desc: "machines FQDN if this inventoy is a machine" }
    expose :deleted_at, documentation: { type: "String", desc: "Deletion date RFC3999 formatted" }
    expose :comment, documentation: { type: "String", desc: "Comment field" }
    expose :place, documentation: { type: "String", desc: "Additional place description" }
    expose :category, documentation: { type: "String", desc: "Additional category description" }
    expose :location_id, documentation: { type: "Integer", desc: "ID of the location" }
    expose :install_date, documentation: { type: "String", desc: "Installation date as YYYY-MM-DD" }
    expose :inventory_status_id, documentation: { type: "Integer", desc: "Inventory status id" } # FIXME
    expose :inventory_status, documentation: { type: "String", desc: "Inventory status" }

    def inventory_status
      object.status_string
    end

    def machine
      m = Machine.find_by_id(object.machine_id)
      unless m
	      return nil
      end
      m.fqdn
    end
  end
end
