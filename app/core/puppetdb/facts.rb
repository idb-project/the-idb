module Puppetdb
  class Facts
    WINDOWS_VERSIONS = {
      '6.1.7601' => '7 SP1 / Server 2008 R2 SP1',
      '6.1.7600' => '7 / Server 2008 R2'
    }.freeze

    def self.for(machine, url)
      for_node(machine.fqdn, url)
    end

    include Virtus.model

    attribute :operatingsystem, String
    attribute :operatingsystemrelease, String
    attribute :lsbdistrelease, String
    attribute :lsbdistdescription, String
    attribute :architecture, String
    attribute :manufacturer, String
    attribute :productname, String
    attribute :memorysize_mb, Float
    attribute :memorysize, Float
    attribute :diskspace, Integer
    attribute :blockdevices, String
    attribute :processorcount, Integer
    attribute :uptime_seconds, Integer
    attribute :is_virtual, Boolean
    attribute :serialnumber, String
    attribute :idb_unattended_upgrades, Boolean
    attribute :idb_unattended_upgrades_blacklisted_packages, Array
    attribute :idb_unattended_upgrades_reboot, Boolean
    attribute :idb_unattended_upgrades_time, String
    attribute :idb_unattended_upgrades_repos, Array
    attribute :idb_pending_updates, Integer
    attribute :idb_pending_security_updates, Integer
    attribute :idb_pending_updates_sum, Integer
    attribute :idb_pending_updates_package_names, Array
    attribute :idb_reboot_required, Boolean
    attribute :idb_installed_packages, JSON
    attribute :monitoring_vm_children, Hash[String => String]

    attr_reader :interfaces

    def initialize(attributes = {})
      # Call super to initialize all attributes.
      super

      # If we cannot find facts for a machine, it is probably not managed
      # by Puppet.
      @missing = !!attributes.empty?

      @interfaces = {}

      attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes)

      attributes[:interfaces].to_s.split(',').each do |interface|
        nic = build_nic(interface, attributes)

        if nic
          @interfaces[nic.name] = nic
        end
      end

      windows_fixes
      proxmox_detection
    end

    def missing?
      !!@missing
    end

    def virtual_machine?
      if manufacturer && !manufacturer.blank? && (manufacturer.downcase == "seabios" || manufacturer.downcase == "bochs")
        return true
      elsif productname && !productname.blank? && productname.downcase == "virtual machine"
        return true
      else
        is_virtual
      end
    end

    def unattended_upgrades?
      idb_unattended_upgrades
    end

    def pending_updates?
    end

    def serialnumber
      super =~ /not specified|system serial number/i ? nil : super
    end

    def operating_system
      unless lsbdistdescription.blank?
        if lsbdistdescription.starts_with?("Univention Corporate Server")
          self.operatingsystem = "UCS"
        end
      end
      self.operatingsystem
    end

    def os_release
      unless lsbdistdescription.blank?
        if lsbdistdescription.starts_with?("Univention Corporate Server")
          self.operatingsystemrelease = lsbdistdescription.split[3] || "?"
        end
      end
      self.operatingsystemrelease || self.lsbdistrelease
    end

    def memorysize_mb
      if @memorysize_mb
        @memorysize_mb
      elsif @memorysize
        if @memorysize.end_with?("GB")
          (@memorysize.to_f*1024).to_i
        end
      end
    end

    private

    def build_nic(name, attributes)
      # We don't need local loopback interfaces.
      return if name == 'lo'
      name_alt = name.gsub("-", "_")

      Nic.new(name: name).tap do |nic|
        # XXX Revisit: Windows seems to only set "macaddress".
        nic.mac = attributes["macaddress_#{name}"] || attributes["macaddress_#{name}".downcase] || attributes["macaddress_#{name_alt}"] || attributes['macaddress']
        nic.mac = nic.mac.downcase if nic.mac
        nic.ip_address = IpAddress.new

        nic.ip_address.addr = attributes["ipaddress_#{name}"] || attributes["ipaddress_#{name}".downcase] || attributes["ipaddress_#{name_alt}"]
        nic.ip_address.addr_v6 = attributes["ipaddress6_#{name}"] || attributes["ipaddress6_#{name}".downcase] || attributes["ipaddress6_#{name_alt}"]
        nic.ip_address.netmask = attributes["netmask_#{name}"] || attributes["netmask_#{name}".downcase] || attributes["netmask_#{name_alt}"]
        # XXX Hardcoded for now! Not sure how facter displays ipv6 addresses.
        nic.ip_address.family = 'inet'
      end
    end

    def windows_fixes
      return unless operatingsystem =~ /windows/i

      if WINDOWS_VERSIONS.has_key?(operatingsystemrelease)
        self.operatingsystemrelease = WINDOWS_VERSIONS[operatingsystemrelease]
      end
    end

    def proxmox_detection
      if operatingsystem == "Debian" && idb_installed_packages && idb_installed_packages.include?("proxmox-ve")
        self.operatingsystem = "Proxmox"
        begin
          self.operatingsystemrelease = idb_installed_packages.scan(/pve-manager\=\S*/).last.split("=")[1] || "-"
        rescue
          self.operatingsystemrelease = ""
        end
      end
    end
  end
end
