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
    attribute :mariadb_encrypted, Boolean

    attr_reader :interfaces

    def initialize(attributes = {})
      # Call super to initialize all attributes.
      super

      # If we cannot find facts for a machine, it is probably not managed
      # by Puppet.
      @missing = !!attributes.empty?

      @interfaces = {}

      attributes = ActiveSupport::HashWithIndifferentAccess.new(attributes)

      if attributes[:networking] && attributes[:networking][:interfaces]
        attributes[:networking][:interfaces].keys.each do |interface_name|
          next if interface_name == 'lo'

          if attributes[:networking][:interfaces]["#{interface_name}"] &&
            attributes[:networking][:interfaces]["#{interface_name}"]["bindings"]
            # all interface information is located in the networking/interfaces section in newer puppetdbs

            attributes[:networking][:interfaces]["#{interface_name}"]["bindings"].each_with_index do |binding, index|
              if attributes[:networking][:interfaces]["#{interface_name}"]["bindings6"] &&
                attributes[:networking][:interfaces]["#{interface_name}"]["bindings6"].size > 0 &&
                (index+1) <= attributes[:networking][:interfaces]["#{interface_name}"]["bindings6"].size

                # v6 addresses are in a different section, and also in an array. So one needs to
                # pick them from the according array index.
                v6 = attributes[:networking][:interfaces]["#{interface_name}"]["bindings6"][index][:address]
              end

              mac = attributes[:networking][:interfaces]["#{interface_name}"][:mac]
              mac = mac.downcase if mac
              nic = build_nic(interface_name, binding["address"], v6, binding["netmask"], mac)
              @interfaces[binding["address"]] = nic
            end
          end
        end
      end

      windows_fixes
      ucs_detection
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
      self.operatingsystem
    end

    def os_release
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

    def build_nic(name, ipv4, ipv6, netmask, mac)
      Nic.new(name: name).tap do |nic|
        nic.mac = mac
        nic.ip_address = IpAddress.new
        nic.ip_address.addr = ipv4
        nic.ip_address.addr_v6 = ipv6
        nic.ip_address.netmask = netmask
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
      if operatingsystem == "Debian" && idb_installed_packages
        if idb_installed_packages.include?("pve-manager")
          self.operatingsystem = "PVE"
          self.operatingsystemrelease = proxmox_scan(idb_installed_packages, "pve-manager")
        elsif idb_installed_packages.include?("proxmox-backup-server")
          self.operatingsystem = "PBS"
          self.operatingsystemrelease = proxmox_scan(idb_installed_packages, "proxmox-backup")
        elsif idb_installed_packages.include?("proxmox-mailgateway")
          self.operatingsystem = "PMG"
          self.operatingsystemrelease = proxmox_scan(idb_installed_packages, "proxmox-mailgateway")
        end
      end
    end

    def proxmox_scan(packages, search)
      begin
        return packages.scan(/#{search}\=\S*/).last.split("=")[1] || "-"
      rescue
        return ""
      end
    end

    def ucs_detection
      unless lsbdistdescription.blank?
        if lsbdistdescription.starts_with?("Univention Corporate Server")
          self.operatingsystem = "UCS"
          begin
            self.operatingsystemrelease = lsbdistdescription.split[3] || "?"
          rescue
            self.operatingsystemrelease = ""
          end
        end
      end
    end
  end
end
