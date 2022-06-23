class SoftwaresController < ApplicationController
  def index
    @machines = SoftwareHelper.software_machines(Machine.all, params["package"], params["version"])
  end
end
