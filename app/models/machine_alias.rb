class MachineAlias < ActiveRecord::Base
  belongs_to :machine
  
  class Entity < Grape::Entity
    expose :name, documentation: { type: "String", desc: "Name" }
    expose :machine, documentation: { type: "String", desc: "Aliased machine FQDN" }

    def machine
      m = Machine.find_by_id object.machine_id
      unless m
	return nil
      end
      m.fqdn
    end
  end
end
