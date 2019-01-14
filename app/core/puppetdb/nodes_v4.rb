module Puppetdb
  class NodesV4 < Struct.new(:urls)
    def all
      filter = IDB.config.puppetdb[:filter].blank? ? nil : Regexp.new(IDB.config.puppetdb[:filter])
      nodes = []

      # Try to find machines in all puppetdb servers.
      urls.each do |url|
        api = Puppetdb::Api.new(url, IDB.config.puppetdb.ssl_verify)
        data = api.get('/pdb/query/v4/nodes').data || []

        data.each do |node|
          if filter.nil? || node['certname'].match(filter)
            nodes << node['certname']
          end
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
        api = Puppetdb::Api.new(url, IDB.config.puppetdb.ssl_verify)
        data = api.get("/pdb/query/v4/nodes/#{fqdn}/facts").data
        return url if data && data.class == Array
      end
      nil
    end
  end
end
