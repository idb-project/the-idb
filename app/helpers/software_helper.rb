module SoftwareHelper
  def self.parse_query(query)
    parsed = Hash.new

    if query.blank?
      return parsed
    end

    query.split.each { |s|
      if s.index("!=")
        name, version = s.split("!=")
        parsed[name] = -> (x) { return x != version }
      elsif s.index("=")
        name, version = s.split("=")
        parsed[name] = -> (x) { return x.start_with?(version) }
      else
        parsed[s] = -> (x) { return true }
      end
    }

    return parsed
  end

  def self.software_machines(all_machines, parsed_query)
    puts "Query:"
    puts parsed_query.inspect

    machines = Array.new
    
    # get all machines which have all software installed
    ms = all_machines.includes(:owner, nics: [:ip_address]).order(:fqdn).where('JSON_CONTAINS(software, ?)', ActiveSupport::JSON.encode(parsed_query.keys.map { |n| {"name" => n}}))
    puts "All machines"
    puts ms.all.inspect


    ms.each { |m| 
      m.software.each { |s| 
        next if not parsed_query[s["name"]]
        next if not parsed_query[s["name"]].call(s["version"])
        machines << m
      }
    }

    return machines
  end
end