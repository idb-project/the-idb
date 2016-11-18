class McoIcingaCollectorService
  def initialize
    @mco = McoSocketClient.new
  end

  def update_machines
    @mco.rpc('icinga', 'idb').each do |response|
      response.data['idb'].each do |hostname, data|
        # We cannot handle hosts without fqdn/alias set.
        next unless data['alias']

        update_alias(data)

        # Only process hosts which are switches.
        next unless is_switch?(data)

        switch = create_switch(data['alias'].strip, data['address'].strip)
        ports = build_switch_ports(data['services'])

        # Delete switch ports that do not exist.
        SwitchPort.where(switch_id: switch.id).each do |port|
          unless ports.map(&:nic).map(&:mac).include?(port.nic.mac)
            port.destroy
          end
        end

        ports.each do |port|
          port.switch_id = switch.id
          port.save!
        end
      end
    end
  end

  private

  def is_switch?(data)
    data['services'].any? {|s| s =~ SwitchPort::ICINGA_REGEX} || Machine.is_switch?(data['alias'])
  end

  def create_switch(fqdn, ip_address)
    switch = Machine.where(fqdn: fqdn).first || Machine.create_switch!(fqdn: fqdn)

    # XXX We hardcode "nic" for now.
    nic = switch.nics.find {|n| n.name == 'nic'} || switch.nics.build(name: 'nic')
    ip = nic.ip_address || nic.build_ip_address(family: 'inet')

    ip.addr = ip_address

    nic.save!
    ip.save!

    switch # Make sure to return the switch.
  end

  def build_switch_ports(services)
    services.select {|service|
      service.downcase =~ SwitchPort::ICINGA_REGEX
    }.map {|service|
      Icinga::SwitchPortParser.new(service).to_switch_port
    }.compact # Remove nil entries.
  end

  def update_alias(data)
    fqdn = data['alias'] # The icinga alias is the IDB fqdn.
    machine = Machine.where(fqdn: fqdn).first

    return unless machine

    MachineAlias.find_or_create_by(name: data['host_name']) do |a|
      a.machine = machine
    end
  end
end
