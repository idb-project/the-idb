class SoftwareController < ApplicationController
  def index
    @machines = nil
    @software = nil
  end

  def create
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
    render :index
  end
end
