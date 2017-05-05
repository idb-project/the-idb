class Switch < Machine
  def self.model_name
    Machine.model_name
  end

  def self.device_type_name
    "Switch"
  end

  def switch_ports
    SwitchPort.where(switch_id: id)
  end
end