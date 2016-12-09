class SoftwaresController < ApplicationController
  def index
    @software = nil
  end

  def search
    @software = Array.new
    params["q"].split.each { |s| 
      n, v = s.split('=')
      if v
        @software << { name: n, version: v }
      else
        @software << { name: n }
      end
    }

    @machines = Machine.includes(:owner, nics: [:ip_address]).order(:fqdn).where('JSON_CONTAINS(software, ?)', ActiveSupport::JSON.encode(@software))
  end
end
