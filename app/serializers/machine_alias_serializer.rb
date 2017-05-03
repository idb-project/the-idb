class MachineAliasSerializer < ActiveModel::Serializer
  attributes :name,:machine

  def machine
    m = Machine.find_by_id object.machine_id
    unless m
      return nil
    end
    m.fqdn
  end
end
