class SoftwaresController < ApplicationController
  def index
    parsed = SoftwareHelper.parse_query(params["q"])
    if parsed.empty?
      return
    end
    @machines = SoftwareHelper.software_machines(Machine.all, parsed)
  end
end
