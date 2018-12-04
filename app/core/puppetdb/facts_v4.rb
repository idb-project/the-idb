module Puppetdb
  class FactsV4 < Facts
    def self.for_node(node, url)
      api = Puppetdb::Api.new(url, IDB.config.puppetdb.ssl_verify)
      data = api.get("/pdb/query/v4/nodes/#{node}/facts").data

      facts = Array(data).each_with_object({}) do |fact, hash|
        if fact.class == Array && fact.first == "error"
          # usually "No information is known about node ..."
        else
          hash[fact['name'].gsub("-", "_")] = fact['value']
        end
      end

      if facts["blockdevices"]
        i = 0
        facts["blockdevices"].split(",").each do |d|
          i += facts["blockdevice_#{d}_size"].to_i if facts["blockdevice_#{d}_size"]
        end
        facts["diskspace"] = i
      end

      new(facts)
    end

    def self.raw_data(node, url)
      api = Puppetdb::Api.new(url, IDB.config.puppetdb.ssl_verify)
      api.get("/pdb/query/v4/nodes/#{node}/facts").data
    end

    attribute :lsbdistrelease, String
    attribute :operatingsystemrelease, String

    def windows_fixes
      return unless operatingsystem =~ /windows/i

      if WINDOWS_VERSIONS.has_key?(lsbdistrelease)
        self.lsbdistrelease = WINDOWS_VERSIONS[lsbdistrelease]
      end
    end
  end
end
