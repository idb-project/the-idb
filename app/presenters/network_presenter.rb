class NetworkPresenter < Keynote::Presenter
  presents :network

  delegate :name, :owner, to: :network

  def id
    network.id
  end

  def name_link
    link_to(network.name, network)
  end

  def address
    network.ip.address
  end

  def addresses
    network.ip.hosts
  end

  def netmask
    network.ip.netmask
  end

  def netmask_hex
    sprintf('%#02x%02x%02x%02x', *netmask.to_s.split('.').map(&:to_i))
  end

  def broadcast
    network.ip.broadcast
  end

  def prefix
    network.ip.prefix
  end

  def host_min
    network.ip.first
  end

  def host_max
    network.ip.last
  end

  def hosts_count
    network.ip.hosts.count
  end

  def hosts_used
    machines.size
  end

  def owner_link
    link_to(network.owner.name, network.owner) if network.owner
  end

  def description
    TextileRenderer.render(network.description) if network.description
  end

  def machine_link(ip, allowed = true, render_link = true)
    machine = machines[ip.address]

    if machine
      link = render_link ? link_to(machine.name, machine) : machine.name
      allowed ? link : %(#{link} <strong class="text-error">NOT ALLOWED!</strong>).html_safe
    else
      allowed ? '' : 'not allowed'
    end
  end

  def machine_aliases(ip)
    machine = machines[ip.address]

    if machine
      machine.aliases.map(&:name).join(', ')
    end
  end

  def ip_address_row(ip, render_link = true)
    allowed = allowed_ip?(ip)
    content = machine_link(ip, allowed, render_link)
    aliases = machine_aliases(ip)
    ip_v6 = machine_v6_by_v4(ip)
    css_class = allowed || 'muted'
    css_class = 'hide_ip' if content.blank?

    build_html do
      tr class: css_class do
        td ip
        td ip_v6
        td content
        td aliases
      end
    end
  end

  private

  def machine_v6_by_v4(ip)
    machine = machines[ip.address]
    if machine && machine.nics
      machine.nics.each do |nic|
        if nic.ip_address.addr == ip.address
          return nic.ip_address.addr_v6
        end
      end
    end
    ""
  end

  def allowed_ip?(ip)
    network.allowed_ip_addresses.empty? || network.allowed_ip_addresses.include?(ip.to_s)
  end

  def machines
    @_machines ||= network.ip_addresses.each_with_object({}) do |ip, hash|
      hash[ip.addr] = ip.machine
    end
  end
end
