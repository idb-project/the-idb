class VirtualMachine < Machine
  # scope to find all vms hosted on machine(s)
  def self.hosted_on(m)
    if m.is_a?(ActiveRecord::Relation)
      where(vmhost: m.pluck(:fqdn))
    else
      where(vmhost: m.fqdn)
    end
  end

  def self.model_name
    Machine.model_name
  end

  def self.device_type_name
    "Virtual Machine"
  end
end