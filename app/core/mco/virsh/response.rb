module Mco
  module Virsh
    class Response
      include Virtus.model

      attribute :host, Hash
      attribute :domains, Array[Mco::Virsh::Domain]

      def vmhost
        host[:fqdn] || host['fqdn']
      end
    end
  end
end
