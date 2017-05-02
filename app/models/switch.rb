class Switch < Machine
  def self.model_name
    Machine.model_name
  end

  def device_type
    "Switch"
  end

  def switch_ports
    SwitchPort.where(switch_id: id)
  end
end