class Nic < ActiveRecord::Base
  MAC_REGEX = /[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}:[0-9a-fA-F]{2}/

  belongs_to :machine
  has_one :ip_address, dependent: :destroy, autosave: true
  has_one :switch_port, dependent: :destroy, autosave: true

  before_save do |record|
    # Make sure mac is nil if the input is an empty string.
    record.mac = nil if record.mac.blank?

    # Make sure we have a downcased mac address.
    record.mac.downcase! if record.mac
  end

  def ipv4addr
    ip_address.addr if ip_address
  end

  def ipv4mask
    ip_address.netmask if ip_address
  end

  def ipv6addr
    ip_address.addr_v6 if ip_address
  end

  def ipv6mask
    ip_address.netmask_v6 if ip_address
  end
  
  class Entity < Grape::Entity
    expose :name, documentation: { type: "String", desc: "Name" }
    expose :mac, documentation: { type: "String", desc: "MAC address" }
    expose :machine, documentation: { type: "String", desc: "Machine FQDN this nic belongs to" }    
    expose :ip_address, documentation: { type: "Object", desc: "IP address of the nic" }, using: IpAddress::Entity
    
    def machine
      m = Machine.find_by_id(object.machine_id)
      unless m
	return nil
      end
      m.fqdn
    end 
  end
end