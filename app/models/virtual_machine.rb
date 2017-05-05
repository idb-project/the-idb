class VirtualMachine < Machine
  def self.model_name
    Machine.model_name
  end

  def self.device_type_name
    "Virtual Machine"
  end
end