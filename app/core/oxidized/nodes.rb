module Oxidized
  class Nodes < Struct.new(:urls)
    def all
      nodes = []

      # Try to find machines in all puppetdb servers.
      urls.each do |url|
        api = Oxidized::Api.new(url, IDB.config.oxidized.ssl_verify)
        data = api.get('/nodes?format=json').data || []

        data.each do |node|
          nodes << node['name']
        end
      end

      nodes
    end

    def facts(node)
      Oxidized::Facts.for_node(node, urls)
    end

    # returns either the oxidized url or nil
    def find_node(fqdn)
      nodes = all()

      nodes.each do |node|
        if node == fqdn
          api = Oxidized::Api.new(url, IDB.config.oxidized.ssl_verify)
          data = api.get("/node/show/#{fqdn}?format=json").data
          return url if data && data.class == Hash
        end
      end
      nil
      # # Try to find machine in all oxidized systems.
      # urls.each do |url|
      #   api = Oxidized::Api.new(url, IDB.config.oxidized.ssl_verify)
      #   data = api.get("/node/show/#{fqdn}?format=json").data
      #   return url if data && data.class == Hash
      # end
      # nil
    end
  end
end
