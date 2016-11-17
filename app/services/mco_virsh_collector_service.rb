class McoVirshCollectorService
  def initialize
    @mco = McoSocketClient.new
  end

  def update_machines
    vmhosts = @mco.rpc('virsh', 'list').map do |host|
      Mco::Virsh::Response.new(host.data)
    end

    vmhosts.each do |host|
      host.domains.each do |domain|
        domain.mac_addresses.each do |mac|
          nic = Nic.where(mac: mac).first

          if nic
            nic.machine.vmhost = host.vmhost.to_s
            nic.machine.save!
          end
        end
      end
    end
  end
end
