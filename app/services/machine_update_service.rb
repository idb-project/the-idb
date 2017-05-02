class MachineUpdateService
  def self.update_from_facts(machine, url, version="v3")
    if version == "v4"
      facts = Puppetdb::FactsV4.for(machine, url)
      raw_data = Puppetdb::FactsV4.raw_data(machine.fqdn, url)
    elsif
      facts = Puppetdb::FactsV3.for(machine, url)
      raw_data = Puppetdb::FactsV3.raw_data(machine.fqdn, url)
    end
    machine.raw_data_puppetdb = raw_data.to_json if raw_data

    # Do not try to update the machine if there are not facts.
    # Also avoids marking the machine as auto-updating.
    return if facts.missing?

    machine.auto_update = true
    machine.os = facts.operatingsystem
    machine.os_release = facts.operatingsystemrelease || facts.lsbdistrelease
    machine.arch = facts.architecture
    machine.ram = facts.memorysize_mb
    machine.cores = facts.processorcount
    machine.uptime = facts.uptime_seconds
    machine.serialnumber = facts.serialnumber
#    machine.device_type = DeviceType.where(is_virtual: facts.virtual_machine?).first
    machine.unattended_upgrades = facts.unattended_upgrades?
    machine.unattended_upgrades_blacklisted_packages = facts.idb_unattended_upgrades_blacklisted_packages
    machine.unattended_upgrades_reboot = facts.idb_unattended_upgrades_reboot
    machine.unattended_upgrades_time = facts.idb_unattended_upgrades_time
    machine.unattended_upgrades_repos = facts.idb_unattended_upgrades_repos
    machine.pending_updates = facts.idb_pending_updates
    machine.pending_security_updates = facts.idb_pending_security_updates
    machine.pending_updates_sum = facts.idb_pending_updates_sum
    machine.pending_updates_package_names = facts.idb_pending_updates_package_names
    machine.diskspace = facts.diskspace
    machine.needs_reboot = facts.idb_reboot_required
    machine.software = parse_installed_packages(facts.idb_installed_packages)

    # First check if a network interface has been removed.
    machine.nics.each do |nic|
      if facts.interfaces.has_key?(nic.name)
        # Delete the interface on the machine if the new address is empty.
        if facts.interfaces[nic.name].ipv4addr.nil?
          nic.destroy
        end
      else
        nic.destroy
      end
    end

    facts.interfaces.each do |name, new_nic|
      next if new_nic.ipv4addr.nil?

      if machine.nics.map(&:name).include?(name)
        # Update the existing nic data.
        nic = machine.nics.find {|n| n.name == name }

        nic.mac = new_nic.mac
        nic.ip_address.addr = new_nic.ip_address.addr
        nic.ip_address.addr_v6 = new_nic.ip_address.addr_v6
        nic.ip_address.netmask = new_nic.ip_address.netmask
        nic.ip_address.family = new_nic.ip_address.family

        nic.save!
      else
        # Just add the new nic objects. They will be saved automatically.
        machine.nics << new_nic
      end
    end

    if facts.virtual_machine?
      machine.becomes!(VirtualMachine)
    else
      machine.becomes!(Machine)
    end

    machine.save!
  end

  def self.parse_installed_packages(packages)
    return nil if packages.blank?

    software = Array.new
    packages.gsub(/[\[\]]/,'').split(' ').each do |package|
      if matched_package = package.match(/\S*=\S*/)
        # deb package
        name, version = matched_package.to_s.split('=')
        software << (version.nil? ? { name: name } : { name: name, version: version })
      elsif matched_package = package.match(/(?<name>.*)-(?<version>.*-.*\..*)/)
        # rpm package
        software << { name: matched_package[:name], version: matched_package[:version] }
      end
    end
    software.empty? ? nil : software
  end
end
