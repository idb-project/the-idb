class IpAddress < ActiveRecord::Base
  belongs_to :nic

  def machine
    nic.machine
  end
  
  class Entity < Grape::Entity
    expose :addr, documentation: { type: "String", desc: "IPv4 address" }
    expose :netmask, documentation: { type: "String", desc: "IPv4 netmask" }
    expose :family, documentation: { type: "String", desc: "" }
    expose :addr_v6, documentation: { type: "String", desc: "IPv6 address" }
    expose :netmask_v6, documentation: { type: "String", desc: "IPv6 prefix" }
  end
end
