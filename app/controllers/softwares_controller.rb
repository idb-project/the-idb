class SoftwaresController < ApplicationController
  def index
    @software, @versions = SoftwareHelper.parse_query(params["q"])
    if @software.empty?
      return
    end
    @machines = SoftwareHelper.software_machines(@software, @versions)
  end
end
