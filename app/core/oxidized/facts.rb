module Oxidized
  class Facts
    include Virtus.model

    attr_reader :interfaces
    attribute :operatingsystem, String
    attribute :ip, String

    def initialize(attributes = {})
      # Call super to initialize all attributes.
      super

      # If we cannot find facts for a machine, it is probably not managed
      # by Puppet.
      @missing = !!attributes.empty?

      @interfaces = {}

      nic = build_nic(attributes)
      if nic
        @interfaces[nic.name] = nic
      end
    end

    def self.for_node(node, url)
      api = Oxidized::Api.new(url, IDB.config.oxidized.ssl_verify)
      data = api.get("/node/show/#{node}?format=json").data

      facts = { "operatingsystem": data["model"], "ip": data["ip"]}
      new(facts)
    end

    def self.raw_data(node, url)
      api = Oxidized::Api.new(url)
      api.get("/node/show/#{node}?format=json").data
    end

    def self.for(machine, url)
      for_node(machine.fqdn, url)
    end

    def missing?
      !!@missing
    end

    private

    def build_nic(attributes)
      name = IDB.config.oxidized.default_interface_name ||= "interface"
      Nic.new(name: name).tap do |nic|
        nic.ip_address = IpAddress.new
        nic.ip_address.addr = attributes[:ip]
        nic.ip_address.netmask = IDB.config.oxidized.default_netmask ||= "255.255.255.0"
        nic.ip_address.family = 'inet'
      end
    end
  end
end
