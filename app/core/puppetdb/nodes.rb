module Puppetdb
  class Nodes < Struct.new(:urls)
    def all
      nodes = []

      # Try to find machines in all puppetdb servers.
      urls.each do |url|
        api = Puppetdb::Api.new(url)
        data = api.get('/v3/nodes').data || []

        data.each do |node|
          nodes << node['name']
        end
      end

      nodes
    end

    def facts(node)
      Puppetdb::FactsV3.for_node(node, urls)
    end

    # returns either the puppetdb url or nil
    def find_node(fqdn)
      # Try to find machine in all puppetdb servers.
      urls.each do |url|
        api = Puppetdb::Api.new(url)
        data = api.get("/v3/nodes/#{fqdn}").data
        return url if data && data["name"]
      end
      nil
    end
  end
end
