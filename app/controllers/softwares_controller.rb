class SoftwaresController < ApplicationController
  def index
    machines = nil
    if params["q"] && !params["q"].blank?
      @software = Array.new
      @versions = Hash.new
      params["q"].split.each { |s|
        n, v = s.split('=')
        @software << { name: n }
        if v
          @versions[n] = v
        else
          @versions[n] = nil
        end
      }

      machines = Machine.includes(:owner, nics: [:ip_address]).order(:fqdn).where('JSON_CONTAINS(software, ?)', ActiveSupport::JSON.encode(@software))

      @machines = Array.new
      machines.each { |m|
        ignore = false
        m.software.each { |s| 
          next if not @versions[s["name"]]
          if not s["version"].start_with? @versions[s["name"]]
            ignore = true
            break
          end
        }
        next if ignore
        @machines << m
      }
    end
  end
end
