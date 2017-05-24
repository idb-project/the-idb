class SwitchPort < ActiveRecord::Base
  ICINGA_REGEX = /^port(\d+)-(\S+)-(#{Nic::MAC_REGEX})$/i

  belongs_to :nic
  belongs_to :switch

  validates :number, :nic_id, :switch_id, presence: true
  
  class Entity < Grape::Entity
    expose :number, documentation: { type: "Integer", desc: "Port number" }
    expose :nic, documentation: { type: "String", desc: "Nic name" }
    expose :machine, documentation: { type: "String", desc: "Machine nic belongs to" }
    expose :switch, documentation: { type: "String", desc: "Switch FQDN the port belongs to" }
    
    def nic
      n = Nic.find_by_id object.nic_id
      unless n
        return nil
      end
      n.name
    end

    def machine
      n = Nic.find_by_id object.nic_id
      unless n
        return nil
      end

      m = Machine.find_by_id n.machine_id
      unless m
        return nil
      end
      m.fqdn
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
