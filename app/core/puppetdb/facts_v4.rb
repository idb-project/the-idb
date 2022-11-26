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

      i = 0
      if facts["blockdevices"]
        # Linux machines
        facts["blockdevices"].split(",").each do |d|
          i += facts.fetch("blockdevice_#{d}_size", "0").to_i
        end
      elsif facts["disks"]
        # Windows machines
        facts["disks"].each do |d|
          if d.is_a? Array
            d = d.last if d.size > 1 # the hash was arrayed to [0, {facts}]
            i += d["allocated_size"].to_i if d["allocated_size"]
          end
        end
      end
      facts["diskspace"] = i

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
