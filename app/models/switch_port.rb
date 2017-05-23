class SwitchPort < ActiveRecord::Base
  ICINGA_REGEX = /^port(\d+)-(\S+)-(#{Nic::MAC_REGEX})$/i

  belongs_to :nic
  belongs_to :switch

  validates :number, :nic_id, :switch_id, presence: true
  
  class Entity < Grape::Entity
    expose :number, documentation: { type: "Integer", desc: "Port number" }
    expose :nic, documentation: { type: "Integer", desc: "Nic id" }
    expose :switch, documentation: { type: "String", desc: "Switch FQDN the port belongs to" }
    
    def nic
      n = Nic.find_by_id object.nic_id
      unless n
	return nil
      end
      n.id
    end

    def switch
      s = Switch.find_by_id object.switch_id
      unless s
	return nil
      end
      s.fqdn
    end
  end
end
