module SoftwareHelper
  def self.parse_query(query)
    software = Array.new
    versions = Hash.new

    if query.blank?
      return software, versions
    end

    query.split.each { |s|
      n, v = s.split('=')
      software << { name: n }
      if v
        versions[n] = v
      else
        versions[n] = nil
      end
    }

    return software, versions
  end

  def self.software_machines(all_machines, software, versions)
    machines = Array.new
    ms = all_machines.includes(:owner, nics: [:ip_address]).order(:fqdn).where('JSON_CONTAINS(software, ?)', ActiveSupport::JSON.encode(software))

    ms.each { |m|
      ignore = false
      m.software.each { |s| 
        next if not versions[s["name"]]
        if not s["version"].start_with? versions[s["name"]]
          ignore = true
          break
        end
      }
      next if ignore
      machines << m
    }
    return machines
  end
end