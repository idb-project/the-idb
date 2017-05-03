class SwitchPortSerializer < ActiveModel::Serializer
  attributes :number,:nic,:switch

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
