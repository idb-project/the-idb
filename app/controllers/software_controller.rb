class SoftwareController < ApplicationController
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

    puts ActiveSupport::JSON.encode(@software)

    @machines = Machine.where('JSON_CONTAINS(software, ?)', ActiveSupport::JSON.encode(@software))
  end
end
