class NicSerializer < ActiveModel::Serializer
  attributes :id,:name,:mac,:machine

  def machine
    m = Machine.find_by_id(object.machine_id)
    unless m
      return nil
    end
    m.fqdn
  end
end
