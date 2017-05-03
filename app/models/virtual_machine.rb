class VirtualMachine < Machine
  def self.model_name
    Machine.model_name
  end

  def device_type
    "Virtual Machine"
  end
end