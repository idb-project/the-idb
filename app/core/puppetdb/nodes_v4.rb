module Puppetdb
  class NodesV4 < Struct.new(:urls)
    def all
      nodes = []

      # Try to find machines in all puppetdb servers.
      urls.each do |url|
        api = Puppetdb::Api.new(url)
        data = api.get('/pdb/query/v4/nodes').data || []

        data.each do |node|
          nodes << node['certname']
        end
      end

      nodes
    end

    def facts(node)
      Puppetdb::FactsV4.for_node(node, urls)
    end

    # returns either the puppetdb url or nil
    def find_node(fqdn)
      # Try to find machine in all puppetdb servers.
      urls.each do |url|
        api = Puppetdb::Api.new(url)
        data = api.get("/pdb/query/v4/nodes/#{fqdn}/facts").data
        return url if data && data.class == Array
      end
      nil
    end
  end
end
